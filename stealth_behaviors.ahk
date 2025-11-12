; ==========================================
; xh1px's Tidy Bank - Stealth Behaviors Module
; Implements human-like interaction patterns & anti-detection
; ==========================================

class StealthBehaviors {
    ; ==========================================
    ; CONFIGURATION
    ; ==========================================

    static mode := "Stealth"                 ; Anti-ban mode: Off, Stealth, Extreme, Psychopath
    static debugMode := false                ; Enable debug logging

    ; ==========================================
    ; MOUSE BEHAVIOR - STEALTH MOVEMENTS
    ; ==========================================

    static CalculateHumanizedDelay(minMs := 100, maxMs := 500) {
        ; Generate humanized delay between interactions
        ; Returns: random delay in milliseconds

        ; Humans don't click at exact intervals
        ; Add variance with weighted distribution
        variance := Random(minMs, maxMs)

        ; 20% chance of longer pause (human hesitation)
        if (Random(1, 100) <= 20) {
            variance += Random(200, 800)
        }

        return variance
    }

    static PerformStealthDrag(fromX, fromY, toX, toY, mode := "Stealth") {
        ; Perform drag operation with human-like characteristics
        ; Returns: true if drag completed successfully

        try {
            ; Select mode for drag behavior
            switch mode {
                case "Stealth":
                    return this.StealthDragSlow(fromX, fromY, toX, toY)
                case "Extreme":
                    return this.ExtremeStealthDrag(fromX, fromY, toX, toY)
                case "Psychopath":
                    return this.PsychopathDrag(fromX, fromY, toX, toY)
                default:
                    return this.NormalDrag(fromX, fromY, toX, toY)
            }
        } catch as err {
            this.Log("Drag error: " . err.Message)
            return false
        }
    }

    static StealthDragSlow(fromX, fromY, toX, toY) {
        ; Slow, deliberate drag with human characteristics
        ; - Smooth acceleration/deceleration
        ; - Variable speed
        ; - Natural pauses
        ; Returns: true if successful

        try {
            this.Log("Performing STEALTH drag from (" . fromX . "," . fromY . ") to (" . toX . "," . toY . ")")

            ; Initial pause before drag (human decision time)
            preDragDelay := Random(50, 150)
            Sleep(preDragDelay)

            ; Calculate distance
            distX := toX - fromX
            distY := toY - fromY
            distance := Sqrt(distX * distX + distY * distY)

            ; Divide drag into segments for smooth motion
            segments := Ceil(distance / 10)  ; ~10px per segment

            ; Mouse down at starting position
            MouseMove(fromX, fromY)
            Sleep(Random(50, 100))
            MouseDown("Left")
            Sleep(Random(100, 200))

            ; Execute drag with smooth motion
            for i := 1 to segments {
                ; Calculate position in this segment
                progress := i / segments
                currentX := Round(fromX + (distX * progress))
                currentY := Round(fromY + (distY * progress))

                ; Move to position
                MouseMove(currentX, currentY)

                ; Variable delay between segments
                ; Slower near start and end (human acceleration/deceleration)
                if (i < 3 || i > segments - 2) {
                    segmentDelay := Random(10, 30)
                } else {
                    segmentDelay := Random(5, 15)
                }

                Sleep(segmentDelay)
            }

            ; Small random final position adjustment
            randomFinalX := toX + Random(-2, 2)
            randomFinalY := toY + Random(-2, 2)
            MouseMove(randomFinalX, randomFinalY)
            Sleep(Random(50, 100))

            ; Mouse up (release)
            MouseUp("Left")
            Sleep(Random(100, 300))

            this.Log("Stealth drag completed")
            return true

        } catch as err {
            this.Log("Stealth drag error: " . err.Message)
            MouseUp("Left")  ; Ensure mouse is released
            return false
        }
    }

