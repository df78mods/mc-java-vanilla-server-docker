#!/bin/bash

jqExists=$(which jq)

if [[ jqExists == "" ]]; then
	echo "jq is required for the script to work, please install \"jq\" to use."
	exit 1
fi

usage()
{
cat << EOF
Usage: $0 -img IMAGE_NAME -mcv MC_VERSION

This script launches the minecraft server in a docker container.

OPTIONS:
   -img IMAGE_NAME  The name of the image to use.
   -mcv MC_VERSION  The version of minecraft version server to use.
   -h               Show this message
EOF
}

MC_VERSION=
IMAGE_NAME=
JAVA_VERSION=8

while (( $# )); do
	case "$1" in
		-img | --image-name ) IMAGE_NAME=$2; shift 2;;
		-mcv | --minecraft-version ) MC_VERSION=$2; shift 2;;
		-h | --help )                usage; exit 0;;
		* )                          usage; exit 1;;
	esac
done

MCMETADATA=$(cat available_versions.json | jq ".\"$MC_VERSION\"")

if [[ $? -ne 0 ]]; then
	echo "Argument '$MC_VERSION' is NOT a valid version number. Please try a different version."
	exit 1
fi

JAVA_VERSION=$(echo $MCMETADATA | jq ".javaVersion")
SERVER_LINK=$(echo $MCMETADATA | jq ".url")

echo "JAVA_VERSION=$JAVA_VERSION" > .env
echo "IMAGE_NAME=$IMAGE_NAME" >> .env
echo "SERVER_LINK=$SERVER_LINK" >> .env
echo "MC_VERSION=$MC_VERSION" >> .env
echo "USER=$USER" >> .env
