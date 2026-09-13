package csv_parser

import (
	"encoding/csv"
	"errors"
	"os"
	"scripts/internal/utils/logger"
)

const CSV_COMMA = '|'

// Check if the binary can write to a new file in current directory.
func checkCanWrite() (err error) {
	// Cannot do anything when the binary cannot write to CSV file, thus fatal logging used.
	wd, err := os.Getwd()
	if err != nil {
		logger.Fatal(err)
		return
	}

	tmpFile, err := os.CreateTemp(wd, "stub.log")
	if err != nil {
		logger.Fatal(err) // Permission to create is denied.
		return
	}

	// Clean up immediately.
	tmpFile.Close()
	os.Remove(tmpFile.Name())
	return
}

func fileExists(filepath string) bool {
	_, err := os.Stat(filepath)
	return !errors.Is(err, os.ErrNotExist)
}

func ReadCSVFile(filepath string) (records [][]string, err error) {
	err = checkCanWrite()
	if err != nil {
		logger.Fatal(err)
		return
	}

	if !fileExists(filepath) { // Return just the header if file does not exist.
		logger.Warnf("File '%s' does not exist, but will be created.", filepath)
		records = [][]string{{"mcv", "url", "jmav"}}
		return
	}

	file, err := os.Open(filepath)
	logger.Debugf("Opening CSV file '%s' to read.", filepath)
	if err != nil {
		logger.Fatal(err)
		return
	}
	defer file.Close()

	logger.Debugf("Opened CSV file '%s' to read.", filepath)
	reader := csv.NewReader(file)
	reader.Comma = CSV_COMMA

	records, err = reader.ReadAll()
	if err != nil {
		logger.Fatal(err)
		return
	}
	logger.Debugf("CSV file '%s' has %d lines.", filepath, len(records))
	return
}

func WriteCSVFile(records [][]string, filepath string) (err error) {
	file, err := os.OpenFile(filepath, os.O_CREATE|os.O_WRONLY, 0644)
	logger.Debugf("Opening CSV file '%s' to write.", filepath)
	if err != nil {
		logger.Fatal(err)
		return
	}
	defer file.Close()

	writer := csv.NewWriter(file)
	defer writer.Flush()

	logger.Debugf("Opened CSV file '%s' to write %d lines.", filepath, len(records))
	writer.Comma = CSV_COMMA
	writer.UseCRLF = false

	err = writer.WriteAll(records)
	if err != nil {
		logger.Fatal(err)
		return
	}

	logger.Debugf("Written %d lines successfully to CSV file '%s'.", len(records), filepath)
	return
}
