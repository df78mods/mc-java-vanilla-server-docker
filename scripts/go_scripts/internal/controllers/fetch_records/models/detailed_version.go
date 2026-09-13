package models

import (
	"encoding/json"
	"io"
	"net/http"
	"scripts/internal/utils/logger"
)

type DetailedVersionDownload struct {
	Url string `json:"url"`
}

type DetailedVersionDownloads struct {
	Server *DetailedVersionDownload `json:"server,omitempty"`
}

type DetailedJavaVersion struct {
	MajorVersion int `json:"majorVersion"`
}

type DetailedVersion struct {
	Downloads   DetailedVersionDownloads `json:"downloads"`
	JavaVersion DetailedJavaVersion      `json:"javaVersion"`
}

// Fetches the detailed version data from URL to populate object.
func (v *DetailedVersion) GetData(url string) (err error) {
	logger.Debugf("Fetching information from url '%s'.", url)
	res, err := http.Get(url)
	if err != nil {
		return logger.Error(err)
	}

	defer res.Body.Close()

	body, err := io.ReadAll(res.Body)
	if err != nil {
		return logger.Error(err)
	}

	logger.Debugf("Information from url '%s' fetched successfully.", url)
	return logger.Error(json.Unmarshal(body, v))
}
