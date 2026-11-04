# Design — ScamShield (source of truth for UI)

## 1. Direction: "Sarkari-paper calm, stamp-sharp alerts"
The user is a scared 65-year-old being told they're under arrest. The UI must feel **calm, official-paper plain, and unmistakable when it's danger**. It should feel like a well-printed government notice, not a cyber-security startup.

- **Signature element (the one thing people remember):** the **Pressure Playbook track**, 5 rubber-stamp chips (Adhikari → Darr → Jaldi → Chhupao → Paisa/OTP) that "stamp" in as each tactic is caught, with its timestamp. Fake officials use fake stamps, and we stamp their tactics. It appears on Analysing, Live Guard and Verdict.
- **Color is for meaning only.** The page is warm paper + ink. The only strong colors are the three risk colors.
- **One thing per screen.** Each screen has one primary action, in ink-filled big buttons.
- **Light theme only** for the hackathon. It's designed for daylight, high contrast and elderly eyes. Don't add dark mode.

## 2. Tokens — `lib/ui/theme/tokens.dart` (the ONLY place values live)
### Color
| Token | Hex | Use |
| --- | --- | --- |
| `paper` | `#F7F3EC` | Scaffold background |
| `surface` | `#FFFDF8` | Cards, sheets |
| `ink` | `#1D1B18` | Text, primary buttons (filled), stamp borders |
| `inkMuted` | `#55504A` | Secondary text (7.2:1 on paper) |
| `line` | `#DDD5C7` | Borders, dividers |
| `highlight` | `#FFE8A3` | Background behind matched quote text |
| `lowStrong` / `lowTint` | `#175234` / `#E3F0E7` | LOW banner text+icon / bg |
| `medStrong` / `medTint` / `medInk` | `#9A6400` / `#FBEFD5` / `#4A3000` | MEDIUM icon only (non-text) / bg / text (10.7:1) |
| `highStrong` / `onHigh` | `#A21C15` / `#FFFFFF` | HIGH banner bg / text (7.7:1). Also the "1930 call" button |
| `focus` | `#1D1B18` | 3 dp focus ring |

Build `ColorScheme` **manually** from these (primary = ink, onPrimary = surface, error = highStrong, surface = surface). **Do NOT use `ColorScheme.fromSeed`.** The Flutter template's `Colors.deepPurple` seed is the #1 AI-slop tell.

### Typography (bundled **Mukta**, which covers Latin + Devanagari; weights 400/600/700/800)
| Token | Size/LineHeight (sp) | Weight | Use |
| --- | --- | --- | --- |
| `display` | 36 / 1.15 | 800 | Verdict word ("KHATRA") |
| `h1` | 28 / 1.2 | 700 | Screen titles |
| `h2` | 22 / 1.3 | 700 | Section/rule titles |
| `body` | 20 / 1.5 | 400 | Default text, minimum for content |
| `bodyStrong` | 20 / 1.5 | 600 | Emphasis, button labels |
| `label` | 18 / 1.3 | 600 | Chips, stamp labels |
| `caption` | 16 / 1.4 | 400 | Timestamps, footnotes. Never smaller than 16 |
Use `FontFeature.tabularFigures()` for timestamps and scores. Respect `MediaQuery.textScaler` and never clamp it. Layouts must survive 1.3×.

### Space, shape, elevation
- Spacing scale: `4, 8, 12, 16, 24, 32, 48`. Screen padding 24. Gap between stacked buttons 16.
- Radius: `r8` (stamps, chips), `r12` (cards), `r16` (big buttons). No pill-shaped everything.
- Elevation: **0 everywhere.** Separate things with `line` borders (1.5 dp) and spacing. Only modal sheets may use a soft neutral shadow.
- Touch targets: primary buttons **64 dp tall**, all tappables ≥ 56 dp, 12 dp min gap.

### Motion (`lib/ui/theme/motion.dart`)
- Stamp-in: scale 1.15→1.0 + opacity 0→1, rotate to -2°, 220 ms `Curves.easeOutCubic`, plus `HapticFeedback.mediumImpact()`.
- Risk meter fill: 400 ms `easeOutCubic`.
- HIGH banner: one 300 ms fade-in. No pulsing, no shaking.
- If `MediaQuery.disableAnimations` is true, all durations are 0.

