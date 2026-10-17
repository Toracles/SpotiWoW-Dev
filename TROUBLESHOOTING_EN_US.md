# Troubleshooting — SpotiWoW-Dev

This guide is for **SpotiWoW-Dev**, the development version of the project for Turtle WoW / OctoWoW.

## The player or companion will not connect

1. Make sure the SpotiWoW-Dev companion is running and Spotify is open with playback active.
2. Check that you are using the WoW 1.12.1 game client and that the selected folder contains `VanillaFixes.exe`.
3. Check that SuperWoW is installed and provides the `ImportFile` and `ExportFile` functions.
4. In game, type `/spn help` to check that the add-on loaded and see the available commands.

## Spotify artwork is missing

Live artwork loading requires `customassets.dll`, enabled in `dlls.txt`.

- Check that the DLL is already installed in your game client. Setup does not provide it; it enables the DLL only when it is present.
- Check the corresponding entry in `dlls.txt`, then restart the game client after any change.
- Make sure the companion and add-on are up to date and point to the same game installation.

Temporary artwork files are not kept in the repository.

## The title, artist, or album does not match Spotify

- First check which track is actually playing in Spotify.
- Give the companion a few seconds to refresh its state, then check the in-game player again.
- If the old information remains, close and restart both the companion and the game client.
- Specify whether the mismatch affects the title, artist, album, duration, or artwork. Titles in different languages should be displayed as Spotify provides them.

## Lyrics or the hotkey is not working

- `Ctrl+Alt+L` toggles Lyrics mode from the companion.
- The ON/OFF status is shown locally to the player; it is not sent to other people in chat.
- Lyrics are sent to the selected channel only when that feature is enabled.

## The add-on or a command is missing

- Check that the `SpotiWoW-Dev` folder is in `Interface/AddOns` for the game client you are using.
- Check that the add-on is enabled on the character selection screen.
- Use the archive for the correct language: FR or US.
- Type `/spn help` to see the command list.

## What to include in a bug report

Include the SpotiWoW-Dev version, whether you use Turtle WoW or OctoWoW, the add-on language, compact or expanded player mode, and the steps to reproduce the problem.

Companion logs are in `logs/bridge.log` and `logs/launcher.log`, in the application folder. Before sharing them, remove any token, secret, authorization code, or account data. Never post a Spotify Client Secret.

To report a bug, use the **Bug report** form in the Issues section of the SpotiWoW-Dev repository.
