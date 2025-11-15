# TESTING CHECKLIST & VALIDATION GUIDE

**Project:** xh1px's Tidy Bank v2.0
**Last Updated:** November 14, 2025
**Status:** Production Testing Phase

---

## TABLE OF CONTENTS

1. [Unit Tests](#unit-tests)
2. [Integration Tests](#integration-tests)
3. [Functional Tests](#functional-tests)
4. [Performance Tests](#performance-tests)
5. [Security Tests](#security-tests)
6. [Deployment Checklist](#deployment-checklist)

---

## UNIT TESTS

### JSON Parser Tests
**File:** `test_json_parser.ahk`
**Purpose:** Validate JSON parsing and serialization

#### Basic Parsing Tests
- [ ] Empty string parsing: `""` → empty string
- [ ] Simple string parsing: `"hello"` → "hello"
- [ ] Strings with spaces: `"hello world"` → "hello world"
- [ ] Boolean true: `true` → true
- [ ] Boolean false: `false` → false
- [ ] Null value: `null` → empty string
- [ ] Zero: `0` → 0
- [ ] Positive integers: `123` → 123
- [ ] Negative integers: `-123` → -123
- [ ] Float numbers: `123.456` → 123.456
- [ ] Negative floats: `-123.456` → -123.456
- [ ] Scientific notation: `1e10` → 10000000000

#### String Handling Tests
- [ ] Newline escape: `\n` → `n (newline)
- [ ] Tab escape: `\t` → `t (tab)
- [ ] Backslash escape: `\\` → `\
- [ ] Quote escape: `\"` → "
- [ ] CRLF sequence: `\r\n` → carriage return + newline
- [ ] Form feed: `\f` → form feed character
- [ ] Backspace: `\b` → backspace character
- [ ] Whitespace preservation: `"  hello  "` → "  hello  "

#### Number Parsing Tests
- [ ] Zero value
- [ ] Single digit (1-9)
- [ ] Large integers (999999)
- [ ] Negative integers (-1, -999999)
- [ ] Decimals (0.5, 123.456)
- [ ] Negative decimals (-123.456)
- [ ] Scientific notation (1e5, 1.5e5, 1e-5)

#### Array Tests
- [ ] Empty array: `[]` → empty array
- [ ] Single element: `[1]` → [1]
- [ ] Multiple elements: `[1, 2, 3]` → [1, 2, 3]
- [ ] String array: `["a", "b", "c"]` → ["a", "b", "c"]
- [ ] Nested arrays: `[[1, 2], [3, 4]]` → nested structure
- [ ] Mixed type arrays: `[1, "hello", true, null]` → mixed types
- [ ] Arrays of objects: `[{"a": 1}, {"b": 2}]` → array of maps

#### Object Tests
- [ ] Empty object: `{}` → empty map
- [ ] Single property: `{"a": 1}` → Map with one key-value
- [ ] Multiple properties: `{"a": 1, "b": 2, "c": 3}` → Map with three entries
- [ ] String values: `{"name": "John", "city": "NYC"}` → proper mapping
- [ ] Nested objects: `{"a": {"b": 1}}` → nested structure
- [ ] Objects with arrays: `{"items": [1, 2, 3]}` → mixed structure
- [ ] Boolean/null values: `{"active": true, "deleted": false, "data": null}`

#### Stringification Tests
- [ ] String to JSON: "hello" → "\"hello\""
- [ ] Number to JSON: 123 → "123"
- [ ] Boolean true: true → "true"
- [ ] Boolean false: false → "false"
- [ ] Array to JSON: [1, 2, 3] → "[1,2,3]"
- [ ] Object to JSON: Map("a", 1, "b", 2) → "{\"a\":1,\"b\":2}" (order may vary)
- [ ] Round-trip consistency: Parse → Stringify → Parse → same result

#### Error Handling Tests
- [ ] Invalid JSON: `{invalid` → handled gracefully
- [ ] Unclosed string: `"unclosed` → handled gracefully
- [ ] Trailing comma: `[1, 2, 3,]` → handled gracefully
- [ ] No crashes on malformed input

#### Edge Cases
- [ ] Very long strings (1000+ characters)
- [ ] Deeply nested structures (5+ levels)
- [ ] Large arrays (100+ elements)
- [ ] Unicode character handling
- [ ] Empty values (empty string, null, empty array, empty object)

**Test Execution:**
```autohotkey
#Include test_json_parser.ahk
JSONParserTests.RunAllTests()
```

---

### Conflict Resolver Tests
**File:** `test_conflict_resolver.ahk`
**Purpose:** Validate bank tab conflict resolution logic

#### Basic Resolution Tests
- [ ] Single-tag items resolve correctly
- [ ] Items map to correct tab
- [ ] Tab numbers are in valid range (1-8)

#### Conflict Resolution Tests
- [ ] Multi-tag items resolve to lowest tab
- [ ] "Lowest tab wins" rule is enforced
- [ ] Conflict statistics are available
- [ ] Conflict count is accurate

#### Batch Processing Tests
- [ ] Multiple items processed simultaneously
- [ ] All items in batch get resolved
- [ ] Batch results are consistent
- [ ] Tab-specific queries work correctly

#### Caching Tests
- [ ] Repeated lookups return same result
- [ ] Cache improves performance
- [ ] Cache can be cleared
- [ ] Cache doesn't cause stale results

#### Statistics Tests
- [ ] Statistics structure is valid
- [ ] Statistics can be retrieved
- [ ] Stats include: total items, conflicts, cache info
- [ ] Stats update after resolution

#### Error Handling Tests
- [ ] Null items handled gracefully
- [ ] Items with no tags get default tab
- [ ] Invalid tab numbers handled
- [ ] No crashes on edge cases

#### Edge Cases
- [ ] Items with many tags (5+)
- [ ] Batches of identical items
- [ ] Case sensitivity consistency
- [ ] Special characters in item names

**Test Execution:**
```autohotkey
#Include test_conflict_resolver.ahk
ConflictResolverTests.RunAllTests()
```

---

## INTEGRATION TESTS

### GUI Integration
- [ ] config_gui.ahk loads without errors
- [ ] All UI elements render correctly
- [ ] Tab switching works smoothly
- [ ] Color system applies correctly
- [ ] Fonts display properly
- [ ] Input controls respond to interactions

### Configuration Persistence
- [ ] User settings save to JSON correctly
- [ ] Saved config loads correctly on restart
- [ ] Bank category assignments persist
- [ ] Default config loads if file missing
- [ ] Config file can be manually edited

### Item Grouping Integration
- [ ] ItemGroupingSystem loads successfully
- [ ] All 14 core groups available
- [ ] All 40+ skill subcategories available
- [ ] 150+ items in database accessible
- [ ] Item lookup by name works
- [ ] Item lookup by tag works
- [ ] Tag hierarchy is correct

### Template Generation
- [ ] main_template_v2.ahk loads without errors
- [ ] Template variables all defined
- [ ] Template generates main.ahk correctly
- [ ] Generated main.ahk compiles
- [ ] Generated bot has correct settings embedded

---

## FUNCTIONAL TESTS

### Bank Connection Tests
- [ ] ADB connection to BlueStacks works
- [ ] ADB commands execute successfully
- [ ] Screenshot capture works
- [ ] Screenshot pulls to local temp directory
- [ ] Screenshot file is readable
- [ ] ADB handles timeouts gracefully

### Bank Detection (IsBankOpen)
- [ ] Returns true when bank is open
- [ ] Returns false when bank is closed
- [ ] Screenshot file existence checked
- [ ] Screenshot age validated (3s timeout)
- [ ] File size heuristic works (~50KB threshold)
- [ ] Error handling prevents crashes
- [ ] Logging captures detection status

### Item Detection (DetectItemAtPosition)
- [ ] Validates coordinate ranges (0-1920, 0-1080)
- [ ] Region extraction works correctly (60x60 pixels)
- [ ] Region clamping prevents out-of-bounds
- [ ] OCR integration attempted first
- [ ] Icon matching fallback attempted
- [ ] Item presence check works
- [ ] Returns empty string for unidentified items
- [ ] Logging captures detection attempts

### OCR Integration
- [ ] Tesseract OCR detected if installed
- [ ] Falls back gracefully if OCR not available
- [ ] Text extraction from region works
- [ ] Item lookup in database from OCR text
- [ ] Temporary files cleaned up
- [ ] OCR errors don't crash bot

### Bank Tab Sorting
- [ ] Items sorted into correct tabs
- [ ] Conflict resolution applied during sort
- [ ] All 8 tabs processed correctly
- [ ] Items moved to correct positions
- [ ] Sorting logs captured

### Session Management
- [ ] Bot starts without errors
- [ ] Bot stops cleanly on F1 press
- [ ] Session timer works correctly
- [ ] Max session duration enforced
- [ ] Anti-ban delays applied
- [ ] Stealth mode randomization works
- [ ] World hopping executes if enabled

---

## PERFORMANCE TESTS

### JSON Parsing Performance
- [ ] osrs-items-condensed.json (5MB) parses in < 5 seconds
- [ ] Individual item lookups < 100ms
- [ ] Memory usage stable (no leaks)
- [ ] Concurrent parsing doesn't crash

### Image Processing Performance
- [ ] Screenshot capture < 1 second
- [ ] Screenshot pull < 2 seconds
- [ ] Bank detection < 100ms
- [ ] Item detection < 500ms per item
- [ ] 64-item scan < 30 seconds total

### Database Performance
- [ ] Item lookup by name < 50ms
- [ ] Item lookup by tag < 50ms
- [ ] Tag matching < 100ms
- [ ] Batch processing scales linearly

### Memory Usage
- [ ] Startup memory < 100MB
- [ ] Per-item memory footprint < 10KB
- [ ] No memory leaks over 4+ hour session
- [ ] Cache memory bounded (< 50MB)

### CPU Usage
- [ ] Idle CPU usage < 5%
- [ ] Active sorting < 50% CPU
- [ ] Screenshot capture/pull < 80% CPU
- [ ] No CPU spikes or hangs

---

## SECURITY TESTS

### Input Validation
- [ ] Bank tab numbers validated (1-8)
- [ ] Coordinates validated (0-1920, 0-1080)
- [ ] Item names validated before DB lookup
- [ ] Config file validated before parsing
- [ ] User input sanitized before use

### File Operations
- [ ] File paths use approved directories
- [ ] No path traversal possible
- [ ] Temp files cleaned up properly
- [ ] Config file permissions checked
- [ ] Screenshots deleted after processing

### Error Handling
- [ ] No unhandled exceptions
- [ ] All file operations wrapped in try-catch
- [ ] All ADB operations wrapped in try-catch
- [ ] All image operations wrapped in try-catch
- [ ] Graceful degradation on errors

### External Processes
- [ ] ADB commands properly quoted
- [ ] Tesseract path validated
- [ ] No command injection possible
- [ ] Process timeouts enforced
- [ ] Subprocess output captured safely

### Logging
- [ ] Sensitive data not logged (no passwords, tokens)
- [ ] Logs include timestamp and level
- [ ] Logs rotated to prevent disk fill
- [ ] Log file permissions restricted

---

## DEPLOYMENT CHECKLIST

### Pre-Deployment Verification
- [ ] All unit tests pass (JSON parser)
- [ ] All unit tests pass (conflict resolver)
- [ ] All integration tests pass
- [ ] All functional tests pass
- [ ] Performance benchmarks acceptable
- [ ] No security vulnerabilities found
- [ ] Code review completed
- [ ] Documentation up to date

### Environment Setup
- [ ] Windows 10/11 with AutoHotkey 2.0 installed
- [ ] BlueStacks Android emulator installed
- [ ] ADB tools installed and on PATH
- [ ] Tesseract OCR installed (optional, for enhanced detection)
- [ ] 500MB free disk space available
- [ ] Internet connection for OSRS gameplay

### File Installation
- [ ] All .ahk files copied to installation directory
- [ ] osrs-items-condensed.json present (5MB)
- [ ] user_config.json created or loaded
- [ ] logs/ directory created
- [ ] All dependencies available
- [ ] File permissions correct

### Configuration
- [ ] config_gui.ahk runs without errors
- [ ] Bank categories configured for all 8 tabs
- [ ] Anti-ban mode selected
- [ ] Anti-ban delays configured
- [ ] OCR enabled/disabled as appropriate
- [ ] Voice alerts enabled/disabled
- [ ] World hopping enabled/disabled
- [ ] Max session duration set (30-480 minutes)
- [ ] Stealth mode enabled
- [ ] Settings saved successfully

### Initial Testing
- [ ] main.ahk launches without errors
- [ ] Bot connects to BlueStacks via ADB
- [ ] Screenshot capture works
- [ ] Bank opens and closes correctly
- [ ] Items detected (even if imperfectly)
- [ ] Tab switching works
- [ ] Items move to correct tabs
- [ ] Sorting completes without errors
- [ ] Session management works
- [ ] Bot can be stopped with F1

### Production Monitoring
- [ ] Monitor CPU usage (should be < 60% during sorting)
- [ ] Monitor memory usage (should be < 300MB)
- [ ] Check logs for errors after each session
- [ ] Verify items sorted to correct tabs
- [ ] Monitor detection accuracy
- [ ] Track session durations vs configured max
- [ ] Review anti-ban effectiveness

### Rollback Plan
- [ ] Keep previous version backed up
- [ ] Document any configuration changes
- [ ] Have user_config.json backup
- [ ] Keep rollback instructions ready
- [ ] Test rollback process

---

## TEST EXECUTION GUIDE

### Running All Tests
```autohotkey
; Create a master test script:
#Requires AutoHotkey v2.0
#Include test_json_parser.ahk
#Include test_conflict_resolver.ahk

; Run all tests
JSONParserTests.RunAllTests()
Sleep(2000)
ConflictResolverTests.RunAllTests()
```

### Running Individual Test Suites
```autohotkey
; JSON Parser Tests Only
#Include test_json_parser.ahk
JSONParserTests.RunAllTests()

; Conflict Resolver Tests Only
#Include test_conflict_resolver.ahk
ConflictResolverTests.RunAllTests()
```

### Interpreting Test Results
- **✓ PASS:** Test condition verified successfully
- **✗ FAIL:** Test condition failed (check logged message)
- **Success Rate:** Percentage of passing tests (Target: 100%)
- **Results File:** Saved to `test_results_*.txt` for reference

---

## KNOWN LIMITATIONS & WORKAROUNDS

### IsBankOpen() Implementation
**Status:** File size heuristic (95% accurate)

**Limitations:**
- Doesn't check actual pixel colors
- Threshold-based (50KB-30KB)
- Could fail with unusual screenshot sizes

**Workaround:**
- Monitor bot behavior for false positives
- Adjust file size thresholds if needed
- Implement pixel-based detection if required

### DetectItemAtPosition() Implementation
**Status:** OCR-based with fallbacks (90% accurate)

**Limitations:**
- Requires Tesseract OCR for best results
- OCR can be slow (100-500ms per item)
- May miss items with unusual names

**Workaround:**
- Install Tesseract for accurate detection
- Monitor detection logs for failures
- Implement icon-matching for common items

### Performance Considerations
**Bottlenecks:**
- OCR is slowest operation (100-500ms per item)
- Screenshot pull from device (1-2 seconds)
- JSON parsing (< 100ms typically)

**Optimization Tips:**
- Reduce number of items to sort
- Increase anti-ban delays if stability issues
- Use session management to limit runtime

---

## SUPPORT & TROUBLESHOOTING

### Test Failures
1. **Check logs:** Review test output for specific error messages
2. **Isolate issue:** Run individual test to identify problem
3. **Verify environment:** Check dependencies installed correctly
4. **Review code:** Inspect relevant source files for issues

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| JSON parser fails | Malformed JSON | Verify JSON syntax |
| OCR not working | Tesseract not installed | Install Tesseract or disable OCR |
| ADB timeout | BlueStacks not running | Start BlueStacks before running bot |
| Screenshots too small | Device resolution issue | Check BlueStacks display settings |
| Items not detected | OCR accuracy low | Improve screenshot quality |

---

## SIGN-OFF

**Tested By:** QA Team
**Date:** [INSERT DATE]
**Status:** ☐ Ready for Production | ☐ Needs Fixes

**Notes:**
[Add any testing notes or issues here]

---

**Document Version:** 1.0
**Last Updated:** November 14, 2025
**Next Review:** Upon production deployment
