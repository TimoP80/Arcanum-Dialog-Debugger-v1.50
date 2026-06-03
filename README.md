# Arcanum Dialog Debugger

A Delphi / VCL CLI tool for parsing, evaluating, and stepping through Arcanum dialog files (`.dlg`).

## Features

- Loads Arcanum dialog files in native format: `{N}{Text}{G/I/R}{Tests}{R}{Result}`
- Node-based navigation with `// NODE:` and `// DESCRIPTION:` comments
- Full EventScripts test-code evaluation (`EvaluateTests`)
- Full EventScripts result-code execution (`ExecuteResults`)
- Generated-dialog commands (A–Z, Q, I, R, G, M) recognized and parsed
- Line-to-node resolution for `TargetLine` jumps
- Debug logging of state transitions

## Building

Open `src/DialogDebugger.dproj` in Delphi (Win32) and build.

## Legend

| Term | Meaning |
|------|---------|
| NPC line | `{N}{Male text}{Female text}{}{}{}{}` |
| PC line | `{N}{Text}{}{Tests}{R line}{Results}` |
| Generated | `{N}{X: params}...` where X is A–Z, Q, I, R, G, M |
