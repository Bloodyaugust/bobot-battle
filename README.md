# bobot-battle

A turn-based, arena-combat, multiplayer game.

To format:
`` gdformat `find . -wholename './scripts/*.gd'`  ``

## Dockerfile

To build:
`docker build .circleci/images/godot/ -t greysonr/godot_butler:<version number>`

To push:
`docker push greysonr/godot_butler:<tag name>`
