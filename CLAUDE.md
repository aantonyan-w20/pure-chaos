# Pure Chaos — rules for agents and humans

This is a Roblox game managed with Rojo. Everything below is binding for any
change made to this repo, whether by a person or an AI agent.

## Repo layout (Rojo mapping in `default.project.json`)

| Folder | Becomes | Rule |
| --- | --- | --- |
| `src/server/` | `ServerScriptService.Server` | Server-only code |
| `src/client/` | `StarterPlayer.StarterPlayerScripts.Client` | Client-only code |
| `src/shared/` | `ReplicatedStorage.Shared` | Modules both sides may require |

File suffixes decide what an instance becomes: `*.server.luau` → Script,
`*.client.luau` → LocalScript, plain `*.luau` → ModuleScript.

## Architecture rules

- **One entry point per side.** `src/server/Main.server.luau` is the only
  server Script; `src/client/*.client.luau` LocalScripts stay thin. Everything
  else is a ModuleScript.
- **Modules do one thing.** A module either builds instances (world/UI), holds
  pure logic, or glues the two — never all three. Pure game rules (like
  `TicTacToe/Logic.luau`) must not touch Instances, so they stay testable.
- **All tunable numbers and colors live in `src/shared/Config.luau`.** No magic
  numbers scattered in modules; if you find one, move it to Config.
- **Client ↔ server only via RemoteEvents** created by the server in
  ReplicatedStorage, with their names defined in Config. The server is always
  authoritative: clicks, turns, and wins are validated server-side.
- **Dependencies are explicit.** Pass collaborators (folders, RemoteEvents) as
  parameters instead of reaching for globals or `_G`.

## Size and style limits

- Files: aim for **under ~150 lines**, hard ceiling ~200. Bigger → split it.
- Functions: aim for **under ~30 lines**, one job each. Bigger → extract helpers.
- Indent with tabs. `PascalCase` for module names and Config keys, `camelCase`
  for functions and variables, `UPPER_SNAKE` for module-level constants.
- Every file starts with a `--[[ ... ]]` header saying what it owns and why.
  Inline comments explain *why*, not *what* the next line does.
- Use `task.wait`/`task.delay`/`task.spawn`, never the deprecated `wait`/
  `delay`/`spawn`. Get services once at the top via `game:GetService`.
- Add Luau type annotations on public module function signatures.

## Workflow rules

- `git pull` before starting; commit small and push often.
- Before committing, verify the project still compiles: `rojo build -o game.rbxl`.
- Behavior changes and refactors go in separate commits when practical.
- Update `README.md` when setup steps or the game's features change, and update
  this file when a new convention is agreed on.
