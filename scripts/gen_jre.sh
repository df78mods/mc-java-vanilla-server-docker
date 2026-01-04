#!/bin/bash

jlinkPath=$(which jlink)

if [[ -z "$jlinkPath" ]]; then
	# Cannot create custom JRE, just grab the JRE that came with the JDK. Most likely Java 8 fulfills this condition.
	if [[ -d "/opt/java/openjdk/jre" ]]; then
		cp -rf /opt/java/openjdk/jre /home/jre
		exit 0
	fi
	exit 1
else
	modules=java.base,java.desktop,java.management,java.naming,java.sql,java.xml,jdk.crypto.cryptoki,jdk.unsupported,jdk.zipfs
	jlink --add-modules $modules --output jre --no-header-files --no-man-pages --strip-debug
fi
