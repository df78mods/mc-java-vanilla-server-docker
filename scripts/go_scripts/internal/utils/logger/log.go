package logger

import (
	"fmt"
	"log"
	"os"
	"runtime/debug"
	"time"
)

type logType string

const (
	logInfo  logType = "INFO"
	logWarn  logType = "WARN"
	logDebug logType = "DEBUG"
	logError logType = "ERROR"
	logFatal logType = "FATAL"
)
const TIME_FORMAT = "2006-01-02 15:04:05.000"

var stdinLogger *log.Logger = log.New(os.Stdout, "", 0)
var stderrLogger *log.Logger = log.New(os.Stderr, "", 0)

var Debugf func(text string, v ...any) = func(text string, v ...any) {}
var Debug func(text string) = func(text string) {}

func init() {
	verbose := false
	for _, arg := range os.Args {
		if arg == "-v" || arg == "--verbose" {
			verbose = true
			break
		}
	}

	if verbose {
		Debugf = _debugf
		Debug = _debug
	}
}

func print(logRef *log.Logger, level logType, text string) {
	timestamp := time.Now().Format(TIME_FORMAT)
	logRef.Printf("%s - %s - %s", timestamp, level, text)
}

func printf(logRef *log.Logger, level logType, text string, v ...any) {
	timestamp := time.Now().Format(TIME_FORMAT)
	logRef.Printf("%s - %s - %s", timestamp, level, fmt.Sprintf(text, v...))
}

func Info(text string) {
	print(stdinLogger, logInfo, text)
}

func Infof(text string, v ...any) {
	printf(stdinLogger, logInfo, text, v...)
}

func Warn(text string) {
	print(stderrLogger, logWarn, text)
}

func Warnf(text string, v ...any) {
	printf(stderrLogger, logWarn, text, v...)
}

// Prints an error with the stack trace of the call.
//
// Returns the same error as the argument.
func Error(err error) error {
	if err == nil { // No error, so it becomes a no-op function.
		return nil
	}
	timestamp := time.Now().Format(TIME_FORMAT)
	stderrLogger.Printf("%s - %s - %v\n\n%s", timestamp, logError, err, debug.Stack())
	return err
}

func Fatal(err error) {
	timestamp := time.Now().Format(TIME_FORMAT)
	stderrLogger.Printf("%s - %s - %v\n\n%s", timestamp, logFatal, err, debug.Stack())
	os.Exit(1)
}

func _debug(text string) {
	print(stderrLogger, logDebug, text)
}

func _debugf(text string, v ...any) {
	printf(stderrLogger, logDebug, text, v...)
}
