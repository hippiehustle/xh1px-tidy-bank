# OCR & Detection Implementation Guide
## xh1px-tidy-bank - Production-Ready Detection System

**Document Version**: 1.0.0
**Date**: 2025-12-22
**Status**: IMPLEMENTATION REQUIRED FOR 100% COMPLETION

---

## 🎯 EXECUTIVE SUMMARY

Two critical functions require full implementation to make this bot production-ready:

1. **`ScanBank()`** - Item detection in bank grid (currently returns random test items)
2. **`IsBankOpen()`** - Bank interface detection (currently uses basic file checks)

**Current Status**: Both functions are **PLACEHOLDERS** that work for testing but **WILL NOT** work correctly in production.

---

## ⚠️ CRITICAL: WHY THIS MATTERS

### Current Behavior (Testing Mode)
- `ScanBank()` generates **random item IDs** → Bot organizes random items
- `IsBankOpen()` checks **file size only** → False positives/negatives likely

### Production Impact Without Implementation
- ❌ Bot will not detect actual items in bank
- ❌ Bot will move random items instead of real items
- ❌ Bank will become disorganized instead of organized
- ❌ Bot may fail to detect when bank is open/closed
- ❌ Wasted time running bot on incorrect data

### Required Before Production Use
- ✅ Implement OCR or image-based item detection
- ✅ Implement pixel/color-based bank interface detection
- ✅ Test with real OSRS screenshots
- ✅ Validate detection accuracy (>90% recommended)

---

## 📋 FUNCTION 1: ScanBank()

### Current Implementation (Placeholder)
**Location**: `main.ahk:187-242`, `main_template_v2.ahk:517-551`

```autohotkey
; PLACEHOLDER: Random item generation for testing
id := Random(1, 100) > 50 ? Random(1, 1000) : 0
```

**Behavior**: Returns random item IDs with 50% probability per slot

### Production Requirements

#### Option A: OCR Text Recognition (RECOMMENDED)
**Pros**: Works with any item, no icon database needed
**Cons**: Requires OCR library, slower (100-500ms per item)

**Implementation Steps**:

1. **Install Tesseract OCR**
   ```bash
   # Download from: https://github.com/UB-Mannheim/tesseract/wiki
   # Install to: C:\Program Files\Tesseract-OCR\
   ```

2. **Extract Item Name Region**
   ```autohotkey
   ; For each bank slot at (x, y):
   regionSize := 60  ; Bank slots are 60x60 pixels
   regionX := x - (regionSize / 2)
   regionY := y - (regionSize / 2)

   ; Crop screenshot to this region
   ; (Requires ImageMagick or similar tool)
   ```

3. **Run OCR on Region**
   ```autohotkey
   tesseractPath := "C:\Program Files\Tesseract-OCR\tesseract.exe"
   ocrOutputFile := A_Temp . "\ocr_result.txt"

   RunWait(tesseractPath . " """ . screenshotPath . """ """ . ocrOutputFile . """", , "Hide")

   ; Read OCR result
   itemName := FileRead(ocrOutputFile)
   itemName := Trim(itemName)
   ```

4. **Look Up Item in Database**
   ```autohotkey
   ; Search database for matching item name
   for itemId, item in db {
       if (item["name"] = itemName) {
           return Map(
               "id", itemId,
               "name", item["name"],
               "ge", item["ge"]
           )
       }
   }
   ```

5. **Handle Detection Failures**
   ```autohotkey
   ; If OCR returns empty or no match found:
   - Log the failure with coordinates
   - Return empty string to skip this slot
   - Continue to next slot
   ```

**Dependencies**:
- Tesseract OCR (external tool)
- ImageMagick (for region cropping, optional)
- Item name database (already have: `osrs-items-condensed.json`)

**Expected Performance**:
- Detection Time: 100-500ms per item (64 slots = 6-32 seconds per scan)
- Accuracy: 85-95% (depends on screenshot quality)
- False Positives: Low (item names are distinctive)
- False Negatives: Medium (OCR can misread similar characters)

---

#### Option B: Image Template Matching
**Pros**: Fast (10-50ms per item), no OCR needed
**Cons**: Requires item icon database, breaks on UI changes

**Implementation Steps**:

1. **Create Item Icon Database**
   ```
   /item_icons/
       /1.png    - Abyssal whip icon (60x60px)
       /2.png    - Abyssal dagger icon
       /3.png    - ...24,735 total item icons
   ```

