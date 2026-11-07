# Tasks — do ONE at a time, in order

Each task: read the linked docs → (tests first for logic) → implement → `dart format lib test && flutter analyze && flutter test` → tick the box → report with the test output. UI tasks also run the golden review (DESIGN.md §8).

**Definition of Done (every task):** acceptance criteria met · 0 analyzer issues · all tests pass · no new packages outside CLAUDE.md · no hardcoded strings/colors in widgets · nothing secret or transcript-like logged.

**Checkpoint goal:** the full upload chain (T00–T16) runs on a real Android phone by **hour 5**. If you're behind, skip T17's polish and T18.

---

## Phase 0 — Setup (~0:00–0:40)
- [x] **T00 Scaffold.** `flutter create --org com.scamshield --platforms android scamshield` (or use the existing project). Add the CLAUDE.md packages. Put `analysis_options.yaml` from this pack at the root. Declare `assets/action_plan.json`, `assets/demo/`, and the Mukta fonts (400/600/700/800) in `pubspec.yaml`. Create the folder structure from ARCHITECTURE §2. Add `lib/core/config.dart` with `Config.validate()`. Add `<uses-permission RECORD_AUDIO/INTERNET>` to the Android manifest. Set Android `minSdk` ≥ 23.
  *AC:* `flutter analyze` 0 issues. The app launches to a placeholder Home on a device. `.env` is git-ignored.
- [x] **T01 Theme + strings + base widgets.** `tokens.dart`, `app_theme.dart` (manual `ColorScheme`, Mukta, flat AppBar, InkRipple, no elevation), `motion.dart`, `strings.dart` (Hinglish + Hindi maps, `S.of(lang)`), `BigButton`, `SectionCard`, `StatusLine`. Golden infra: `test/flutter_test_config.dart` loads Mukta. `test/golden/components_golden_test.dart` renders all BigButton variants.
  *AC:* the component golden PNG shows Mukta (not placeholder boxes), ink buttons, and paper background. Report anti-slop checklist items for these components.

## Phase 1 — Engine, pure Dart, TDD (~0:40–1:50)
- [x] **T02 Models + demo script loader.** `engine/models.dart` per ARCHITECTURE §3. `DemoScript.fromJson` for `assets/demo/scripts.json`.
  *AC:* a test loads all 6 scripts from the file and asserts ids/segment counts.
- [x] **T03 Lexicon.** Normalization, the RegExps and the negation guard exactly per RISK_ENGINE §2.
  *AC:* tests for each stage in Latin AND Devanagari (≥ 2 positives each). Negatives: "bank kabhi OTP nahi maangta" → no extraction, "kal thane aa jaana" → nothing. Each script's lexicon-only stages match the table in TESTING.md §3.
- [x] **T04 Grounding.** Quote and entity grounding per RISK_ENGINE §4.
  *AC:* in `scam_cbi`, "apne bete ko phone mat karna" and phone `9876543210` are rejected. Other canned quotes are accepted with `atSec` from the matching segment. Punctuation/case differences still match.
- [x] **T05 RiskEngine.** Formula + hard rules + levels + evidence selection per RISK_ENGINE §3.
  *AC:* all 6 vectors (lexicon + grounded LLM) give the exact score/level/stages. The lexicon-only vectors from TESTING.md §3 pass. Unit tests for each hard rule and the live-mode monotonic flag.
- [x] **T06 WAV utils.** `WavHeader.parse` (finds the `fmt ` and `data` chunks, rejects non-PCM16/non-mono/non-16 kHz with `AudioFormatException`), `WavSplitter.split(bytes, 25s)` → `AudioChunk`s with correct `startSec`, and `wavFromPcm16`.
  *AC:* tests build a synthetic 61 s WAV in memory → 3 chunks (25, 25, 11 s). Each chunk re-parses as a valid WAV. A header with an extra `LIST` chunk still parses.
- [x] **T07 ActionPlanService + ComplaintService.** Parse `assets/action_plan.json` (pass the JSON string in), `planFor(Answers, RiskLevel)`, and `ComplaintService.build(verdict, answers, now)` per the template in TESTING.md §4.
  *AC:* `paid` → the urgent 1930 rule first. All "no" + MEDIUM/HIGH → the `none` rule. All "no" + LOW → `low_safe`. HIGH → the `alert_family` action is present (added if missing). The JSON's `note` field describes these matching rules. The complaint for `scam_cbi` contains "CBI", "Inspector Sharma", ≥ 4 timed quotes, `______` for unknowns, and NOT the rejected phone.

## Phase 2 — Services + sources (~1:50–3:00)
- [x] **T08 SarvamSttService.** Per ARCHITECTURE §5.1. First ask the human to run this in their own terminal and paste the response (you never read `.env`):
  `curl -s https://api.sarvam.ai/speech-to-text -H "api-subscription-key: $SARVAM_API_KEY" -F file=@assets/demo/scam_cbi.wav -F model=saaras:v3 -F mode=codemix -F language_code=unknown -F with_timestamps=true` (use a ≤ 25 s clip).
  Save it to `test/fixtures/sarvam_sample.json`, then implement the parser for that real shape.
  *AC:* tests with `package:http/testing.dart` `MockClient`: timestamps present → multiple segments with offsets; `timestamps: null` → one segment; 500 → 1 retry then `SttException`; 401 → no retry.
