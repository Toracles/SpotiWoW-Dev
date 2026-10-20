from __future__ import annotations

"""Windows setup wizard for SpotiWoW-Dev.

The installer downloads the portable bundle for its own GitHub release, verifies
the release tag, commit SHA, package manifest, and GitHub asset digest, then installs
only the addon/companion (never the Turtle WoW client or third-party DLLs).
"""

import hashlib
import locale
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import threading
import urllib.error
import urllib.parse
import urllib.request
import zipfile

import tkinter as tk
from tkinter import filedialog, messagebox, ttk

APP_NAME = "SpotiWoW-Dev"
PORTABLE_ASSET_NAMES = {"fr": "SpotiWoW-Dev-Portable-FR.zip", "us": "SpotiWoW-Dev-Portable-US.zip"}
VANILLAFIXES_NAME = "VanillaFixes.exe"
GAME_EXECUTABLE_NAMES = (VANILLAFIXES_NAME, "WoW.exe")
LAUNCHER_NAME = "SpotiWoW-Dev.exe"
UNINSTALLER_NAME = "SpotiWoW-Dev-Uninstall.exe"
ADDON_NAME = "SpotiWoW-Dev"
NO_WINDOW = getattr(subprocess, "CREATE_NO_WINDOW", 0x08000000)

DEFAULT_CONFIG = {
    "client_id": "",
    "game_dir": "",
    "render_url": "",
    "reauthorize_on_next_start": False,
    "language": "fr",
    "lyrics_offset_ms": 0,
    "lyrics_providers": ["Musixmatch", "Lrclib", "NetEase", "Megalobiz"],
    "lyrics_search_timeout_seconds": 18,
    "lyrics_cache_days": 90,
    "lyrics_negative_cache_hours": 6,
}


