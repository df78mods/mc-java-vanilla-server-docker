#!/bin/bash

apt-get update

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
mkdir -p usr/bin usr/local/bin etc root home
mkdir -m 777 tmp
ln -s usr/bin bin
ln -s usr/lib lib
ln -s usr/lib64 lib64
