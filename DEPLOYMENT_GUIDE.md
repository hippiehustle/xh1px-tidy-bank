# DEPLOYMENT GUIDE - xh1px's Tidy Bank v2.0

**Version:** 2.0
**Release Date:** November 14, 2025
**Status:** Production Ready

---

## TABLE OF CONTENTS

1. [Overview](#overview)
2. [System Requirements](#system-requirements)
3. [Pre-Deployment Checklist](#pre-deployment-checklist)
4. [Installation Steps](#installation-steps)
5. [Configuration](#configuration)
6. [Verification](#verification)
7. [Operation](#operation)
8. [Monitoring](#monitoring)
9. [Troubleshooting](#troubleshooting)
10. [Maintenance](#maintenance)
11. [Rollback Procedures](#rollback-procedures)

---

## OVERVIEW

### What is xh1px's Tidy Bank?

xh1px's Tidy Bank is an **OSRS Bank Sorting Bot** - an automation tool that organizes items in your Old School RuneScape bank account into 8 configurable tabs based on item type and user-defined categories.

### Key Features

- **Intelligent Organization:** Automatically categorizes 24,735+ items using 14 core groups
- **Conflict Resolution:** Handles items that could fit multiple categories using "lowest tab wins" rule
- **Flexible Configuration:** User-friendly GUI for customizing bank tab assignments
- **Safety Features:** Anti-ban modes, stealth delays, randomization to avoid detection
- **Session Management:** Configurable max session duration with automatic shutdown
- **Comprehensive Logging:** Full audit trail of all operations
- **Modern Interface:** Card-based GUI with color system and typography
- **Zero Dependencies:** Self-contained (JSON parser included, no external libraries)

### Architecture

```
config_gui.ahk          → User Configuration Interface (GUI)
    ↓
main_template_v2.ahk   → Bot Core Implementation
    ↓
bank_tab_resolver.ahk  → Conflict Resolution Engine
    ↓
item_grouping.ahk      → Item Classification System
    ↓
osrs-items-condensed.json → Item Database (24,735 items)
    ↓
ADB / BlueStacks       → Android Emulator Interface
```

---

## SYSTEM REQUIREMENTS

### Hardware

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 2 GHz Dual Core | 2.5+ GHz Quad Core |
| RAM | 4 GB | 8+ GB |
| Storage | 1 GB free | 2+ GB free |
| Screen | 1024x768 | 1920x1080+ |

### Software

| Component | Requirement | Version | Purpose |
|-----------|-------------|---------|---------|
| **Windows** | Required | 10/11 | Operating System |
| **AutoHotkey** | Required | 2.0+ | Script Engine |
| **BlueStacks** | Required | Latest | Android Emulator |
| **ADB Tools** | Required | Latest | Device Communication |
| **Tesseract OCR** | Optional | 5.0+ | Item Name Recognition |
| **.NET Framework** | Optional | 4.7+ | For advanced features |

### Network

- **Internet Connection:** Required for OSRS gameplay
- **Local Network:** ADB communication (localhost 5555)
- **Bandwidth:** < 1 Mbps during operation

### Disk Space

| Component | Size |
|-----------|------|
| AutoHotkey v2.0 | 20 MB |
| BlueStacks | 300 MB |
| OSRS Client | 500 MB |
| Bot Files | 10 MB |
| Logs (30 days) | 50 MB |
| **Total** | **~900 MB** |

---

## PRE-DEPLOYMENT CHECKLIST

### 1. System Verification
- [ ] Windows 10/11 installed (21H2 or later)
- [ ] Administrator access available
- [ ] 1+ GB free disk space
- [ ] 4+ GB available RAM
- [ ] Internet connection stable
- [ ] Firewall allows ADB (localhost:5555)
- [ ] No antivirus blocking execution

### 2. Dependencies Installation
- [ ] AutoHotkey v2.0 installed from [autohotkey.com](https://www.autohotkey.com)
- [ ] BlueStacks installed and updated to latest version
- [ ] ADB tools installed (Windows, macOS, or Linux)
- [ ] (Optional) Tesseract OCR installed from [GitHub](https://github.com/UB-Mannheim/tesseract/wiki)
- [ ] All paths added to system PATH variable

### 3. Files Preparation
- [ ] All .ahk source files present and readable
- [ ] osrs-items-condensed.json (5 MB) present
- [ ] user_config.json will be auto-created
- [ ] logs/ directory will be auto-created
- [ ] No corrupted or incomplete files

### 4. Testing Environment
- [ ] BlueStacks can start and run OSRS
- [ ] ADB can connect to BlueStacks (adb connect 127.0.0.1:5555)
- [ ] OSRS loads in emulator without errors
- [ ] Screenshots can be captured from device
- [ ] At least one bank account in OSRS

### 5. Backups
- [ ] OSRS save game backed up
- [ ] User data backed up (if applicable)
- [ ] Original .ahk files backed up
- [ ] Known good configuration documented

---

## INSTALLATION STEPS

### Step 1: Install Dependencies

#### 1a. AutoHotkey v2.0
```powershell
# Download from https://www.autohotkey.com/download/ahk2exe/
# Run installer
AutoHotkey_2.0-installer.exe

# Verify installation
autohotkey --version  # Should show v2.0.x
```

#### 1b. BlueStacks
```powershell
# Download from https://www.bluestacks.com/
# Run installer with default settings
BlueStacksInstaller.exe

# Start BlueStacks
# Configure resolution to 1920x1080 in Settings
```

#### 1c. ADB Tools
```powershell
# Download Android SDK Platform Tools from:
# https://developer.android.com/studio/releases/platform-tools

# Extract to: C:\adb\
# Add to PATH:
# 1. Right-click "This PC" → Properties
# 2. Advanced system settings → Environment Variables
# 3. Edit "Path" → Add "C:\adb"
# 4. Restart PowerShell

# Verify installation
adb --version  # Should show version info
```

#### 1d. Tesseract OCR (Optional)
```powershell
# Download from:
# https://github.com/UB-Mannheim/tesseract/wiki

# Run installer with default settings
tesseract-ocr-w64-setup-v5.x.exe

# Verify installation
tesseract --version  # Should show version info
```

### Step 2: Configure BlueStacks

1. **Start BlueStacks**
   - Launch application
   - Wait for Android to fully boot
   - Allow any permission prompts

2. **Configure Display**
   - Open Settings (⚙️ icon)
   - Display tab
   - Set resolution to 1920x1080
   - Set DPI to 240
   - Apply changes and restart

3. **Install OSRS**
   - Open Google Play Store
   - Search for "Old School RuneScape"
   - Install official Jagex client
   - Wait for installation to complete

4. **Configure ADB**
   - Open BlueStacks Settings
   - Advanced → ADB
   - Enable "Android Debug Bridge"
   - Port should be 5555
   - Apply and restart BlueStacks

### Step 3: Copy Bot Files

```powershell
# Create installation directory
mkdir C:\TidyBank
cd C:\TidyBank

# Copy all .ahk files
copy *.ahk C:\TidyBank\

# Copy database file
copy osrs-items-condensed.json C:\TidyBank\

# Create logs directory
mkdir C:\TidyBank\logs

# Verify files
dir C:\TidyBank\
# Should show:
# - main_template_v2.ahk
# - config_gui.ahk
# - json_parser.ahk
# - item_grouping.ahk
# - bank_tab_resolver.ahk
# - constants.ahk
# - performance.ahk
# - osrs-items-condensed.json
# - logs\ (directory)
```

### Step 4: Establish ADB Connection

```powershell
# Start BlueStacks first
# Then in PowerShell:

# Connect to BlueStacks
adb connect 127.0.0.1:5555

# Verify connection
adb devices
# Output should show:
# List of attached devices
# 127.0.0.1:5555    device

# If not listed, try:
adb disconnect
adb connect 127.0.0.1:5555
```

### Step 5: Initial Bot Launch

```powershell
# Navigate to bot directory
cd C:\TidyBank

# Run configuration GUI
.\config_gui.ahk

# Or from PowerShell:
Start-Process "C:\Program Files\AutoHotkey\AutoHotkey.exe" "config_gui.ahk"
```

---

## CONFIGURATION

### Step 1: Launch Configuration GUI

1. Run `config_gui.ahk`
2. Modern card-based interface opens
3. Two tabs available:
   - **Bot Settings:** Anti-ban, features, session
   - **Bank Configuration:** Tab assignments

### Step 2: Configure Bot Settings (Tab 1)

**Anti-Ban & Safety Section:**
- [ ] Select Anti-Ban Mode:
  - **Psychopath:** Minimal delays (fastest)
  - **Extreme:** Moderate delays
  - **Stealth:** Maximum randomization
  - **Off:** No anti-ban delays (not recommended)
- [ ] Enable Stealth Mode (Primary Safety) - Recommended: ON
  - Adds randomized delays and natural movements

**Session Configuration:**
- [ ] Set Max Session Duration (30-480 minutes)
  - Recommended: 240 minutes (4 hours)
  - Prevents excessive play-time detection

**Feature Toggles:**
- [ ] Enable OCR Item Detection
  - Recommended: ON (if Tesseract installed)
  - OFF if experiencing detection issues
- [ ] Enable Voice Alerts
  - Recommended: ON (audio feedback)
  - OFF if running in background/silent
- [ ] Enable World Hopping
  - Recommended: OFF (advanced feature)
  - ON to occasionally switch game worlds

### Step 3: Configure Bank Categories (Tab 2)

1. **Select Bank Tab:** Click Tab 1-8 buttons
2. **Available Groups:** Scrollable list on left
   - Shows 14 core groups and 40+ subgroups
   - Core groups: Skills, Equipment, Resources, Consumables, Tools, Quest Items, Currency, Clue Scrolls, PvP Items, Minigame Items, Cosmetics, Pets, Transportation, Miscellaneous

3. **Assign Groups:**
   - Check boxes to assign groups to current tab
   - Checking a core group auto-checks all subgroups
   - Groups can only be assigned to one tab
   - Right panel shows "Current Tab Assignment"

4. **Common Configurations:**

   **Example 1: Basic Setup**
   ```
   Tab 1: Skills (attack, strength, defense, magic, ranged, etc.)
   Tab 2: Equipment (armor, weapons, shields, jewelry)
   Tab 3: Consumables (food, potions, drinks)
   Tab 4: Resources (ore, logs, herbs, seeds)
   Tab 5: Tools (pickaxe, axe, hammer, harpoon)
   Tab 6: Currency (coins, tokens)
   Tab 7: Quest Items
   Tab 8: Cosmetics, Clue Scrolls
   ```

   **Example 2: Value-Based**
   ```
   Tab 1: High Value Items (rare drops, equipment)
   Tab 2: Medium Value (resources, tools)
   Tab 3: Consumables (stackable)
   Tab 4-8: Specialized (quests, cosmetics, etc.)
   ```

### Step 4: Save Configuration

1. Click "Save Bank Config" button
2. Confirmation message appears
3. main.ahk is automatically generated
4. Settings saved to user_config.json

---

## VERIFICATION

### Pre-Launch Verification

```autohotkey
; Create test_launch.ahk to verify everything
#Requires AutoHotkey v2.0

; Test 1: Verify all includes load
try {
    #Include json_parser.ahk
    #Include item_grouping.ahk
    #Include bank_tab_resolver.ahk
    #Include constants.ahk
    MsgBox("✓ All includes loaded successfully")
} catch as err {
    MsgBox("✗ Include failed: " . err.Message)
    ExitApp()
}

; Test 2: Verify database
try {
    if FileExist(A_ScriptDir . "\osrs-items-condensed.json") {
        MsgBox("✓ Item database found")
    } else {
        MsgBox("✗ Database not found")
        ExitApp()
    }
} catch as err {
    MsgBox("✗ Database check failed: " . err.Message)
    ExitApp()
}

; Test 3: Verify config file
try {
    if FileExist(A_ScriptDir . "\user_config.json") {
        MsgBox("✓ Configuration file exists")
    } else {
        MsgBox("! Configuration will be created on first run")
    }
} catch as err {
    MsgBox("✗ Config check failed: " . err.Message)
    ExitApp()
}

MsgBox("All verifications passed - Ready to launch!")
ExitApp()
```

### ADB Connection Verification

```powershell
# Test ADB connection
adb devices

# If device not listed:
adb disconnect
adb connect 127.0.0.1:5555
adb devices  # Should show device now

# Test screenshot capability
adb shell screencap -p /sdcard/test.png
adb pull /sdcard/test.png C:\temp\
dir C:\temp\test.png  # Should exist and be ~200KB+
```

### Bank Access Verification

1. Open OSRS in BlueStacks
2. Navigate to any bank location (Lumbridge, Falador, etc.)
3. Open bank
4. Verify all 8 tabs visible
5. Screenshot should capture bank interface
6. Close bank

### Configuration Verification

1. Run config_gui.ahk again
2. Bot Settings tab should show your saved settings
3. Bank Configuration should show your tab assignments
4. All assigned groups should appear in "Current Tab Assignment" section

---

## OPERATION

### Launching the Bot

#### Method 1: Direct Execution
```powershell
cd C:\TidyBank
.\main.ahk
```

#### Method 2: AutoHotkey.exe
```powershell
Start-Process "C:\Program Files\AutoHotkey\AutoHotkey.exe" "C:\TidyBank\main.ahk"
```

#### Method 3: Windows Explorer
1. Navigate to C:\TidyBank
2. Right-click main.ahk
3. Select "Run with AutoHotkey"

### Running the Bot

1. **Pre-Launch Setup:**
   - Ensure BlueStacks is running
   - Log into OSRS account
   - Navigate to a bank
   - Position bank window properly
   - Ensure no other bots/macros running

2. **Launch Bot:**
   - Run main.ahk from C:\TidyBank\
   - Verify ADB connection message
   - Bot initializes and starts monitoring

3. **During Operation:**
   - Let bot run uninterrupted
   - Don't close BlueStacks window
   - Don't trigger manual clicks in emulator
   - Monitor progress in logs/console

4. **Stopping the Bot:**
   - Press **F1** key to toggle bot on/off
   - Press **F1** again to resume
   - Hold **Escape** to force quit
   - Wait for clean shutdown (check logs)

### Understanding the Session

**Session Lifecycle:**
1. Bot initializes (0-5 sec)
2. ADB connection verified (1-3 sec)
3. Screenshots and scanning begins (5 sec intervals)
4. Items detected and tabs resolved (50-500 ms per item)
5. Items moved to correct tabs (1-5 sec per item)
6. Cycle repeats every 800 ms
7. Session ends when:
   - Max duration reached
   - User presses F1
   - Bank closes
   - Error occurs

**Example Session (4 items in bank):**
```
00:00 - Bot starts, ADB connects
00:05 - Screenshot captured
00:06 - 4 items detected
00:07 - Items resolved to tabs (2→Tab1, 1→Tab3, 1→Tab5)
00:08 - Items moved to tabs
00:09 - Next scan cycle begins
...
04:00 - Max session duration reached
04:00 - Bot gracefully shuts down
```

---

## MONITORING

### Log Files

**Location:** `C:\TidyBank\logs\tidybank_log.txt`

**Log Levels:**
- **INFO:** General information, normal operations
- **WARNING:** Potential issues, non-critical problems
- **ERROR:** Recoverable errors, operations failed
- **DEBUG:** Detailed diagnostic information

**Log Entry Format:**
```
[2025-11-14 14:30:45] INFO: Bank detected open (screenshot size: 245680 bytes)
[2025-11-14 14:30:46] DEBUG: Item detected via OCR at (151, 231): Iron sword
[2025-11-14 14:30:47] DEBUG: Item "Iron sword" resolved to Tab 2 (Equipment)
[2025-11-14 14:30:48] INFO: Item moved from inventory to Tab 2
```

### Real-Time Monitoring

While bot is running, check:

1. **Console Output:** (if running in interactive mode)
   - Should see log messages
   - No red error messages

2. **Performance Metrics:**
   - CPU usage: 20-60% during sorting
   - Memory usage: 150-300 MB
   - Network: < 1 Mbps

3. **BlueStacks Window:**
   - Should see items moving
   - Bank interface responsive
   - No visual glitches or freezes

### Health Checks

**Every 5 minutes:**
- [ ] Bot is still running (process exists)
- [ ] No error messages in log
- [ ] Items are being processed

**Every 30 minutes:**
- [ ] Performance metrics normal
- [ ] Memory not increasing unbounded
- [ ] Log file growing at expected rate

**Every 1 hour:**
- [ ] Review recent log entries for errors
- [ ] Check items moved to correct tabs
- [ ] Verify no duplicate movements
- [ ] Confirm session timer accurate

---

## TROUBLESHOOTING

### Common Issues & Solutions

#### Issue 1: "ADB connection failed"

**Symptoms:**
```
[ERROR] ADB connection to 127.0.0.1:5555 failed
[ERROR] Unable to execute screencap command
```

**Causes:**
- BlueStacks not running
- ADB not installed
- Firewall blocking port 5555
- Wrong ADB version

**Solutions:**
```powershell
# 1. Verify BlueStacks is running
tasklist | findstr BlueStacks  # Should show process

# 2. Restart ADB
adb kill-server
adb start-server
adb connect 127.0.0.1:5555

# 3. Verify connection
adb devices  # Should list device as "device"

# 4. Check firewall
# Windows Defender → Firewall → Allow app through
# Make sure "adb" or "Android SDK" is allowed

# 5. If still failing, restart BlueStacks
# Open BlueStacks
# Settings → Advanced → ADB
# Ensure enabled on port 5555
# Restart BlueStacks
```

#### Issue 2: "Screenshot file not found"

**Symptoms:**
```
[ERROR] Screenshot file does not exist at C:\Users\...\Temp\tidybank_screenshot.png
[WARNING] Bank status unknown - assuming bank is open
```

**Causes:**
- ADB screencap command failed
- Screenshot pull failed
- Temp directory inaccessible
- Insufficient disk space

**Solutions:**
```powershell
# 1. Test screenshot manually
adb shell screencap -p /sdcard/test.png
adb pull /sdcard/test.png C:\temp\

# 2. Verify temp directory writable
# Should be able to create files in C:\Users\[user]\AppData\Local\Temp\

# 3. Check disk space
# Need at least 500 MB free

# 4. If screenshot is created but pull fails
# Check Windows Temp directory permissions
# Right-click Temp → Properties → Security
# Ensure your user has full permissions
```

#### Issue 3: "Items not detected (OCR failing)"

**Symptoms:**
```
[WARNING] Item detected at (151, 231) but cannot identify - skipping
[DEBUG] Tesseract OCR error: tesseract.exe not found
```

**Causes:**
- Tesseract OCR not installed
- Tesseract not in PATH
- Screenshot quality poor
- Item names not recognized

**Solutions:**

Option A: Install Tesseract
```powershell
# Download from:
# https://github.com/UB-Mannheim/tesseract/wiki

# Run installer
tesseract-ocr-w64-setup-v5.x.exe

# Restart bot
```

Option B: Disable OCR (use fallback)
```ahk
; In config_gui.ahk, disable "Enable OCR Item Detection"
; Bot will use fallback icon matching and bank grid detection
```

Option C: Improve screenshot quality
```
BlueStacks Settings → Display
- Resolution: 1920x1080 (recommended)
- DPI: 240
- Brightness: 100%
- Contrast: 50% (normal)
```

#### Issue 4: "Session ends prematurely"

**Symptoms:**
```
[WARNING] Session time limit reached
[INFO] Bot shutting down after 3:42 session
```

**Causes:**
- Max session duration reached
- Bot crashed or stopped
- Manual shutdown (F1 pressed)
- Bank closed unexpectedly

**Solutions:**
```
# 1. Increase max session duration
config_gui.ahk → Bot Settings → Max Session Duration
Set to 480 (8 hours) instead of default 240

# 2. Check for crashes
Review logs for ERROR messages indicating crash

# 3. Keep bank open
Don't close bank during operation

# 4. Minimize interruptions
Don't press F1 during normal operation
```

#### Issue 5: "Wrong items in tabs"

**Symptoms:**
```
Items appearing in wrong tabs
Conflict resolution not working as expected
```

**Causes:**
- Item grouping configuration incorrect
- Conflict resolution not applied
- Tag mapping incomplete
- Item name misspelled in database

**Solutions:**
```
# 1. Review bank configuration
config_gui.ahk → Bank Configuration
Verify correct groups assigned to each tab

# 2. Check item grouping
Open item_grouping.ahk
Review CORE_GROUPS and tag assignments

# 3. Check logs for resolution details
Review DEBUG logs for item resolution process

# 4. Manually correct misplaced items
If only a few items wrong, move manually

# 5. Reconfigure and regenerate
Update bank configuration → Save
This generates new main.ahk with correct mappings
```

### Emergency Procedures

**If bot becomes unresponsive:**

```powershell
# 1. Press Escape key (force quit)
# 2. Wait 5 seconds
# 3. If still running:
taskkill /IM AutoHotkey.exe /F

# 4. Restart bot
./main.ahk
```

**If ADB connection stuck:**

```powershell
# Kill and restart ADB
adb kill-server
adb start-server

# Kill BlueStacks
taskkill /IM BlueStacks.exe /F

# Restart BlueStacks
# Wait for full boot (~30 sec)

# Restart bot
./main.ahk
```

**If bank corrupted:**

```
# 1. Close OSRS and BlueStacks
# 2. Restore from backup
# 3. Relaunch
# 4. Contact Jagex support if issue persists
```

---

## MAINTENANCE

### Daily Maintenance

- [ ] Review logs for errors
- [ ] Verify items in correct tabs
- [ ] Check for any security alerts
- [ ] Monitor performance metrics

### Weekly Maintenance

- [ ] Archive old log files (older than 7 days)
- [ ] Update OSRS client if prompted
- [ ] Run test suite (verify functionality)
- [ ] Check for AutoHotkey updates

### Monthly Maintenance

- [ ] Full system health check
- [ ] Review and optimize configuration
- [ ] Update Tesseract if available
- [ ] Backup user_config.json
- [ ] Review item database for updates
- [ ] Check for security patches

### Quarterly Maintenance

- [ ] Update all dependencies
- [ ] Review code for improvements
- [ ] Performance benchmark
- [ ] Security audit
- [ ] Documentation review
- [ ] Backup complete system

### Log Management

**Archive Old Logs:**
```powershell
# Keep only last 7 days
# Older logs should be archived
cd C:\TidyBank\logs

# Create archive
mkdir archive
Move-Item *.txt archive\ -Filter {$_.LastWriteTime -lt (Get-Date).AddDays(-7)}

# Compress archive
Compress-Archive archive\ logs_archive_$(Get-Date -Format yyyyMMdd).zip
Remove-Item archive\ -Recurse
```

**Log Retention Policy:**
- **7 days:** Active logs in tidybank_log.txt
- **30 days:** Archive in logs_archive_*.zip
- **1 year:** Backup storage (if needed for investigation)
- **After 1 year:** Safe to delete

---

## ROLLBACK PROCEDURES

### If Bot Causes Issues

**Scenario 1: Items moved to wrong tabs**

```
1. Stop the bot immediately (Press F1)
2. Manually move items back to correct tabs
3. Review bank configuration
4. Adjust grouping assignments
5. Regenerate bot configuration
6. Test with small batch first
7. Resume operation if successful
```

**Scenario 2: Bot crashes or hangs**

```
1. Kill bot process (Escape or taskkill)
2. Check recent log entries for error
3. Verify ADB connection
4. Restart BlueStacks
5. Relaunch bot
If persists:
6. Disable advanced features (OCR, world hopping)
7. Simplify configuration
8. Try with shorter max session duration
```

**Scenario 3: Performance degradation**

```
1. Stop bot
2. Clear logs (backup first)
3. Restart BlueStacks
4. Reduce number of items to sort
5. Increase anti-ban delays
6. Monitor performance
```

**Complete Rollback:**

```powershell
# If major issues, return to previous version

# 1. Stop bot
# 2. Back up current config
copy user_config.json user_config.json.backup

# 3. Replace bot files with known good version
# (You should have backed these up before deployment)
copy C:\TidyBank_Backup_v1.9\*.ahk C:\TidyBank\
copy C:\TidyBank_Backup_v1.9\osrs-items-condensed.json C:\TidyBank\

# 4. Test bot
.\main.ahk

# 5. If working, investigate issue with v2.0
# 6. When ready, update to fixed version
```

### Version Compatibility

| Version | Status | Notes |
|---------|--------|-------|
| 1.9 | Deprecated | Last stable legacy version |
| 2.0 | Current | Production release |
| 2.1 | Future | Planned improvements |

---

## ADDITIONAL RESOURCES

### Support Channels

- **GitHub Issues:** [Report bugs and feature requests](https://github.com/xh1px/xh1px-tidy-bank/issues)
- **Documentation:** See `/docs` folder for detailed guides
- **Logs:** Check `C:\TidyBank\logs\` for diagnostic information

### Useful Links

- **AutoHotkey Documentation:** https://www.autohotkey.com/docs/v2/
- **BlueStacks Forum:** https://www.bluestacks.com/support/
- **OSRS Official:** https://www.oldschool.runescape.com/

### Related Documentation

- See `FULL_DEBUG_ANALYSIS.md` for code analysis and architecture
- See `TESTING_CHECKLIST.md` for comprehensive test suite
- See `QUICK_START_V2.md` for 5-minute quick start
- See `README.md` for project overview

---

## SIGN-OFF

**Deployment Status:** ✓ Ready for Production

**Verified By:** Development Team
**Date:** November 14, 2025
**Environment:** Windows 10/11, AutoHotkey v2.0, BlueStacks Latest

**Approved For:**
- ✓ Personal use
- ✓ Single account operation
- ✓ Educational study of bot architecture
- ⚠ Commercial use (requires licensing)

**Liability Disclaimer:**
This software is provided as-is for educational purposes. The creators are not responsible for any account bans, item loss, or other consequences resulting from use. Use at your own risk and in compliance with game terms of service.

---

**Document Version:** 1.0
**Last Updated:** November 14, 2025
**Next Review:** 30 days post-deployment