TEXT = {
    "fr": {
        "window_title": "SpotiWoW-Dev — Installation",
        "language_label": "Langue de l’addon / Add-on language",
        "intro": "Ferme Turtle WoW avant l’installation. L’assistant installe l’addon et le compagnon ; si customassets.dll est déjà présent, il l’active pour les jaquettes Spotify dynamiques.",
        "game_dir_label": "Dossier du client WoW (VanillaFixes.exe ou WoW.exe)",
        "browse": "Parcourir…",
        "detect_fail": "Détection automatique non concluante : sélectionne le dossier contenant VanillaFixes.exe ou WoW.exe.",
        "render_url_label": "URL du relais Render (facultatif)",
        "render_url_help": "À renseigner après avoir créé le service Render. Laisse vide pour garder le mode Chat actuel.",
        "replace_token_prompt": "Une autorisation Spotify est déjà enregistrée sur ce PC. Veux-tu changer de compte Spotify ? Oui ouvrira Spotify pour une nouvelle autorisation au prochain démarrage. Non conserve la session actuelle.",
        "invalid_render_url": "L’URL Render doit commencer par https://, ou rester vide.",
        "client_id_label": "Spotify Client ID",
        "client_id_help": "Le Client ID enregistré sur ce PC est prérempli. Le texte est masqué à l’écran, mais ce Client ID n’est pas un mot de passe. Spotify demandera toujours l’autorisation au premier lancement du compagnon. N’entre pas de Client Secret.",
        "show_client_id": "Afficher",
        "hide_client_id": "Masquer",
        "shortcuts": "Créer un raccourci sur le bureau et dans le menu Démarrer",
        "ready": "Prêt à installer.",
        "install": "Installer",
        "cancel": "Annuler",
        "choose_dir": "Choisir le dossier du client WoW",
        "invalid_game": "Ce dossier ne semble pas contenir le client attendu.\n\nNi VanillaFixes.exe ni WoW.exe n’a été trouvé dans :\n{path}",
        "invalid_id": "Le Client ID semble vide ou invalide. Copie le Client ID depuis ton application Spotify Developer.",
        "repo_missing": "Cet installateur n’est pas encore relié au dépôt GitHub du projet.\n\nLe mainteneur doit configurer le dépôt puis publier une Release.",
        "status_release": "Vérification de la version liée à cet installateur…",
        "status_download": "Téléchargement de {tag}…",
        "status_verify": "Vérification du paquet et de son commit GitHub…",
        "status_addon": "Installation de l’addon dans le client WoW…",
        "status_companion": "Installation du compagnon et configuration Spotify…",
        "status_shortcuts": "Création des raccourcis Windows…",
        "unsafe_zip": "Le paquet téléchargé contient un chemin ZIP non sûr.",
        "asset_missing": "La release liée à cet installateur ne contient pas {asset}. Vérifie que le workflow de publication a terminé.",
        "bad_hash": "La vérification SHA-256 a échoué. Aucun fichier n’a été installé.",
        "bad_manifest": "Le paquet ne correspond pas au commit GitHub attendu. Aucun fichier n’a été installé.",
        "manifest_missing": "La version de cet installateur est introuvable. Télécharge-le depuis la page Releases du dépôt.",
        "incomplete": "Le paquet est incomplet : addon, lanceur, bridge ou icône manquant.",
        "done_title": "Installation terminée",
        "done_message": "Installation terminée !\n\nAddon : {addon}\nCompagnon : {companion}\nLangue : {language}\n\nRelance le client WoW avant de tester les jaquettes. Le premier lancement du compagnon peut ouvrir le navigateur pour autoriser Spotify.",
        "http_error": "GitHub a répondu HTTP {code}. Vérifie que le dépôt est public et qu’une Release est publiée.",
        "failed": "L’installation a échoué :\n\n{error}",
        "busy_close": "L’installation est en cours. Attends sa fin avant de fermer cette fenêtre.",
        "interrupted": "Installation interrompue.",
    },
    "us": {
        "window_title": "SpotiWoW-Dev — Setup",
        "language_label": "Add-on language / Langue de l’addon",
        "intro": "Close Turtle WoW before installing. Setup installs the add-on and companion; if customassets.dll is already present, it enables it for live Spotify cover art.",
        "game_dir_label": "WoW client folder (VanillaFixes.exe or WoW.exe)",
        "browse": "Browse…",
        "detect_fail": "Automatic detection did not find the client. Select the folder containing VanillaFixes.exe or WoW.exe.",
        "render_url_label": "Render relay URL (optional)",
        "render_url_help": "Enter this after creating your Render service. Leave blank to keep using Chat mode.",
        "replace_token_prompt": "A Spotify authorization is already saved on this PC. Change Spotify accounts? Yes will open Spotify authorization next time the companion starts. No keeps the current session.",
        "invalid_render_url": "The Render URL must start with https://, or be left blank.",
        "client_id_label": "Spotify Client ID",
        "client_id_help": "The Client ID saved on this PC is prefilled. It is hidden on screen, but a Client ID is not a password. Spotify will still ask you to authorize the companion on first launch. Do not enter a Client Secret.",
        "show_client_id": "Show",
        "hide_client_id": "Hide",
        "shortcuts": "Create a desktop and Start Menu shortcut",
        "ready": "Ready to install.",
        "install": "Install",
        "cancel": "Cancel",
        "choose_dir": "Choose the WoW client folder",
        "invalid_game": "This folder does not appear to contain the expected client.\n\nNeither VanillaFixes.exe nor WoW.exe was found in:\n{path}",
        "invalid_id": "The Client ID looks empty or invalid. Copy the Client ID from your Spotify Developer app.",
        "repo_missing": "This setup has not been connected to the project's GitHub repository yet.\n\nThe maintainer must configure the repository and publish a Release.",
        "status_release": "Checking the release linked to this setup…",
        "status_download": "Downloading {tag}…",
        "status_verify": "Verifying the package and its GitHub commit…",
        "status_addon": "Installing the add-on into the WoW client…",
        "status_companion": "Installing the companion and configuring Spotify…",
        "status_shortcuts": "Creating Windows shortcuts…",
        "unsafe_zip": "The downloaded package contains an unsafe ZIP path.",
        "asset_missing": "The release linked to this setup does not contain {asset}. Make sure the release workflow completed.",
        "bad_hash": "SHA-256 verification failed. No files were installed.",
        "bad_manifest": "The package does not match the expected GitHub commit. No files were installed.",
        "manifest_missing": "This setup's release information is missing. Download setup from the repository Releases page.",
        "incomplete": "The package is incomplete: add-on, launcher, bridge, or icon is missing.",
        "done_title": "Installation complete",
        "done_message": "Installation complete!\n\nAdd-on: {addon}\nCompanion: {companion}\nLanguage: {language}\n\nRestart the WoW client before testing cover art. The companion's first launch may open a browser to authorize Spotify.",
        "http_error": "GitHub returned HTTP {code}. Check that the repository is public and a Release has been published.",
        "failed": "Installation failed:\n\n{error}",
        "busy_close": "Installation is in progress. Wait for it to finish before closing this window.",
        "interrupted": "Installation interrupted.",
    },
}