2. **Extract Icon from Screenshot**
   ```autohotkey
   ; For each bank slot at (x, y):
   ; Extract 60x60 pixel region as bitmap
   ; (Requires GDI+ or image library)
   ```

3. **Compare Against Icon Database**
   ```autohotkey
   ; For each icon in database:
   ; Calculate pixel difference score
   ; Return item with lowest difference (best match)

   bestMatch := 0
   bestScore := 999999

   for itemId, iconPath in iconDatabase {
       score := CompareImages(extractedIcon, iconPath)
       if (score < bestScore) {
           bestScore := score
           bestMatch := itemId
       }
   }

   ; If best score is below threshold, accept match
   if (bestScore < 1000) {  ; Adjust threshold
       return Map("id", bestMatch, ...)
   }
   ```

4. **Optimize with Hash-Based Lookup**
   ```autohotkey
   ; Pre-compute icon hashes for faster matching
   iconHash := CalculateImageHash(extractedIcon)

   ; Look up in hash map
   if itemHashes.Has(iconHash) {
       return itemHashes[iconHash]
   }
   ```

**Dependencies**:
- Complete OSRS item icon database (24,735 icons)
- Image processing library (GDI+, Python PIL, or similar)
- Hashing algorithm for fast lookup

**Expected Performance**:
- Detection Time: 10-50ms per item (64 slots = 0.6-3.2 seconds per scan)
- Accuracy: 95-99% (icons are highly distinctive)
- False Positives: Very low
- False Negatives: Low (unless new items added to game)

---

#### Option C: Hybrid Approach (BEST)
**Combine OCR + Template Matching for highest accuracy**

1. **Try template matching first** (fast)
2. **If confidence < 90%**: Fall back to OCR (slower but more accurate)
3. **If both fail**: Log unknown item and skip slot

**Implementation**:
```autohotkey
DetectItemAtPosition(x, y) {
    ; Fast path: Template matching
    item := TryIconMatching(x, y)
    if (item != "" && item["confidence"] > 0.9) {
        return item
    }

    ; Fallback: OCR
    item := TryOCR(x, y)
    if (item != "") {
        return item
    }

    ; Unknown item
    Log("Could not identify item at (" . x . ", " . y . ")")
    return ""
}
```

---

## 📋 FUNCTION 2: IsBankOpen()

### Current Implementation (Placeholder)
**Location**: `main.ahk:360-388`, `main_template_v2.ahk:1221-1302`

```autohotkey
; Check if screenshot is recent (created in last 5 seconds)
timeDiff := DateDiff(currentTime, fileTime, "S")
return (timeDiff < 5)  ; PLACEHOLDER: Not checking actual bank UI
```

**Behavior**: Returns true if screenshot file exists and is recent (last 3-5 seconds)

### Production Requirements

#### Option A: Pixel Color Detection (RECOMMENDED)
**Pros**: Fast (1-5ms), simple, reliable
**Cons**: May break on UI updates or theme changes

**Implementation Steps**:

1. **Identify Bank UI Anchor Points**
   ```
   Known OSRS bank interface elements:
   - Bank title bar: "Bank of " text at ~(100, 180)
   - Bank tabs: Distinctive tab colors at y=80
   - Bank grid background: Specific color pattern
   - Bank close button: Red X at top-right
   ```

2. **Check Specific Pixel Colors**
   ```autohotkey
   IsBankOpen() {
       global screenshot

       if !FileExist(screenshot) {
           return false
       }

       ; Check bank title bar area (dark background)
       titleBarColor := GetPixelColor(screenshot, 100, 180)
       if (titleBarColor != 0x3E3529) {  ; OSRS bank title bar color
           return false
       }

       ; Check bank tab area (distinctive tab colors)
       tabColor := GetPixelColor(screenshot, 150, 80)
       if (tabColor != 0x5E3820) {  ; OSRS bank tab color
           return false
       }

       ; Check bank grid background
       gridColor := GetPixelColor(screenshot, 71, 171)
       if (gridColor != 0x3E3529) {  ; OSRS bank grid background
           return false
       }

       ; All checks passed - bank is open
       return true
   }
   ```

