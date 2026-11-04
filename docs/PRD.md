# PRD — ScamShield

**One line:** "Paise bhejne se pehle, ek baar check karo." Upload a suspicious call recording and get an evidence-backed verdict, what to do next, a ready complaint draft, and an alert to family.

## 1. Problem
- Digital-arrest scams: fraudsters impersonate CBI/police/customs/TRAI, threaten arrest, demand urgency and secrecy, then extract money. I4C complaints: 39,925 (2022) → 1,23,672 (2024) → 58,249 (2025) → 16,377 (Jan–Jun 2026). Losses: ₹91 cr (2022) → ₹1,935.5 cr (2024).
- Cases are falling but per-victim losses are huge (₹2–15 cr cases in 2026) and victims are mostly elderly.
- Existing tools check numbers and links (Truecaller) or only run on flagship phones (Google Scam Detection on Pixel 9+/Galaxy S26). None of them track the *conversation's pressure pattern* in Hinglish and pull in family.

## 2. Users
| Persona | Need |
| --- | --- |
| **Primary: "Papa", 60+, retired, Android budget phone, Hindi/Hinglish** | Big clear answer: "Ye scam hai ya nahi? Ab kya karun?" |
| **Secondary: "Rohan", 25–35, the son/daughter who installs and sets it up** | Gets alerted when Papa is in danger, with evidence |
| **Judges (demo audience)** | A working flow in under 2 minutes, honest limits |

## 3. Goals for the hackathon (success = all true at demo time)
1. Upload a scam WAV → HIGH verdict with ≥4 evidence lines in < 30 s on hall Wi-Fi.
2. Benign WAVs (bank, passport police) → LOW. Ambiguous (family emergency) → MEDIUM.
3. Answering "Paise bhej diye" shows the 1930 urgent plan. The complaint draft is pre-filled and the judge's phone receives a Telegram alert.
4. Offline Demo mode replays the same flow with no network.
5. Bonus: Live Guard (mic) shows chips lighting up from a live roleplay.

## 4. Scope
**In (MVP):**
- Upload WAV (16 kHz mono PCM, any length) and short MP3/M4A/OGG (< 30 s)
- Live Guard (mic, foreground screen only)
- Demo mode (canned scripts, offline)
- Verdict with 5 stage chips, risk meter, evidence timeline, Hindi summary
- 3 questions → rules-based action plan → complaint draft (copy/share)
- Trusted Circle: pair 1+ guardians via Telegram deep-link QR, then send alerts
- Hindi voice warning (TTS) on HIGH
- Language: Hinglish (Roman) default, Hindi (Devanagari) toggle

**Out (say "roadmap" if asked):** listening to an active phone/WhatsApp call on the same device (Android blocks it), accessibility-service capture, AI call answering, backend/accounts/DB, iOS, long MP3/M4A via Sarvam Batch API (stretch only), regional languages beyond Hindi/English UI.

## 5. User stories and acceptance criteria
**US-1 Upload check**
- WHEN the user picks a supported file, THE app SHALL show the Analysing screen within 1 s and stream transcript lines as pieces finish.
- WHEN a piece fails STT after 1 retry, THE app SHALL continue with the other pieces and show "Kuch hissa sun nahi paaye" on the verdict.
- WHEN the file is unsupported (non-16 kHz WAV, or compressed > 30 s), THE app SHALL show a plain-language error with what to upload instead.

**US-2 Verdict**
- THE verdict SHALL show the level word + icon + color (never color alone), score, scam type, a Hindi summary (≤ 2 sentences), and evidence rows (time · stage · exact quote).
- Every evidence quote SHALL exist in the transcript (grounding).
- WHEN the level is HIGH, THE app SHALL play the TTS warning once (if TTS is available) and show the HIGH banner.

**US-3 Action plan**
- THE app SHALL ask 3 yes/no questions: paid? shared OTP/PIN/bank details? installed an app/screen-shared?
- THE plan SHALL list every matching rule from `assets/action_plan.json` in priority order, with tap-to-act buttons (`tel:1930`, cybercrime.gov.in, bank, Chakshu).

**US-4 Complaint draft**
- THE draft SHALL fill the date, scam type, claimed agency/name/case no., grounded phone/UPI/account entities, evidence quotes with times, and the answers. Unknown fields stay as `______`.
- THE user SHALL be able to copy and share it.

**US-5 Trusted Circle**
- THE user SHALL pair a guardian by showing a QR/link `https://t.me/<bot>?start=<code>`. Pairing completes when the app sees `/start <code>` via `getUpdates` (poll every 2 s, timeout 120 s).
- WHEN the verdict is HIGH and auto-alert is on, OR the user taps "Family ko bhejo", THE app SHALL send the alert to all guardians and show a "Bhej diya ✓" state. On failure it shows retry.

**US-6 Live Guard (bonus)**
- WHEN Live Guard is started, THE app SHALL request mic permission, keep the screen awake, transcribe 6 s chunks, and update chips and the meter. The level never decreases within a session.

**US-7 Demo mode**
- THE Demo screen SHALL list the 6 scripts from `assets/demo/scripts.json` and replay them through the same controller with realistic timing (one segment per ~1.2 s), using canned LLM events.

## 6. Non-functional
- Elderly-first UI: body ≥ 20 sp, touch targets ≥ 56 dp for primary actions, AAA contrast for body text. Respect the system text scale.
- Privacy: no audio or transcript persisted or logged. Guardians receive only a summary + up to 3 quotes.
- Performance: a 2-min WAV is fully analysed in ≤ 30 s (3 parallel STT requests).
- Reliability: every network step has a timeout, 1 retry, and a user-facing fallback. The LLM being down → lexicon-only verdict with a small "Basic check" label.

## 7. Demo script (what the build must support)
1. Upload `scam_cbi.wav`. Chips stamp in, then HIGH, the Hindi voice warning, and the summary.
2. Tap "Haan, paise bhej diye". The 1930 plan appears first.
3. Open the complaint draft (pre-filled) and tap Share.
4. The judge's phone (paired guardian) buzzes with the Telegram alert.
5. "Same engine live bhi chalta hai": Live Guard + a 4-line roleplay → HIGH.
