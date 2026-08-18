#!/bin/sh

apk update
apk add --no-cache eudev-libs

mkdir root

# Prepare the distroless base file system.
cd ./root
mkdir -p usr/local/bin usr/lib usr/lib64 mnt
mkdir -m 1777 mnt/server-files
mkdir -m 1777 tmp
ln -s usr/lib lib
ln -s usr/lib64 lib64

cp -r /lib/*musl* usr/lib/
cp -r /usr/lib/libudev* usr/lib/
