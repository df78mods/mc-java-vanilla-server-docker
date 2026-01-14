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

1. Read [Minecraft's EULA](https://aka.ms/MinecraftEULA) and if you agree, run the convenient `make agree-eula` command.

2. Run the command `make server [MC version]`, replacing [MC version] with your minecraft version to start your new minecraft server instance.

## Post setup:

- You will be given direct access to the server CLI.
  - Enter command `stop` in the server CLI to close the server. Recommended for graceful exit.
  - You can alternatively use `Ctrl-C` but generally not recommended.
- You can then `make up` later if you want to start the server up again.
- JVM arguments can be set in [docker-compose.yaml](./docker-compose.yaml) file in the `command:` line.
- The server files will be populated in the `out` folder so that users can access them and backup anytime.
- `make server` is only needed when you want to host a different version or initial setup.
- If you want to always have a clean server setup, run `make new-server [MC version]`

## Cleanup:

- `make down` clears the docker compose.
- `make clean-world` clears the world files, great for starting another version.
- `make clean` Does both the commands above.
- `make reset` Cleans the project up. Only really use if no longer using this repository.

## Notes

- If you want to reset the world, you can run `make clean-world` after exiting `make up`.
- It is a good idea to backup the `out/world` data incase you want to reload the world again.
- You can look at MC versions via `make find [Query version]` command or look at [available_versions.csv](./available_versions.csv)
- Try to `git pull` if the newest server version is not supported.
  - There is a github action that auto-populates the server versions every 24 hours.

## Extra

WARNING: Not for those new to docker.

### Environment only image

There is a build stage where only the JRE environment is made without downloading the server. Can be great for trying out other modded servers.

You can start up an instance by going to the existing [docker-compose.yaml](./docker-compose.yaml) and change the following:
1. Change the `target` value in `build` from `minecraft-server` to `env-base`.
2. Place the server JAR file in this directory. Recommended to rename the JAR file to `server.jar`.
3. Uncomment the volume bind for the server JAR in the yaml file.
4. Run `make server [MC Version]` as usual.

Disclaimer: Modded servers are not guaranteed to work with this setup as they may need extra JRE modules.

### Alpine vs Distroless

Currently there are two dockerfiles available for setup. They have extensions using image base.

|Image Base|alpine|distroless|
|:-|:--:|:--:|
|Distribution|alpine|debian|
|C Library|musl libc|glibc|
|Final Image Size|smaller|small|

Distroless: A debian-based image that mostly has the files needed to run the minecraft server.
* Bigger image due to `glibc` and JRE being compiled with `glibc`.
* More common C library used and more cross-platform support.

Alpine: Its own linux distribution designed with a small image in mind.
* Uses `musl C` which uses less memory footprint but potentially less features that can support.

The `distroless` dockerfile setup is selected as default due to the `glibc` which is more commonly used.

If you want to try alpine, just go to the line where `dockerfile:` is located in [docker-compose.yaml](./docker-compose.yaml) and change the extension from `distroless` to `alpine`.

# Credits

- [Mojang Studios](https://www.minecraft.net/) for providing the server JARs and metadata.
- [liebki's repo](https://github.com/liebki/MinecraftServerForkDownloads) for reference to auto-update github action and having populated most server links.
