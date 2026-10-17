# SpotiWoW-Dev v1.6.5-alpha

> Development version for testing; changes and bugs are possible.

**Author: CloudNine_Ex**

A Spotify companion for Turtle WoW / OctoWoW clients based on 1.12.1 with SuperWoW. The project ships both French (FR) and US English add-on variants.

- French end-user readme: `README_FR.md`
- US English end-user readme: `README_EN_US.md`

## For players
Download `SpotiWoW-Dev-Setup.exe` from the release you want. Setup is pinned to that release and verifies its GitHub tag, commit SHA, package manifest, and SHA-256 digest before installation.
/spn help for all commands.

## For maintainers
The shared Lua behavior is in `Interface/AddOns/SpotiWoW-Dev/SpotiWoW-Dev.lua`. French locale and metadata are in that add-on folder. US English locale and metadata are under `variants/US`. Publishing a GitHub Release triggers `.github/workflows/release.yml` to build the tray launcher, installer, and both language bundles.

## Compatibility and privacy
- Requires Turtle WoW / OctoWoW, SuperWoW file functions `ImportFile` and `ExportFile`, and `VanillaFixes.exe`.
- Live Spotify artwork uses `customassets.dll` to load the add-on's predeclared loose textures from `Data/`; the installer enables that DLL only when it is already installed.
- Does not distribute the game client or any third-party game DLLs.
- Each user supplies their own Spotify Client ID. Do not commit `config.json`, `tokens.json`, or `lyrics_cache.json`.
- The hotkey's Lyrics ON/OFF status is local-only (`DEFAULT_CHAT_FRAME:AddMessage`), not a chat message sent to other players.

