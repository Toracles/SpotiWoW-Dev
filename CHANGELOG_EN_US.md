# Changelog

## v1.4.13
- Fixed FR and US locale loading so `/spn help`, `/spn say`, and other messages display text instead of internal keys.
- Added live-cover support for CustomAssets: 24-bit 128 × 128 TGA artwork rotates through 512 texture paths declared before the client starts.
- The installer enables `customassets.dll` only when the DLL already exists, preserving every other `dlls.txt` entry; release archives include the texture paths under `Data/`.
- Filled the expanded player's right panel with Spotify status, volume controls, and a Lyrics toggle.

## v1.4.12
- Fixed the French locale file: the reserved key `repeat` prevented the locale from loading, causing `/spn help` to show internal keys instead of command descriptions.

## v1.4.11
- Restyled the interface with a dark metallic frame, framed cover art, dark controls, and a neon accent; all four themes retain distinct colors.
- Enlarged the compact player to 300 × 68 px, separated volume, and constrained long titles to prevent overlap.
- Added persistent shuffle, repeat album, and repeat track indicators, including in compact mode.
- Artwork is now generated as RGBA TGA for better compatibility with the 1.12 client.
- Removed the unconfigured SignPath signing step from the GitHub Actions workflow.

## v1.4.10
- Added a settings panel, available from the player or `/spn settings`, to choose a theme and switch between compact and expanded layouts.

## v1.4.9
- Redesigned the WoW mini-player with premium metallic styling and Obsidian, Azerite, Fel, and Bloodmoon themes; accent, border, glow, button, metadata, and progress settings are customizable.
- Added an expanded player with Spotify cover art, album, playback time, shuffle, and repeat; the compact layout retains its 250 × 58 px dimensions at this version.
- Settings persist in WoW SavedVariables, with French and US English localization.
- The companion downloads Spotify covers and converts them to local textures for the add-on.

## v1.4.6
- The bridge checks Spotify every 10 seconds to refresh track metadata.
- Long track titles scroll in the add-on interface so the full title can be read.

## v1.4.5
- When the WoW client closes, the bridge stops and SpotiWoW-Octo also exits the system tray automatically.
- Added a log entry for this automatic shutdown.

## v1.4.4
- Removed the three retired root-level maintainer guides and their obsolete README links. `.gitignore` now prevents them from being reintroduced accidentally.
- Retained the v1.4.3 fix that monitors the actual `WoW.exe` process to stop the bridge after Alt+F4.

## v1.4.3
- Fixed automatic bridge shutdown by monitoring the actual `WoW.exe` client instead of every executable in the game folder.
- Added diagnostic logging for the tracked client PID and session closure.

## v1.4.2
- Fixed the setup installer crash when formatting the completion message: the language selector no longer conflicts with the template’s `{language}` placeholder.

## v1.4.1
- Fixed the GitHub Actions release workflow by passing absolute icon and script paths to PyInstaller.
- Updated GitHub Actions to Node.js 24-compatible versions to address the Node.js 20 deprecation warning.

## v1.4.0
- Added full French (FR) and US English add-on variants.
- Official add-on author: CloudNine_Ex.
- Localized local system messages, help, tooltips, and now-playing announcements.
- Ctrl+Alt+L works without typing a command into the in-game chat. ON/OFF status appears only in the local chat frame.
- The installer lets users choose a language and downloads the matching package.
- Technical identifiers and existing SavedVariables are retained for compatibility.
