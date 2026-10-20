# SpotiWoW-Dev v1.7.3

<p align="center">
  <img src="companion/SpotiWoW-Dev.png" alt="SpotiWoW-Dev icon" width="180">
</p>

> **Development build for Turtle WoW.** This version is still evolving and may contain bugs or experimental changes.

SpotiWoW-Dev brings Spotify playback into Turtle WoW through a lightweight Windows companion and the SuperWoW file bridge. The setup automatically looks for a client folder containing `VanillaFixes.exe` or `WoW.exe`. It supports French and US English.

> **Spotify Premium is required for every SpotiWoW user.**

## Feature overview

- **Three player layouts:** compact, square, and expanded, with Spotify track, artist, album, cover art, playback progress, and controls arranged for each size.
- **Seven WoW-inspired themes:** Obsidian, Azerite, Fel, Bloodmoon, Sunwell, Silver Dawn, and Fang Set, with configurable accent and progress colors, glow, borders, and button styling.
- **A customizable settings panel:** choose the layout and theme, show or hide controls and track details, and adjust the progress bar and click-to-seek behavior. Settings persist in-game.
- **Spotify controls:** play/pause, previous/next, seeking, volume, shuffle, and repeat. Shuffle and repeat states remain visibly indicated on the player.
- **Lyrics:** synchronized multi-source lookup and local cache, with the existing WoW Chat transport or optional Render relay. Render can show local bubbles over visible character nameplates; otherwise it prints locally and never falls back to WoW channels. `/spn render` checks the relay.
- **Render and multiboxing:** all opted-in players share one relay; lyrics are sent independently of WoW chat limits, while settings such as Lyrics on/off are saved per character. Render keeps only a short in-memory lyric snapshot for clients just joining.
- **Spotify Jam invites:** invite party or raid members from in-game; they can accept or decline in a popup and open the Spotify link. The Jam itself must be started in Spotify.
- **Windows companion:** connects to Spotify, supplies live track metadata and artwork to the add-on, starts Spotify when needed, and keeps the bridge running until every WoW client is closed. Relaunch the shortcut to open another WoW client without duplicating Spotify or the bridge.
- **Update reminders:** checks published releases without a GitHub API key, shows a local chat notice at every login when the setup is available, and provides a direct release link in the notification-area menu.
- **Setup and privacy:** setup can preserve or replace Spotify authorization, protects the token with Windows DPAPI, clears lyric/art caches, and installs a full uninstaller.
- **French and US English editions:** localized add-on messages and language-specific add-on packages are available in Releases.

## Docs

- [US English user guide](README_EN_US.md)
- [US English changelog](CHANGELOG_EN_US.md)

## Download

Download the versioned `SpotiWoW-Dev-Setup-v<version>.exe` asset from [GitHub Releases](https://github.com/Toracles/SpotiWoW-Dev/releases). The installer is pinned to its release and verifies the tag, source commit, package manifest, and SHA-256 digest before installation.

For requirements, Spotify setup, and installation steps, see the guides above. `/spn help` lists the in-game commands.

## Résumé des fonctionnalités

> **Un compte Spotify Premium est requis pour tous les utilisateurs de SpotiWoW.**

- **Trois formats de lecteur :** compact, carré et agrandi, avec titre, artiste, album, pochette Spotify, progression et commandes adaptés à chaque format.
- **Sept thèmes inspirés de WoW :** Obsidian, Azerite, Fel, Bloodmoon, Puits de soleil, Aube-Argent et Set du Croc. Personnalise les couleurs d’accent et de progression, la lueur, les bordures et les boutons.
- **Panneau de réglages complet :** choix du thème et du format, affichage des commandes et des infos du morceau, apparence de la barre et recherche dans le morceau au clic. Les réglages sont conservés en jeu.
- **Commandes Spotify :** lecture/pause, morceau précédent/suivant, recherche, volume, aléatoire et répétition. Les états aléatoire et répétition restent visibles sur le lecteur.
- **Paroles :** recherche synchronisée et cache local, avec le transport Chat actuel ou le relais Render facultatif. Render affiche une bulle locale sur les plaques de personnage visibles ; sinon la ligne est écrite localement, sans jamais basculer vers un canal WoW. `/spn render` vérifie le relais.
- **Render et multiboxing :** les joueurs qui activent Render partagent un relais unique ; les réglages comme Lyrics ON/OFF sont conservés par personnage. Le relais garde brièvement la dernière ligne en mémoire pour les clients qui viennent de se connecter.
- **Invitations Spotify Jam :** invite les membres du groupe ou du raid depuis le jeu ; ils peuvent accepter ou refuser dans une fenêtre et ouvrir le lien Spotify. Le Jam doit être lancé dans Spotify.
- **Compagnon Windows :** connexion à Spotify, transmission en direct des métadonnées et jaquettes, et démarrage de Spotify si nécessaire. Le bridge reste actif tant qu’un client WoW est ouvert. Relance le raccourci pour ouvrir un autre client sans dupliquer Spotify ni le bridge.
- **Rappels de mise à jour :** vérification des releases publiées sans clé API GitHub, message local dans le chat à chaque connexion si le setup est disponible, et lien direct depuis le menu de notification.
- **Installation et confidentialité :** l’installeur conserve ou remplace l’autorisation Spotify, protège le token avec DPAPI Windows, efface les caches paroles/jaquettes et installe un désinstalleur complet.
- **Éditions française et anglaise US :** messages traduits et paquets addon par langue disponibles dans les Releases.

## Documentations

- [Guide utilisateur français](README_FR.md)
- [Journal des modifications français](CHANGELOG_FR.md)

> SpotiWoW-Dev reste une version de développement destinée aux tests.
