@ECHO OFF

SETLOCAL enabledelayedexpansion

CALL :set-mc-env
EXIT /B %ERRORLEVEL%

:set-mc-env
SET CSV_SEP="|"

FOR %%X IN (%*) DO (
	IF DEFINED NEXT_IS_VAL (
		:: Assign the current token to the flag caught in the last iteration
		SET "!NEXT_IS_VAL!=%%~X"
		SET "NEXT_IS_VAL="
	) ELSE IF "%%~X"=="-img" (
		SET "NEXT_IS_VAL=IMAGE_NAME"
	) ELSE IF "%%~X"=="--image" (
		SET "NEXT_IS_VAL=IMAGE_NAME"
	) ELSE IF "%%~X"=="-mcv" (
		SET "NEXT_IS_VAL=MC_VERSION"
	) ELSE IF "%%~X"=="--minecraft-version" (
		SET "NEXT_IS_VAL=MC_VERSION"
	) ELSE IF "%%~X"=="--help" (
		CALL :help-text
		EXIT /B 0
	) ELSE IF "%%~X"=="-h" (
		CALL :help-text
		EXIT /B 0
	) ELSE (
		CALL :help-text
		EXIT /B 1
	)
)

IF NOT DEFINED MC_VERSION (
	ECHO "Argument '' is NOT a valid version number. Please try a different version."
	EXIT /B 1
)

IF NOT DEFINED IMAGE_NAME (
	CALL :help-text
	EXIT /B 1
)

FOR /F "skip=1 usebackq tokens=1,2,3 delims=|" %%A IN ("scripts\available_versions.csv") DO (
	IF "%%~A"=="%MC_VERSION%" (
		SET JAVA_VERSION=%%~C
		SET SERVER_LINK=%%~B
	)
)

IF NOT DEFINED SERVER_LINK (
	ECHO "Argument '%MC_VERSION%' is NOT a valid version number. Please try a different version."
	EXIT /B 1
)

ECHO JAVA_VERSION=%JAVA_VERSION%> .env
ECHO IMAGE_NAME=%IMAGE_NAME%>> .env
ECHO SERVER_LINK=%SERVER_LINK%>> .env
ECHO MC_VERSION=%MC_VERSION%>> .env

ENDLOCAL
EXIT /B 0

:help-text
ECHO Usage: %~nx0 -img IMAGE_NAME -mcv MC_VERSION
ECHO.
ECHO This script sets up the minecraft server environment variables for docker to build.
ECHO.
ECHO OPTIONS:
ECHO    -img IMAGE_NAME  The name of the image to use.
ECHO    -mcv MC_VERSION  The version of minecraft version server to use.
ECHO    -h               Show this message
EXIT /B
