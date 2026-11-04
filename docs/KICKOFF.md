# Kickoff — exact prompts to paste into Claude Code

Tips: start each task in a fresh context (`/clear`). Use Plan Mode (Shift+Tab) for the first prompt and for any task touching more than 3 files. Don't let Claude start the next task until you've glanced at the report.

## 0. Before the event (no app code, just prep)
- Fill `.env` from `.env.example`. Create the Telegram bot via @BotFather. Test the Sarvam key with one curl.
- Download Mukta (400/600/700/800) from Google Fonts into `assets/fonts/`.
- Record the 6 roleplay WAVs from `assets/demo/scripts.json` and convert them (TESTING.md §6).
- Check the hackathon rules on pre-written code. These docs are planning material. Write the app code at the event.

## 1. First session — understand + plan (Plan Mode)
```
Read CLAUDE.md and every file in docs/. Don't write code yet.
1) Summarize the product, the pipeline, and the demo flow in 10 bullets.
2) List any contradictions or gaps you find between the docs (be specific: file + section).
3) Ask me up to 5 questions that would change the implementation.
4) Then propose the plan for T00 and T01 only.
```

## 2. Build loop (one task per context)
```
/next-task
```
or a specific one: `/next-task T05`. After each report, check: tests pasted? box ticked? Then `/clear` and continue.

**Parallel tip (2+ laptops):** use separate git branches or worktrees. Laptop 1 runs T02–T07 (engine, pure Dart, no UI conflicts). Laptop 2 runs T01 then T13–T15 against fake controller state. Merge at T12.

## 3. Checkpoint at hour 5
```
We are at the checkpoint in docs/TASKS.md. Here's what happened on the real phone: <paste errors/screenshots>.
Diagnose root causes first (don't patch symptoms), list fixes in priority order for the demo, then fix the top one and re-run the tests.
```

## 4. Design review
```
/slop-check
```
If the UI still feels generic:
```
Look at the Verdict golden PNG. A demanding product designer says it looks like a default Flutter app.
Name the 5 most generic things in it, referencing docs/DESIGN.md tokens and §7. Fix them without adding new colors or packages, then show the new PNG.
```

## 5. Demo hardening (last hour)
```
/security-check
```
```
Simulate the demo (docs/PRD.md §7) and list every point where it could fail on stage (network, permissions, TTS, Telegram, long files).
For each one, confirm the fallback exists in code (file:line) or add it. Don't add features.
```

## 6. If something breaks during the demo build
```
Bug: <symptom>. Expected: <x>. Seen: <y>. Steps: <1,2,3>.
Write a failing test that reproduces it first, then fix it, then show the test passing.
```
