# SpotiWoW-Dev v1.7.2 — US English

> **Development version** — this version is still evolving and may include experimental changes. It is intended for testing; bugs or behavior changes may occur.

SpotiWoW-Dev connects Spotify to Turtle WoW through the SuperWoW file bridge. This package uses the US English interface and in-game messages.

## Easy installation
1. Download the versioned `SpotiWoW-Dev-Setup-v<version>.exe` asset from the **Releases** page of the official GitHub repository.
2. Close Turtle WoW before installing.
3. Select English (US) in the installer and choose the client folder. Enter your Client ID on the first installation; future setup runs prefill it from the local configuration. Spotify will still request authorization on the companion’s first launch.
4. In your Spotify Developer app settings, add the exact Redirect URI `http://127.0.0.1:8888/callback`.
5. Finish the setup and launch **SpotiWoW-Dev** from the shortcut.

The Render URL is optional for Chat transport. To use Render or Jam invites, deploy the repository service from render.yaml, then enter its HTTPS URL in setup. All participants must use the same URL.

Setup is pinned to its specific GitHub release. Before installing, it verifies the tag, source commit SHA, package manifest, and GitHub-published SHA-256 digest.

The installer never asks for a Client Secret and does not download Turtle WoW, VanillaFixes, SuperWoW, SuperAPI, or their DLLs.

## Requirements
- A Spotify Premium account is required for every SpotiWoW user.
- Turtle WoW client based on WoW 1.12.1; setup detects it through `VanillaFixes.exe` or `WoW.exe`.
- SuperWoW with the `ImportFile` and `ExportFile` functions.
- `VanillaFixes.exe` or `WoW.exe` in the client folder; the companion prefers VanillaFixes and launches `WoW.exe` directly when needed.
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
- Existing Chat lyrics transport or optional Render relay, with local status and no automatic fallback.
- Windows notification-area launcher with no visible CMD console. The launcher also starts Spotify if it is closed.
- Keeps the bridge running until all WoW clients are closed; relaunch the shortcut to open another client without starting another Spotify bridge.
- Checks published GitHub releases without an API key and announces an update only when its installer is available. The add-on shows a local chat reminder at every login; the Windows notification-area menu displays the version and opens its release page.

Chat transport keeps the current behavior and never uses Render. Render transport, enabled in settings, relays lyrics in real time and displays them in each player’s local chat; it never falls back to a WoW channel. All Render users must use the same service URL in setup. On Render Free, the service spins down after 15 minutes without traffic. Its next cold start takes about one minute; lyric delivery then adds network latency. The relay forwards lyrics in memory and does not save them to disk.

To invite your group to a Spotify Jam, start the Jam in Spotify and enter /spn jam followed by its Spotify link while in a party or raid. Other players must configure the same relay and select Render transport; they can accept or decline in an in-game popup. Accepting opens the Spotify link. Spotify does not provide a public API to create a Jam.

Setup clears the lyrics cache and cover art on every install while preserving the Spotify session when you choose to keep it. Windows DPAPI protects the OAuth token. An uninstall shortcut removes the add-on, companion, caches, and local Spotify data. Historical identifiers SpotifyNowDB, SpotifyNowState.txt, and SpotifyNowCommand.txt remain for compatibility.

## Troubleshooting
- See the [US English troubleshooting guide](TROUBLESHOOTING_EN_US.md) for connection, artwork, metadata, lyrics, and command issues.
- Logs: `logs/bridge.log` and `logs/launcher.log` in the companion app folder.
- If auto-detection fails, manually choose the folder that contains `VanillaFixes.exe` or `WoW.exe`.

For an add-on-only update, download `SpotiWoW-Dev-Addon-US.zip` from Releases. The US English version displays system messages in English.
