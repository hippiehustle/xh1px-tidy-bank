#!/bin/bash
# AutoHotkey Validation Script
# Validates .ahk files for common syntax errors and patterns
# Can be run standalone or as part of pre-commit hook

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0
FILES_CHECKED=0

# If running in pre-commit mode, only check staged files
PRE_COMMIT_MODE=false
if [ "$1" == "--pre-commit" ]; then
    PRE_COMMIT_MODE=true
fi

echo -e "${BOLD}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║     AutoHotkey v2 Code Validation Tool                ║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to check a single file
validate_file() {
    local file="$1"
    local file_errors=0
    local file_warnings=0

    echo -e "${BLUE}📄 Validating: ${file}${NC}"

    # Check 1: Spaces in function/method names
    # This check is intentionally conservative to avoid false positives
    # It only checks for specific bad patterns like "Name With Space("
    # Manual review is better than automated detection for this issue
    # if [[ $(grep -nE "[A-Za-z][A-Za-z0-9_]+ +[A-Za-z][A-Za-z0-9_]*\s*\(" "$file" 2>/dev/null | \
    #        grep -v "^\s*;" | \
    #        grep -v "^\s*\(if\|else if\|while\|for\|return\|static\)" | \
    #        grep -v ":=" | \
    #        wc -l) -gt 0 ]]; then
    #     echo -e "${YELLOW}  ⚠️  WARNING: Possible space in function/method name${NC}"
    #     echo -e "${YELLOW}     Manual review recommended${NC}"
    #     ((file_warnings++))
    # fi
    # (Disabled due to high false positive rate - rely on SessionStart hook or manual testing instead)

    # Check 2: ListView.Modify with comma-skipping
    local modify_issues=$(grep -n "\.Modify([^)]*,\s*,\s*," "$file" 2>/dev/null | wc -l)
    if [ "$modify_issues" -gt 0 ]; then
        echo -e "${YELLOW}  ⚠️  WARNING: Found $modify_issues ListView.Modify with commas${NC}"
        echo -e "${YELLOW}     AHK v2 requires empty strings \"\" instead of commas${NC}"
        grep -n "\.Modify([^)]*,\s*,\s*," "$file" 2>/dev/null | head -3 | while read line; do
            echo -e "${YELLOW}     $line${NC}"
        done
        ((file_warnings++))
    fi

    # Check 3: Closures with loop variables
    if grep -n "OnEvent.*=>\s*.*\(A_Index\|tabNum\|i\b\)" "$file" 2>/dev/null | head -3; then
        echo -e "${YELLOW}  ⚠️  WARNING: Closure may capture loop variable${NC}"
        echo -e "${YELLOW}     Verify IIFE or .Bind() is used to capture value${NC}"
        ((file_warnings++))
    fi

    # Check 4: Mismatched braces (disabled - unreliable with string literals and comments)
    # This check produces too many false positives with embedded JSON, regex, etc.
    # local open_braces=$(grep -o "{" "$file" 2>/dev/null | wc -l)
    # local close_braces=$(grep -o "}" "$file" 2>/dev/null | wc -l)
    # if [ "$open_braces" -ne "$close_braces" ]; then
    #     echo -e "${YELLOW}  ⚠️  WARNING: Possible mismatched braces${NC}"
    #     echo -e "${YELLOW}     Found $open_braces '{' but $close_braces '}' (may be false positive)${NC}"
    #     ((file_warnings++))
    # fi

    # Check 5: Assignment instead of comparison (skip known false positives)
    # Only warn about clear assignment cases, not comparisons with literals
    if grep -nE "if\s*\(\s*[A-Za-z_][A-Za-z0-9_]*\s*=\s*[^=]" "$file" 2>/dev/null | \
       grep -v "==" | \
       grep -v "= true" | \
       grep -v "= false" | \
       grep -v "= null" | \
       head -2; then
        echo -e "${YELLOW}  ⚠️  WARNING: Possible assignment in if statement${NC}"
        echo -e "${YELLOW}     Use '==' for comparison, not '='${NC}"
        ((file_warnings++))
    fi

    # Check 6: Map access without Has() check (basic pattern)
    local map_access=$(grep -n "\[[\"'][A-Za-z_][A-Za-z0-9_]*[\"']\]\s*:=" "$file" 2>/dev/null | wc -l)
    local has_checks=$(grep -n "\.Has(" "$file" 2>/dev/null | wc -l)
    if [ "$map_access" -gt 0 ] && [ "$has_checks" -eq 0 ]; then
        echo -e "${YELLOW}  ⚠️  WARNING: Map operations without .Has() checks${NC}"
        echo -e "${YELLOW}     Consider checking key existence before access${NC}"
        ((file_warnings++))
    fi

    # Check 7: Global variable patterns
    # Look for common global variables that might be missing from declarations
    if grep -q "tabConfigs\s*:=" "$file" 2>/dev/null; then
        # Check if there's a global declaration for tabConfigs
        if ! grep -q "global.*tabConfigs" "$file" 2>/dev/null; then
            echo -e "${YELLOW}  ⚠️  WARNING: tabConfigs assigned without global declaration${NC}"
            echo -e "${YELLOW}     This may create a local variable instead${NC}"
            ((file_warnings++))
        fi
    fi

    if grep -q "groupToTab\s*:=" "$file" 2>/dev/null; then
        if ! grep -q "global.*groupToTab" "$file" 2>/dev/null; then
            echo -e "${YELLOW}  ⚠️  WARNING: groupToTab assigned without global declaration${NC}"
            ((file_warnings++))
        fi
    fi

    # Check 8: Common typos
    if grep -n "\.Lenght\b" "$file" 2>/dev/null; then
        echo -e "${RED}  ❌ ERROR: Typo 'Lenght' should be 'Length'${NC}"
        ((file_errors++))
    fi

    if grep -n "\.Deletee\b" "$file" 2>/dev/null; then
        echo -e "${RED}  ❌ ERROR: Typo 'Deletee' should be 'Delete'${NC}"
        ((file_errors++))
    fi

    # Check 9: File operations without error handling
    local file_ops=$(grep -n "FileAppend\|FileDelete\|FileRead" "$file" 2>/dev/null | wc -l)
    local try_blocks=$(grep -n "^\s*try\s*{" "$file" 2>/dev/null | wc -l)
    if [ "$file_ops" -gt 0 ] && [ "$try_blocks" -eq 0 ]; then
        echo -e "${YELLOW}  ⚠️  WARNING: File operations without try-catch blocks${NC}"
        echo -e "${YELLOW}     Consider adding error handling${NC}"
        ((file_warnings++))
    fi

    # Summary for this file
    if [ $file_errors -eq 0 ] && [ $file_warnings -eq 0 ]; then
        echo -e "${GREEN}  ✅ No issues found${NC}"
    else
        if [ $file_errors -gt 0 ]; then
            echo -e "${RED}  ❌ Found $file_errors error(s)${NC}"
        fi
        if [ $file_warnings -gt 0 ]; then
            echo -e "${YELLOW}  ⚠️  Found $file_warnings warning(s)${NC}"
        fi
    fi

    echo ""

    ERRORS=$((ERRORS + file_errors))
    WARNINGS=$((WARNINGS + file_warnings))

    return $file_errors
}

