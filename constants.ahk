#Requires AutoHotkey v2.0

; ==========================================
; GLOBAL CONSTANTS - Tidy Bank
; Centralized configuration for coordinates and settings
; ==========================================

class BankCoordinates {
    ; UI Grid coordinates for bank interface
    static GRID_START_X := 71
    static GRID_START_Y := 171
    static GRID_CELL_SPACING := 60
    static GRID_COLS := 8
    static GRID_ROWS := 8
    static GRID_CELL_CENTER_OFFSET := 21

    ; Bank tab coordinates
    static TAB_BASE_X := 150
    static TAB_SPACING := 60
    static TAB_Y := 80
    static TAB_COUNT := 8

    ; Screen center for interactions
    static SCREEN_CENTER_X := 960
    static SCREEN_CENTER_Y := 540

    ; Get grid cell position
    static GetCellPosition(row, col) {
        if (row < 0 || row >= this.GRID_ROWS || col < 0 || col >= this.GRID_COLS) {
            return Map()
        }

        return Map(
            "x", this.GRID_START_X + (col * this.GRID_CELL_SPACING) + this.GRID_CELL_CENTER_OFFSET,
            "y", this.GRID_START_Y + (row * this.GRID_CELL_SPACING) + this.GRID_CELL_CENTER_OFFSET
        )
    }

    ; Get bank tab X coordinate by tab number (1-8)
    static GetTabXCoordinate(tabNum) {
        if (tabNum < 1 || tabNum > this.TAB_COUNT) {
            return 0
        }
        return this.TAB_BASE_X + ((tabNum - 1) * this.TAB_SPACING)
    }

    ; Get bank tab coordinates
    static GetTabCoordinates(tabNum) {
        return Map(
            "x", this.GetTabXCoordinate(tabNum),
            "y", this.TAB_Y
        )
    }
}

class TimeConstants {
    ; Timing for operations (in milliseconds)
    static SCREENSHOT_DELAY := 200
    static TAB_SWITCH_DELAY := 300
    static DRAG_DURATION := 150
    static ADB_TIMEOUT := 5000
    static ITEM_SCAN_DELAY := 100

    ; Anti-ban delay ranges (in milliseconds)
    static SHORT_PAUSE_MIN := 100
    static SHORT_PAUSE_MAX := 500
    static MEDIUM_PAUSE_MIN := 500
    static MEDIUM_PAUSE_MAX := 2000
    static LONG_PAUSE_MIN := 5000
    static LONG_PAUSE_MAX := 15000

    ; Session timing
    static LOOP_INTERVAL := 800
    static SESSION_CHECK_INTERVAL := 60000  ; Check every minute

    ; Generate random pause within range
    static GetShortPause() {
        return Random(this.SHORT_PAUSE_MIN, this.SHORT_PAUSE_MAX)
    }

    static GetMediumPause() {
        return Random(this.MEDIUM_PAUSE_MIN, this.MEDIUM_PAUSE_MAX)
    }

    static GetLongPause() {
        return Random(this.LONG_PAUSE_MIN, this.LONG_PAUSE_MAX)
    }
}

class FilePathConstants {
    ; Base directories
    static SCRIPT_DIR := A_ScriptDir
    static TEMP_DIR := A_Temp
    static LOG_DIR := A_ScriptDir . "\logs"

    ; File names
    static SCREENSHOT_FILE := A_Temp . "\tidybank_screenshot.png"
    static CONFIG_FILE := A_ScriptDir . "\user_config.json"
    static DATABASE_FILE := A_ScriptDir . "\osrs-items-condensed.json"
    static TEMPLATE_FILE := A_ScriptDir . "\main_template_v2.ahk"
    static LOG_FILE := A_ScriptDir . "\logs\tidybank_log.txt"

    ; Ensure log directory exists
    static EnsureLogDirectory() {
        if !DirExist(this.LOG_DIR) {
            try {
                DirCreate(this.LOG_DIR)
                return true
            } catch as err {
                return false
            }
        }
        return true
    }
}

class ADBConstants {
    ; ADB connection settings
    static DEVICE_ADDRESS := "127.0.0.1:5555"
    static DEVICE_ID := "adb -s " . this.DEVICE_ADDRESS

