@ECHO OFF

SETLOCAL enabledelayedexpansion

SET SEARCH_TERM=%*
SET LINE_COUNT=0
SET LINE=

FOR /F "skip=1 usebackq tokens=1 delims=|" %%A IN ("scripts\available_versions.csv") DO (
	SET "CURRENT_VERSION=%%A"
	IF NOT "!CURRENT_VERSION:%SEARCH_TERM%=!"=="!CURRENT_VERSION!" (
		SET /a LINE_COUNT+=1
		SET "LINE[!LINE_COUNT!]=%%A"
	)
)

IF /i "%LINE_COUNT%"=="0" (
	ECHO There are no results.
) ELSE (
	ECHO Current Results:
	FOR /l %%i IN (%LINE_COUNT%, -1, 1) DO (
		ECHO !LINE[%%i]!
	)
)

ENDLOCAL
