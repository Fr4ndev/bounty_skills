## Overview

A Python tool for testing Google Maps API keys against 21 different Google API endpoints to check which services are exposed and vulnerable.
---
> [!IMPORTANT]
🎥 For a complete walkthrough of the tool, watch the demo video here: https://youtu.be/3KMUnLdlOSE. The feature shown below starts at **20:27**.

## Features

- Tests a single key or a list of keys from a file
- Checks 21 Google API endpoints in one run
- Shows PoC endpoint URLs for each vulnerability found
- Proxy support for routing traffic
- Quiet mode to show only vulnerable results
- Save vulnerable URLs to output file
- Ctrl+C safe — stops cleanly without crashing

---

## Requirements

```
pip install requests urllib3
```

---

## Usage

```
python3 keyhunt.py -k <api_key>
python3 keyhunt.py -k <api_key> --poc
python3 keyhunt.py -kf api_keys.txt --poc
python3 keyhunt.py -kf api_keys.txt -q -o output.txt
```

---

## Arguments

| Flag | Description |
|------|-------------|
| `-k` | Single Google Maps API key to test |
| `-kf` | File with API keys, one per line |
| `-p` | Proxy URL (e.g. http://127.0.0.1:8080) |
| `--poc` | Show vulnerable endpoint URLs |
| `-q` | Quiet mode, only show vulnerable APIs |
| `-o` | Save vulnerable URLs to file |

---

## APIs Checked

| # | API |
|---|-----|
| 1 | Custom Search API |
| 2 | Static Map API |
| 3 | Street View API |
| 4 | Directions API |
| 5 | Geocode API |
| 6 | Distance Matrix API |
| 7 | Find Place Text API |
| 8 | Autocomplete API |
| 9 | Elevation API |
| 10 | Timezone API |
| 11 | Nearest Roads API |
| 12 | Geolocation API |
| 13 | Snap to Roads API |
| 14 | Speed Limit API |
| 15 | Place Details API |
| 16 | Nearby Search API |
| 17 | Text Search API |
| 18 | Place Photo API |
| 19 | FCM API |
| 20 | Query Autocomplete API |
| 21 | Generative Language API |

---

## Output

Each API will show one of two results:

- `[VULN]` — API is accessible with the provided key
- `[+]` — API is restricted or not enabled

---

## Notes

- Only test keys you own or have authorization to test
- For educational and research purposes only
