; ==========================================
; xh1px's Tidy Bank - ADB Connection Module
; Phase 1: Device Connectivity & Screenshot Management
; ==========================================

class ADBConnection {
    ; ==========================================
    ; CONFIGURATION
    ; ==========================================

    static adbPath := ""                    ; Path to adb.exe
    static deviceId := ""                   ; Connected device ID
    static screenshotPath := ""             ; Temp screenshot directory
    static screenshotTimeout := 10000       ; Screenshot timeout (ms)
    static connectionTimeout := 5000        ; Connection timeout (ms)
    static debugMode := false               ; Enable debug logging
    static maxRetries := 3                  ; Retry attempts for failed operations

    ; ==========================================
    ; INITIALIZATION
    ; ==========================================

    static Initialize() {
        ; Initialize ADB connection system
        ; Returns: true if ADB is found and usable

        try {
            ; Find ADB executable
            if (!this.FindADB()) {
                this.Log("ERROR: ADB not found. Install Android SDK Platform Tools.")
                return false
            }

            ; Set screenshot directory
            this.screenshotPath := A_Temp . "\bank_sorter_screenshots\"

            ; Create screenshot directory if needed
            if (!DirExist(this.screenshotPath)) {
                DirCreate(this.screenshotPath)
            }

            this.Log("ADB Connection initialized successfully")
            return true
        } catch as err {
            this.Log("ADB Initialization error: " . err.Message)
            return false
        }
    }

    static FindADB() {
        ; Search for ADB executable in common locations
        ; Returns: true if found, sets adbPath

        commonPaths := [
            "C:\android-sdk\platform-tools\adb.exe",
            "C:\Program Files\android-sdk\platform-tools\adb.exe",
            "C:\Program Files (x86)\android-sdk\platform-tools\adb.exe",
            A_AppData . "\android-sdk\platform-tools\adb.exe",
            A_Temp . "\platform-tools\adb.exe"
        ]

        ; Check common locations
        for path in commonPaths {
            if (FileExist(path)) {
                this.adbPath := path
                this.Log("ADB found at: " . path)
                return true
            }
        }

        ; Try system PATH
        try {
            shell := ComObjCreate("WScript.Shell")
            exec := shell.Exec(ComSpec " /C where adb.exe")
            if (!exec.Status) {
                adbPath := Trim(exec.StdOut.ReadAll())
                if (adbPath != "") {
                    this.adbPath := adbPath
                    this.Log("ADB found in system PATH: " . adbPath)
                    return true
                }
            }
        }

        return false
    }

    ; ==========================================
    ; DEVICE DETECTION
    ; ==========================================

    static ListConnectedDevices() {
        ; List all connected ADB devices
        ; Returns: Array of device IDs

        try {
            devices := []

            ; Run 'adb devices' command
            result := this.ExecuteADB("devices", 5000)

            if (result == "") {
                this.Log("No devices detected")
                return devices
            }

            ; Parse device list
            lines := StrSplit(result, "`n")
            for line in lines {
                line := Trim(line)

                ; Skip header and empty lines
                if (line == "" || line == "List of attached devices:")
                    continue

                ; Split on whitespace to get device ID
                parts := StrSplit(line, A_Tab)
                if (parts.Length >= 2 && parts[2] == "device") {
                    devices.Push(parts[1])
                }
            }

            this.Log("Found " . devices.Length . " device(s)")
            return devices
        } catch as err {
            this.Log("Device list error: " . err.Message)
            return []
        }
    }

    static ConnectToDevice(deviceIdOrIP := "") {
        ; Connect to an ADB device
        ; Returns: true if connection successful

        try {
            ; If no device specified, auto-detect
            if (deviceIdOrIP == "") {
                devices := this.ListConnectedDevices()
                if (devices.Length == 0) {
                    this.Log("No devices available to connect to")
                    return false
                }
                deviceIdOrIP := devices[1]
            }

            ; If IP address, connect via TCP
            if (InStr(deviceIdOrIP, ":")) {
                this.Log("Connecting to " . deviceIdOrIP . " via TCP...")
                result := this.ExecuteADB("connect " . deviceIdOrIP, this.connectionTimeout)
            } else {
                this.Log("Checking device " . deviceIdOrIP)
            }

            this.deviceId := deviceIdOrIP
            this.Log("Connected to device: " . this.deviceId)
            return true
        } catch as err {
            this.Log("Device connection error: " . err.Message)
            return false
        }
    }

    static VerifyConnection() {
        ; Verify connection to current device
        ; Returns: true if device is connected and responsive

        try {
            if (this.deviceId == "") {
                this.Log("No device selected")
                return false
            }

            ; Try to get device properties
            result := this.ExecuteADB("shell getprop ro.product.device", 3000)

            if (result == "") {
                this.Log("Device not responding")
                return false
            }

            this.Log("Device connection verified: " . Trim(result))
            return true
        } catch as err {
            this.Log("Connection verification error: " . err.Message)
            return false
        }
    }

    ; ==========================================
    ; SCREENSHOT CAPTURE
    ; ==========================================

