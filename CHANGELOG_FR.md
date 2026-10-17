# Journal des modifications

## v1.4.15
- Le bridge conserve son scan Spotify si un nom de morceau ne peut pas être encodé par Windows ; les métadonnées sont transportées en UTF-8.
- Ctrl+Alt+S relance immédiatement le scan Spotify ; les métadonnées périmées sont effacées quand rien n’est en lecture.

## v1.4.14
- Réduit la jaquette en mode compact pour la séparer clairement de la rangée de commandes.

## v1.4.13
- Répare le chargement des locales FR et US : `/spn help`, `/spn say` et les autres messages ne révèlent plus les clés internes.
- Jaquettes compatibles avec le chargeur CustomAssets : textures TGA 24 bits en 128 × 128, distribuées sur 512 chemins déjà connus du client et mises à jour par le bridge.
- L’installateur ajoute `customassets.dll` à `dlls.txt` uniquement si la DLL existe, sans toucher aux autres entrées ; les archives ajoutent les textures sous `Data/`.
- Complète le panneau droit du lecteur agrandi avec l’état Spotify, le volume, ses commandes et un bouton Lyrics.

## v1.4.12
- Correction du fichier de traduction français : le nom réservé `repeat` empêchait le chargement de toute la locale, et `/spn help` affichait les clés internes à la place des commandes.

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