3. **Implement GetPixelColor() Helper**
   ```autohotkey
   GetPixelColor(imagePath, x, y) {
       ; Requires image processing library
       ; Options:
       ; 1. GDI+ (built-in to Windows)
       ; 2. Python script with PIL/Pillow
       ; 3. ImageMagick via command line

       ; Example with ImageMagick:
       cmd := "magick """ . imagePath . """ -format ""%[pixel:p{" . x . "," . y . "}]"" info:"
       color := RunWaitOutput(cmd)
       return ConvertColorToHex(color)
   }
   ```

4. **Add Color Tolerance**
   ```autohotkey
   ; Colors may vary slightly due to compression
   IsColorMatch(actualColor, expectedColor, tolerance := 10) {
       ; Extract RGB components
       aR := (actualColor >> 16) & 0xFF
       aG := (actualColor >> 8) & 0xFF
       aB := actualColor & 0xFF

       eR := (expectedColor >> 16) & 0xFF
       eG := (expectedColor >> 8) & 0xFF
       eB := expectedColor & 0xFF

       ; Check if within tolerance
       return (Abs(aR - eR) <= tolerance
           && Abs(aG - eG) <= tolerance
           && Abs(aB - eB) <= tolerance)
   }
   ```

**Dependencies**:
- Image processing library (GDI+, ImageMagick, or Python PIL)
- Accurate pixel color values for OSRS bank UI
- Color tolerance algorithm for compression artifacts

**Expected Performance**:
- Detection Time: 1-5ms
- Accuracy: 95-99%
- False Positives: Very low (specific color combination)
- False Negatives: Low (unless OSRS UI update)

---

#### Option B: OCR Title Detection
**Pros**: Robust to color changes, text is always present
**Cons**: Slower (50-200ms), requires OCR

**Implementation**:
```autohotkey
IsBankOpen() {
    global screenshot

    if !FileExist(screenshot) {
        return false
    }

    ; Extract title bar region (100x40 pixels at top-left)
    titleText := ExtractTextFromRegion(screenshot, 100, 180, 100, 40)

    ; Check if text contains "Bank"
    if (InStr(titleText, "Bank") > 0) {
        return true
    }

    return false
}
```

---

#### Option C: File Size Heuristic (CURRENT - UNRELIABLE)
**Current implementation** - Uses file size as proxy
**NOT RECOMMENDED** - Too many false positives/negatives

```autohotkey
; If file is larger than threshold, likely bank is open
if (fileSize > 50000) {  ; UNRELIABLE
    return true
}
```

**Problems**:
- File size varies based on what's on screen
- Compression makes size unpredictable
- No way to distinguish bank UI from other UIs
- High false positive rate

---

## 🛠️ IMPLEMENTATION TOOLS

### Required Tools

