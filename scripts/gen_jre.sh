#!/bin/bash

jlinkPath=$(which jlink)

if [[ -z "$jlinkPath" ]]; then
	# Cannot create custom JRE, just grab the JRE that came with the JDK. Most likely Java 8 fulfills this condition.
	if [[ -d "/opt/java/openjdk/jre" ]]; then
		cp -rf /opt/java/openjdk/jre /home/jre
		exit 0
	fi
	exit 1
fi

javaMajorVersion=$(echo $JAVA_VERSION | grep -Po "jdk-\K[^\.]+")
compress="--compress=zip-0"

if (( javaMajorVersion < 21 )); then
	compress="--compress=0"
fi

modules=java.base,java.desktop,java.management,java.naming,java.sql,java.xml,jdk.crypto.cryptoki,jdk.unsupported,jdk.zipfs
jlink --add-modules $modules --output jre --no-header-files --no-man-pages --strip-debug $compress