- [x] **T09 LlmService (OpenAI-compatible).** Prompt builder (RISK_ENGINE §6; transcript inside `<<<TRANSCRIPT … TRANSCRIPT>>>` in the USER message), fence stripping, tolerant parsing, retry without `response_format` on 400.
  *AC:* MockClient tests: valid JSON → `LlmAnalysis`; fenced JSON parses; one malformed event is dropped and the rest are kept; timeout → `LlmException`. A test asserts the system prompt contains no transcript text.
- [x] **T10 TelegramAlertService + GuardianStore.** Pairing code gen, deep link, `getUpdates` polling with offset, `sendMessage` (no `parse_mode`), and the alert text builder (max 3 quotes, ≤ 700 chars).
  *AC:* MockClient tests: `/start <code>` found → Guardian saved; wrong code ignored; send to 2 guardians, one fails → per-guardian results.
- [x] **T11 Sources.** `UploadSource` (WAV → split; MP3/M4A/OGG ≤ 30 s → a single chunk, passed as-is with the original filename; longer → `AudioFormatException`), `DemoSource` (emits segments every 1.2 s + canned LLM events; the interval is injectable for tests), `MicSource` (`record` `startStream` PCM16 16 kHz mono → 6 s chunks via `wavFromPcm16`).
  *AC:* unit tests for Upload/Demo with fake bytes and a zero interval. Mic is covered by the manual test in TESTING.md §6.

## Phase 3 — Controller + UI (~3:00–5:00)
- [x] **T12 AnalysisController.** Upload + Demo runs per ARCHITECTURE §4, with ordered pool-of-3 STT, live chip updates, final LLM + grounding, the fallback to `basicCheckOnly`, `partialAudio`, TTS + auto-alert hooks (via injected services).
  *AC:* tests with fakes: Demo `scam_cbi` → HIGH 100; LLM throws → `basicCheckOnly` with lexicon-only score 85; 1 of 3 STT pieces fails → `partialAudio` true and segments stay ordered; HIGH + autoAlert → `alert.sendVerdict` is called once.
- [x] **T13 Home + Upload + Analysing** with `StageStamp`, `StageTrack`, `RiskMeter`.
  *AC:* goldens (1.0 and 1.3) for Home (with/without guardian), Upload (with error), Analysing (mid-run with 3 stamps). Report the anti-slop checklist with ✓/✗ per item, fix the ✗s.
- [x] **T14 Verdict** with `LevelBanner`, `EvidenceRow`, TTS replay button.
  *AC:* goldens for HIGH (`scam_cbi`), MEDIUM (`scam_trai`), LOW (`benign_bank`), and HIGH + `basicCheckOnly`. Widget test: the banner has a semantics label including the level word.
- [x] **T15 Questions + Action plan + Complaint.**
  *AC:* widget test: answer paid=Haan → the plan's first card is urgent with the "1930 pe call karein" danger button (the `url_launcher` call is mocked). The complaint Copy button puts text on the clipboard. Goldens for all three screens.
- [x] **T16 Guardians + alert wiring.** QR screen, polling UI with countdown, success/timeout states, auto-alert switch, "Family ko bhejo" on Verdict with `StatusLine` states.
  *AC:* widget test with a fake AlertService: pairing success shows "jud gaye ✓". Goldens for QR + success.
- [ ] **CHECKPOINT (hour 5):** the human runs TESTING.md §6 "Upload chain" on a real phone with real keys. Fix whatever breaks before continuing.

## Phase 4 — Bonus + hardening (~5:00–7:30)
- [x] **T17 Demo screen.** List the 6 scripts with kind tags → run through `/analysing` → `/verdict`.
  *AC:* golden of the list. With airplane mode on, `scam_cbi` reaches HIGH.
- [x] **T18 Live Guard.** `MicSource` + windowed LLM every 2nd chunk (RISK_ENGINE §6), monotonic level, wakelock on while running, Stop → Verdict. Mic permission denied → error state.
  *AC:* controller test with a fake source: the level never decreases. Manual test TESTING.md §6 "Live".
- [ ] **T19 Design + a11y pass.** Regenerate all goldens at 1.0 and 1.3. Go through DESIGN.md §7 for EVERY screen and fix the ✗s. Check overflow at 1.3. Check semantics labels on icon-buttons.
  *AC:* a report table screen × checklist with all ✓.
- [ ] **T20 Security + release.** Run SECURITY.md §6 checklist. Build the release APK with obfuscation. Install it and run the full demo script (PRD §7) twice.
  *AC:* checklist all ✓. The APK path is reported. No `.env` in git (`git ls-files | grep -i env` shows only `.env.example`).

## Cut order if late
T18 Live Guard → T17 polish → 1.3× goldens → TTS. **Never cut:** T03–T05 engine tests, Upload → Verdict → Plan → Complaint → Alert, Demo offline fallback.
