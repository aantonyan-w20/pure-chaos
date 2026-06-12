# Our Roblox Game

A Roblox game built by two friends, managed with [Rojo](https://rojo.space/) so all
game code lives in this repository instead of being locked inside Roblox Studio.

## How this works

- All scripts live in `src/` as `.luau` files. **Edit code in your text editor, not in Studio.**
- Rojo syncs those files into Roblox Studio live while you work.
- Git/GitHub is how we share changes with each other.

```
src/
  client/   → runs on each player's machine (StarterPlayerScripts)
  server/   → runs on the Roblox server (ServerScriptService)
  shared/   → modules used by both (ReplicatedStorage.Shared)
default.project.json  → tells Rojo how files map into the game
```

## One-time setup (each person)

1. Install [Roblox Studio](https://create.roblox.com/) and log in.
2. Install Rojo:
   - **macOS:** `brew install rojo`
   - **Windows/any:** install [Rokit](https://github.com/rojo-rbx/rokit), then run `rokit install` in this folder.
3. In Roblox Studio: **Plugins from Rojo** — run `rojo plugin install` in a terminal, then restart Studio. (You should see a Rojo button in the Plugins tab.)
4. Clone this repository:
   ```sh
   git clone <repo-url>
   cd <repo-folder>
   ```

## Daily workflow

1. Pull the latest changes first:
   ```sh
   git pull
   ```
2. Start the Rojo server in this folder:
   ```sh
   rojo serve
   ```
3. Open the place in Roblox Studio (`rojo build -o game.rbxl` then open `game.rbxl`,
   or open your saved place file).
4. In Studio, click the **Rojo** plugin button → **Connect**. Your code now live-syncs:
   edit a `.luau` file, save it, and it updates in Studio instantly.
5. Press **Play** in Studio to test.
6. When you're done, share your work:
   ```sh
   git add -A
   git commit -m "describe what you changed"
   git push
   ```

## Ground rules so we don't clobber each other

- **Always `git pull` before you start working.**
- Commit and push small changes often — big rare pushes cause painful merge conflicts.
- Code (`src/`) is owned by git. Map/building changes made by hand in Studio are **not**
  synced back to files by default — for now, do building in Studio inside Team Create or
  define parts in `default.project.json` / scripts, and keep gameplay logic in `src/`.
- If you both need to change the same file, talk first (or use branches).

## Useful commands

| Command | What it does |
| --- | --- |
| `rojo serve` | Start live sync server for Studio |
| `rojo build -o game.rbxl` | Build a fresh place file from the repo |
| `git pull` | Get your friend's latest changes |
| `git push` | Share your changes |
