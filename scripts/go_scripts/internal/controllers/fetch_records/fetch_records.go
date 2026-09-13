package fetch_records

import (
	"scripts/internal/controllers/fetch_records/models"
	"scripts/internal/utils/logger"
	"strconv"
	"time"
)

const API_RATE_LIMIT time.Duration = 1500 * time.Millisecond

func GetAllRecordsAfterVersion(version string) (records [][]string, err error) {
	var vM models.VersionManifest
	err = vM.GetData()
	if err != nil {
		return
	}

	logger.Debugf("Fetching versions after '%s'.", version)
	for i, vD := range vM.Versions {
		if vD.ID == version {
			logger.Debugf("Halt looping the list at index %d of manifest version list.", i)
			break
		}

		time.Sleep(API_RATE_LIMIT) // Do not hit rate limit.
		var dV models.DetailedVersion
		err = dV.GetData(vD.Url)
		if err != nil {
			break
		}

		if dV.Downloads.Server == nil {
			logger.Warnf("Server URL not available for version '%s'.", vD.ID)
			continue
		}

		record := []string{vD.ID, dV.Downloads.Server.Url, strconv.Itoa(dV.JavaVersion.MajorVersion)}
		records = append(records, record)
		logger.Infof("Metadata acquired:\n - Version: %s\n - URL: %s\n - Java Minimum Version: %s", record[0], record[1], record[2])
	}

	return
}
