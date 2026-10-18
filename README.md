# SpotiWoW-Dev v1.6.20

<p align="center">
  <img src="companion/SpotiWoW-Dev.png" alt="SpotiWoW-Dev icon" width="180">
</p>

> **Development build for Turtle WoW.** This version is still evolving and may contain bugs or experimental changes.

SpotiWoW-Dev brings Spotify playback into Turtle WoW through a lightweight Windows companion and the SuperWoW file bridge. The setup automatically looks for a client folder containing `VanillaFixes.exe` or `WoW.exe`. It supports French and US English.

## Feature overview

- **Three player layouts:** compact, square, and expanded, with Spotify track, artist, album, cover art, playback progress, and controls arranged for each size.
- **Seven WoW-inspired themes:** Obsidian, Azerite, Fel, Bloodmoon, Sunwell, Silver Dawn, and Fang Set, with configurable accent and progress colors, glow, borders, and button styling.
- **A customizable settings panel:** choose the layout and theme, show or hide controls and track details, and adjust the progress bar and click-to-seek behavior. Settings persist in-game.
- **Spotify controls:** play/pause, previous/next, seeking, volume, shuffle, and repeat. Shuffle and repeat states remain visibly indicated on the player.
- **Lyrics:** synchronized multi-source lookup with a local cache, configurable chat channel, and `Ctrl+Alt+L` toggle. The Lyrics status notice is local to your chat window.
- **Windows companion:** connects to Spotify, supplies live track metadata and artwork to the add-on, and stops the bridge when the game client exits.
- **Update reminders:** checks published releases without a GitHub API key, shows a local chat notice at every login when the setup is available, and provides a direct release link in the notification-area menu.
- **Installer convenience:** the Spotify Client ID is saved locally and prefilled on future setup runs; Spotify authorization is still required on first launch.
- **French and US English editions:** localized add-on messages and language-specific add-on packages are available in Releases.

## Docs

- [US English user guide](README_EN_US.md)
- [US English changelog](CHANGELOG_EN_US.md)

## Documentations

- [Guide utilisateur français](README_FR.md)
- [Journal des modifications français](CHANGELOG_FR.md)

## Download

Download `SpotiWoW-Dev-Setup.exe` from [GitHub Releases](https://github.com/Toracles/SpotiWoW-Dev/releases). The installer is pinned to its release and verifies the tag, source commit, package manifest, and SHA-256 digest before installation.

For requirements, Spotify setup, and installation steps, see the guides above. `/spn help` lists the in-game commands.

## Résumé des fonctionnalités

- **Trois formats de lecteur :** compact, carré et agrandi, avec titre, artiste, album, pochette Spotify, progression et commandes adaptés à chaque format.
- **Sept thèmes inspirés de WoW :** Obsidian, Azerite, Fel, Bloodmoon, Puits de soleil, Aube-Argent et Set du Croc. Personnalise les couleurs d’accent et de progression, la lueur, les bordures et les boutons.
- **Panneau de réglages complet :** choix du thème et du format, affichage des commandes et des infos du morceau, apparence de la barre et recherche dans le morceau au clic. Les réglages sont conservés en jeu.
- **Commandes Spotify :** lecture/pause, morceau précédent/suivant, recherche, volume, aléatoire et répétition. Les états aléatoire et répétition restent visibles sur le lecteur.
- **Paroles :** recherche synchronisée auprès de plusieurs sources, cache local et choix du canal. `Ctrl+Alt+L` active ou désactive les paroles ; son message de statut reste local à ta fenêtre de chat.
- **Compagnon Windows :** connexion à Spotify, transmission des métadonnées et des jaquettes en direct à l’addon, puis arrêt du bridge à la fermeture du client.
- **Rappels de mise à jour :** vérification des releases publiées sans clé API GitHub, message local dans le chat à chaque connexion si le setup est disponible, et lien direct depuis le menu de notification.
- **Installation simplifiée :** le Spotify Client ID est mémorisé localement et prérempli lors des prochaines installations ; l’autorisation Spotify reste nécessaire au premier lancement.
- **Éditions française et anglaise US :** messages traduits et paquets addon par langue disponibles dans les Releases.

> SpotiWoW-Dev reste une version de développement destinée aux tests.
