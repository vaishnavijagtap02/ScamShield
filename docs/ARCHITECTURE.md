# Architecture — ScamShield

## 1. Pipeline
```
AudioSource (Upload | Mic | Demo)
  → AudioChunk(wavBytes, startSec, durationSec)     [Upload: 25 s pieces · Mic: 6 s · Demo: canned segments]
  → SttService.transcribe()                          [Sarvam REST, 3 in parallel, results re-ordered by index]
  → Segment(index, startSec, endSec, text)
  → Lexicon.scan(segment)            → TacticEvent(source: lexicon, confidence: 0.5)
  → LlmService (Upload: 1 call on full transcript · Live: every 2 chunks on last 90 s)
  → Grounding.filter(events, entities, transcript)
  → RiskEngine.evaluate(events)      → RiskResult(score, level, stagesSeen)
  → Verdict(level, score, scamType, events, entities, summaryHi, flags)
  → [UI] Verdict → Questions(Answers) → ActionPlanService.planFor() → ComplaintService.build() → AlertService.send()
```
DemoSource skips STT and LLM. It emits canned `Segment`s and canned LLM events from `assets/demo/scripts.json`, but still runs Lexicon → Grounding → RiskEngine, so the demo exercises the real engine.

## 2. Folder structure
```
lib/
  main.dart                       # ProviderScope + App
  app.dart                        # MaterialApp.router, theme, routes
  core/                           # PURE DART
    config.dart                   # String.fromEnvironment reads (only place)
    result.dart                   # sealed exceptions: SttException, LlmException, AlertException, AudioFormatException
  engine/                         # PURE DART, fully unit-tested
    models.dart                   # Stage, RiskLevel, ScamType, Segment, TacticEvent, Entities, Verdict, Answers
    lexicon.dart
    grounding.dart
    risk_engine.dart
    action_plan_service.dart      # parses assets/action_plan.json (string passed in)
    complaint_service.dart
    wav.dart                      # WavHeader.parse, WavSplitter, wavFromPcm16
  services/
    stt_service.dart              # abstract + SarvamSttService
    llm_service.dart              # abstract + OpenAiCompatibleLlmService
    alert_service.dart            # abstract + TelegramAlertService
    tts_service.dart              # wraps flutter_tts
    guardian_store.dart           # shared_preferences: guardians, autoAlert, language
  sources/
    audio_source.dart             # abstract AudioSource { Stream<AudioChunk> chunks(); Future<void> stop(); }
    upload_source.dart
    mic_source.dart
    demo_source.dart              # emits DemoItem (segment + canned llm events)
  state/
    providers.dart                # service providers (overridable in tests)
    analysis_controller.dart      # Notifier<AnalysisState>
    guardian_controller.dart      # pairing + list
    settings_controller.dart      # language, autoAlert
  ui/
    theme/tokens.dart, app_theme.dart
    strings.dart
    widgets/                      # StageTrack, StageStamp, RiskMeter, EvidenceRow, BigButton, LevelBanner, SectionCard
    screens/                      # home, upload, analysing, verdict, questions, action_plan, complaint, live_guard, demo, guardians, settings
assets/
  action_plan.json
  demo/scripts.json  demo/*.wav (team adds)
  fonts/Mukta-*.ttf (team adds)
test/  (see TESTING.md)
```

## 3. Models (`lib/engine/models.dart`)
```dart
enum Stage { authority, fear, urgency, secrecy, extraction }   // canonical order
enum RiskLevel { low, medium, high }
enum ScamType { digitalArrest, kycBank, courierParcel, traiSim, investment, loanApp, sextortion, familyEmergency, none, unknown }
enum EventSource { lexicon, llm }

class Segment { final int index; final double startSec; final double endSec; final String text; }
class TacticEvent { final Stage stage; final String quote; final double atSec; final double confidence; final EventSource source; final String? explanationHi; }
class Entities { final String? claimedAgency, claimedName, caseNo, amountAsked; final List<String> phones, upiIds, accounts; }
class RiskResult { final int score; final RiskLevel level; final Set<Stage> stagesSeen; }
class Verdict {
  final RiskLevel level; final int score; final ScamType scamType;
  final List<TacticEvent> evidence;      // grounded, best per stage first, sorted by atSec
  final Entities entities; final String summaryHi;
  final bool basicCheckOnly;             // true when LLM failed → lexicon-only
  final bool partialAudio;               // true when ≥1 STT piece failed
}
class Answers { final bool paid, sharedCredentials, remoteApp; }
```
`ScamType` JSON values are snake_case (`digital_arrest`, …). Map them in `ScamTypeX.fromJson`.

## 4. Controller (`AnalysisController`)
State: `AnalysisState { phase (idle|running|done|error), List<Segment> segments, List<TacticEvent> events, RiskResult risk, Verdict? verdict, String? errorKey, int piecesDone, int piecesTotal }`.

