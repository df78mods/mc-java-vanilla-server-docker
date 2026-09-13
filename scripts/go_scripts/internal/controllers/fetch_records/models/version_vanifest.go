package models

import (
	"encoding/json"
	"go_scripts/internal/utils/logger"
	"io"
	"net/http"
)

type VersionSummary struct {
	ID  string `json:"id"`
	Url string `json:"url"` // This is the url to get detailed information about mentioned version.
}

type VersionManifest struct {
	Versions []VersionSummary `json:"versions"`
}

// Fetches the data of Mojang's version manifest to populate object.
func (v *VersionManifest) GetData() (err error) {
	logger.Debug("Fetching MC Java version manifest file.")
	res, err := http.Get("https://piston-meta.mojang.com/mc/game/version_manifest_v2.json")
	if err != nil {
		return logger.Error(err)
	}

	defer res.Body.Close()

	body, err := io.ReadAll(res.Body)
	if err != nil {
		return logger.Error(err)
	}

	logger.Debug("MC Java version manifest file acquired successfully.")
	return logger.Error(json.Unmarshal(body, v))
}