# Get list of files to check
if [ "$PRE_COMMIT_MODE" = true ]; then
    # Pre-commit mode: check staged files
    FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.ahk$')
    if [ -z "$FILES" ]; then
        echo -e "${GREEN}No .ahk files staged for commit${NC}"
        exit 0
    fi
    echo "Mode: Pre-commit validation"
else
    # Standalone mode: check all .ahk files
    FILES=$(find . -name "*.ahk" -not -path "./.*" -not -path "*/node_modules/*" 2>/dev/null)
    if [ -z "$FILES" ]; then
        echo -e "${YELLOW}No .ahk files found in project${NC}"
        exit 0
    fi
    echo "Mode: Full project validation"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Validate each file
for file in $FILES; do
    ((FILES_CHECKED++))
    validate_file "$file"
done

# Final summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BOLD}📊 VALIDATION SUMMARY${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Files checked:  ${FILES_CHECKED}"
echo -e "Errors found:   ${RED}${ERRORS}${NC}"
echo -e "Warnings found: ${YELLOW}${WARNINGS}${NC}"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "\n${GREEN}${BOLD}✅ VALIDATION PASSED${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "\n${YELLOW}${BOLD}⚠️  VALIDATION PASSED WITH WARNINGS${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
else
    echo -e "\n${RED}${BOLD}❌ VALIDATION FAILED${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [ "$PRE_COMMIT_MODE" = true ]; then
        echo -e "${RED}Commit aborted due to validation errors${NC}"
    fi
    exit 1
fi