**Upload run:**
1. `UploadSource.chunks()` → for each chunk, `stt.transcribe()` with a pool of 3. Keep results in a `Map<int, Segment>` and append to state in index order only.
2. After each segment: `lexicon.scan()` → merge events → `riskEngine.evaluate()` → update state (live chips during analysis).
3. When all pieces are done: `llm.analyzeFull(segments)` → `grounding.filter()` → merge → final `RiskResult` → build `Verdict` (scamType/entities/summary from LLM, or `unknown`/empty/fallback summary when the LLM fails, with `basicCheckOnly: true`).
4. If HIGH: `tts.speakWarning()`. If `autoAlert` is on and guardians exist → `alert.sendVerdict()` (fire-and-forget, with status shown).

**Live run:** same, but `MicSource` (6 s), `llm.analyzeWindow(last 90 s, alreadySeen)` every 2nd chunk, no final full call. The level is monotonic (never decreases). Stop = cancel the stream and build the Verdict from the current state.

**Merge rule:** keep all grounded events. The per-stage confidence used by the engine = the max confidence among that stage's events (lexicon = 0.5).

## 5. External API contracts
### 5.1 Sarvam STT (REST)
```
POST https://api.sarvam.ai/speech-to-text            (multipart/form-data)
Header: api-subscription-key: $SARVAM_API_KEY
Fields: file=<chunk.wav>, model=saaras:v3, mode=$STT_MODE (default codemix), language_code=unknown, with_timestamps=true
200 → { "request_id": "...", "transcript": "...", "language_code": "hi-IN",
        "timestamps": { "words": ["...","..."], "start_time_seconds": [0.0, 3.2], "end_time_seconds": [3.1, 5.9] } | null }
```
- If `timestamps` is present, create one Segment per entry with `startSec = chunk.startSec + start`. Otherwise one Segment per chunk.
- **Verify the real shape first** (task T03): call it once with a test WAV and save the JSON to `test/fixtures/sarvam_sample.json` (redacted). The parser must handle `timestamps: null`.
- Timeout 20 s, 1 retry after 800 ms on 5xx/timeout. A 4xx means no retry → `SttException`.

### 5.2 LLM (OpenAI-compatible chat completions; provider set by env)
```
POST $LLM_BASE_URL/chat/completions
Header: Authorization: Bearer $LLM_API_KEY
Body: { "model": "$LLM_MODEL", "temperature": 0, "response_format": {"type":"json_object"},
        "messages": [ {"role":"system","content": SYSTEM_PROMPT}, {"role":"user","content": USER_MESSAGE} ] }
→ choices[0].message.content = JSON string (schema in RISK_ENGINE.md §6)
```
- Strip ```` ```json ```` fences if present before `jsonDecode`. Validate fields and drop malformed events (don't throw on one bad event).
- If a provider rejects `response_format`, retry once without it (the prompt already demands JSON).
- Timeout 25 s, 1 retry. Then `LlmException` → controller falls back to lexicon-only.

### 5.3 Telegram Bot API
```
Pair:  show QR of https://t.me/$TELEGRAM_BOT_USERNAME?start=<code>   (code: 10 chars [A-Za-z0-9])
Poll:  GET https://api.telegram.org/bot$TOKEN/getUpdates?offset=<lastUpdateId+1>&timeout=0
       find message.text == "/start <code>" → save Guardian(name: message.from.first_name, chatId: message.chat.id)
Send:  POST https://api.telegram.org/bot$TOKEN/sendMessage  {"chat_id": <id>, "text": "<plain text>"}   (NO parse_mode)
```
- Poll every 2 s, stop after 120 s or on success. Track `offset` so old updates aren't re-read.
- Send to each guardian independently and report per-guardian success.

## 6. Config (`lib/core/config.dart`)
`SARVAM_API_KEY, STT_MODE (codemix), LLM_BASE_URL, LLM_API_KEY, LLM_MODEL, TELEGRAM_BOT_TOKEN, TELEGRAM_BOT_USERNAME, DEMO_ONLY (false)`.
`Config.validate()` returns the list of missing keys. Home shows a small banner "Demo mode only" if any are missing, and Demo still works.

## 7. Error handling map
| Failure | User sees (strings.dart key) | App does |
| --- | --- | --- |
| Unsupported file | `errUnsupportedFile` | Stay on Upload |
| One STT piece fails | `notePartialAudio` on verdict | Continue |
| All STT fails / no network | `errNoNetwork` + "Demo chalayein" button | Stop run |
| LLM fails | `labelBasicCheck` chip on verdict | Lexicon-only verdict |
| Telegram fails | `alertFailedRetry` | Retry button |
| Mic permission denied | `errMicPermission` (explains: Settings → Apps → ScamShield → Permissions → Microphone) | Retry button re-calls `record.hasPermission()` |
| TTS language missing | (silent) | Skip voice, keep banner |

## 8. Routing (`go_router`)
`/` Home · `/upload` · `/analysing` · `/verdict` · `/questions` · `/plan` · `/complaint` · `/live` · `/demo` · `/guardians` · `/settings`. Analysis state is shared via the controller, not route params. Back from `/verdict` goes to Home (clears state).