    ; ADB commands
    static CMD_SCREENCAP := " shell screencap -p /sdcard/bank.png"
    static CMD_PULL := ' pull /sdcard/bank.png "'
    static CMD_TAP := " shell input tap"
    static CMD_SWIPE := " shell input swipe"
    static CMD_KEYEVENT := " shell input keyevent"
}

class ValidationConstants {
    ; Validation ranges
    static MAX_SESSION_MIN := 30
    static MAX_SESSION_MAX := 1440
    static DEFAULT_MAX_SESSION := 120

    ; AntiBan modes
    static ANTIBAN_MODES := ["Psychopath", "Extreme", "Stealth", "Off"]

    ; Sort modes
    static SORT_MODES := ["Category", "GEValue", "Alphabet", "ItemID"]

    ; Valid configuration keys
    static VALID_CONFIG_KEYS := ["AntiBan", "VoiceAlerts", "WorldHop", "MaxSession", "UseOCR", "StealthMode", "BankCategories"]

    ; Validate antiban mode
    static IsValidAntiBanMode(mode) {
        for validMode in this.ANTIBAN_MODES {
            if (mode == validMode) {
                return true
            }
        }
        return false
    }

    ; Validate MaxSession value
    static IsValidMaxSession(value) {
        numValue := Number(value)
        return (numValue >= this.MAX_SESSION_MIN && numValue <= this.MAX_SESSION_MAX)
    }

    ; Validate tab number
    static IsValidTabNumber(tabNum) {
        numTab := Number(tabNum)
        return (numTab >= 1 && numTab <= 8)
    }

    ; Validate row/col for grid
    static IsValidGridCell(row, col) {
        return (row >= 0 && row < 8 && col >= 0 && col < 8)
    }
}

class ColorConstants {
    ; UI Color palette
    static PRIMARY_BG := "0a0e14"
    static SECONDARY_BG := "151b24"
    static TERTIARY_BG := "1a2332"
    static PRIMARY_ACCENT := "00d9ff"
    static SECONDARY_ACCENT := "0ea5e9"
    static PRIMARY_TEXT := "e5f4ff"
    static SECONDARY_TEXT := "7a8fa3"
    static TERTIARY_TEXT := "4a5a6a"
    static BUTTON_BORDER := "0ea5e9"
    static INPUT_BORDER := "2a3f52"
    static SUCCESS := "00d9ff"
    static WARNING := "fbbf24"
    static ERROR := "ef4444"
}

class LogLevelConstants {
    static INFO := "INFO"
    static WARNING := "WARNING"
    static ERROR := "ERROR"
    static DEBUG := "DEBUG"
}

; ==========================================
; HELPER UTILITY FUNCTIONS
; ==========================================

; Safe sleep with validation
SafeSleep(ms) {
    numMs := Number(ms)
    if (numMs > 0) {
        Sleep(numMs)
        return true
    }
    return false
}

; Get formatted timestamp for logging
GetTimestamp() {
    return FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
}

; Validate file path exists
FilePathExists(filePath) {
    return FileExist(filePath)
}

; Safe file delete
SafeFileDelete(filePath) {
    try {
        if FileExist(filePath) {
            FileDelete(filePath)
            return true
        }
        return true
    } catch as err {
        return false
    }
}

; Safe directory create
SafeDirCreate(dirPath) {
    try {
        if !DirExist(dirPath) {
            DirCreate(dirPath)
        }
        return true
    } catch as err {
        return false
    }
}

; Check if application is running
IsApplicationRunning(appName) {
    try {
        return WinExist(appName)
    } catch {
        return false
    }
}

; Round coordinates to nearest integer
RoundCoordinates(x, y) {
    return Map("x", Round(x), "y", Round(y))
}

; Calculate distance between two points
CalculateDistance(x1, y1, x2, y2) {
    dx := x2 - x1
    dy := y2 - y1
    return Round(Sqrt(dx*dx + dy*dy), 2)
}

; Clamp value between min and max
Clamp(value, min, max) {
    num := Number(value)
    if (num < min)
        return min
    if (num > max)
        return max
    return num
}

; Validate coordinate is within screen bounds
IsValidScreenCoordinate(x, y) {
    try {
        numX := Number(x)
        numY := Number(y)
        return (numX > 0 && numY > 0)
    } catch {
        return false
    }
}
