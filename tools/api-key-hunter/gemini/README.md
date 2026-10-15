# Gemini API Key Toolkit

A toolkit for discovering, validating, and testing exposed Google Gemini API keys.

It consists of two components:

- **Gemisc.py** – A high-speed Python scanner that discovers exposed Google API keys from websites and JavaScript files, verifies them against the Gemini API, and identifies the services each key can access.
- **lostsec.html** – A browser-based Gemini client that lets you interact directly with the Gemini API using discovered API keys. No backend or server required.

> [!IMPORTANT]
> 🎥 A complete walkthrough of the toolkit is available here:
https://youtu.be/3KMUnLdlOSE?si=j0FZ5WRFW-jBgi5d

Jump to **11:24** to see this tool features in action.

---

# Gemisc.py

A multi-threaded reconnaissance tool for discovering exposed Google API keys, validating them, and identifying accessible Gemini capabilities.

## Features

- Scan a single website or an entire target list
- Automatically crawl and scan linked JavaScript files
- Extract exposed Google API keys
- Verify whether discovered keys are active
- Detect supported Gemini capabilities:
  - 💬 Text Generation
  - 🖼️ Imagen 4
  - 🔊 Text-to-Speech (TTS)
  - 🎬 Veo 3 Video Generation
- Referer spoofing to bypass referer-restricted keys
- Multi-threaded scanning with live progress
- Save discovered keys and verification results
- Interactive menu mode

## Installation

```bash
pip install requests colorama tqdm urllib3
```

## Usage

```bash
python Gemisc.py -t example.com

python Gemisc.py -f targets.txt

python Gemisc.py -l keys.txt --verify

python Gemisc.py
```

## Arguments

| Option | Description |
|---------|-------------|
| `-t` | Scan a single domain or URL |
| `-f` | Scan domains listed in a file |
| `-l` | Verify API keys from a file |
| `--verify` | Enable verification mode |
| `-o` | Save output (default: `results.txt`) |
| `--timeout` | Request timeout (default: `8`) |
| `-q` | Quiet mode |
| `-h` | Display help |

## Operating Modes

| Mode | Description |
|------|-------------|
| **Scan** | Discover exposed API keys in HTML and JavaScript files |
| **Verify** | Validate discovered keys against the Gemini API |
| **Capabilities** | Identify which Gemini services each key can access |

---

# lostsec.html

A standalone browser client for interacting with the Gemini API using discovered or personal API keys.

No installation, backend, or web server required.

Simply open the file in your browser and start chatting.

## Features

- Supports all major Gemini models
- Multi-turn conversation memory
- Image understanding (Vision)
- File upload support
- Built-in code editor with syntax highlighting
- Imagen 4 image generation
- Export chat history
- Secure local storage for API keys and conversations
- Fully client-side

## Usage

1. Open **lostsec.html** in your browser.
2. Paste a Gemini API key.
3. Click **Authenticate**.
4. Choose a model.
5. Start chatting.

---

# Disclaimer

- Only scan systems you own or are explicitly authorized to test.
- This project is intended for security research and educational purposes.
- Protect any API keys you discover and disclose exposed credentials responsibly.
