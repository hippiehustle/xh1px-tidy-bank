# Claude Code Development Tools for AutoHotkey

This directory contains development tools, validation scripts, and reference documentation to help Claude Code produce error-free AutoHotkey v2 code.

---

## 📁 Directory Structure

```
.claude/
├── README.md                          # This file
├── AHK_CODE_REVIEW_CHECKLIST.md      # Comprehensive code review checklist
├── AHK_V2_SYNTAX_REFERENCE.md        # AutoHotkey v2 syntax quick reference
├── hooks/
│   └── SessionStart                   # Runs validation when session starts
└── scripts/
    ├── validate_ahk.sh               # Main validation script
    ├── pre-commit                     # Git pre-commit hook template
    └── install_hooks.sh              # Install pre-commit hook
```

---

## 🚀 Quick Start

### For Claude Code Sessions

When a new Claude Code session starts, the `SessionStart` hook automatically runs and validates all `.ahk` files in the project.

### For Manual Validation

```bash
# Validate all .ahk files in project
./.claude/scripts/validate_ahk.sh

# Validate only staged files (pre-commit mode)
./.claude/scripts/validate_ahk.sh --pre-commit
```

### Install Git Pre-Commit Hook

```bash
# Run the installation script
./.claude/scripts/install_hooks.sh

# Or manually
cp .claude/scripts/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

Once installed, validation runs automatically before each commit.

---

## 📚 Documentation

### 1. **AHK_CODE_REVIEW_CHECKLIST.md**

Comprehensive checklist covering:
- ✅ Variable scope and global declarations
- ✅ Closures and callback functions
- ✅ ListView operations
- ✅ Function naming rules
- ✅ String handling
- ✅ Map operations
- ✅ Control flow patterns
- ✅ Error handling
- ✅ Common pitfalls in this project

**When to use**: Before every commit, review modified `.ahk` files against this checklist.

### 2. **AHK_V2_SYNTAX_REFERENCE.md**

Quick syntax reference including:
- 📦 Data structures (Arrays, Maps, Objects)
- 🔄 Control flow (if, loops, while)
- 📞 Functions and arrow functions
- 🎨 GUI controls and events
- 🔗 Closures and scope
- 📝 String operations
- 📄 File operations
- 🔢 JSON handling
- 🎯 Classes
- ⚠️ Common gotchas

**When to use**: Quick lookup when writing or reviewing code.

---

## 🔍 Validation Checks

The validation script (`validate_ahk.sh`) performs these checks:

### ❌ Errors (Block Commit)

1. **Spaces in function/method names**
   - Example: `static GetItemsByCore Group()`
   - Fix: `static GetItemsByCoreGroup()`

2. **Mismatched braces**
   - Counts `{` and `}` to ensure they match

3. **Common typos**
   - `.Lenght` → `.Length`
   - `.Deletee` → `.Delete`

### ⚠️ Warnings (Allow Commit)

1. **ListView.Modify with commas**
   - Pattern: `.Modify(row, , , , "value")`
   - Fix: `.Modify(row, "", "", "", "value")`

2. **Closures with loop variables**
   - Pattern: `OnEvent("Click", (*) => Func(A_Index))`
   - Fix: Use IIFE or .Bind()

3. **Assignment in if statements**
   - Pattern: `if (var = value)`
   - Fix: `if (var == value)`

4. **Global variables without declaration**
   - Pattern: `tabConfigs := Map()` without `global tabConfigs`

5. **Map access without .Has() checks**
   - Reminder to check key existence

6. **File operations without try-catch**
   - Reminder to add error handling

---

## 🛠️ Tools Overview

### 1. Session Start Hook

**File**: `.claude/hooks/SessionStart`

**Purpose**: Automatically validates project when Claude Code session starts

**What it does**:
- Scans all `.ahk` files in project
- Runs pattern-based validation
- Reports errors and warnings
- Always allows session to continue (non-blocking)

**Output Example**:
```
🔍 Running AutoHotkey project validation...
Scanning for .ahk files...

📄 Checking: ./config_gui.ahk
  ✅ No issues found

📄 Checking: ./item_grouping.ahk
  ✅ No issues found

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Validation Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Files checked: 2
Status: ✅ All checks passed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 2. Validation Script

**File**: `.claude/scripts/validate_ahk.sh`

**Purpose**: Standalone or pre-commit validation of `.ahk` files

**Usage**:
```bash
# Validate all files
./claude/scripts/validate_ahk.sh

# Pre-commit mode (only staged files)
./.claude/scripts/validate_ahk.sh --pre-commit
```

**Features**:
- Comprehensive pattern matching
- Color-coded output
- Error and warning categorization
- Line number reporting for issues
- Summary statistics

### 3. Pre-Commit Hook

**File**: `.claude/scripts/pre-commit`

**Purpose**: Prevent commits with validation errors

**How it works**:
1. Triggered automatically before each `git commit`
2. Runs validation on staged `.ahk` files only
3. Allows commit if no errors (warnings OK)
4. Blocks commit if errors found

