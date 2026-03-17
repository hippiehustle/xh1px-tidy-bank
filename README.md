# xh1px's Tidy Bank
## Professional OSRS Bank Sorting Bot

```
 ███████╗██╗  ██╗██╗██████╗ ██╗  ██╗    ████████╗██╗██████╗ ██╗   ██╗
 ██╔════╝██║  ██║██║██╔══██╗╚██╗██╔╝    ╚══██╔══╝██║██╔══██╗╚██╗ ██╔╝
 █████╗  ███████║██║██████╔╝ ╚███╔╝        ██║   ██║██║  ██║ ╚████╔╝
 ██╔══╝  ██╔══██║██║██╔══██╗ ██╔██╗        ██║   ██║██║  ██║  ╚██╔╝
 ██║     ██║  ██║██║██████╔╝██╔╝ ██╗       ██║   ██║██████╔╝   ██║
 ╚═╝     ╚═╝  ╚═╝╚═╝╚═════╝ ╚═╝  ╚═╝       ╚═╝   ╚═╝╚═════╝    ╚═╝

        Intelligent Bank Organization for Old School RuneScape
```

[![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0-blue.svg)](https://www.autohotkey.com/)
[![Status](https://img.shields.io/badge/Status-Production_Ready-success.svg)]()
[![Items](https://img.shields.io/badge/Items-24,735-orange.svg)]()

---

## 🎯 What This Is

An **intelligent OSRS bank sorting bot** that automatically organizes your bank using:

✅ **24,735 tagged items** with hierarchical classification
✅ **AI-ready architecture** for vision-based item detection
✅ **Multiple sorting modes** (GE Value, Category, Alphabet, Item ID)
✅ **Anti-ban system** with human-like behavior
✅ **Stealth mode** for undetectable operation
✅ **Professional GUI** for easy configuration
✅ **Real-time logging** and error handling

---

## 🚀 Quick Start

### Prerequisites
1. **BlueStacks** Android emulator running OSRS Mobile
2. **ADB** (Android Debug Bridge) at `127.0.0.1:5555`
3. **AutoHotkey v2.0** installed

### Get Running in 3 Steps

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/xh1px-tidy-bank.git
cd xh1px-tidy-bank

# 2. (Optional) Configure via GUI
# Run src/config_gui.ahk to customize settings

# 3. Launch the bot
# Run src/main.ahk and press F1 to start
```

### Hotkeys
- **F1** - Toggle bot on/off
- **F2** - Emergency shutdown (panic button)
- **Esc** - Exit bot

---

## 📂 Project Structure

```
xh1px-tidy-bank/
│
├── 📁 src/                          # Source code
│   ├── main.ahk                     # 🎯 Main bot script (RUN THIS)
│   ├── config_gui.ahk               # GUI configuration tool
│   ├── json_parser.ahk              # JSON parsing utilities
│   ├── constants.ahk                # Global constants & config
│   └── 📁 lib/                      # Optional libraries
│       ├── item_grouping.ahk        # Item classification system
│       ├── bank_tab_resolver.ahk    # Conflict resolution
│       └── performance.ahk          # Performance monitoring
│
├── 📁 data/                         # Data files
│   ├── osrs-items-condensed.json    # Item database (24,735 items)
│   └── user_config.json             # User settings (auto-generated)
│
├── 📁 docs/                         # Documentation
│   ├── QUICKSTART.md                # Quick start guide
│   ├── DEPLOYMENT_GUIDE.md          # Deployment instructions
│   ├── START_HERE.md                # New user guide
│   └── 📁 guides/                   # Implementation guides
│       ├── ITEM_GROUPING_GUIDE.md   # Item classification system
│       ├── OCR_IMPLEMENTATION.md    # OCR integration guide
│       ├── AI_INTEGRATION.md        # AI/ML integration (advanced)
│       ├── CONFLICT_RESOLUTION_GUIDE.md  # Conflict handling
│       └── ITEM_GROUPING_USAGE.md   # Usage examples
│
├── 📁 tests/                        # Test files
│   ├── test_json_parser.ahk
│   ├── test_syntax.ahk
│   └── test_conflict_resolver.ahk
│
├── 📁 logs/                         # Runtime logs
│   └── tidybank_log.txt
│
├── 📁 archive/                      # Historical files
│   ├── old_reports/                 # Development reports
│   └── old_scripts/                 # Deprecated scripts
│
├── README.md                        # This file
├── .gitignore                       # Git ignore rules
└── xh1px_logo.png                   # Project logo
```

---

## 📚 Documentation

### 🎓 For New Users
- **[docs/QUICKSTART.md](docs/QUICKSTART.md)** - Get started in 5 minutes
- **[docs/START_HERE.md](docs/START_HERE.md)** - Complete beginner's guide
- **[docs/DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md)** - Production deployment

### 🔧 For Developers
- **[docs/guides/ITEM_GROUPING_GUIDE.md](docs/guides/ITEM_GROUPING_GUIDE.md)** - Item classification system
- **[docs/guides/CONFLICT_RESOLUTION_GUIDE.md](docs/guides/CONFLICT_RESOLUTION_GUIDE.md)** - Conflict handling
- **[docs/guides/OCR_IMPLEMENTATION.md](docs/guides/OCR_IMPLEMENTATION.md)** - OCR integration (advanced)
- **[docs/guides/AI_INTEGRATION.md](docs/guides/AI_INTEGRATION.md)** - AI/ML integration (advanced)

### 📖 API Reference
- **[src/constants.ahk](src/constants.ahk)** - All constants and helper functions
- **[src/json_parser.ahk](src/json_parser.ahk)** - JSON parsing library

---

## ✨ Features

### Core Functionality
- 🏦 **Automatic Bank Sorting** - Organizes items based on your preferences
- 🎯 **Multiple Sort Modes**:
  - **GE Value** - Sort by Grand Exchange price (high to low)
  - **Category** - Group by item type (coming soon)
  - **Alphabet** - Sort alphabetically by name
  - **Item ID** - Sort by OSRS item ID
- 📸 **Screenshot Detection** - Captures bank state for analysis
- 🎭 **Anti-Ban System** - Human-like delays and behaviors
- 🔇 **Stealth Mode** - Minimal footprint, undetectable operation

### Advanced Features
- 🗣️ **Voice Alerts** - Optional TTS notifications
- 🌍 **World Hopping** - Auto world-hop support (coming soon)
- ⏱️ **Session Management** - Auto-stop after configured time
- 📊 **Real-time Logging** - Track all bot activities
- 🔒 **Environment Validation** - Checks BlueStacks and ADB before starting

### Developer Features
- 🧠 **AI-Ready Architecture** - Prepared for ML-based item detection
- 🔌 **Modular Design** - Easy to extend and customize
- 📦 **Complete Item Database** - All 24,735 OSRS items tagged
- 🎨 **Modern GUI** - Easy configuration interface

---

## ⚙️ Configuration

### Via GUI (Recommended)
Run `src/config_gui.ahk` to configure:
- Anti-ban mode (Psychopath/Extreme/Stealth/Off)
- Sort mode (GEValue/Alphabet/ItemID)
- Voice alerts
- Session time limits
- OCR/Vision settings

### Manual Configuration
Edit `data/user_config.json`:
```json
{
    "AntiBan": "Psychopath",
    "VoiceAlerts": false,
    "WorldHop": false,
    "SortMode": "GEValue",
    "MaxSession": 240,
    "UseOCR": false,
    "StealthMode": true
}
```

---

## 🔒 Safety Features

### Anti-Ban Protection
- **Psychopath Mode**: Minimal delays (2% chance of 3-6 min breaks)
- **Extreme Mode**: Moderate delays (5% chance of 3-6 min breaks)
- **Stealth Mode**: Maximum safety (1% chance of 5-10 min breaks)
- **Human-like Movement**: Randomized drag paths and timings

### Emergency Controls
- **F2 Panic Button**: Instantly shuts down bot and locks device
- **Session Time Limits**: Auto-stop after configured duration
- **Environment Validation**: Ensures BlueStacks/ADB running before start

---

## 🛠️ Development

### Current Status
✅ Core bot functionality complete
✅ JSON parsing and database loading
✅ Anti-ban system implemented
✅ Configuration GUI working
🔄 Item detection (placeholder - needs OCR/AI)
📋 Category-based sorting (planned)
📋 AI vision integration (planned)

### Roadmap
1. **Phase 1**: OCR integration for item detection
2. **Phase 2**: AI vision model (YOLO/CNN)
3. **Phase 3**: Natural language configuration
4. **Phase 4**: Continuous learning system

See **[docs/guides/AI_INTEGRATION.md](docs/guides/AI_INTEGRATION.md)** for the full AI roadmap.

---

## 🐛 Troubleshooting

### Bot Won't Start
- Ensure BlueStacks is running
- Check ADB connection: `adb devices`
- Verify ADB is at `127.0.0.1:5555`

### Database Not Loading
- Check `data/osrs-items-condensed.json` exists
- Verify file is valid JSON (not corrupted)

### Items Not Detected
- Current version uses placeholder detection
- See `docs/guides/OCR_IMPLEMENTATION.md` for production setup
- Consider AI integration: `docs/guides/AI_INTEGRATION.md`

---

## 📝 License

This project is provided as-is for educational purposes. Use at your own risk. The developers are not responsible for any account bans or issues arising from using this bot.

**⚠️ Warning**: Using bots violates OSRS Terms of Service and can result in account bans.

---

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📧 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/xh1px-tidy-bank/issues)
- **Documentation**: See `docs/` directory
- **Guides**: See `docs/guides/` for advanced topics

---

## 🙏 Credits

- **Item Database**: Based on OSRSBox database
- **AutoHotkey v2**: [AutoHotkey.com](https://www.autohotkey.com/)
- **BlueStacks**: Android emulation
- **Contributors**: See GitHub contributors

---

**Built with ❤️ for the OSRS community**

*Last Updated: 2026-03-17*
