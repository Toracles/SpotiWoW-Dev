# Journal des modifications

## v1.4.11
- Refonte néon métallique de l’interface : cadre sombre, jaquette encadrée, boutons assombris et accent violet par défaut ; les quatre thèmes gardent leurs couleurs propres.
- Lecteur compact agrandi à 300 × 68 px, volume isolé et titres longs limités pour éviter les chevauchements.
- Indicateurs persistants pour aléatoire, répétition album et répétition morceau, y compris en mode compact.
- Jaquettes générées en TGA RGBA pour améliorer la compatibilité du client 1.12.
- Suppression de l’étape de signature SignPath non configurée du workflow GitHub Actions.

## v1.4.10
- Ajout d’un panneau de réglages accessible depuis le lecteur ou avec `/spn settings`, pour choisir le thème et basculer entre le format compact et agrandi.

## v1.4.9
- Refonte du mini-lecteur WoW en style métallique, thèmes Obsidian, Azerite, Fel et Bloodmoon ; couleurs, bordures, lueur, boutons, métadonnées et barre de progression réglables.
- Ajout d’un mode agrandi avec jaquette Spotify, album, temps de lecture, lecture aléatoire et répétition ; le format compact conserve alors ses dimensions de 250 × 58 px.
- Les réglages sont sauvegardés dans les SavedVariables WoW ; les commandes et l’aide existent en français et anglais US.
- Le compagnon récupère les jaquettes Spotify et les convertit en textures locales pour l’addon.

## v1.4.6
- Le bridge interroge Spotify toutes les 10 secondes pour actualiser les métadonnées du morceau.
- Le titre défile dans l’interface de l’addon lorsqu’il est trop long, afin de pouvoir le lire en entier.

## v1.4.5
- À la fermeture du client WoW, le bridge s’arrête et l’application SpotiWoW-Octo quitte aussi automatiquement la zone de notification.
- Ajout d’une entrée de journal pour cette fermeture automatique.

## v1.4.4
- Retrait des trois anciens guides de maintenance de la racine du dépôt et suppression des liens obsolètes dans les README. Les règles `.gitignore` empêchent leur réapparition accidentelle.
- Conservation du correctif v1.4.3 qui surveille le vrai processus `WoW.exe` pour arrêter le bridge après Alt+F4.

## v1.4.3
- Correction de l’arrêt automatique du bridge : le lanceur surveille désormais le processus réel `WoW.exe`, plutôt que tous les exécutables présents dans le dossier du jeu.
- Ajout de journaux de diagnostic pour le suivi du PID client et la fermeture de la session.

## v1.4.2
- Correction du plantage de l’installateur à la fin de l’installation : le sélecteur de langue ne rentre plus en conflit avec le paramètre `{language}` du message de confirmation.

## v1.4.1
- Correction du workflow GitHub Actions : les chemins des icônes et scripts transmis à PyInstaller sont désormais absolus.
- Mise à jour des actions GitHub vers des versions utilisant Node.js 24 pour éliminer l’avertissement de dépréciation de Node.js 20.

## v1.4.0
- Ajout de variantes complètes de l’addon : Français (FR) et English (US).
- Auteur officiel de l’addon : CloudNine_Ex.
- Internationalisation des messages système locaux, de l’aide, des info-bulles et du message de morceau en cours.
- Le raccourci Ctrl+Alt+L reste sans saisie de commande dans le chat. Le statut ON/OFF s’affiche uniquement dans la fenêtre de chat locale.
- L’installeur propose la langue et télécharge le paquet correspondant.
- Les identifiants techniques et les SavedVariables existants sont conservés pour compatibilité.
