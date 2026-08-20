#!/bin/bash

DEBS_DIR=debs
INSTALL_DIR=insdir
mkdir $INSTALL_DIR $DEBS_DIR root

# Deps include glibc and udev. udev has glibc dependency so glibc (libc6) thus libc6 not included for now.
DEPS=$(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances libudev1 | grep "^\w" | sort -u)
cd $DEBS_DIR
apt-get download $DEPS
DEBS=$(ls *.deb)
cd ..

# Extract to root folder for distroless container transfer.
for file in $DEBS;do
	DEP="${file%%_*}"
	dpkg-deb --extract ./$DEBS_DIR/$file ./$INSTALL_DIR/$DEP
	cp -r ./$INSTALL_DIR/$DEP/* ./root
done

rm -rf $INSTALL_DIR
rm -rf $DEBS_DIR

# Prepare the distroless base file system.
cd ./root
mkdir -p usr/local/bin mnt
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
