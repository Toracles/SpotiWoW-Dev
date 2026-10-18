# Journal des modifications

## v1.6.20
- Le README regroupe maintenant les guides anglais sous Docs et les guides français sous Documentations.
- L’installeur recharge le Client ID Spotify depuis la configuration locale, le masque par défaut et permet de l’afficher. Spotify demande toujours son autorisation au premier lancement.

## v1.6.19
- À la réinstallation, supprime l’ancien raccourci du Bureau et du menu Démarrer avant de recréer le raccourci SpotiWoW-Dev avec le nouvel emblème sous un nouveau nom de fichier afin que Windows reconstruise l'aperçu en cache. Le programme et ses données restent installés. L'icône du tray utilise aussi le fichier actualisé.

## v1.6.18
- Remplace les icônes Windows du compagnon et de l’installateur par le nouvel emblème doré et rubis, également affiché dans le README GitHub.
- Supprime les fichiers de l’ancienne variante inutilisée du dépôt Dev et recentre le projet sur Turtle WoW 1.18.1.
- Détecte automatiquement le dossier du client avec `VanillaFixes.exe` ou `WoW.exe`, y compris dans les emplacements Classic usuels ; le compagnon lance directement `WoW.exe` si VanillaFixes est absent.

## v1.6.17
- Accélère la fermeture complète de SpotiWoW-Dev : arrêt gracieux plus court du bridge, puis arrêt forcé avec délais réduits si nécessaire.
- Réduit aussi l’attente avant la fermeture automatique du compagnon quand le client WoW se ferme.
- Rend le bouton de fermeture du menu Player Settings clairement visible.

## v1.6.16
- Corrige l’alignement vertical de « SpotiWoW » dans le cartouche du menu Player Settings.

## v1.6.15
- Corrige le chargement de l’addon : les infobulles des boutons Lyrics et Channel sont maintenant reliées après leur création, ce qui rétablit le lecteur et les commandes `/spn`.

## v1.6.14
- Ajoute une vérification périodique des releases publiques GitHub, sans clé API ; une mise à jour n’est annoncée que lorsque le setup est publié.
- Affiche un rappel local dans le chat WoW à chaque connexion de personnage, avec la version et le lien de la release.
- Ajoute au menu de l’icône de notification un accès direct à la release, une vérification manuelle et une alerte Windows quand une mise à jour est prête.
- Conserve la dernière information connue si GitHub est temporairement inaccessible et vérifie à nouveau périodiquement.

## v1.6.13-alpha
- Corrige une erreur de syntaxe dans le sélecteur de thème du paquet anglais, qui empêchait le chargement du Lua, du lecteur et des commandes `/spn`.
- Aligne la version du TOC anglais sur la version de la release.

## v1.6.12-alpha
- Renomme les thèmes #FFFFFF et #FF4FD8 dans le lecteur et les réglages : Aube-Argent et Set du Croc.

