# SpotiWoW-Dev v1.7.2 — Français

> **Version de développement** — cette version est en cours d’évolution et peut contenir des changements expérimentaux. Elle est destinée aux tests ; des bugs ou changements de comportement restent possibles.

SpotiWoW-Dev relie Spotify à Turtle WoW via le bridge de fichiers SuperWoW. Cette version utilise l’interface et les messages en français.

## Installation simple
1. Télécharge le fichier versionné `SpotiWoW-Dev-Setup-v<version>.exe` depuis la page **Releases** du dépôt GitHub officiel.
2. Ferme Turtle WoW avant l’installation.
3. Choisis Français (FR) dans l’installateur et sélectionne le dossier du client. Colle ton Client ID lors de la première installation ; les mises à jour le préremplissent depuis la configuration locale. Spotify demandera quand même son autorisation au premier lancement du compagnon.
4. Dans les paramètres de ton application Spotify Developer, ajoute le Redirect URI exact `http://127.0.0.1:8888/callback`.
5. Termine l’installation puis lance **SpotiWoW-Dev** depuis le raccourci créé.

L’URL Render est facultative pour le transport Chat. Pour Render et les invitations Jam, déploie le service du dépôt depuis render.yaml, puis saisis son URL HTTPS dans l’installateur. Tous les participants doivent utiliser cette même URL.

Le setup est lié à sa release GitHub précise. Avant d’installer, il vérifie le tag, le SHA du commit source, le manifeste du paquet et son empreinte SHA-256 publiée par GitHub.

L’installateur ne demande jamais de Client Secret et ne télécharge pas Turtle WoW, VanillaFixes, SuperWoW, SuperAPI ni leurs DLL.

## Prérequis
- Un compte Spotify Premium pour chaque utilisateur de SpotiWoW.
- Client Turtle WoW basé sur WoW 1.12.1 ; l’installateur le repère avec `VanillaFixes.exe` ou `WoW.exe`.
- SuperWoW avec les fonctions `ImportFile` et `ExportFile`.
- `VanillaFixes.exe` ou `WoW.exe` présent dans le dossier du client ; le compagnon privilégie VanillaFixes et lance `WoW.exe` directement si besoin.
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
- Transport de paroles Chat inchangé ou relais Render facultatif, avec statut local et sans repli automatique.
- Lanceur de zone de notification Windows sans console CMD visible. Le lanceur démarre aussi Spotify s’il est fermé.
- Le bridge reste actif jusqu’à la fermeture de tous les clients WoW. Relance le raccourci pour ouvrir un autre client sans démarrer un deuxième bridge.
- Vérification des releases GitHub publiées sans clé API : le bridge ne signale une version que lorsque son installateur est disponible. L’addon affiche le rappel dans le chat local à chaque connexion ; le menu de notification Windows indique la version et ouvre directement sa page de release.

Le transport Chat conserve le fonctionnement actuel et n’utilise pas Render. Le transport Render, activé dans les réglages, relaie les paroles en temps réel et les affiche localement ; il ne bascule jamais automatiquement vers un canal WoW. Tous les joueurs Render doivent utiliser la même URL de service renseignée dans l’installateur. Sur Render gratuit, le service s’endort après 15 minutes sans trafic. Son prochain démarrage à froid prend environ une minute ; les paroles ajoutent ensuite le temps de réseau. Le relais transmet les paroles en mémoire sans les enregistrer sur disque.

Pour inviter le groupe à un Spotify Jam, démarre le Jam dans Spotify puis saisis /spn jam suivi du lien Spotify en groupe ou en raid. Les autres joueurs doivent avoir configuré le même relais et choisi le transport Render ; ils peuvent accepter ou refuser dans une fenêtre en jeu. L’acceptation ouvre le lien Spotify. Spotify ne fournit pas d’API publique pour créer le Jam.

L’installateur efface le cache de paroles et les jaquettes à chaque installation, tout en conservant la session Spotify si tu choisis de la garder. Le token OAuth est protégé par DPAPI Windows. Un raccourci de désinstallation retire l’addon, le compagnon, les caches et les données Spotify locales. Les identifiants techniques historiques SpotifyNowDB, SpotifyNowState.txt et SpotifyNowCommand.txt sont conservés pour la compatibilité.

## Dépannage
- Consulte le [guide de dépannage en français](TROUBLESHOOTING_FR.md) pour les problèmes de connexion, de jaquette, de métadonnées, de paroles et de commandes.
- Journaux : `logs/bridge.log` et `logs/launcher.log` dans le dossier de l’application compagnon.
- Si aucun dossier n’est détecté, sélectionne manuellement celui qui contient `VanillaFixes.exe` ou `WoW.exe`.

Pour une mise à jour de l’addon uniquement, télécharge `SpotiWoW-Dev-Addon-FR.zip` depuis les Releases. La version française affiche les messages système en français.