def t(lang_code: str, key: str, **kwargs) -> str:
    """Translate a UI string; keep lang_code distinct from template placeholders.

    Some templates legitimately use a {language} placeholder, so the selector
    parameter must not itself be named `language`.
    """
    template = TEXT.get(lang_code, TEXT["fr"]).get(key, key)
    return template.format(**kwargs) if kwargs else template


def resource_dir() -> Path:
    if getattr(sys, "frozen", False) and hasattr(sys, "_MEIPASS"):
        return Path(sys._MEIPASS)
    return Path(__file__).resolve().parent


def read_release_manifest() -> dict[str, str]:
    """Read the tag and commit this setup was built for."""
    path = resource_dir() / "release-manifest.json"
    try:
        manifest = json.loads(path.read_text(encoding="utf-8-sig"))
    except (OSError, ValueError) as exc:
        raise RuntimeError("release-manifest.json is missing or invalid") from exc
    tag = manifest.get("tag") if isinstance(manifest, dict) else None
    commit_sha = manifest.get("commit_sha") if isinstance(manifest, dict) else None
    if not isinstance(tag, str) or not re.fullmatch(r"v[0-9]+\.[0-9]+\.[0-9]+(?:-[A-Za-z0-9.-]+)?", tag):
        raise RuntimeError("release tag in manifest is invalid")
    if not isinstance(commit_sha, str) or not re.fullmatch(r"[0-9a-fA-F]{40}", commit_sha):
        raise RuntimeError("release commit in manifest is invalid")
    return {"tag": tag, "commit_sha": commit_sha.lower()}


def verify_bundle_manifest(bundle: Path, expected: dict[str, str]) -> None:
    """Require the downloaded portable archive to declare this setup's exact release commit."""
    manifest_path = "companion/release-manifest.json"
    try:
        with zipfile.ZipFile(bundle, "r") as archive:
            payload = json.loads(archive.read(manifest_path).decode("utf-8-sig"))
    except (OSError, KeyError, ValueError, zipfile.BadZipFile) as exc:
        raise RuntimeError("portable release manifest is missing or invalid") from exc
    actual_tag = payload.get("tag") if isinstance(payload, dict) else None
    actual_sha = payload.get("commit_sha") if isinstance(payload, dict) else None
    if actual_tag != expected["tag"] or not isinstance(actual_sha, str) or actual_sha.lower() != expected["commit_sha"]:
        raise RuntimeError("portable package does not match the setup release commit")


def read_repository_slug() -> str:
    for candidate in (resource_dir() / "repo.txt", Path(__file__).resolve().parent / "repo.txt"):
        try:
            value = candidate.read_text(encoding="utf-8").strip()
            if value and re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", value):
                return value
        except OSError:
            continue
    env_value = os.environ.get("SPOTIWOW_GITHUB_REPO", "").strip()
    if re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", env_value):
        return env_value
    return ""


def is_game_dir(path: Path) -> bool:
    return path.is_dir() and any((path / name).is_file() for name in GAME_EXECUTABLE_NAMES)


def game_candidates() -> list[Path]:
    # Standard Blizzard Classic folders are candidates, but they are only accepted
    # when they contain a supported Turtle WoW executable.
    raw = [
        r"C:\Program Files (x86)\World of Warcraft\_classic_era_",
        r"C:\Program Files\World of Warcraft\_classic_era_",
        r"C:\Program Files (x86)\World of Warcraft\_classic_",
        r"C:\Program Files\World of Warcraft\_classic_",
        r"C:\Games\Turtle WoW",
        r"C:\Games\TurtleWoW",
        r"C:\Turtle WoW",
        r"C:\TurtleWoW",
        r"C:\Jeux\TurtleWoW",
        str(Path.home() / "Games" / "Turtle WoW"),
        str(Path.home() / "Games" / "TurtleWoW"),
    ]
    scan_roots = [Path(r"C:\Games"), Path(r"C:\Jeux"), Path(r"C:\Turtle WoW"), Path(r"C:\TurtleWoW")]
    for env_name in ("PROGRAMFILES", "PROGRAMFILES(X86)"):
        base_value = os.environ.get(env_name)
        if base_value:
            base = Path(base_value)
            raw.extend((
                str(base / "World of Warcraft" / "_classic_era_"),
                str(base / "World of Warcraft" / "_classic_"),
                str(base / "Turtle WoW"),
                str(base / "TurtleWoW"),
            ))
            scan_roots.append(base)
    for root in scan_roots:
        try:
            raw.extend(str(child) for child in root.iterdir() if child.is_dir())
        except OSError:
            continue

    result: list[Path] = []
    seen: set[str] = set()
    for item in raw:
        path = Path(item).expanduser()
        key = os.path.normcase(str(path))
        if key not in seen and is_game_dir(path):
            result.append(path.resolve())
            seen.add(key)
    return result