## v1.6.11-alpha
- Garde le contour et l’accent néon des boutons visibles pendant le survol.
- Ajoute un repère de lecture qui suit le pointeur sur la barre et affiche l’heure visée quand Click to Seek est actif.
- Ajoute des infobulles explicatives aux réglages, champs HEX et boutons Appliquer, en français et en anglais US.
- Ajoute les thèmes Puits de soleil (#FFB020), Deuillegivre (#FFFFFF) et Tisse-rêves (#FF4FD8).

## v1.6.9-alpha
- Centre « SpotiWoW » dans le cartouche du panneau Player Settings.

## v1.6.8-alpha
- Ajoute les boutons Shuffle et Repeat au mode compact et élargit légèrement le lecteur pour les garder alignés et visibles.
- Affiche l’état des modes de façon persistante dans Compact, Square et Expanded : fond accentué pour Shuffle et Repeat All, contour néon pour Repeat 1.
- Repositionne la ligne d’accent au bord supérieur et l’arrête avant les boutons en haut à droite dans les trois formats, en conservant la barre de progression inférieure.
- Uniformise le survol des boutons du lecteur et des réglages avec un fond rouge charbon, sans dégradé rouge/noir.
- Centre l’en-tête du panneau Player Settings et aligne les deux champs hexadécimaux ainsi que leurs boutons Apply dans le cadre.

## v1.6.7-alpha
- Corrige l’alignement du panneau Player Settings et garde toutes les options à l’intérieur du cadre.
- Réorganise les commandes du Square Mode pour garder le volume et chaque bouton visibles, sans chevauchement.
- Affiche « SpotiWoW » dans l’en-tête du panneau de réglages.
- Remplace les fonds de boutons étirés par un fond charbon rouge uniforme, assorti au thème.
- Rend Button Accents visible : l’activation colore les libellés et contours avec l’accent néon choisi ; la désactivation restaure le style doré.
- Répare Accent Hex et Progress Hex, avec application immédiate de la couleur d’accent au cadre et de la couleur de progression aux segments de la barre.
- Ajoute des infobulles localisées pour expliquer les champs de couleur, Button Accents et Click to Seek.
## v1.6.6-alpha
- Aligne les métadonnées et commandes de Square et Expanded, évite que le panneau d’état croise le séparateur et raccourcit les libellés du menu pour qu’ils restent lisibles.
- Le menu Player Settings regroupe les personnalisations visuelles, les couleurs personnalisées et les options des paroles (activation et canal), avec leur état visible.
- Reprend les cadres métalliques, fonds pierre sombre et titres dorés des panneaux classiques de WoW ; les quatre néons restent des accents sur la progression, les commandes actives et les détails lumineux.
- Réduit légèrement le Square Mode à 236 × 236 px et sa pochette à 68 × 68 px ; les commandes restent alignées dans le lecteur.
- Déplace le volume dans une ligne dédiée au-dessus des commandes en Square Mode afin qu’il reste visible.
- Le bouton supérieur parcourt désormais Compact → Square → Agrandi → Compact.
- Le panneau « Réglages du lecteur » donne accès aux quatre thèmes, aux couleurs d’accent et de progression, ainsi qu’à la lueur, la bordure, les accents des boutons, les commandes, les métadonnées, la barre de progression, la recherche au clic et ses trois styles.
- Les changements sont sauvegardés dans les réglages existants et les options avancées restent aussi accessibles via `/spn`.

## v1.6.5-alpha
- Le setup est désormais lié au tag et au SHA exacts du commit qui a produit cette release ; il ne peut plus basculer silencieusement sur une autre version publiée.
- Le workflow joint le même manifeste de provenance au setup et aux paquets portables. À l’installation, le setup vérifie la cible GitHub du tag, le SHA du commit, le manifeste du ZIP et son empreinte SHA-256 publiée par GitHub avant toute extraction.
- La version française et la version US appliquent les mêmes contrôles. En cas d’écart ou de manifeste absent, l’installation s’arrête avant de modifier les fichiers du jeu.

## v1.6.4-alpha
- Refonte de l’interface du lecteur sur une base charbon sombre, plus nette et plus cohérente avec les quatre accents néon Obsidian, Azerite, Fel et Bloodmoon.
- Ajout d’un format carré dédié avec pochette, titre, artiste, album, progression, temps et commandes complètes.
- Réorganisation du compact en conservant ses dimensions de 300 × 68 px ; la pochette et la rangée de boutons disposent maintenant de zones distinctes.
- Mise en page de contrôle revue dans le format agrandi (460 × 164 px) ; aucun nouveau traitement en arrière-plan n’est ajouté.
- Nouveau choix de format dans /spn settings et commande /spn mode compact|square|expanded. /spn expand et les anciennes sauvegardes restent compatibles.
- Défilement des titres découpé en caractères UTF-8 pour ne pas couper les titres multilingues.
- Tous les réglages existants, commandes, jaquettes dynamiques, raccourcis, modes aléatoire/répétition et progression cliquable sont conservés.

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
- À la fermeture du client WoW, le bridge s’arrête et l’application SpotiWoW-Dev quitte aussi automatiquement la zone de notification.
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

