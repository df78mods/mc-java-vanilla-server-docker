package main

import (
	"flag"
	"go_scripts/internal/controllers/csv_parser"
	"go_scripts/internal/controllers/fetch_records"
	"os"
)

var csvFilePath string

func addNewRecordsToTop(existing, new [][]string) [][]string {
	modRecords := make([][]string, 0, len(existing)+len(new))
	modRecords = append(modRecords, existing[0]) // Existing should have header.
	modRecords = append(modRecords, new...)
	modRecords = append(modRecords, existing[1:]...)
	return modRecords
}

func init() {
	flag.StringVar(&csvFilePath, "src-csv", "available_versions.csv", "The name of the file to store the records in.")
	flag.Bool("verbose", false, "Tells the application to print debug text.")
}

func main() {
	flag.Parse()

	existingRecords, err := csv_parser.ReadCSVFile(csvFilePath)
	if err != nil {
		os.Exit(1)
	}

	var latestExistingVersion string
	if len(existingRecords) > 1 { // Skip to second entry since 1st entry is header.
		latestExistingVersion = existingRecords[1][0]
	}

	newRecords, err := fetch_records.GetAllRecordsAfterVersion(latestExistingVersion)
	if err != nil {
		os.Exit(1)
	}

	existingRecords = addNewRecordsToTop(existingRecords, newRecords)
	err = csv_parser.WriteCSVFile(existingRecords, csvFilePath)
	if err != nil {
		os.Exit(1)
	}
}
