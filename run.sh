#!/bin/bash

EXIT=0
OUT_DIR=out
IMAGE_NAME=minecraft.vanilla.server
IS_FIRST_PROMPT=1
VALID_SEARCH_TERM=

docker info > /dev/null
if [ $? -ne 0 ]; then
	echo Docker is not installed/running.
	read -n 1 -s -r -p $'Press any key to continue . . . \n'
	exit 1
fi

renderHelp()
{
cat << EOF
Available Useful Commands:
clear - Clean the terminal window.
find - Searches the cache for available minecraft versions.
help - Prints this text.

Server Setup Commands:
agree-eula - Agree to Minecraft's EULA.
clean - Removes the contents from \`$OUT_DIR\` directory.
server - Start a minecraft server.
run-server - Start an existing setup minecraft server.

Miscellaneous Commands (use at own risk):
new-server - Start a minecraft server from fresh.
reset - Set the project back to a clean state.
EOF
}

cleanOutDir()
{
mkdir -p $OUT_DIR
if [[ -f "$OUT_DIR/eula.txt" ]]; then
	mv $OUT_DIR/eula.txt eula.out
fi
rm -rf $OUT_DIR/{*,.*}
if [[ -f eula.out ]]; then
	mv eula.out $OUT_DIR/eula.txt
fi
}

cleanImages()
{
IMAGES=$(docker images --filter "reference=$IMAGE_NAME:*" -q | tr '\n' ' ')
docker rmi $IMAGES
}

cleanContainer()
{
docker compose down
}

listMcVersions()
{
read -p "Enter Search Term: " SEARCH_TERM
./scripts/find_versions.sh $SEARCH_TERM
}

agreeEula()
{
mkdir -p $OUT_DIR
echo "eula=TRUE" > $OUT_DIR/eula.txt
echo Agreed to Minecraft EULA.
}

buildEnv()
{
VALID_SEARCH_TERM=
read -p "Enter Minecraft Version: " MC_VERSION
./scripts/setup_mc_env.sh -img $IMAGE_NAME -mcv "$MC_VERSION"
if [ $? -eq 0 ]; then
	VALID_SEARCH_TERM=$MC_VERSION
fi
}

setupServer()
{
if [[ ! -f ./.env ]]; then
	echo No server setup, please run "server" to create a server instance.
	return 0
fi
docker compose up -d
docker compose attach mc-server
}

setupNewServer()
{
cleanContainer
buildEnv
if [[ -n "${VALID_SEARCH_TERM}" ]]; then
	setupServer
fi
}

while [[ $EXIT -eq 0 ]]; do
	if [[ $IS_FIRST_PROMPT -eq 0 ]]; then
		echo ''
	fi
	IS_FIRST_PROMPT=0

	EULA_EXISTS=$(grep -qixs "eula=TRUE" $OUT_DIR/eula.txt)
	if [[ $? -ne 0 ]]; then
		echo Minecraft EULA Link: https://aka.ms/MinecraftEULA
		echo Agree to Minecraft\'s EULA by typing \'agree-eula\' command.
		echo ''
	fi

	echo Enter a command prompt. Type \'help\' for commands you can use.
	read -p "> " CMD

	case "$CMD" in
		help ) renderHelp;;
		clear ) clear; IS_FIRST_PROMPT=1;;
		clean ) cleanOutDir;;
		agree-eula ) clear; agreeEula;;
		find ) listMcVersions;;
		server ) setupNewServer;;
		new-server ) cleanOutDir; setupNewServer;;
		run-server ) setupServer;;
		reset ) cleanOutDir; cleanContainer; cleanImages;;
		exit ) EXIT=1;;
		* ) echo Invalid argument $CMD;;
	esac
done

exit 0
