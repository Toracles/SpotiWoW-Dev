"""Start the installed Spotify desktop app without invoking an unregistered URI scheme."""
from __future__ import annotations

import os
from pathlib import Path
import shutil
import subprocess
import sys

NO_WINDOW = getattr(subprocess, "CREATE_NO_WINDOW", 0x08000000)


def _installed_executable() -> Path | None:
    local = Path(os.environ.get("LOCALAPPDATA", ""))
    roaming = Path(os.environ.get("APPDATA", ""))
    candidates = [
        roaming / "Spotify" / "Spotify.exe",
        local / "Programs" / "Spotify" / "Spotify.exe",
        Path(os.environ.get("ProgramFiles", r"C:\Program Files")) / "Spotify" / "Spotify.exe",
        Path(os.environ.get("ProgramFiles(x86)", r"C:\Program Files (x86)")) / "Spotify" / "Spotify.exe",
    ]
    try:
        import winreg
        key_path = r"Software\Microsoft\Windows\CurrentVersion\App Paths\Spotify.exe"
        for hive in (winreg.HKEY_CURRENT_USER, winreg.HKEY_LOCAL_MACHINE):
            for view in (0, getattr(winreg, "KEY_WOW64_64KEY", 0), getattr(winreg, "KEY_WOW64_32KEY", 0)):
                try:
                    with winreg.OpenKey(hive, key_path, 0, winreg.KEY_READ | view) as key:
                        value, _ = winreg.QueryValueEx(key, None)
                    if value:
                        candidates.insert(0, Path(str(value).strip('"')))
                except OSError:
                    continue
    except ImportError:
        pass
    located = shutil.which("Spotify.exe")
    if located:
        candidates.insert(0, Path(located))
    seen = set()
    for candidate in candidates:
        try:
            resolved = candidate.expanduser().resolve()
            marker = os.path.normcase(str(resolved))
            if marker not in seen and resolved.is_file():
                return resolved
            seen.add(marker)
        except OSError:
            continue
    return None


def _store_app_id() -> str | None:
    if os.name != "nt":
        return None
    powershell = shutil.which("powershell.exe")
    if not powershell:
        return None
    script = "$app = Get-StartApps | Where-Object { $_.Name -match 'Spotify' } | Select-Object -First 1; if ($app) { $app.AppID }"
    try:
        result = subprocess.run(
            [powershell, "-NoProfile", "-NonInteractive", "-Command", script],
            capture_output=True, text=True, timeout=8, creationflags=NO_WINDOW,
        )
        app_id = (result.stdout or "").strip().splitlines()
        if result.returncode == 0 and app_id and all(ch.isalnum() or ch in "._!+-" for ch in app_id[0]):
            return app_id[0]
    except (OSError, subprocess.SubprocessError):
        pass
    return None


def is_spotify_running() -> bool:
    try:
        import psutil
        for process in psutil.process_iter(["name"]):
            if (process.info.get("name") or "").casefold() == "spotify.exe":
                return True
    except Exception:
        pass
    return False


def launch_spotify() -> bool:
    executable = _installed_executable()
    if executable is not None:
        try:
            subprocess.Popen([str(executable)], close_fds=True)
            return True
        except OSError:
            pass
    app_id = _store_app_id()
    if app_id:
        try:
            subprocess.Popen(["explorer.exe", "shell:AppsFolder\\" + app_id], close_fds=True)
            return True
        except OSError:
            pass
    return False


def ensure_spotify_running() -> bool:
    return True if is_spotify_running() else launch_spotify()


def open_spotify_link(url: str) -> bool:
    """Open Spotify if needed, then hand the Jam invitation URL to the browser."""
    ensure_spotify_running()
    try:
        import webbrowser
        return bool(webbrowser.open(url))
    except Exception:
        return False