    static ExtremeStealthDrag(fromX, fromY, toX, toY) {
        ; Extremely careful drag with maximum stealth
        ; - Very slow movement
        ; - Multiple pauses during drag
        ; - Jitter/micro-movements
        ; Returns: true if successful

        try {
            this.Log("Performing EXTREME STEALTH drag")

            ; Longer initial pause
            Sleep(Random(200, 500))

            ; Calculate movement
            distX := toX - fromX
            distY := toY - fromY
            distance := Sqrt(distX * distX + distY * distY)

            ; Very fine segments for extreme smoothness
            segments := Ceil(distance / 5)  ; ~5px per segment

            ; Move to start position and prepare
            MouseMove(fromX, fromY)
            Sleep(Random(100, 300))

            MouseDown("Left")
            Sleep(Random(200, 400))

            ; Execute extremely slow drag with pauses
            pauseCounter := 0
            for i := 1 to segments {
                progress := i / segments
                currentX := Round(fromX + (distX * progress))
                currentY := Round(fromY + (distY * progress))

                ; Add micro-jitter (human hand tremor)
                jitterX := Random(-1, 1)
                jitterY := Random(-1, 1)
                currentX += jitterX
                currentY += jitterY

                MouseMove(currentX, currentY)

                ; Very slow movement
                Sleep(Random(15, 35))

                ; Random pause every 10 segments (human thinking)
                pauseCounter++
                if (pauseCounter >= 10 && Random(1, 100) <= 15) {
                    Sleep(Random(100, 300))
                    pauseCounter := 0
                }
            }

            ; Final adjustment with pause
            Sleep(Random(100, 200))
            MouseUp("Left")
            Sleep(Random(200, 500))

            this.Log("Extreme stealth drag completed")
            return true

        } catch as err {
            this.Log("Extreme stealth drag error: " . err.Message)
            MouseUp("Left")
            return false
        }
    }

    static PsychopathDrag(fromX, fromY, toX, toY) {
        ; Fast, direct drag (confident bot behavior)
        ; - Slightly variable speed
        ; - Some randomization to avoid detection
        ; Returns: true if successful

        try {
            this.Log("Performing PSYCHOPATH drag (fast & direct)")

            MouseMove(fromX, fromY)
            Sleep(Random(20, 50))

            MouseDown("Left")
            Sleep(Random(20, 50))

            ; Fast movement with slight variation
            distX := toX - fromX
            distY := toY - fromY
            distance := Sqrt(distX * distX + distY * distY)

            ; Fewer segments for faster movement
            segments := Max(3, Ceil(distance / 30))

            for i := 1 to segments {
                progress := i / segments
                currentX := Round(fromX + (distX * progress))
                currentY := Round(fromY + (distY * progress))

                MouseMove(currentX, currentY)
                Sleep(Random(2, 8))
            }

            MouseUp("Left")
            Sleep(Random(20, 50))

            return true

        } catch as err {
            this.Log("Psychopath drag error: " . err.Message)
            MouseUp("Left")
            return false
        }
    }

    static NormalDrag(fromX, fromY, toX, toY) {
        ; Standard drag without special stealth (baseline)
        ; Returns: true if successful

        try {
            MouseMove(fromX, fromY)
            Sleep(Random(100, 200))
            MouseDown("Left")
            Sleep(Random(50, 100))
            MouseMove(toX, toY)
            Sleep(Random(100, 200))
            MouseUp("Left")
            Sleep(Random(100, 200))

            return true
        } catch as err {
            MouseUp("Left")
            return false
        }
    }

    ; ==========================================
    ; CLICK BEHAVIOR - HUMANIZED CLICKS
    ; ==========================================

