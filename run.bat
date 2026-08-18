@ECHO OFF

docker info >NUL 2>NUL
IF %ERRORLEVEL% NEQ 0 (
	ECHO Docker is not installed/running.
	PAUSE
	EXIT /B 1
)

SETLOCAL

SET IMAGE_NAME=minecraft.vanilla.server
SET OUT_DIR=out
SET IS_FIRST_PROMPT=1
SET VALID_SEARCH_TERM=

:prompt
IF "%IS_FIRST_PROMPT%"=="0" (
	ECHO.
)

SET IS_FIRST_PROMPT=0

IF NOT EXIST %OUT_DIR%\eula.txt (
	ECHO Minecraft EULA Link: https://aka.ms/MinecraftEULA
	ECHO Agree to Minecraft's EULA by typing 'agree-eula' command.
	ECHO.
)

ECHO Enter a command prompt. Type 'help' for commands you can use.
SET /p ARG="> "

IF NOT EXIST %OUT_DIR% (
	MKDIR %OUT_DIR%
)

IF /i "%ARG%"=="exit" (
	GOTO :EOF
) ELSE IF /i "%ARG%"=="help" (
	CALL :help
) ELSE IF /i "%ARG%"=="reset" (
	CALL :clean-out-dir
	CALL :clean-container
	CALL :clean-images
) ELSE IF /i "%ARG%"=="clean" (
	CALL :clean-out-dir
) ELSE IF /i "%ARG%"=="clear" (
	CLS
	SET IS_FIRST_PROMPT=1
) ELSE IF /i "%ARG%"=="find" (
	CALL :list-mc-versions
) ELSE IF /i "%ARG%"=="run-server" (
	CALL :setup-server
) ELSE IF /i "%ARG%"=="server" (
	CALL :clean-container
	CALL :build-env
	IF DEFINED VALID_SEARCH_TERM (
		CALL :setup-server
	)
) ELSE IF /i "%ARG%"=="new-server" (
	CALL :clean-container
	CALL :clean-out-dir
	CALL :build-env
	IF DEFINED VALID_SEARCH_TERM (
		CALL :setup-server
	)
) ELSE IF /i "%ARG%"=="agree-eula" (
	CLS
	CALL :agree-eula
) ELSE (
	ECHO Invalid argument %ARG%
)

GOTO prompt

:help
ECHO Available Useful Commands:
ECHO clear - Clean the terminal window.
ECHO find - Searches the cache for available minecraft versions.
ECHO help - Prints this text.
ECHO.
ECHO Server Setup Commands:
ECHO agree-eula - Agree to Minecraft's EULA.
ECHO clean - Removes the contents from %OUT_DIR% directory.
ECHO server - Start a minecraft server.
ECHO run-server - Start an existing setup minecraft server.
ECHO.
ECHO Miscellaneous Commands (use at own risk):
ECHO new-server - Start a minecraft server from fresh.
ECHO reset - Set the project back to a clean state.

EXIT /B

:clean-out-dir
IF EXIST %OUT_DIR%\eula.txt (
	MOVE %OUT_DIR%\eula.txt eula.out >NUL
)
DEL /q /s %OUT_DIR%\* >NUL
FOR /d %%x in (%OUT_DIR%\*) DO (
	RD /s /q "%%x" >NUL
)
IF EXIST eula.out (
	MOVE eula.out %OUT_DIR%\eula.txt >NUL
)
EXIT /B

:clean-images
SET "IMAGE_LIST="
FOR /F "delims=" %%i IN ('docker images --filter "reference=%IMAGE_NAME%:*" -q') DO (
	SET "IMAGE_LIST=%IMAGE_LIST% %%i"
)
ECHO %IMAGE_LIST%
IF DEFINED IMAGE_LIST (
	SET "IMAGE_LIST=%IMAGE_LIST:~1%"
)
docker rmi %IMAGE_LIST%
EXIT /B

:clean-container
docker compose down 2>NUL
EXIT /B

:list-mc-versions
SET /p SEARCH_TERM="Enter Search Term: "
CALL scripts\find_versions.bat %SEARCH_TERM%
EXIT /B

:agree-eula
ECHO eula=TRUE> %OUT_DIR%\eula.txt
ECHO Agreed to Minecraft EULA.
EXIT /B

:build-env
SET VALID_SEARCH_TERM=
SET /p MC_VERSION="Enter Minecraft Version: "
CALL scripts\setup_mc_env.bat -img %IMAGE_NAME% -mcv "%MC_VERSION%"
IF %ERRORLEVEL% EQU 0 (
	SET VALID_SEARCH_TERM=%MC_VERSION%
)
EXIT /B

:setup-server
IF NOT EXIST .env (
	ECHO No server setup, please run "server" to create a server instance.
	EXIT /B
)
docker compose up -d
docker compose attach mc-server
EXIT /B

ENDLOCAL