    static TakeScreenshot(outputPath := "") {
        ; Capture screenshot from connected device
        ; Returns: path to screenshot file

        try {
            if (this.deviceId == "") {
                this.Log("No device connected")
                return ""
            }

            if (outputPath == "") {
                outputPath := this.screenshotPath . "screenshot_" . A_TickCount . ".png"
            }

            ; Remote path on device
            remotePath := "/sdcard/bank_screenshot.png"

            this.Log("Capturing screenshot from device...")

            ; Take screenshot on device
            result := this.ExecuteADB("shell screencap -p " . remotePath, this.screenshotTimeout)

            if (!this.VerifyRemoteFile(remotePath)) {
                this.Log("Screenshot capture failed on device")
                return ""
            }

            ; Pull screenshot from device
            cmd := "pull " . remotePath . " """ . outputPath . """"
            result := this.ExecuteADB(cmd, this.screenshotTimeout)

            if (!FileExist(outputPath)) {
                this.Log("Failed to pull screenshot to local path")
                return ""
            }

            this.Log("Screenshot saved: " . outputPath)
            return outputPath
        } catch as err {
            this.Log("Screenshot capture error: " . err.Message)
            return ""
        }
    }

    static VerifyRemoteFile(remotePath) {
        ; Verify file exists on remote device
        ; Returns: true if file exists

        try {
            result := this.ExecuteADB("shell test -f " . remotePath, 2000)
            ; If test succeeds, no output is returned
            return true
        } catch {
            return false
        }
    }

    ; ==========================================
    ; ADB COMMAND EXECUTION
    ; ==========================================

    static ExecuteADB(command, timeout := 5000) {
        ; Execute an ADB command and return output
        ; Returns: command output or empty string on error

        try {
            if (this.adbPath == "") {
                this.Log("ADB path not set")
                return ""
            }

            ; Build full command
            fullCmd := '\"' . this.adbPath . '\" '

            ; Add device ID if available
            if (this.deviceId != "") {
                fullCmd .= "-s " . this.deviceId . " "
            }

            fullCmd .= command

            this.Log("Executing: " . fullCmd)

            ; Execute command with timeout
            shell := ComObjCreate("WScript.Shell")
            exec := shell.Exec(ComSpec " /C " . fullCmd)

            ; Wait for completion with timeout
            startTime := A_TickCount
            while (!exec.Status && (A_TickCount - startTime) < timeout) {
                Sleep(100)
            }

            if ((A_TickCount - startTime) >= timeout) {
                this.Log("Command timeout after " . timeout . "ms")
                return ""
            }

            ; Read output
            output := exec.StdOut.ReadAll() . exec.StdErr.ReadAll()
            this.Log("Command output: " . Trim(output))

            return output
        } catch as err {
            this.Log("ADB command error: " . err.Message)
            return ""
        }
    }

    ; ==========================================
    ; INPUT CONTROL
    ; ==========================================

    static TapScreen(x, y) {
        ; Send tap/click to device at coordinates
        ; Returns: true if tap successful

        try {
            if (this.deviceId == "") {
                this.Log("No device connected")
                return false
            }

            cmd := "shell input tap " . x . " " . y
            result := this.ExecuteADB(cmd, 2000)

            this.Log("Tapped at (" . x . "," . y . ")")
            return true
        } catch as err {
            this.Log("Tap error: " . err.Message)
            return false
        }
    }

    static SwipeScreen(x1, y1, x2, y2, duration := 500) {
        ; Send swipe gesture to device
        ; Returns: true if swipe successful

        try {
            if (this.deviceId == "") {
                this.Log("No device connected")
                return false
            }

            cmd := "shell input swipe " . x1 . " " . y1 . " " . x2 . " " . y2 . " " . duration
            result := this.ExecuteADB(cmd, 3000)

            this.Log("Swiped from (" . x1 . "," . y1 . ") to (" . x2 . "," . y2 . ")")
            return true
        } catch as err {
            this.Log("Swipe error: " . err.Message)
            return false
        }
    }

    static DragItem(fromX, fromY, toX, toY, duration := 500) {
        ; Drag an item from one position to another
        ; Returns: true if drag successful

        try {
            if (this.deviceId == "") {
                this.Log("No device connected")
                return false
            }

            ; Use swipe to simulate drag (continuous motion)
            return this.SwipeScreen(fromX, fromY, toX, toY, duration)
        } catch as err {
            this.Log("Drag error: " . err.Message)
            return false
        }
    }

    ; ==========================================
    ; LOGGING
    ; ==========================================

    static Log(message) {
        if (this.debugMode) {
            timestamp := FormatTime(A_Now, "HH:mm:ss.sss")
            logMsg := "[ADB] [" . timestamp . "] " . message
            OutputDebug(logMsg)
        }
    }

    static EnableDebug(enable := true) {
        this.debugMode := enable
    }
}

; ==========================================
; USAGE EXAMPLE
; ==========================================

/*
; Initialize ADB
if (!ADBConnection.Initialize()) {
    MsgBox("Failed to initialize ADB")
    ExitApp()
}

; List devices
devices := ADBConnection.ListConnectedDevices()
MsgBox("Found " . devices.Length . " device(s)")

; Connect to first device
if (devices.Length > 0) {
    if (ADBConnection.ConnectToDevice(devices[1])) {
        ; Verify connection
        if (ADBConnection.VerifyConnection()) {
            ; Take screenshot
            screenshot := ADBConnection.TakeScreenshot()
            if (screenshot != "") {
                MsgBox("Screenshot saved: " . screenshot)
            }
        }
    }
}
*/