    static HumanizedClick(x, y, delayBefore := 0, delayAfter := 0) {
        ; Perform humanized click with optional delays
        ; Returns: true if successful

        try {
            ; Pre-click delay (human processing time)
            if (delayBefore == 0) {
                delayBefore := this.CalculateHumanizedDelay(50, 200)
            }

            Sleep(delayBefore)

            ; Move to position with slight variance
            varX := x + Random(-2, 2)
            varY := y + Random(-2, 2)

            MouseMove(varX, varY)
            Sleep(Random(30, 80))

            ; Double-click random chance (human behavior)
            if (Random(1, 100) <= 3) {
                MouseClick("Left")
                Sleep(Random(50, 150))
                MouseClick("Left")
            } else {
                MouseClick("Left")
            }

            ; Post-click delay
            if (delayAfter == 0) {
                delayAfter := this.CalculateHumanizedDelay(100, 300)
            }

            Sleep(delayAfter)
            return true

        } catch as err {
            this.Log("Click error: " . err.Message)
            return false
        }
    }

    ; ==========================================
    ; POSITION TRACKING
    ; ==========================================

    static TrackCharacterPosition() {
        ; Track character position in game (placeholder)
        ; Returns: Map with position data

        try {
            ; In real implementation:
            ; 1. Analyze current screenshot
            ; 2. Detect character sprite position
            ; 3. Calculate offset from bank

            position := Map(
                "x", 0,
                "y", 0,
                "inBank", false,
                "timestamp", A_Now
            )

            return position

        } catch as err {
            this.Log("Position tracking error: " . err.Message)
            return Map()
        }
    }

    static VerifyPlayerNearBank() {
        ; Verify player is positioned at bank before operations
        ; Returns: true if player is at bank

        try {
            pos := this.TrackCharacterPosition()

            if (pos["inBank"]) {
                this.Log("Player verified at bank")
                return true
            }

            this.Log("Player not at bank - may need to navigate")
            return false

        } catch as err {
            this.Log("Bank position verification error: " . err.Message)
            return false
        }
    }

    ; ==========================================
    ; ANTI-DETECTION MEASURES
    ; ==========================================

    static ImplementBreakPattern() {
        ; Implement break pattern to avoid detection
        ; Simulates human getting tired/distracted

        try {
            this.Log("Implementing break pattern")

            ; Random break duration (1-5 minutes)
            breakDuration := Random(60000, 300000)
            breakMinutes := breakDuration / 60000

            this.Log("Taking break for " . Round(breakMinutes, 1) . " minutes")

            ; Extended break
            Sleep(breakDuration)

            ; Return with "lag simulation" - slower response
            return true

        } catch as err {
            this.Log("Break pattern error: " . err.Message)
            return false
        }
    }

    static RandomizeInteractionDelay() {
        ; Add random delay to interactions for variability
        ; Returns: random delay in milliseconds

        ; Base delay with high variance
        baseDelay := Random(500, 2000)

        ; Random outliers (human distraction)
        if (Random(1, 100) <= 10) {
            baseDelay += Random(1000, 5000)
        }

        return baseDelay
    }

    static VariableBankTabDelay() {
        ; Variable delay between bank tab switches
        ; Returns: random delay in milliseconds

        return Random(400, 1200)
    }

    ; ==========================================
    ; LOGGING
    ; ==========================================

    static Log(message) {
        if (this.debugMode) {
            timestamp := FormatTime(A_Now, "HH:mm:ss.sss")
            logMsg := "[STEALTH] [" . timestamp . "] " . message
            OutputDebug(logMsg)
        }
    }

    static EnableDebug(enable := true) {
        this.debugMode := enable
    }

    static SetMode(newMode) {
        this.mode := newMode
        this.Log("Stealth mode set to: " . newMode)
    }
}

; ==========================================
; USAGE EXAMPLE
; ==========================================

/*
; Initialize
StealthBehaviors.EnableDebug(true)
StealthBehaviors.SetMode("Stealth")

; Perform stealth drag
StealthBehaviors.PerformStealthDrag(100, 100, 200, 200, "Stealth")

; Humanized click
StealthBehaviors.HumanizedClick(150, 150)

; Get position
pos := StealthBehaviors.TrackCharacterPosition()
MsgBox("Position: (" . pos["x"] . "," . pos["y"] . ")")

; Verify bank
if (StealthBehaviors.VerifyPlayerNearBank()) {
    MsgBox("Player at bank!")
}
*/