**Bypass** (not recommended):
```bash
git commit --no-verify
```

### 4. Hook Installation Script

**File**: `.claude/scripts/install_hooks.sh`

**Purpose**: Easy installation of Git hooks

**Usage**:
```bash
./.claude/scripts/install_hooks.sh
```

---

## 🎯 Workflow Integration

### Recommended Development Workflow

1. **Start Session**
   - SessionStart hook validates project
   - Review any issues reported

2. **Write Code**
   - Reference `AHK_V2_SYNTAX_REFERENCE.md` as needed
   - Follow patterns from `AHK_CODE_REVIEW_CHECKLIST.md`

3. **Before Committing**
   - Review changes against `AHK_CODE_REVIEW_CHECKLIST.md`
   - Run manual validation: `./.claude/scripts/validate_ahk.sh`
   - Fix any errors/warnings

4. **Commit**
   - Pre-commit hook validates staged files
   - Commit proceeds if validation passes

5. **Test on Windows**
   - Run `.ahk` files on Windows machine
   - Verify functionality

---

## 🐛 Bugs Prevented by These Tools

### Real Bugs Fixed in This Project

1. **Closure Capture Bug** (Commit `7f76aa9`)
   - **Detected by**: Closure validation check
   - **Pattern**: Loop variable in arrow function
   - **Impact**: Bank tab buttons all called same function

2. **Missing Global Declaration** (Commit `353c00d`)
   - **Detected by**: Global variable assignment check
   - **Pattern**: `tabConfigs := Map()` without `global tabConfigs`
   - **Impact**: Save functionality didn't persist data

3. **ListView.Modify Syntax** (Commit `421f8f1`)
   - **Detected by**: ListView.Modify comma check
   - **Pattern**: `.Modify(row, , , , "value")`
   - **Impact**: ListView updates failed

4. **Space in Method Name** (Commit `4d61312`)
   - **Detected by**: Function name validation
   - **Pattern**: `GetItemsByCore Group` with space
   - **Impact**: Script failed to load

---

## 📊 Validation Statistics

After running validation, you'll see:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 VALIDATION SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Files checked:  5
Errors found:   0
Warnings found: 2
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Exit Codes**:
- `0` = Validation passed (no errors, warnings OK)
- `1` = Validation failed (errors found)

---

## 🔧 Customization

### Add New Validation Checks

Edit `.claude/scripts/validate_ahk.sh` and add new checks in the `validate_file()` function:

```bash
# Check 10: Your custom check
if grep -n "your_pattern" "$file" 2>/dev/null; then
    echo -e "${RED}  ❌ ERROR: Your error message${NC}"
    ((file_errors++))
fi
```

### Modify SessionStart Hook

Edit `.claude/hooks/SessionStart` to customize project-wide validation.

### Update Documentation

Keep reference docs up-to-date:
- `AHK_CODE_REVIEW_CHECKLIST.md` - Add new patterns
- `AHK_V2_SYNTAX_REFERENCE.md` - Add new syntax examples

---

## 💡 Tips for Claude Code

When writing AutoHotkey code:

1. **Always check the checklist** before committing
2. **Reference syntax guide** for correct patterns
3. **Run validation manually** during development
4. **Review validation output** at session start
5. **Add comments** for complex closures or conversions
6. **Test on Windows** before finalizing

---

## 🚨 Troubleshooting

### Validation Script Not Running

```bash
# Make sure it's executable
chmod +x .claude/scripts/validate_ahk.sh

# Run directly
bash .claude/scripts/validate_ahk.sh
```

### Pre-Commit Hook Not Working

```bash
# Check if hook is installed
ls -la .git/hooks/pre-commit

# Reinstall
./.claude/scripts/install_hooks.sh

# Make sure it's executable
chmod +x .git/hooks/pre-commit
```

### SessionStart Hook Not Running

```bash
# Check if hook exists and is executable
ls -la .claude/hooks/SessionStart
chmod +x .claude/hooks/SessionStart
```

### False Positives

If validation reports false positives:
1. Review the pattern in `validate_ahk.sh`
2. Add exception handling if needed
3. Document in comments why pattern is safe

---

## 📈 Future Improvements

Potential enhancements:

- [ ] Integration with AutoHotkey syntax checker on Windows
- [ ] VSCode extension integration
- [ ] Automated fix suggestions
- [ ] Performance profiling
- [ ] Test coverage reporting
- [ ] Documentation generation from code
- [ ] Dependency analysis
- [ ] Dead code detection

---

## 📄 License

These tools are part of the xh1px-tidy-bank project.

---

## 🤝 Contributing

To improve these tools:

1. Test validation on more `.ahk` files
2. Add new pattern checks as bugs are discovered
3. Update documentation with new patterns
4. Report false positives or missed errors

---

**Last Updated**: 2025-11-14
**Version**: 1.0.0
**Maintained by**: Claude Code
