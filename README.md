# Minecraft Server Setup

This repository contains the setup for setting up a minecraft server without having to install your own version of Java. This setup only supports vanilla minecraft for the time being.

Setup includes the following:
- Selects the Java version appropriate for the server version.
- Downloads the correct server version for you, given availability.
- Gets you started straight to server setup.

## Requirements:

- [Docker](https://www.docker.com/) - Needed for this setup. Great for quickly spinning up an environment for the server.
- Linux, Mac or [WSL for Windows](https://learn.microsoft.com/en-us/windows/wsl/install) - Needed to use bash commands.
- [Make](https://www.gnu.org/software/make/manual/make.html) - CLI to easily execute scripts given in the [Makefile](./Makefile).

## Steps:

### Compulsory first step:

Read [Minecraft's EULA](https://aka.ms/MinecraftEULA) and if you agree, run the convenient `make agree-eula` command.

All command references are found [here](#makefile-command-references), refer there for information about each command listed.

### Starting up the MC server right away for the first time:

1. Run the command `make server [MC version]` to start your new minecraft server instance.

### Manual setup:

1. Run `make setup-env [MC Version]`.

2. Build the image that uses the setup env variables via command:

- `make build`
- `make rebuild`

3. Run `make up` to start the minecraft instance.

Note: Command `make image [MC Version]` does steps 1 and 2 in one go.

## Post setup:

- You will be given direct access to the server CLI.
  - Enter command `stop` in the server CLI to close the server. Recommended for graceful exit.
  - You can alternatively use `Ctrl-C` but generally not recommended.
- You can then `make up` later if you want to start the server up again.
- JVM arguments can be set in [docker-compose.yaml](./docker-compose.yaml) file in the `command` line.
- The server files will be populated in the `out` folder so that users can access them and backup anytime.
- `make server` is only needed when you want to host a different version or initial setup.
- If you want to always have a clean server setup, run `make new-server [MC version]`

## Notes

- It is a good idea to backup the `out/world` data incase you want to reload the world again.
- You can look at MC versions via `make find [Query version]` command or look at [available_versions.csv](./available_versions.csv)
- Try to `git pull` if the newest server version is not supported.
  - There is a github action that auto-populates the server versions every 24 hours.
- Currently the docker setup does not support showing the GUI app generated from `server.jar`, so including `--nogui` after the jar file path is crucial.
  - Currently no plan to adding GUI support to containers due to current complexity.
  - Requires different setup depending on OS.

## Extras

WARNING: Not for those new to docker.

### Environment only image

There is a build stage where only the JRE environment is made without downloading the server. Can be great for trying out other modded servers.

You can start up an instance by going to the existing [docker-compose.yaml](./docker-compose.yaml) and change the following:
1. Change the `target` value in `build` from `minecraft-server` to `env-base`.
2. Run `make image [MC Version]` to build env-base image. Excludes downloading the `server.jar` file.
3. Place the server JAR file in this directory. Recommended to rename the JAR file to `server.jar`.
4. Uncomment the volume bind for the server JAR in the yaml file.
5. Run `make up` to start the container.

Disclaimer: Modded servers are not guaranteed to work with this setup as they may need extra JRE modules.

### Alpine vs Distroless

Currently there are two dockerfiles available for setup. They have extensions using image base.

|Image Base|alpine|distroless|
|:-|:--:|:--:|
|Distribution|alpine|debian|
|C Library|musl libc|glibc|
|Final Image Size|smaller|small|

Distroless: A custom-made image that mostly has the files needed to run the minecraft server.
* Bigger image due to `glibc` and JRE being compiled with `glibc`.
* Custom made from extracting files from `.deb` files.

Alpine: Its own linux distribution designed with a small image in mind.
* Uses `musl C` which uses less memory footprint but potentially less features that can support.

The `distroless` dockerfile setup is selected as default due to the `glibc` which is more commonly used.

If you want to try alpine, just go to the line where `dockerfile:` is located in [docker-compose.yaml](./docker-compose.yaml) and change the extension from `distroless` to `alpine`.

# Makefile Command References:

All the commands grouped by intended functionality. Replace `[MC Version]` with your desired minecraft version.

## Setup Commands:

- `make agree-eula` - Inserts the `eula.txt` file indicating you agree to the terms.
- `make find [Query]` - Search versions with matching `[Query]` that are available to use in place of `[MC Version]`.
- `make setup-env [MC Version]` - Sets up environment variables for [docker-compose.yaml](./docker-compose.yaml) to refer to.

## Build Commands:

1. Do `make setup-env` before doing the following commands:

- `make build` - Builds the image using cached layers when possible to save time.
- `make rebuild` - Builds the image from scratch regardless of presence of cached layers.

2. Bundled commands that you can run standalone:

- `make image [MC Version]` - Runs `make setup-env [MC Version]` and then `make build`.

## Launch Commands:

1. Do `make setup-env` before doing the following commands:

- `make up` - Launches the container based on the `.env` file. Skips rebuilding image if it exists.

2. Bundled commands that you can run standalone:

- `make server [MC Version]` - Runs `make setup-env [MC Version]` and then `make up`.
- `make new-server [MC Version]` - Starts up a new instance from fresh image build.

## Cleanup Commands:

- `make down` - Close the server.
- `make out-clean` - Clears the `out` folder leaving the eula and the `.gitignore` in place.
- `make clean` Does `make down` and then `make out-world`.
- `make reset` Cleans the project up. Only really use if no longer using this repository.

Surplus:

- `make image-clean` - Clears the images made in this project assuming tag base names have not changed.

# Credits

- [Mojang Studios](https://www.minecraft.net/) for providing the server JARs and metadata.
- [liebki's repo](https://github.com/liebki/MinecraftServerForkDownloads) for reference to auto-update github action and having populated most server links.
