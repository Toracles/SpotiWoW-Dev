# SpotiWoW-Dev v1.6.11-alpha — Français

> **Version de développement** — cette version est en cours d’évolution et peut contenir des changements expérimentaux. Elle est destinée aux tests ; des bugs ou changements de comportement restent possibles.

SpotiWoW-Dev relie Spotify à Turtle WoW / OctoWoW via le bridge de fichiers SuperWoW. Cette version utilise l’interface et les messages en français.

## Installation simple
1. Télécharge `SpotiWoW-Dev-Setup.exe` depuis la page **Releases** du dépôt GitHub officiel.
2. Ferme Turtle WoW avant l’installation.
3. Choisis `Français (FR)` dans l’installateur, sélectionne le dossier contenant `VanillaFixes.exe`, puis colle ton Spotify Client ID.
4. Dans les paramètres de ton application Spotify Developer, ajoute le Redirect URI exact `http://127.0.0.1:8888/callback`.
5. Termine l’installation puis lance **SpotiWoW-Dev** depuis le raccourci créé.

Le setup est lié à sa release GitHub précise. Avant d’installer, il vérifie le tag, le SHA du commit source, le manifeste du paquet et son empreinte SHA-256 publiée par GitHub.

L’installateur ne demande jamais de Client Secret et ne télécharge pas Turtle WoW, VanillaFixes, SuperWoW, SuperAPI ni leurs DLL.

## Prérequis
- Client Turtle WoW / OctoWoW basé sur WoW 1.12.1.
- SuperWoW avec les fonctions `ImportFile` et `ExportFile`.
- `VanillaFixes.exe` présent dans le dossier du client.
- Une application Spotify Developer configurée avec le Redirect URI indiqué ci-dessus.
- `customassets.dll` activée dans `dlls.txt` pour le chargement des jaquettes Spotify en direct. L’installateur active la DLL si elle est déjà présente.

## Fonctionnalités
- Raccourci `Ctrl+Alt+L` pour activer/désactiver Lyrics depuis le compagnon, sans saisir de commande dans le chat.
- Message `Mode Lyrics : ON/OFF` affiché localement dans la fenêtre de chat via `DEFAULT_CHAT_FRAME:AddMessage`. Aucun message de statut n’est envoyé aux autres joueurs.
- Lecteur à fond charbon et accents néon en trois formats : compact (300 × 68 px), carré (236 × 236 px) et agrandi (460 × 164 px). Pochette Spotify, artiste, album, temps et commandes varient selon le format. Sélection dans `/spn settings` ou commande `/spn mode compact|square|expanded`.
- Thèmes Obsidian, Azerite, Fel, Bloodmoon, Puits de soleil, Aube-Argent et Set du Croc, avec accents néon, lueur, bordures et commandes personnalisables ; progression réglable et cliquable pour chercher dans le morceau.
- Le bouton `...` ouvre le panneau complet, habillé comme une fenêtre classique de WoW : thème, format, couleurs, lueur, bordure, boutons, métadonnées, commandes et progression. Le bouton supérieur parcourt compact, carré et agrandi.
- Le panneau droit agrandi affiche Spotify, l’état de lecture, le volume et les raccourcis Volume/Paroles.
- Les modes aléatoire, répétition album et répétition morceau restent indiqués dans le lecteur. Obsidian, Azerite, Fel et Bloodmoon gardent chacun leur accent néon.
- Réglages sauvegardés dans WoW. `/spn help` affiche les thèmes et options ; `/spn expand` bascule le mode agrandi.
- Recherche de paroles horodatées multi-sources et cache local.
- Lanceur de zone de notification Windows sans console CMD visible.
- Arrêt automatique du bridge lorsque le processus du client `WoW.exe` se ferme, y compris avec Alt+F4.

Les paroles elles-mêmes restent envoyées dans le canal choisi si cette option est activée. Les noms techniques `SpotifyNowDB`, `SpotifyNowState.txt` et `SpotifyNowCommand.txt` sont conservés pour la compatibilité.

## Dépannage
- Consulte le [guide de dépannage en français](TROUBLESHOOTING_FR.md) pour les problèmes de connexion, de jaquette, de métadonnées, de paroles et de commandes.
- Journaux : `logs/bridge.log` et `logs/launcher.log` dans le dossier de l’application compagnon.
- Si aucun dossier n’est détecté, sélectionne manuellement celui qui contient `VanillaFixes.exe`.

Pour une mise à jour de l’addon uniquement, télécharge `SpotiWoW-Dev-Addon-FR.zip` depuis les Releases. La version française affiche les messages système en français.