def saved_client_id(game_dir: Path | None = None) -> str:
    """Load this user's saved Client ID so setup upgrades do not ask for it again."""
    local_app_data = Path(os.environ.get("LOCALAPPDATA") or (Path.home() / "AppData" / "Local"))
    candidates = [local_app_data / "Programs" / APP_NAME / "config.json"]
    if game_dir is not None:
        candidates.append(game_dir / "companion" / "config.json")
    for path in candidates:
        try:
            config = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, ValueError):
            continue
        client_id = config.get("client_id") if isinstance(config, dict) else None
        if isinstance(client_id, str):
            client_id = client_id.strip()
            if len(client_id) >= 10 and not any(ch.isspace() for ch in client_id):
                return client_id
    return ""

def saved_config_value(key: str, game_dir: Path | None = None) -> str:
    local_app_data = Path(os.environ.get("LOCALAPPDATA") or (Path.home() / "AppData" / "Local"))
    candidates = [local_app_data / "Programs" / APP_NAME / "config.json"]
    if game_dir is not None:
        candidates.append(game_dir / "companion" / "config.json")
    for path in candidates:
        try:
            value = json.loads(path.read_text(encoding="utf-8")).get(key, "")
        except (OSError, ValueError, AttributeError):
            continue
        if isinstance(value, str):
            return value.strip()
    return ""


def safe_extract(bundle: Path, destination: Path) -> None:
    root = destination.resolve()
    with zipfile.ZipFile(bundle, "r") as archive:
        for member in archive.infolist():
            target = (destination / member.filename).resolve()
            try:
                target.relative_to(root)
            except ValueError as exc:
                raise RuntimeError("Unsafe ZIP path in downloaded package / chemin ZIP non sûr dans le paquet téléchargé.") from exc
        archive.extractall(destination)


def enable_custom_assets(game_dir: Path) -> bool:
    """Enable the already-installed loose asset loader without changing other DLL entries."""
    if not (game_dir / "customassets.dll").is_file():
        return False
    dll_list = game_dir / "dlls.txt"
    try:
        contents = dll_list.read_text(encoding="utf-8", errors="replace") if dll_list.is_file() else ""
    except OSError:
        return False
    if any(line.strip().casefold() == "customassets.dll" for line in contents.splitlines()):
        return True
    newline = "\r\n" if "\r\n" in contents else "\n"
    if contents and not contents.endswith(("\n", "\r")):
        contents += newline
    try:
        dll_list.write_text(contents + "customassets.dll" + newline, encoding="utf-8", newline="")
        return True
    except OSError:
        return False


def powershell_quote(value: str) -> str:
    return value.replace("'", "''")


def create_shortcut(shortcut_path: Path, target_path: Path, working_dir: Path, icon_path: Path) -> None:
    shortcut_path.parent.mkdir(parents=True, exist_ok=True)
    script = (
        "$shell = New-Object -ComObject WScript.Shell; "
        f"$s = $shell.CreateShortcut('{powershell_quote(str(shortcut_path))}'); "
        f"$s.TargetPath = '{powershell_quote(str(target_path))}'; "
        f"$s.WorkingDirectory = '{powershell_quote(str(working_dir))}'; "
        f"$s.IconLocation = '{powershell_quote(str(icon_path))}'; "
        "$s.Save()"
    )
    subprocess.run(
        ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", script],
        check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE,
        creationflags=NO_WINDOW,
    )