## 3. Components — `lib/ui/widgets/`
| Widget | Spec |
| --- | --- |
| `BigButton` | Full width, 64 dp, r16. Variants: `primary` (ink bg, surface text), `secondary` (surface bg, 1.5 dp ink border), `danger` (highStrong bg, onHigh text). Optional leading icon 28 dp + optional second line (`caption`). Pressed: darken 8%. Disabled: 40% opacity + still readable label. |
| `StageStamp` | Box r8, padding 12×8. **Unseen:** 1.5 dp dashed `line` border, `inkMuted` label. **Seen:** 2 dp solid `ink` border, `ink` label, rotated -2°, timestamp `mm:ss` caption below. Label always visible: never icon-only. |
| `StageTrack` | Row of 5 `StageStamp`s, wraps to 2 rows on narrow widths or high text scale. Order = canonical. |
| `RiskMeter` | Horizontal bar 16 dp tall, 3 labelled zones (Theek / Savdhan / Khatra). The fill uses the current level's strong color. Score text right-aligned (tabular). Semantics: "Risk score 85, Khatra". |
| `LevelBanner` | Full-bleed block. HIGH: `highStrong` bg, `onHigh` text, warning icon, `display` "KHATRA", body "Ye scam lagta hai". MEDIUM: `medTint` bg, `medInk` text, "SAVDHAN". LOW: `lowTint` bg, `lowStrong` text, "THEEK LAGTA HAI". Always word + icon + color. |
| `EvidenceRow` | `mm:ss` (caption, tabular) · stage name (label, ink) · quote in `"…"` with the matched words on a `highlight` background. 1.5 dp bottom `line`. Optional `explanationHi` in `inkMuted`. |
| `SectionCard` | `surface` bg, 1.5 dp `line` border, r12, padding 16. |
| `ActionRuleCard` | `SectionCard`. Urgent rules get a 6 dp `highStrong` left bar. Title `h2`, numbered steps `body`, then its action `BigButton`s. |
| `StatusLine` | Icon + one line, for "Rohan ko alert bhej diya ✓" / "Bhej nahi paaye — Dobara bhejein". |

## 4. Screens (each lists the states that must be designed)
**Home `/`**
- Top row: wordmark "ScamShield" (Mukta 800, 28) left, "हिं / Hin" language toggle and Settings icon-button (with tooltip + semantics) right.
- Guardian status: `StatusLine` "Alert jaayega: Rohan ✓", or a `SectionCard` "Family ko jodein: scam pe unhe turant pata chalega" → `/guardians`.
- `BigButton.primary` "Recording check karein" / "Call recording ya voice note".
- `BigButton.secondary` "Live Guard" / "Speaker pe chal rahi call suno". `BigButton.secondary` "Demo".
- Bottom `SectionCard` fact (rotates through 3 strings): "Koi bhi police ya CBI video call pe arrest nahi karti."
- States: keys missing → caption banner "Sirf Demo mode chalega (API keys missing)".

**Upload `/upload`**: Title "Recording chunein". One line: what's supported. `BigButton.primary` "File chunein". Privacy caption: "Audio sirf likhne (transcription) ke liye bheja jaata hai. Phone pe ya kahin aur save nahi hota." States: picking, unsupported file (`SectionCard` with what to do), too-long compressed file.

**Analysing `/analysing`**: `StageTrack` top, `RiskMeter`, progress caption "3 / 5 hisse sune", transcript list (newest at bottom, auto-scroll, matched phrases highlighted). Secondary "Rokein" button. States: first-piece wait ("Sun rahe hain…" + a determinate progress bar, never a bare spinner), partial failure note, total failure (error card + "Demo chalayein").

**Verdict `/verdict`**: `LevelBanner`, `summaryHi` (`body`), scam-type chip, "Basic check" chip if `basicCheckOnly`, `StageTrack` (final), "Saboot (Evidence)" list of `EvidenceRow`s, `BigButton.primary` "Aage: kya karein?", `BigButton.secondary` "Family ko bhejo" / `StatusLine` after sending. HIGH: TTS plays once; a speaker icon-button replays it.

**Questions `/questions`**: Title "Kuch sawaal". 3 rows, each a question in `bodyStrong` + a 2-option segmented control (**Haan / Nahi**, each ≥ 56 dp, the selected one ink-filled). `BigButton.primary` "Plan dikhao" (enabled when all 3 are answered).

**Action plan `/plan`**: Urgent rule cards first. The "1930 pe call karein" button is `BigButton.danger`. Then other rules. Bottom: `BigButton.primary` "Complaint draft dekhein".

**Complaint `/complaint`**: `SectionCard` with selectable draft text (`body`, blanks shown as `______`). Buttons: "Copy karein" (then `StatusLine` "Copy ho gaya ✓"), "Share karein", "cybercrime.gov.in kholein".

