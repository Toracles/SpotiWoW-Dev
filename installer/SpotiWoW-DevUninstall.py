from __future__ import annotations

import ctypes
import json
import os
from pathlib import Path
import subprocess
import sys
import time
import tkinter as tk
from tkinter import messagebox

APP_NAME = "SpotiWoW-Dev"
APP_ROOT = Path(os.environ.get("LOCALAPPDATA", str(Path.home() / "AppData" / "Local"))) / "Programs" / APP_NAME
NO_WINDOW = getattr(subprocess, "CREATE_NO_WINDOW", 0x08000000)


def is_supported_game(path: Path) -> bool:
    return path.is_dir() and any((path / name).is_file() for name in ("WoW.exe", "VanillaFixes.exe"))


def remove_tree(path: Path) -> None:
    try:
        if path.is_dir():
            import shutil
            shutil.rmtree(path)
        elif path.exists():
            path.unlink()
    except OSError:
        pass


def remove_known_file(path: Path) -> None:
    try:
        path.unlink()
    except OSError:
        pass


def main() -> int:
    root = tk.Tk()
    root.withdraw()
    config_path = APP_ROOT / "config.json"
    game_dir = None
    language = "fr"
    try:
        config = json.loads(config_path.read_text(encoding="utf-8"))
        language = str(config.get("language", "fr")).casefold()
        candidate = Path(str(config.get("game_dir", ""))).resolve()
        if is_supported_game(candidate):
            game_dir = candidate
    except (OSError, ValueError, TypeError):
        pass
    is_fr = language.startswith("fr")
    question = "Désinstaller SpotiWoW-Dev ? Cela supprime l’addon, le compagnon, l’autorisation Spotify, le Client ID, les réglages et les caches de ce PC." if is_fr else "Uninstall SpotiWoW-Dev? This removes the add-on, companion, Spotify authorization, Client ID, settings, and caches from this PC."
    if not messagebox.askyesno(APP_NAME, question):
        return 0

    # Stop both the tray launcher and its bridge worker before removing installed files.
    try:
        subprocess.run(["taskkill.exe", "/F", "/IM", "SpotiWoW-Dev.exe"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, creationflags=NO_WINDOW, timeout=10)
    except Exception:
        pass

    if game_dir:
        remove_tree(game_dir / "Interface" / "AddOns" / APP_NAME)
        data_dir = game_dir / "Data" / "Interface" / "AddOns" / APP_NAME
        remove_tree(data_dir)
        legacy_companion = game_dir / "companion"
        remove_tree(legacy_companion)
        imports = game_dir / "imports"
        for name in ("SpotifyNowState.txt", "SpotifyNowCommand.txt", "SpotifyNowUpdate.txt",
                     "SpotifyNowState.txt.tmp", "SpotifyNowCommand.txt.tmp", "SpotifyNowUpdate.txt.tmp"):
            remove_known_file(imports / name)
        account_root = game_dir / "WTF" / "Account"
        if account_root.is_dir():
            for account in account_root.iterdir():
                saved = account / "SavedVariables"
                for name in ("SpotifyNowDB.lua", "SpotifyNowDB.lua.bak"):
                    remove_known_file(saved / name)

    user_profile = Path(os.environ.get("USERPROFILE", str(Path.home())))
    appdata = Path(os.environ.get("APPDATA", str(Path.home() / "AppData" / "Roaming")))
    shortcuts = [
        user_profile / "Desktop" / f"{APP_NAME}.lnk",
        user_profile / "Desktop" / f"{APP_NAME} Uninstall.lnk",
        appdata / "Microsoft" / "Windows" / "Start Menu" / "Programs" / f"{APP_NAME}.lnk",
        appdata / "Microsoft" / "Windows" / "Start Menu" / "Programs" / f"{APP_NAME} Uninstall.lnk",
    ]
    for shortcut in shortcuts:
        remove_known_file(shortcut)

    # The running uninstaller cannot delete its own executable; remove its whole fixed install directory after exit.
    app_root_text = str(APP_ROOT).replace("'", "''")
    script = f"Start-Sleep -Seconds 2; Remove-Item -LiteralPath '{app_root_text}' -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -LiteralPath $PSCommandPath -Force -ErrorAction SilentlyContinue"
    ps_script = Path(os.environ.get("TEMP", str(Path.home() / "AppData" / "Local" / "Temp"))) / f"spotiwow-uninstall-{os.getpid()}.ps1"
    try:
        ps_script.write_text(script, encoding="utf-8")
        subprocess.Popen(["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(ps_script)], stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, creationflags=NO_WINDOW, close_fds=True)
    except Exception:
        # If deferred cleanup cannot start, the user can rerun the uninstaller after closing it.
        messagebox.showwarning(APP_NAME, "The add-on was removed. Close this uninstaller and run it once more to finish removing the companion files.")
        return 1

    done = "SpotiWoW-Dev est désinstallé. L’autorisation Spotify, le Client ID, les caches et les réglages ont été supprimés." if is_fr else "SpotiWoW-Dev has been uninstalled. Spotify authorization, Client ID, caches, and settings were removed."
    messagebox.showinfo(APP_NAME, done)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