class SetupApp:
    def __init__(self) -> None:
        self.root = tk.Tk()
        try:
            os_locale = locale.getlocale()[0] or ""
        except Exception:
            os_locale = ""
        self.language_code = "fr" if os_locale.casefold().startswith("fr") else "us"
        self.root.title(t(self.language_code, "window_title"))
        self.root.geometry("700x615")
        self.root.minsize(660, 580)
        self.root.resizable(True, True)
        self.root.protocol("WM_DELETE_WINDOW", self.close)
        icon = resource_dir() / "SpotiWoW-Dev-Ruby.ico"
        if icon.is_file():
            try:
                self.root.iconbitmap(str(icon))
            except tk.TclError:
                pass

        self.game_dir_var = tk.StringVar()
        detected = game_candidates()
        if detected:
            self.game_dir_var.set(str(detected[0]))
        self.client_id_var = tk.StringVar(value=saved_client_id(detected[0] if detected else None))
        self.render_url_var = tk.StringVar(value=saved_config_value("render_url", detected[0] if detected else None))
        self.client_id_visible = False
        self.language_var = tk.StringVar(value="Français (FR)" if self.language_code == "fr" else "English (US)")
        self.create_shortcut_var = tk.BooleanVar(value=True)
        self.status_var = tk.StringVar(value=t(self.language_code, "ready"))
        self.busy = False

        main = ttk.Frame(self.root, padding=18)
        main.pack(fill="both", expand=True)
        ttk.Label(main, text="SpotiWoW-Dev", font=("Segoe UI", 18, "bold")).pack(anchor="w")
        self.intro_label = ttk.Label(main, wraplength=650)
        self.intro_label.pack(anchor="w", pady=(4, 12))

        language_row = ttk.Frame(main)
        language_row.pack(fill="x", pady=(0, 10))
        self.language_label = ttk.Label(language_row)
        self.language_label.pack(side="left")
        self.language_combo = ttk.Combobox(
            language_row, textvariable=self.language_var, state="readonly",
            values=("Français (FR)", "English (US)"), width=18,
        )
        self.language_combo.pack(side="left", padx=(8, 0))
        self.language_combo.bind("<<ComboboxSelected>>", self._on_language_change)

        self.game_dir_label = ttk.Label(main, font=("Segoe UI", 10, "bold"))
        self.game_dir_label.pack(anchor="w")
        path_row = ttk.Frame(main)
        path_row.pack(fill="x", pady=(5, 12))
        ttk.Entry(path_row, textvariable=self.game_dir_var).pack(side="left", fill="x", expand=True)
        self.browse_button = ttk.Button(path_row, command=self.browse)
        self.browse_button.pack(side="left", padx=(8, 0))
        self.detect_label = ttk.Label(main, wraplength=650)
        if not detected:
            self.detect_label.pack(anchor="w", pady=( -8, 10))

        self.client_id_label = ttk.Label(main, font=("Segoe UI", 10, "bold"))
        self.client_id_label.pack(anchor="w")
        client_id_row = ttk.Frame(main)
        client_id_row.pack(fill="x", pady=(5, 4))
        self.client_id_entry = ttk.Entry(client_id_row, textvariable=self.client_id_var, show="*")
        self.client_id_entry.pack(side="left", fill="x", expand=True)
        self.client_id_visibility_button = ttk.Button(client_id_row, command=self.toggle_client_id_visibility)
        self.client_id_visibility_button.pack(side="left", padx=(8, 0))
        self.client_id_help = ttk.Label(main, wraplength=650, justify="left")
        self.client_id_help.pack(anchor="w", pady=(0, 10))
        self.render_url_label = ttk.Label(main, font=("Segoe UI", 10, "bold"))
        self.render_url_label.pack(anchor="w")
        self.render_url_entry = ttk.Entry(main, textvariable=self.render_url_var)
        self.render_url_entry.pack(fill="x", pady=(5, 3))
        self.render_url_help = ttk.Label(main, wraplength=650, justify="left")
        self.render_url_help.pack(anchor="w", pady=(0, 10))

        self.shortcut_check = ttk.Checkbutton(main, variable=self.create_shortcut_var)
        self.shortcut_check.pack(anchor="w", pady=(0, 10))
        self.progress = ttk.Progressbar(main, mode="indeterminate")
        self.progress.pack(fill="x", pady=(0, 7))
        ttk.Label(main, textvariable=self.status_var, wraplength=650).pack(anchor="w")

        buttons = ttk.Frame(main)
        buttons.pack(fill="x", side="bottom", pady=(16, 0))
        self.install_button = ttk.Button(buttons, command=self.install)
        self.install_button.pack(side="right")
        self.cancel_button = ttk.Button(buttons, command=self.close)
        self.cancel_button.pack(side="right", padx=(0, 8))
        self._apply_language()

    def _on_language_change(self, _event=None) -> None:
        self.language_code = "fr" if self.language_var.get().startswith("Français") else "us"
        self._apply_language()

    def _apply_language(self) -> None:
        lang = self.language_code
        self.root.title(t(lang, "window_title"))
        self.intro_label.configure(text=t(lang, "intro"))
        self.language_label.configure(text=t(lang, "language_label"))
        self.game_dir_label.configure(text=t(lang, "game_dir_label"))
        self.browse_button.configure(text=t(lang, "browse"))
        self.detect_label.configure(text=t(lang, "detect_fail"))
        self.client_id_label.configure(text=t(lang, "client_id_label"))
        self.client_id_help.configure(text=t(lang, "client_id_help"))
        self.render_url_label.configure(text=t(lang, "render_url_label"))
        self.render_url_help.configure(text=t(lang, "render_url_help"))
        self.client_id_visibility_button.configure(
            text=t(lang, "hide_client_id" if self.client_id_visible else "show_client_id")
        )
        self.shortcut_check.configure(text=t(lang, "shortcuts"))
        self.install_button.configure(text=t(lang, "install"))
        self.cancel_button.configure(text=t(lang, "cancel"))
        if not self.busy:
            self.status_var.set(t(lang, "ready"))

    def _t(self, key: str, **kwargs) -> str:
        return t(self.language_code, key, **kwargs)

    def toggle_client_id_visibility(self) -> None:
        self.client_id_visible = not self.client_id_visible
        self.client_id_entry.configure(show="" if self.client_id_visible else "*")
        self.client_id_visibility_button.configure(
            text=self._t("hide_client_id" if self.client_id_visible else "show_client_id")
        )

    def browse(self) -> None:
        start = self.game_dir_var.get().strip() or str(Path.home())
        selected = filedialog.askdirectory(parent=self.root, title=self._t("choose_dir"), initialdir=start)
        if selected:
            self.game_dir_var.set(selected)

    def set_status(self, text: str) -> None:
        self.root.after(0, lambda: self.status_var.set(text))

    def install(self) -> None:
        if self.busy:
            return
        game_dir = Path(self.game_dir_var.get().strip().strip('"')).expanduser()
        client_id = self.client_id_var.get().strip()
        render_url = self.render_url_var.get().strip().rstrip("/")
        if render_url and not re.fullmatch(r"https://[A-Za-z0-9.-]+(?::\d+)?", render_url):
            messagebox.showerror(APP_NAME, self._t("invalid_render_url"), parent=self.root)
            return
        if not is_game_dir(game_dir):
            messagebox.showerror(APP_NAME, self._t("invalid_game", path=game_dir), parent=self.root)
            return
        if len(client_id) < 10 or any(ch.isspace() for ch in client_id):
            messagebox.showerror(APP_NAME, self._t("invalid_id"), parent=self.root)
            return
        repo = read_repository_slug()
        if not repo:
            messagebox.showerror(
                APP_NAME,
                self._t("repo_missing"),
                parent=self.root,
            )
            return

        app_root = Path(os.environ.get("LOCALAPPDATA", str(Path.home() / "AppData" / "Local"))) / "Programs" / APP_NAME
        has_saved_session = (app_root / "spotify_session.dat").is_file() or (app_root / "tokens.json").is_file() or (game_dir / "companion" / "tokens.json").is_file()
        replace_token = bool(has_saved_session and messagebox.askyesno(APP_NAME, self._t("replace_token_prompt"), parent=self.root))
        create_shortcuts = bool(self.create_shortcut_var.get())
        self.busy = True
        self.install_button.configure(state="disabled")
        self.language_combo.configure(state="disabled")
        self.cancel_button.configure(state="disabled")
        self.progress.start(12)
        language = self.language_code
        threading.Thread(
            target=self._install_worker,
            args=(repo, game_dir.resolve(), client_id, render_url, replace_token, create_shortcuts, language),
            daemon=True,
        ).start()

    def _install_worker(self, repo: str, game_dir: Path, client_id: str, render_url: str, replace_token: bool, create_shortcuts: bool, language: str) -> None:
        asset_name = PORTABLE_ASSET_NAMES[language]
        language_label = "Français (FR)" if language == "fr" else "English (US)"
        try:
            self.set_status(t(language, "status_release"))
            try:
                expected = read_release_manifest()
            except RuntimeError as exc:
                raise RuntimeError(t(language, "manifest_missing")) from exc
            headers = {
                "Accept": "application/vnd.github+json",
                "User-Agent": "SpotiWoW-Dev-Setup",
                "X-GitHub-Api-Version": "2022-11-28",
            }
            tag_path = urllib.parse.quote(expected["tag"], safe="")
            request = urllib.request.Request(
                f"https://api.github.com/repos/{repo}/releases/tags/{tag_path}", headers=headers,
            )
            with urllib.request.urlopen(request, timeout=30) as response:
                release = json.loads(response.read().decode("utf-8"))
            if release.get("draft") or release.get("tag_name") != expected["tag"]:
                raise RuntimeError(t(language, "bad_manifest"))
            commit_request = urllib.request.Request(
                f"https://api.github.com/repos/{repo}/commits/{tag_path}", headers=headers,
            )
            with urllib.request.urlopen(commit_request, timeout=30) as response:
                remote_commit = json.loads(response.read().decode("utf-8")).get("sha", "")
            if not isinstance(remote_commit, str) or remote_commit.casefold() != expected["commit_sha"]:
                raise RuntimeError(t(language, "bad_manifest"))
            asset = next((a for a in release.get("assets", []) if a.get("name") == asset_name), None)
            if not asset or not asset.get("browser_download_url"):
                raise RuntimeError(t(language, "asset_missing", asset=asset_name))

            with tempfile.TemporaryDirectory(prefix="spotiwow_setup_") as temp_name:
                temp = Path(temp_name)
                bundle = temp / asset_name
                self.set_status(t(language, "status_download", tag=release.get('tag_name', 'latest release')))
                download_request = urllib.request.Request(
                    asset["browser_download_url"],
                    headers={"User-Agent": "SpotiWoW-Dev-Setup", "Accept": "application/octet-stream"},
                )
                digest = hashlib.sha256()
                with urllib.request.urlopen(download_request, timeout=60) as response, bundle.open("wb") as out:
                    while True:
                        chunk = response.read(1024 * 1024)
                        if not chunk:
                            break
                        out.write(chunk)
                        digest.update(chunk)
                remote_digest = str(asset.get("digest") or "")
                if not re.fullmatch(r"sha256:[0-9a-fA-F]{64}", remote_digest):
                    raise RuntimeError(t(language, "bad_hash"))
                if digest.hexdigest().casefold() != remote_digest.split(":", 1)[1].casefold():
                    raise RuntimeError(t(language, "bad_hash"))

                self.set_status(t(language, "status_verify"))
                try:
                    verify_bundle_manifest(bundle, expected)
                except RuntimeError as exc:
                    raise RuntimeError(t(language, "bad_manifest")) from exc
                extracted = temp / "extracted"
                extracted.mkdir()
                safe_extract(bundle, extracted)
                addon_src = extracted / "Interface" / "AddOns" / ADDON_NAME
                companion_src = extracted / "companion"
                launcher_src = companion_src / LAUNCHER_NAME
                bridge_src = companion_src / "spotify_bridge.py"
                icon_src = companion_src / "SpotiWoW-Dev-Ruby.ico"
                uninstall_src = companion_src / UNINSTALLER_NAME
                if not addon_src.is_dir() or not launcher_src.is_file() or not bridge_src.is_file() or not icon_src.is_file() or not uninstall_src.is_file():
                    raise RuntimeError(t(language, "incomplete"))

                self.set_status(t(language, "status_addon"))
                addon_dest = game_dir / "Interface" / "AddOns" / ADDON_NAME
                addon_dest.parent.mkdir(parents=True, exist_ok=True)
                if addon_dest.exists():
                    shutil.rmtree(addon_dest)
                shutil.copytree(addon_src, addon_dest)
                data_src = extracted / "Data" / "Interface" / "AddOns" / ADDON_NAME
                data_dest = game_dir / "Data" / "Interface" / "AddOns" / ADDON_NAME
                for artwork_dir in (addon_dest, data_dest):
                    if artwork_dir.is_dir():
                        for old_art in artwork_dir.glob("artwork_slot_*.tga*"):
                            try:
                                old_art.unlink()
                            except OSError:
                                pass
                if data_src.is_dir():
                    data_dest.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copytree(data_src, data_dest, dirs_exist_ok=True)
                enable_custom_assets(game_dir)
                (game_dir / "imports").mkdir(parents=True, exist_ok=True)

                app_root = Path(os.environ.get("LOCALAPPDATA", str(Path.home() / "AppData" / "Local"))) / "Programs" / APP_NAME
                app_root.mkdir(parents=True, exist_ok=True)
                self.set_status(t(language, "status_companion"))
                for src in companion_src.iterdir():
                    if src.is_file() and src.name not in {"config.json", "tokens.json", "lyrics_cache.json"}:
                        shutil.copy2(src, app_root / src.name)

                config_path = app_root / "config.json"
                config = dict(DEFAULT_CONFIG)
                legacy_companion = game_dir / "companion"
                legacy_config = legacy_companion / "config.json"
                if not config_path.is_file() and legacy_config.is_file():
                    try:
                        old = json.loads(legacy_config.read_text(encoding="utf-8"))
                        if isinstance(old, dict):
                            config.update(old)
                    except (OSError, ValueError):
                        pass
                if config_path.is_file():
                    try:
                        old = json.loads(config_path.read_text(encoding="utf-8"))
                        if isinstance(old, dict):
                            config.update(old)
                    except (OSError, ValueError):
                        pass
                # Preserve an older install's OAuth session/cache if the user is migrating
                # from <game_dir>\companion to the per-user application directory.
                legacy_token = legacy_companion / "tokens.json"
                target_token = app_root / "tokens.json"
                if not target_token.exists() and legacy_token.is_file():
                    shutil.copy2(legacy_token, target_token)
                for cache_file in (app_root / "lyrics_cache.json", legacy_companion / "lyrics_cache.json"):
                    try:
                        cache_file.unlink()
                    except FileNotFoundError:
                        pass
                config["client_id"] = client_id
                config["language"] = language
                config["game_dir"] = str(game_dir).replace("\\", "/")
                config["render_url"] = render_url
                config["reauthorize_on_next_start"] = replace_token
                config_path.write_text(json.dumps(config, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

                if create_shortcuts:
                    self.set_status(t(language, "status_shortcuts"))
                    desktop = Path(os.environ.get("USERPROFILE", str(Path.home()))) / "Desktop" / f"{APP_NAME}.lnk"
                    start_menu = Path(os.environ.get("APPDATA", str(Path.home()))) / "Microsoft" / "Windows" / "Start Menu" / "Programs" / f"{APP_NAME}.lnk"
                    # Remove obsolete branded shortcuts so the current shortcut is the one users see.
                    for directory in {desktop.parent, start_menu.parent}:
                        try:
                            for old_shortcut in directory.glob(f"{APP_NAME.split('-')[0]}-*.lnk"):
                                if old_shortcut.name.casefold() != f"{APP_NAME}.lnk".casefold():
                                    old_shortcut.unlink(missing_ok=True)
                        except OSError:
                            pass
                    for shortcut in (desktop, start_menu):
                        try:
                            create_shortcut(shortcut, app_root / LAUNCHER_NAME, app_root, app_root / "SpotiWoW-Dev-Ruby.ico")
                        except Exception:
                            # An unavailable/locked shortcut location shouldn't undo a valid install.
                            pass
                    uninstall_shortcut = start_menu.parent / f"{APP_NAME} Uninstall.lnk"
                    try:
                        create_shortcut(uninstall_shortcut, app_root / UNINSTALLER_NAME, app_root, app_root / "SpotiWoW-Dev-Ruby.ico")
                    except Exception:
                        pass

                done_message = t(language, "done_message", addon=addon_dest, companion=app_root, language=language_label)
                self.root.after(0, lambda: self._finished(True, done_message, language))
        except urllib.error.HTTPError as exc:
            message = t(language, "http_error", code=exc.code)
            self.root.after(0, lambda: self._finished(False, message, language))
        except Exception as exc:
            message = t(language, "failed", error=f"{type(exc).__name__}: {exc}")
            self.root.after(0, lambda: self._finished(False, message, language))

    def _finished(self, success: bool, message: str, language: str) -> None:
        self.progress.stop()
        self.busy = False
        self.language_combo.configure(state="readonly")
        self.cancel_button.configure(state="normal")
        if success:
            self.status_var.set(t(language, "done_title"))
            messagebox.showinfo(t(language, "done_title"), message, parent=self.root)
            self.root.destroy()
        else:
            self.status_var.set(t(language, "interrupted"))
            self.install_button.configure(state="normal")
            messagebox.showerror(APP_NAME, message, parent=self.root)

    def close(self) -> None:
        if self.busy:
            messagebox.showinfo(APP_NAME, self._t("busy_close"), parent=self.root)
            return
        self.root.destroy()

    def run(self) -> None:
        self.root.mainloop()


if __name__ == "__main__":
    SetupApp().run()

