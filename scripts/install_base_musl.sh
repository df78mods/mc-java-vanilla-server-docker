#!/bin/sh

apk update
apk add --no-cache eudev-libs

mkdir root

# Prepare the distroless base file system.
cd ./root
mkdir -p usr/local/bin usr/lib usr/lib64 mnt etc
mkdir -m 1777 mnt/server-files
mkdir -m 1777 tmp

NON_ROOT_UID=65532
NON_ROOT_GID=65532
NON_ROOT_MOUNT_DIR=mnt/server-files/${NON_ROOT_UID}_${NON_ROOT_GID}
mkdir $NON_ROOT_MOUNT_DIR
chown $NON_ROOT_UID:$NON_ROOT_GID $NON_ROOT_MOUNT_DIR

if [[ -n "${MINECRAFT_EULA}" ]]; then
	EULA_FILE_LOC=$NON_ROOT_MOUNT_DIR/eula.txt
	echo "eula=$MINECRAFT_EULA" > $EULA_FILE_LOC
	chown $NON_ROOT_UID:$NON_ROOT_GID $EULA_FILE_LOC
fi

ln -s usr/lib lib
ln -s usr/lib64 lib64

cp -r /lib/*musl* usr/lib/
cp -r /usr/lib/libudev* usr/lib/

# Generate OS Release file.
source /etc/os-release
cat << EOF > etc/os-release
NAME=$NAME
VERSION_ID=$VERSION_ID
ID=$ID
PRETTY_NAME=Distroless
EOF
