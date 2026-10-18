# Changelog

## v1.6.18
- Replaces the Windows icons for the companion and setup with the new gold-and-ruby emblem.
- Removes unused legacy variant files from the Dev repository and focuses the project on Turtle WoW 1.18.1.
- Automatically detects the game folder through `VanillaFixes.exe` or `WoW.exe`, including common Classic locations; the companion starts `WoW.exe` directly when VanillaFixes is absent.

## v1.6.17
- Speeds up full SpotiWoW-Dev shutdown: the bridge gets a shorter graceful-exit window, followed by faster forced termination if needed.
- Also reduces the delay before the companion closes automatically after the WoW client exits.
- Makes the Player Settings close button clearly visible.

## v1.6.16
- Corrects the vertical alignment of “SpotiWoW” inside the Player Settings header plaque.

## v1.6.15
- Fixes add-on initialization by attaching the Lyrics and Channel tooltips only after their buttons are created, restoring the player and `/spn` commands.

## v1.6.14
- Adds periodic checks for public GitHub releases without an API key; an update is announced only after the setup installer has been published.
- Shows a local WoW chat reminder with the version and release link at every character login.
- Adds direct release access, a manual update check, and a Windows notification when an update is ready.
- Keeps the last known update information if GitHub is temporarily unavailable and retries periodically.

## v1.6.13-alpha
- Fixes an unterminated string in the English theme selector that prevented the add-on Lua, player, and `/spn` commands from loading.
- Aligns the English TOC version with the release.

## v1.6.12-alpha
- Renames the #FFFFFF and #FF4FD8 themes in the player and settings to Silver Dawn and Fang Set.

## v1.6.11-alpha
- Keeps player button borders and neon accents visible while hovering.
- Adds a seek marker that follows the pointer and previews the target time when Click to Seek is enabled.
- Adds explanatory tooltips to settings, HEX fields, and Apply buttons in French and US English.
- Adds the Sunwell (#FFB020), Frostmourne (#FFFFFF), and Dreamweaver (#FF4FD8) themes.

## v1.6.9-alpha
- Centers “SpotiWoW” inside the Player Settings header plaque.

## v1.6.8-alpha
- Adds Shuffle and Repeat buttons to compact mode and slightly widens the player so both remain aligned and visible.
- Keeps mode activity visible in Compact, Square, and Expanded layouts: accent fill for Shuffle and Repeat All, neon outline for Repeat 1.
- Repositions the top accent line at the upper edge and stops it before the top-right buttons in all three layouts, while preserving the bottom progress bar.
- Gives player and settings buttons a consistent charcoal-red hover fill without the red/black gradient.
- Centers the Player Settings header and aligns both hex fields and their Apply buttons within the panel.

## v1.6.7-alpha
- Fixes the Player Settings panel alignment and keeps every option inside its frame.
- Rearranges Square Mode controls so the volume and every button remain visible without overlap.
- Adds “SpotiWoW” to the settings panel header.
- Replaces stretched button textures with a uniform charcoal-red fill that matches the theme.
- Makes Button Accents visible: enabling it colors button labels and borders with the selected neon accent; disabling it restores the gold styling.
- Fixes Accent Hex and Progress Hex, applying the accent color to the player frame and the progress color to segmented bars.
- Adds localized tooltips explaining the color fields, Button Accents, and Click to Seek.
## v1.6.6-alpha
- Aligns Square and Expanded metadata and controls, keeps the status row clear of the divider, and shortens settings labels to prevent clipping.
- Player Settings groups visual customization, custom colors, and lyrics options (toggle and channel), with their current states visible.
- Brings in the metallic frames, dark stone surfaces, and gold titles of classic WoW panels; all four neon themes remain as accents on progress, active controls, and glow details.
- Slightly reduced Square Mode to 236 × 236 px and its artwork to 68 × 68 px while keeping the control row aligned.
- Moved the volume readout to a dedicated row above the controls in Square Mode so it stays visible.
- The top button now cycles Compact → Square → Expanded → Compact.
- The Player Settings panel now exposes all four themes, accent and progress colors, glow, border, button accents, controls, metadata, progress visibility, click-to-seek, and all three progress styles.
- Changes persist in the existing saved settings; advanced options remain available through `/spn` commands as well.

## v1.6.5-alpha
- Setup is now pinned to the exact release tag and commit SHA that produced it, so it cannot silently switch to a different published version.
- The workflow embeds the same provenance manifest in setup and both portable bundles. Before extraction, setup verifies the GitHub tag target, commit SHA, ZIP manifest, and GitHub-published SHA-256 asset digest.
- French and US English installers use the same checks. If the release or package manifest does not match, installation stops before modifying game files.

## v1.6.4-alpha
- Reworked the player around a cleaner charcoal surface with the Obsidian, Azerite, Fel, and Bloodmoon neon accents preserved.
- Added a dedicated square layout with cover art, title, artist, album, progress, elapsed time, and the full control set.
- Reorganized compact mode while keeping its 300 × 68 px dimensions; artwork and controls now occupy separate areas.
- Refined the expanded 460 × 164 px control layout without adding background polling or artwork work.
- Added a layout selector in /spn settings and /spn mode compact|square|expanded. /spn expand and legacy saved settings remain compatible.
- Made scrolling titles UTF-8 character-aware so multilingual names are not split mid-character.
- Preserved existing settings, commands, live artwork, shortcuts, shuffle/repeat indicators, and clickable progress seeking.

## v1.4.15
- The bridge keeps polling when Windows cannot encode a track name; metadata transport remains UTF-8.
- Ctrl+Alt+S triggers an immediate Spotify scan; stale metadata is cleared when playback stops.

## v1.4.14
- Reduced compact-mode artwork so it stays clear of the control row.

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
- When the WoW client closes, the bridge stops and SpotiWoW-Dev also exits the system tray automatically.
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

