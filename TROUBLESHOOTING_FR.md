# Dépannage — SpotiWoW-Dev

Ce guide concerne **SpotiWoW-Dev**, la version de développement du projet pour Turtle WoW.

## Le lecteur ou le compagnon ne se connecte pas

1. Vérifie que le compagnon SpotiWoW-Dev est lancé et que Spotify est ouvert avec une lecture en cours.
2. Vérifie que le client de jeu est celui basé sur WoW 1.12.1 et que le dossier sélectionné contient `VanillaFixes.exe` ou `WoW.exe`.
3. Vérifie que SuperWoW est installé et que les fonctions `ImportFile` et `ExportFile` sont disponibles.
4. Dans le jeu, tape `/spn help` pour vérifier que l’addon est chargé et afficher les commandes disponibles.

## La jaquette Spotify est absente

Le chargement des jaquettes en direct nécessite `customassets.dll`, activée dans `dlls.txt`.

- Vérifie que la DLL est déjà installée dans ton client. Le Setup ne la fournit pas : il active cette DLL uniquement lorsqu’elle est présente.
- Vérifie la ligne correspondante dans `dlls.txt`, puis relance le client après toute modification.
- Vérifie que le compagnon et l’addon sont bien à jour et utilisent la même installation du jeu.

Les fichiers d’image temporaires ne sont pas conservés dans le dépôt.

## Le titre, l’artiste ou l’album ne correspond pas à Spotify

- Vérifie d’abord le morceau effectivement en cours de lecture dans Spotify.
- Laisse quelques secondes au compagnon pour actualiser l’état, puis vérifie à nouveau le lecteur en jeu.
- Si l’information reste ancienne, ferme puis relance le compagnon et le client du jeu.
- Précise si le problème concerne le titre, l’artiste, l’album, la durée ou la jaquette. Les titres dans différentes langues doivent rester affichés tels que Spotify les fournit.

## Les paroles ou le raccourci ne fonctionnent pas

- `Ctrl+Alt+L` active ou désactive le mode Lyrics depuis le compagnon.
- Le statut ON/OFF est un message local au joueur ; il n’est pas envoyé aux autres personnes dans le chat.
- Les paroles ne sont envoyées dans le canal choisi que si cette fonction est activée.

## L’addon ou une commande manque

- Vérifie que le dossier `SpotiWoW-Dev` se trouve dans `Interface/AddOns` du client utilisé.
- Vérifie que l’addon est activé sur l’écran de sélection du personnage.
- Utilise l’archive de la bonne langue : FR ou US.
- Tape `/spn help` pour la liste des commandes.

## Informations à joindre à un signalement

Indique la version de SpotiWoW-Dev, le client Turtle WoW ou Turtle WoW, la langue de l’addon, le mode compact ou agrandi, ainsi que les étapes pour reproduire le problème.

Les journaux du compagnon se trouvent dans `logs/bridge.log` et `logs/launcher.log`, dans le dossier de l’application. Avant de les partager, retire tout jeton, secret, code d’autorisation ou donnée de compte. Ne publie jamais de Client Secret Spotify.

Pour signaler un bug, utilise le formulaire **Bug report** de la section Issues de la repo SpotiWoW-Dev.
