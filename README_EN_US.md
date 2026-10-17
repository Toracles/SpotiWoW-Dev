# SpotiWoW-Dev v1.6.15 — US English

> **Development version** — this version is still evolving and may include experimental changes. It is intended for testing; bugs or behavior changes may occur.

SpotiWoW-Dev connects Spotify to Turtle WoW / OctoWoW through the SuperWoW file bridge. This package uses the US English interface and in-game messages.

## Easy installation
1. Download `SpotiWoW-Dev-Setup.exe` from the **Releases** page of the official GitHub repository.
2. Close Turtle WoW before installing.
3. Select `English (US)` in the installer, choose the folder containing `VanillaFixes.exe`, and enter your Spotify Client ID.
4. In your Spotify Developer app settings, add the exact Redirect URI `http://127.0.0.1:8888/callback`.
5. Finish the setup and launch **SpotiWoW-Dev** from the shortcut.

Setup is pinned to its specific GitHub release. Before installing, it verifies the tag, source commit SHA, package manifest, and GitHub-published SHA-256 digest.

The installer never asks for a Client Secret and does not download Turtle WoW, VanillaFixes, SuperWoW, SuperAPI, or their DLLs.

## Requirements
- Turtle WoW / OctoWoW client based on WoW 1.12.1.
- SuperWoW with the `ImportFile` and `ExportFile` functions.
- `VanillaFixes.exe` in the client folder.
- A Spotify Developer app configured with the Redirect URI shown above.
- `customassets.dll` enabled in `dlls.txt` for live Spotify covers. Setup enables it if the DLL is already present.

## Features
- `Ctrl+Alt+L` toggles Lyrics from the companion without typing a command into the in-game chat.
- `Lyrics mode: ON/OFF` is displayed locally via `DEFAULT_CHAT_FRAME:AddMessage`. The status message is never sent to other players.
- Player inspired by classic WoW panels, with a metallic frame, dark stone backdrop, gold titles, and restrained neon accents in three layouts: compact (300 × 68 px), square (236 × 236 px), and expanded (460 × 164 px). Spotify artwork, artist, album, time, and controls vary by layout. Choose in `/spn settings` or use `/spn mode compact|square|expanded`.
- Obsidian, Azerite, Fel, Bloodmoon, Sunwell, Silver Dawn, and Fang Set themes, with customizable accents, glow, borders, and controls; configurable progress bar with click-to-seek.
- Click `...` on the player (or use `/spn settings`) for the full panel, styled like a classic WoW window: theme, layout, colors, glow, border, buttons, metadata, controls, and progress. The top button cycles through compact, square, and expanded layouts.
- The expanded player's right panel shows Spotify, playback status, volume, and Volume/Lyrics shortcuts.
- Shuffle, repeat album, and repeat track stay visibly indicated on the player. Obsidian, Azerite, Fel, and Bloodmoon each keep their own neon accent color.
- Settings persist in WoW. `/spn help` lists themes and options; `/spn expand` toggles the expanded player.
- Multi-source search for timestamped lyrics and a local cache.
- Windows notification-area launcher with no visible CMD console.
- Automatically stops the bridge when the actual `WoW.exe` client process exits, including Alt+F4.
- Checks published GitHub releases without an API key and announces an update only when its installer is available. The add-on shows a local chat reminder at every login; the Windows notification-area menu displays the version and opens its release page.

Lyrics themselves are still sent to the selected channel when that feature is enabled. Technical identifiers `SpotifyNowDB`, `SpotifyNowState.txt`, and `SpotifyNowCommand.txt` are retained for compatibility.

## Troubleshooting
- See the [US English troubleshooting guide](TROUBLESHOOTING_EN_US.md) for connection, artwork, metadata, lyrics, and command issues.
- Logs: `logs/bridge.log` and `logs/launcher.log` in the companion app folder.
- If auto-detection fails, manually choose the folder that contains `VanillaFixes.exe`.

For an add-on-only update, download `SpotiWoW-Dev-Addon-US.zip` from Releases. The US English version displays system messages in English.