**Live Guard `/live`**: Instruction card "Call ko speaker pe rakhein, ye phone paas rakhein." Listening indicator: a small `ink` dot + "Sun raha hai · 01:24" (no glowing rings). `StageTrack`, `RiskMeter`, last 3 transcript lines. `BigButton.primary` "Rokein aur result dekhein". On HIGH: `LevelBanner` slides in above the track + TTS + auto-alert.

**Demo `/demo`**: List of 6 scripts, each a 64 dp row: title + kind tag (Scam / Asli / Shak). Tap → runs through `/analysing`.

**Guardians `/guardians`**: List of guardians (name, remove). `BigButton.primary` "Naya guardian jodein" → QR (240 dp, on `surface`), the link as selectable caption, instruction "Rohan apne phone se ye QR scan karke Telegram mein *Start* dabayein", countdown "Intezaar… 1:42". Success state: `StatusLine` "Rohan jud gaye ✓". Timeout state: retry. Switch row "Khatra hone pe apne-aap alert bhejo" (56 dp).

**Settings `/settings`**: Language, auto-alert, "Text bada karna hai? Phone ki settings mein font size badhayein" note, and app version.

## 5. Copy rules (`lib/ui/strings.dart`)
- Hinglish (Latin) is the default, with Hindi (Devanagari) as the second map. Address the user as "aap". Lead with the verb: "File chunein", "1930 pe call karein".
- Plain words over jargon. Say "Saboot", not "evidence artifacts". Never say "AI-powered", "seamless", "smart", or "Oops!".
- No emoji in UI copy, except ✓ in status lines.
- Errors say what happened + what to do: "Internet nahi mil raha. Wi-Fi check karein ya Demo chalayein."

## 6. Accessibility
- Body text contrast ≥ 7:1 (AAA). Check every token pair you use.
- Never color alone: levels carry a word + icon, and stamps carry a label + border style.
- Every icon-button has a `tooltip` + `Semantics(label:)`. The verdict banner announces via `SemanticsService.announce` when it appears.
- Focus order follows the visual order. Visible 3 dp focus ring.
- Test at text scale 1.0 and 1.3 (goldens do both).

## 7. Anti-AI-slop checklist (run on every UI task; report each item ✓/✗)
**Flutter-template tells**
- [ ] No `ColorScheme.fromSeed`, no deepPurple/indigo/violet anywhere, no M3 tonal purple-tinted surfaces
- [ ] No default Roboto. Mukta is applied app-wide (check goldens show Mukta, not the placeholder font)
- [ ] No default `FloatingActionButton` as the primary action. No default `AppBar` with a centered title and a shadow
- [ ] No `Card` with default elevation/shadow. Borders + spacing only

**Generic AI-UI tells**
- [ ] No gradients (backgrounds, buttons, text), no glassmorphism/blur, no glow or colored shadows
- [ ] No "security startup" look: no dark navy/neon cyan, no glowing shield or padlock illustration, no hacker-green
- [ ] No hero with a giant icon + "Welcome to ScamShield". No row of 3 feature cards with icons
- [ ] No emoji as icons, no stock illustrations, no lorem/placeholder copy
- [ ] No bare spinner. Loading shows progress + words
- [ ] No snackbar/toast for critical info (HIGH verdict, alert failure). Use in-page banners
- [ ] Not everything rounded the same. The radius scale (8/12/16) is used deliberately

**ScamShield-specific**
- [ ] Only the 3 risk colors are saturated. Everything else is paper/ink/line
- [ ] Body text ≥ 20 sp, primary buttons 64 dp, nothing tappable < 56 dp
- [ ] Each screen has exactly one primary (ink or danger) button
- [ ] All copy comes from `strings.dart`, is Hinglish, and leads with verbs
- [ ] Layout intact at text scale 1.3 (no overflow stripes in goldens)

## 8. Visual review loop (Claude Code)
1. `test/golden/screens_golden_test.dart` pumps each screen with fake state at 412×915 logical px, scale 1.0 and 1.3.
2. `flutter test test/golden --update-goldens` writes PNGs to `test/golden/goldens/`.
3. Open each PNG with the Read tool, go through §7 item by item, and list violations. Fix them and repeat until all are ✓.
4. Mukta must be loaded in `test/flutter_test_config.dart` via `FontLoader('Mukta')` with the asset bytes. Without it, goldens render placeholder boxes and the review is meaningless.
