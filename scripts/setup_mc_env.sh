#!/bin/bash

usage()
{
cat << EOF
Usage: $0 -img IMAGE_NAME -mcv MC_VERSION

This script sets up the minecraft server environment variables for docker to build.

OPTIONS:
   -img IMAGE_NAME  The name of the image to use.
   -mcv MC_VERSION  The version of minecraft version server to use.
   -h               Show this message
EOF
}

MC_VERSION=
IMAGE_NAME=
JAVA_VERSION=8
CSV_SEP='|'

while (( $# )); do
	case "$1" in
		-img | --image-name ) IMAGE_NAME=$2; shift 2;;
		-mcv | --minecraft-version ) MC_VERSION=$2; shift 2;;
		-h | --help )                usage; exit 0;;
		* )                          usage; exit 1;;
	esac
done

MCMETADATA=$(tail -n +2 scripts/available_versions.csv | grep -m 1 "^${MC_VERSION//./\\\.}$CSV_SEP")

if [[ $? -ne 0 ]]; then
	echo "Argument '$MC_VERSION' is NOT a valid version number. Please try a different version."
	exit 1
fi

JAVA_VERSION=$(echo $MCMETADATA | awk -F"$CSV_SEP" '{print $3}')
SERVER_LINK=$(echo $MCMETADATA | awk -F"$CSV_SEP" '{print $2}')
USER_ID=$(id -u)
GROUP_ID=$(id -g)

echo "JAVA_VERSION=$JAVA_VERSION" > .env
echo "IMAGE_NAME=$IMAGE_NAME" >> .env
echo "SERVER_LINK=$SERVER_LINK" >> .env
echo "MC_VERSION=${MC_VERSION// /_}" >> .env
echo "GID=$GROUP_ID" >> .env
echo "UID=$USER_ID" >> .env

if [ -f clib.env ]; then
	source clib.env
	echo "C_LIB=$C_LIB" >> .env
fi
