<img width="1024" height="1024" alt="ChatGPT Image 3 6 2026 klo 11 16 15" src="https://github.com/user-attachments/assets/6dfa5198-55de-4eea-890c-6cf166c43f5d" />

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
- Preferences dialog (`Preferences...` button) for configuring the Arcanum install path, last-used DLG folder, verbose debug output, debug logging, and dialog line-number step
- Persistent configuration stored in `DialogDebugger.ini` next to the executable

## Building

Open `src/DialogDebugger.dproj` in Delphi (Win32) and build.

## Configuration

Settings are read from and written to `DialogDebugger.ini` next to `DialogDebugger.exe`. On first launch, open **Preferences...** and set the Arcanum install path so the Module Manager can locate the game's `Arcanum` folder and any custom modules.

INI sections:

| Section  | Key              | Description                                |
|----------|------------------|--------------------------------------------|
| `Paths`  | `ArcanumPath`    | Absolute path to the Arcanum install dir   |
| `Paths`  | `LastDLGFolder`  | Last directory used by **Load .dlg**       |
| `Debug`  | `VerboseDebug`   | Forward `outputnormally=False` log lines   |
| `Debug`  | `DebugLogging`   | Master switch for the in-app debug memo    |
| `Editor` | `LineNumberStep` | Dialog line-number step (1–1000)           |

## Legend

| Term | Meaning |
|------|---------|
| NPC line | `{N}{Male text}{Female text}{}{}{}{}` |
| PC line | `{N}{Text}{}{Tests}{R line}{Results}` |
| Generated | `{N}{X: params}...` where X is A–Z, Q, I, R, G, M |