1. **Tesseract OCR** (for OCR-based detection)
   - Download: https://github.com/UB-Mannheim/tesseract/wiki
   - Installation path: `C:\Program Files\Tesseract-OCR\`
   - Verify: `tesseract --version`

2. **ImageMagick** (for image processing)
   - Download: https://imagemagick.org/script/download.php
   - Features: Pixel color extraction, region cropping, format conversion
   - Verify: `magick --version`

3. **Python + PIL/Pillow** (alternative to ImageMagick)
   ```bash
   pip install Pillow
   ```

   ```python
   # Python helper script: get_pixel_color.py
   from PIL import Image
   import sys

   img = Image.open(sys.argv[1])
   x, y = int(sys.argv[2]), int(sys.argv[3])
   r, g, b = img.getpixel((x, y))
   print(f"0x{r:02X}{g:02X}{b:02X}")
   ```

4. **GDI+ Library for AutoHotkey** (built-in to Windows)
   - No installation needed
   - Access via `ComObject("WIA.ImageFile")`
   - Can read pixel colors directly

### Optional Tools

1. **OSRS Item Icon Database**
   - Source: OSRS Wiki API
   - Format: 24,735 PNG files (60x60px each)
   - Total size: ~150MB

2. **Image Hashing Library** (for fast icon matching)
   - pHash (Perceptual Hash)
   - dHash (Difference Hash)
   - Can be implemented in AutoHotkey or Python

---

## 📊 RECOMMENDED IMPLEMENTATION PATH

### Phase 1: IsBankOpen() - Pixel Detection ⏱️ 1-2 hours
**Priority**: HIGH - Needed for basic bot operation

1. Install ImageMagick or set up Python PIL
2. Capture reference OSRS bank screenshot
3. Identify 3-4 anchor pixel positions and colors
4. Implement GetPixelColor() helper
5. Add color tolerance checking
6. Test with multiple bank states (open, closed, different tabs)

**Validation**:
```autohotkey
; Test cases
TestIsBankOpen() {
    ; Test 1: Bank open screenshot
    assert(IsBankOpen() == true)

    ; Test 2: Bank closed screenshot
    assert(IsBankOpen() == false)

    ; Test 3: Different bank tab screenshot
    assert(IsBankOpen() == true)
}
```

---

### Phase 2: ScanBank() - OCR Detection ⏱️ 4-8 hours
**Priority**: HIGH - Core bot functionality

1. Install Tesseract OCR
2. For each bank slot:
   - Extract 60x60px region around slot center
   - Save as temporary image file
   - Run Tesseract on region
   - Parse OCR output (item name)
3. Look up item name in database
4. Handle OCR failures gracefully
5. Log detection successes/failures
6. Test with real bank screenshots

**Validation**:
```autohotkey
; Test cases
TestScanBank() {
    ; Test with known bank screenshot
    items := ScanBank()

    ; Verify item count (should detect 20+ items)
    assert(items.Length > 20)

    ; Verify item IDs are valid (exist in database)
    for item in items {
        assert(db.Has(item["id"]))
    }
}
```

---

### Phase 3: Performance Optimization ⏱️ 2-4 hours
**Priority**: MEDIUM - Makes bot faster

1. **Cache OCR Results**
   ```autohotkey
   ; Don't re-scan unchanged slots
   slotCache := Map()

   if slotCache.Has(slotKey) && !SlotChanged(slotKey) {
       return slotCache[slotKey]  ; Use cached result
   }
   ```

2. **Parallel Processing**
   - Scan multiple slots simultaneously
   - Use threading or async operations

3. **Region Pre-processing**
   - Enhance contrast before OCR
   - Remove background noise
   - Sharpen text for better recognition

---

### Phase 4: Template Matching (Optional) ⏱️ 8-16 hours
**Priority**: LOW - Nice to have, not required

1. Download/create OSRS item icon database
2. Implement image comparison algorithm
3. Pre-compute icon hashes for fast lookup
4. Add hybrid fallback (template → OCR if confidence low)

---

## ✅ VALIDATION & TESTING

### Test Dataset Requirements

1. **Bank Open Screenshots** (10+ samples)
   - Different bank locations (Grand Exchange, Lumbridge, Varrock)
   - Different lighting conditions
   - Different zoom levels

2. **Bank Closed Screenshots** (10+ samples)
   - Character standing near bank
   - Character in combat
   - Different game states

3. **Bank Grid Screenshots** (20+ samples)
   - Different item combinations
   - Full bank vs sparse bank
   - Common items vs rare items
   - Stacked items with quantities

### Acceptance Criteria

#### ScanBank()
- ✅ Detects items with >90% accuracy
- ✅ Handles empty slots correctly
- ✅ Completes full grid scan in <10 seconds
- ✅ Logs detection failures for debugging
- ✅ Returns valid item IDs from database

#### IsBankOpen()
- ✅ Detects bank open/closed with >95% accuracy
- ✅ Completes check in <50ms
- ✅ False positive rate <5%
- ✅ False negative rate <5%
- ✅ Works across different bank locations

---

## 📝 IMPLEMENTATION CHECKLIST

### Before Starting
- [ ] Review OSRS bank UI screenshots
- [ ] Identify key detection points (pixels, text areas)
- [ ] Choose implementation approach (OCR vs template matching)
- [ ] Install required tools (Tesseract, ImageMagick, or Python)
- [ ] Create test dataset (20+ screenshots)

### IsBankOpen() Implementation
- [ ] Install image processing tool
- [ ] Capture reference bank screenshot
- [ ] Identify anchor pixel positions (3-4 locations)
- [ ] Record exact RGB values for each anchor
- [ ] Implement GetPixelColor() helper function
- [ ] Implement IsColorMatch() with tolerance
- [ ] Replace placeholder IsBankOpen() logic
- [ ] Test with open bank screenshots (10+ samples)
- [ ] Test with closed bank screenshots (10+ samples)
- [ ] Verify <5% false positive/negative rate
- [ ] Add logging for debugging

### ScanBank() Implementation
- [ ] Install Tesseract OCR
- [ ] Verify Tesseract installation path
- [ ] Test OCR on sample item icons
- [ ] Implement region extraction (60x60px per slot)
- [ ] Implement OCR text extraction
- [ ] Implement item name lookup in database
- [ ] Handle OCR failures gracefully
- [ ] Replace placeholder ScanBank() logic
- [ ] Test with full bank screenshot
- [ ] Test with sparse bank screenshot
- [ ] Verify >90% detection accuracy
- [ ] Optimize for performance (<10s scan time)
- [ ] Add comprehensive logging

### Validation
- [ ] Create automated test suite
- [ ] Run tests on all sample screenshots
- [ ] Measure accuracy metrics
- [ ] Measure performance metrics
- [ ] Document any edge cases or limitations
- [ ] Update user documentation

### Deployment
- [ ] Update README with implementation notes
- [ ] Document tool dependencies
- [ ] Create installation guide for Tesseract/ImageMagick
- [ ] Add troubleshooting section
- [ ] Create example screenshots
- [ ] Update DEPLOYMENT_GUIDE.md

---

## 🚨 RISKS & MITIGATION

### Risk 1: OCR Accuracy Issues
**Impact**: Bot detects wrong items → incorrect organization
**Mitigation**:
- Use high-quality screenshots (1920x1080)
- Pre-process images (enhance contrast)
- Implement confidence threshold (skip low-confidence detections)
- Add fallback to template matching
- Log all detection attempts for debugging

### Risk 2: OSRS UI Changes
**Impact**: Pixel colors change → IsBankOpen() breaks
**Mitigation**:
- Check multiple anchor points (not just one)
- Use color tolerance (±10 RGB units)
- Add version detection (check for UI updates)
- Document exact OSRS version tested against
- Provide update guide for UI changes

### Risk 3: Performance Degradation
**Impact**: Scanning takes too long → bot feels slow
**Mitigation**:
- Cache detection results
- Only re-scan changed slots
- Use fast detection method first (template matching)
- Optimize image processing pipeline
- Add progress indicators to UI

### Risk 4: External Tool Dependencies
**Impact**: Tesseract not installed → bot doesn't work
**Mitigation**:
- Check for tool availability on startup
- Show clear error message with download link
- Provide installation guide
- Consider bundling tools with bot (if licensing allows)
- Add fallback to manual configuration

---

## 📚 ADDITIONAL RESOURCES

### Documentation
- [Tesseract OCR Documentation](https://tesseract-ocr.github.io/)
- [ImageMagick Command-Line Tools](https://imagemagick.org/script/command-line-tools.php)
- [AutoHotkey v2 Image Functions](https://www.autohotkey.com/docs/v2/lib/ImageSearch.htm)
- [OSRS Wiki API](https://oldschool.runescape.wiki/w/Application_programming_interface)

### Example Code
See `main_template_v2.ahk` lines 602-822 for comprehensive detection stubs with extensive documentation.

### Community Resources
- OSRS Bot Development Discord: [Link if available]
- AutoHotkey Forums: https://www.autohotkey.com/boards/
- Computer Vision for Games: [OpenCV tutorials]

---

## ✨ SUCCESS METRICS

### Completion Criteria
- ✅ IsBankOpen() implemented with >95% accuracy
- ✅ ScanBank() implemented with >90% accuracy
- ✅ Both functions tested with 20+ screenshots
- ✅ Performance meets targets (<50ms and <10s)
- ✅ All dependencies documented
- ✅ Installation guide created
- ✅ Test suite passes 100%

### Quality Gates
- No hardcoded test data in production functions
- All detection logic properly logged
- Error handling for all external tool calls
- Graceful degradation on detection failures
- User-friendly error messages

---

## 🎯 FINAL NOTES

**Current Code Status**: ✅ 95% Complete
**Remaining Work**: OCR/detection implementation (this guide)
**Estimated Time**: 8-16 hours of focused development
**Difficulty**: Intermediate (requires external tools and testing)

**Once Complete**: Bot will be **100% production-ready** and fully functional for OSRS bank organization!

---

**Document Version**: 1.0.0
**Last Updated**: 2025-12-22
**Author**: Claude Code Assistant
**Project**: xh1px-tidy-bank
