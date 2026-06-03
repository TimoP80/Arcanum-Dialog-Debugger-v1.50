# Changelog

All notable changes to this project are documented here.

## [v0.2.0] - 2026-06-03

### Added
- Full Arcanum native dialog line parser (`DialogueParser.pas`)
  - NPC lines: `{N}{Male}{Female}`
  - PC lines: `{N}{Text}{Tests}{R}{Results}`
  - Generated-dialog commands (A–Z, Q, I, R, G, M)
- `TDialogueNode` with `NPCLines`, `PlayerOptions`, `GeneratedOptions`, `LineMap`
- `TDialogueParser.ParseDialogue` and helpers
- `DialogEngine.EvaluateTests` — all EventScripts test codes ($$, al, ar, ch, fo, gf, gv, ha, ia, in, lc, le, lf, ma, me, na, ni, pa, pe, pf, ps, pv, qa, qb, qu, ra, re, rp, rq, ru, sc, sk, ss, ta, tr, wa, wt)
- `DialogEngine.ExecuteResults` — all EventScripts result codes ($$, al, ce, co, et, fl, fp, gf, gv, ii, in, jo, lc, lf, lv, mm, nk, np, or, pf, pv, qu, re, ri, rp, rq, ru, sc, so, ss, su, tr, uw, wa, xp)
- Engine state fields: `FPlayerLevel`, `FMagicAptitude`, `FTechAptitude`, `FCurrentArea`, `FCurrentNPC`, `FRumors`, `FPlayerReputations`
- `DialogEngine.FindLineInNodes` for `TargetLine` resolution
- `TDialogEngine.TSkill` enum mapping 0–15 → skill names
- Generated-option expansion in `EvaluateOptions` (Q: handled)

### Changed
- `DIalogueParser.pas` → renamed to `DialogueParser.pas` (correct casing)
- `DialogDebugger.dpr` and `.dproj` updated to reference `DialogueParser.pas`
- `EvaluateTests` and `ExecuteResults` rewritten from stub to full implementation
