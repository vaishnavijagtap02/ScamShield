# Testing — ScamShield

## 1. Strategy
- **Pyramid:** most tests are pure-Dart unit tests on `lib/engine/` (fast, exact). Then service tests with `MockClient` (`package:http/testing.dart`), controller tests with fakes (`mocktail` or hand-written fakes), and a few widget + golden tests per screen. Real device checks are manual (§6), because hackathon time doesn't allow `integration_test` flakiness.
- **Tests first** for engine, wav, action plan, complaint, and parsers. Write the failing test, show it fail, then implement.
- **No network in tests, ever.** Every service takes an injected `http.Client`. Providers are overridden in widget tests (`ProviderScope(overrides: [...])`).
- **Deterministic:** inject clocks (`DateTime Function() now`) and intervals (DemoSource). No real `Future.delayed` in tests.
- **Test names say behavior:** `test('rejects LLM quote not present in transcript', ...)`.

## 2. Layout
```
test/
  flutter_test_config.dart          # loads Mukta fonts for goldens
  fixtures/
    sarvam_sample.json              # real STT response, redacted (T08)
    llm_valid.json  llm_fenced.txt  llm_one_bad_event.json
  engine/  lexicon_test.dart  grounding_test.dart  risk_engine_test.dart  wav_test.dart
           action_plan_test.dart  complaint_test.dart  demo_scripts_test.dart
  services/ stt_service_test.dart  llm_service_test.dart  alert_service_test.dart
  sources/  upload_source_test.dart  demo_source_test.dart
  state/    analysis_controller_test.dart
  ui/       verdict_screen_test.dart  questions_flow_test.dart  guardians_test.dart
  golden/   components_golden_test.dart  screens_golden_test.dart  goldens/*.png
```
Tests read `assets/demo/scripts.json` with `File('assets/demo/scripts.json').readAsStringSync()` (cwd = project root under `flutter test`).

## 3. Engine vectors (must match RISK_ENGINE §7)
**Lexicon + grounded canned LLM** (primary):
| id | stages | score | level |
| --- | --- | --- | --- |
| scam_cbi | authority, fear, urgency, secrecy, extraction | 100 | high |
| scam_courier | authority, fear, urgency, extraction | 100 | high |
| scam_trai | authority, fear, urgency | 59 | medium |
| benign_bank | — | 0 | low |
| benign_passport | authority | 9 | low |
| ambiguous_family | urgency, extraction | 33 | medium |

**Lexicon only** (LLM failed → `basicCheckOnly`). Rounding is Dart `num.round()` (half away from zero):
| id | stages | score | level |
| --- | --- | --- | --- |
| scam_cbi | all 5 | 85 | high |
| scam_courier | authority, fear, urgency, extraction | 73 | high |
| scam_trai | authority, fear, urgency | 40 | medium |
| benign_bank | — | 0 | low |
| benign_passport | authority | 8 | low |
| ambiguous_family | urgency, extraction | 20 | low |

Also assert: in `scam_cbi` the quote "apne bete ko phone mat karna" and phone "9876543210" are rejected, and the UPI `customs.clearance@okaxis` in `scam_courier` is kept.

These vectors were cross-checked with an independent simulation of RISK_ENGINE §2–4. If your Dart output differs, the bug is in the Dart code (or the doc was changed without updating this table).

## 4. Complaint template (`ComplaintService.build`)
```
Subject: Suspected {scamTypeEn} fraud call on {dd MMM yyyy}

I received a call from {phones.join(', ') | "an unknown number"} on {dd MMM yyyy}.
The caller claimed to be {claimedName | "______"} from {claimedAgency | "______"}{caseNo != null ? ", citing case no. {caseNo}" : ""}.

What the caller said (from my recording):
- [mm:ss] "quote"          (one line per evidence row, max 6)

Money/details requested: {amountAsked | "______"}{upiIds.isNotEmpty ? " | UPI: {upiIds.join(', ')}" : ""}{accounts.isNotEmpty ? " | Account: {accounts.join(', ')}" : ""}
Money sent by me: {paid ? "Yes - UTR/Transaction ID: ______" : "No"}
OTP/PIN/bank details shared: {sharedCredentials ? "Yes" : "No"}
Remote-access app installed / screen shared: {remoteApp ? "Yes" : "No"}

I request action against the above numbers/accounts.
Name: ______   Phone: ______   City/District: ______
```
`scamTypeEn`: digital arrest, KYC/bank, courier/parcel, TRAI/SIM, investment, loan app, sextortion, family emergency, unknown.

## 5. Telegram alert text (`AlertTextBuilder`)
```
ScamShield: {userName|"Aapke parivaar ke sadasya"} ne ek call check ki — {LEVEL_WORD} ({scamTypeHi}).
{summaryHi}
Saboot:
[mm:ss] "{quote}"        (max 3, highest-confidence first)
{paid == true ? "Paise bhej diye gaye hain — abhi call karein aur 1930 pe report karwayein." : "Please abhi unhe call karein."}
```
Plain text only, ≤ 700 chars (truncate the quotes first).

## 6. Manual device checks (real phone, real keys)
Prepare demo WAVs: record the `scripts.json` lines as a roleplay on any phone, then convert:
`ffmpeg -i input.m4a -ac 1 -ar 16000 -sample_fmt s16 scam_cbi.wav`. Keep each WAV under ~60 s.

| Check | Steps | Pass when |
| --- | --- | --- |
| Upload chain | Upload `scam_cbi.wav` → answer Haan/Nahi/Nahi → plan → complaint → Share | HIGH in < 30 s; 1930 card first; draft has CBI + quotes; guardian phone gets Telegram |
| Benign | Upload `benign_bank.wav` | LOW, no auto-alert |
| Offline demo | Airplane mode → Demo → `scam_cbi` | Same HIGH flow, no errors |
| LLM down | Run with a wrong `LLM_API_KEY` | "Basic check" chip, still HIGH (85) |
| Wi-Fi drop | Start upload, turn Wi-Fi off mid-run | `partialAudio` note or "Internet nahi mil raha" + Demo button, no crash |
| Live | Live Guard, teammate reads the `scam_cbi` lines aloud near the phone | Stamps appear in order, HIGH by line 5, level never drops |
| Text scale | Android font size = largest | No overflow, buttons still tappable |
| TTS | HIGH verdict | Hindi warning plays once, replay works |

## 7. Commands
```bash
flutter test                                   # everything
flutter test test/engine                       # fast loop while building the engine
flutter test test/golden --update-goldens      # regenerate PNGs, then review per DESIGN.md §8
flutter analyze && dart format --set-exit-if-changed lib test
```
