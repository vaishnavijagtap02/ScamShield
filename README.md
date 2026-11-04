# ScamShield — Claude Code starter pack

Planning docs and config for building ScamShield (Flutter, Android) with Claude Code in an 8-hour hackathon. Put this pack into your Flutter project root and point Claude Code at it.

## What's inside
```
CLAUDE.md                  ← auto-loaded by Claude Code every session (rules, commands, gotchas)
analysis_options.yaml      ← strict lints (very_good_analysis)
.env.example               ← key names → copy to .env (never commit)
.gitignore.append          ← append to Flutter's .gitignore
.claude/settings.json      ← permissions (blocks reading .env) + auto `dart format` hook (needs jq)
.claude/commands/          ← /next-task, /slop-check, /security-check
docs/
  PRD.md                   ← problem, users, scope, user stories + acceptance criteria
  ARCHITECTURE.md          ← pipeline, folders, models, controller, API contracts, errors
  RISK_ENGINE.md           ← lexicon, weights, formula, LLM prompts, grounding, test vectors
  DESIGN.md                ← design direction, tokens, components, every screen, anti-slop checklist
  TASKS.md                 ← T00–T20 ordered tasks with acceptance criteria
  TESTING.md               ← test strategy, vectors, templates, manual device checks
  SECURITY.md              ← threat model, secrets, data handling, pre-demo checklist
  KICKOFF.md               ← exact prompts to paste into Claude Code
assets/
  action_plan.json         ← static safety steps (Hinglish + Hindi), never LLM-generated
  demo/scripts.json        ← 6 scripted calls: offline demo + test vectors + roleplay lines
```

## Setup (15 min)
1. `flutter create --org com.scamshield --platforms android scamshield`, then copy this pack into the project root (merge the `assets/` folder; append `.gitignore.append` to `.gitignore`).
2. `cp .env.example .env` and fill in the keys (Sarvam, an OpenAI-compatible LLM, the Telegram bot).
3. Download Mukta 400/600/700/800 from Google Fonts into `assets/fonts/`.
4. Install `jq` (used by the format hook). Connect an Android phone with USB debugging on.
5. Open Claude Code in the project and paste prompt §1 from `docs/KICKOFF.md`.

## Requirements
Flutter stable (Dart 3), Android phone (API 23+), a Sarvam API key, any OpenAI-compatible LLM key, a Telegram bot token.

## Key decisions (why it's built this way)
- **Upload-first** because Android doesn't let normal apps hear an active call. Live Guard (speaker + mic) is the bonus.
- **Rules decide, LLM assists.** The LLM proposes tactics, grounding rejects quotes not in the transcript, and the action plan is static JSON. Explainable and injection-resistant.
- **Offline demo** replays `scripts.json` through the real engine, so a dead Wi-Fi can't kill the pitch.
- **Elderly-first UI:** 20 sp body, 64 dp buttons, AAA contrast, paper + ink + three risk colors. No AI-default purple.
