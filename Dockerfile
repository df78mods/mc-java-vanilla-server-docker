ARG JAVA_VERSION=8

# Generate the custom JRE as required.
FROM eclipse-temurin:${JAVA_VERSION}-alpine AS jre-dev
WORKDIR /home

COPY ./scripts/gen_jre.sh /home/setup.sh
RUN apk update && apk upgrade && apk add --no-cache \
    bash \
    binutils

SHELL ["/bin/bash"]
RUN ./setup.sh

# Container to host the new JRE.
FROM alpine:latest AS server-base

# Include optional libs for minecraft server functionality.
RUN apk update && apk upgrade && apk add --no-cache \
    eudev-libs

ENV JAVA_HOME=/usr/local
COPY --from=jre-dev /home/jre $JAVA_HOME

ARG UNAME=root
ARG GNAME=root
ARG UID=1000
ARG GID=1000

# Create a group and a system user in a single RUN instruction to reduce image layers
RUN addgroup -S -g $GID $GNAME && adduser -S -D -u $UID -G $GNAME $UNAME
WORKDIR /home/${UNAME}

# Setup the vanilla minecraft server to be ready to run.
FROM server-base AS minecraft-server
ARG SERVER_LINK
RUN wget -O /home/server.jar $SERVER_LINK

ARG UNAME=root
USER ${UNAME}

CMD ["java", "-jar", "/home/server.jar", "--nogui"]
