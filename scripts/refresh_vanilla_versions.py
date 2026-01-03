import json
import sys
import time
import requests

MOJANG_MANIFEST_URL = "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"

def getJson(url: str) -> dict[str, any]:
    """
    Fetches JSON data from a given URL.

    Args:
        url (str): The URL to fetch data from.

    Returns:
        dict (dict): Parsed JSON data from the response.
    """
    response = requests.get(url=url, timeout=120)

    if response.status_code != 200:
        print(f"Error: Failed to fetch data from {url}")
        sys.exit(1)

    return response.json()

def getExistingEntries() -> dict[str, dict[str, any]]:
    """
    Get the dict form of the existing entry from "available_versions.json".

    Returns:
        dict (dict[str, dict[str, any]]): The result in Python Dict form.
    """
    existsLink = {}
    with open("available_versions.json", "r") as f:
        existsLink = json.loads(f.read())
    return existsLink

def getAllMissingVanillaMetaDataJSON(excluded: dict[str, any]) -> dict[str, str]:
    """
    Fetch all of Mojang's MC versions. Attempt to exclude existing entries.
    
    Args:
        excluded (dict[str, str]): The dict to exclude. The key of the dict is the important bit.
    
    Returns:
        dict (dict[str, str]): The dict with the version as the key and the url to the manifest json for the respective version.
    """
    allMetaData = getJson(MOJANG_MANIFEST_URL)
    includedMetaDataUrls = {}

    if "versions" not in allMetaData:
        return includedMetaDataUrls

    for version in allMetaData["versions"]:
        key = version["id"]
        # Guaranteed order of newest on top so break if in excluded.
        if key in excluded:
            break

        includedMetaDataUrls[key] = version["url"]
    
    return includedMetaDataUrls

def fetchRequiredMetaData(url: str) -> dict[str, any]:
    """
    Use the url that ideally fetches the manifest data for the minecraft version.
    
    Args:
        url (str): The URL to fetch data from.

    Returns:
        dict (dict): Parsed JSON data with the url to download link and supported java version.
    """
    metadata = getJson(url)
    result = {}
    
    for key in ["downloads", "javaVersion"]:
        if key not in metadata:
            return {}
        
    if "server" in metadata["downloads"]:
        result["url"] = metadata["downloads"]["server"]["url"]
    
    if "majorVersion" in metadata["javaVersion"]:
        result["javaVersion"] = metadata["javaVersion"]["majorVersion"]
    
    return result

def getMissingEntries(items: dict[str, str]) -> dict[str, any]:
    """
    Using the argument, get the appropriate manifest entries and return the dict.
    
    Args:
        items (dict[str, str]): The items consisting of the version as the key and the manifest url as the value.

    Returns:
        dict (dict[str, any]): Dicts using version as key and parsed JSON data with the url to download link and supported java version as the value respectively.
    """
    result = {}
    for version, url in items.items():
        time.sleep(1.5) # Rate limit delay of 1.5 seconds. Ideally only 1-2 new entries per run so should not run for long.
        metadata = fetchRequiredMetaData(url)
        if len(metadata.keys()) == 2:
            result[version] = metadata
    return result

def main() -> None:
    existingEntries = getExistingEntries()
    missingEntries = getMissingEntries(getAllMissingVanillaMetaDataJSON(existingEntries))
    newResultEntry = missingEntries | existingEntries
    with open("available_versions.json", "w") as f:
        f.write(json.dumps(newResultEntry))

if __name__ == "__main__":
    main()
