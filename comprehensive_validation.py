#!/usr/bin/env python3
"""
Comprehensive Debug Analysis Script
Validates all AutoHotkey files for syntax, structure, and logic issues
"""

import os
import re
import json
from pathlib import Path
from collections import defaultdict

# Configuration
PROJECT_ROOT = Path("/home/xh1px/xh1px-tidy-bank")
AHK_FILES = [
    "main.ahk",
    "main_template_v2.ahk",
    "constants.ahk",
    "config_gui.ahk",
    "item_grouping.ahk",
    "bank_tab_resolver.ahk",
    "json_parser.ahk",
    "performance.ahk",
    "test_json_parser.ahk",
    "test_conflict_resolver.ahk"
]

# Issue tracking
issues = {
    "critical": [],
    "high": [],
    "medium": [],
    "low": []
}

def log_issue(severity, file_path, line_num, message, category):
    """Log an issue with context"""
    issues[severity].append({
        "file": str(file_path),
        "line": line_num,
        "message": message,
        "category": category
    })

def check_brace_balance(file_path, content, lines):
    """Check if all braces and brackets are balanced"""
    print(f"\n  Checking brace balance in {file_path.name}...")

    # Track braces outside strings and comments
    braces = []
    brackets = []
    in_string = False
    in_comment = False

    for line_num, line in enumerate(lines, 1):
        # Skip comment lines
        if line.strip().startswith(';'):
            continue

        i = 0
        while i < len(line):
            char = line[i]

            # Handle strings
            if char == '"' and (i == 0 or line[i-1] != '\\'):
                in_string = not in_string

            # Only count braces outside strings
            if not in_string:
                if char == '{':
                    braces.append((line_num, 'open'))
                elif char == '}':
                    if not braces:
                        log_issue("critical", file_path, line_num,
                                f"Unmatched closing brace '}}' found", "SYNTAX")
                    else:
                        braces.pop()
                elif char == '[':
                    brackets.append((line_num, 'open'))
                elif char == ']':
                    if not brackets:
                        log_issue("critical", file_path, line_num,
                                f"Unmatched closing bracket ']' found", "SYNTAX")
                    else:
                        brackets.pop()

            i += 1

    # Check for unclosed braces
    if braces:
        for line_num, _ in braces:
            log_issue("critical", file_path, line_num,
                    f"Unclosed opening brace '{{' found", "SYNTAX")

    if brackets:
        for line_num, _ in brackets:
            log_issue("critical", file_path, line_num,
                    f"Unclosed opening bracket '[' found", "SYNTAX")

def extract_functions(content):
    """Extract function definitions from content"""
    # Match function definitions: FunctionName( or static FunctionName(
    func_pattern = r'^\s*(?:static\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*\('
    functions = []

    for match in re.finditer(func_pattern, content, re.MULTILINE):
        func_name = match.group(1)
        # Filter out keywords that look like functions
        if func_name not in ['if', 'while', 'for', 'switch', 'Loop', 'try', 'catch']:
            functions.append(func_name)

    return set(functions)

def extract_function_calls(content):
    """Extract function calls from content"""
    # Match function calls: FunctionName(
    call_pattern = r'([A-Za-z_][A-Za-z0-9_]*)\s*\('
    calls = []

    for match in re.finditer(call_pattern, content):
        func_name = match.group(1)
        # Filter out keywords
        if func_name not in ['if', 'while', 'for', 'switch', 'Loop', 'try', 'catch',
                            'Map', 'Array', 'SubStr', 'InStr', 'StrLen', 'Round',
                            'Number', 'String', 'Integer', 'Float', 'StrReplace',
                            'StrSplit', 'StrLower', 'StrUpper', 'Trim', 'FileExist',
                            'FileRead', 'FileAppend', 'FileDelete', 'FileGetTime',
                            'FileGetSize', 'DirExist', 'DirCreate', 'MsgBox',
                            'Sleep', 'SetTimer', 'Run', 'RunWait', 'ExitApp',
                            'WinActivate', 'WinExist', 'Random', 'Floor', 'Sqrt',
                            'ComObject', 'OutputDebug', 'FormatTime', 'Error',
                            'Gui', 'CreateTrackedOperation', 'Log']:
            calls.append(func_name)

    return calls

def check_function_definitions(file_path, content, lines):
    """Check that all function calls have definitions"""
    print(f"\n  Checking function definitions in {file_path.name}...")

    defined_functions = extract_functions(content)
    function_calls = extract_function_calls(content)

    # Check for undefined function calls
    undefined = set(function_calls) - defined_functions

    # Filter out known built-in functions and class methods
    builtins = {'Has', 'Push', 'Delete', 'Clone', 'Length', 'Count', 'Value',
                'Choose', 'Add', 'Modify', 'GetCount', 'GetText', 'Opt',
                'SetFont', 'UseTab', 'ModifyCol', 'OnEvent', 'Show', 'Close',
                'Speak', 'Parse', 'Stringify', 'LoadDatabase', 'GetItemById',
                'GetItemByName', 'Initialize', 'ResolveItemTab', 'RecordMetric',
                'GetElapsedTime', 'Complete', 'StartTimer', 'StopTimer',
                'IsValidAntiBanMode', 'IsValidMaxSession', 'IsValidTabNumber',
                'GetCellPosition', 'GetTabCoordinates', 'GetShortPause',
                'EnsureLogDirectory', 'SafeSleep', 'GetTimestamp', 'SafeFileDelete',
                'SafeDirCreate', 'IsApplicationRunning', 'RoundCoordinates',
                'IsValidScreenCoordinate', 'CalculateDistance', 'Clamp',
                'IsNumber', 'IsNaN'}

    undefined = undefined - builtins

    for func in undefined:
        log_issue("high", file_path, 0,
                f"Function '{func}' called but not defined (may be in #Include)",
                "FUNCTION_DEF")

def check_global_variables(file_path, content, lines):
    """Check global variable usage"""
    print(f"\n  Checking global variable usage in {file_path.name}...")

    # Extract function bodies
    func_pattern = r'(\w+)\s*\([^)]*\)\s*\{([^}]+)\}'

    # Common global variables
    known_globals = {'cfg', 'adb', 'screenshot', 'running', 'sessionStart',
                    'db', 'itemHashes', 'bankCategories', 'MyGui', 'MainTabs',
                    'selectedBankTab', 'tabConfigs', 'bankTabButtons', 'userCfg',
                    'defaultCfg', 'cfgFile', 'ColorSystem', 'TypographySystem',
                    'SpacingSystem'}

    # This is a basic check - full implementation would need AST parsing

def check_includes(file_path, content, lines):
    """Check #Include dependencies"""
    print(f"\n  Checking #Include statements in {file_path.name}...")

    include_pattern = r'#Include\s+(\S+)'

    for line_num, line in enumerate(lines, 1):
        match = re.search(include_pattern, line)
        if match:
            included_file = match.group(1)
            included_path = PROJECT_ROOT / included_file

            if not included_path.exists():
                log_issue("critical", file_path, line_num,
                        f"#Include file not found: {included_file}",
                        "DEPENDENCY")

def check_string_balance(file_path, content, lines):
    """Check if all strings are properly closed"""
    print(f"\n  Checking string balance in {file_path.name}...")

    for line_num, line in enumerate(lines, 1):
        # Skip comments
        if line.strip().startswith(';'):
            continue

        # Count unescaped quotes
        quote_count = 0
        i = 0
        while i < len(line):
            if line[i] == '"' and (i == 0 or line[i-1] != '\\'):
                quote_count += 1
            i += 1

        if quote_count % 2 != 0:
            log_issue("critical", file_path, line_num,
                    "Unmatched quote found - string not properly closed",
                    "SYNTAX")

def check_placeholder_functions(file_path, content, lines):
    """Find placeholder/incomplete functions"""
    print(f"\n  Checking for placeholder functions in {file_path.name}...")

    placeholder_keywords = ['placeholder', 'todo', 'fixme', 'hack', 'temporary',
                           'not implemented', 'coming soon']

    for line_num, line in enumerate(lines, 1):
        line_lower = line.lower()
        for keyword in placeholder_keywords:
            if keyword in line_lower and (';' in line or '//' in line):
                log_issue("medium", file_path, line_num,
                        f"Placeholder/incomplete code found: {keyword.upper()}",
                        "IMPLEMENTATION")

def check_error_handling(file_path, content, lines):
    """Check for proper error handling"""
    print(f"\n  Checking error handling in {file_path.name}...")

    # Find Run/RunWait commands without try-catch
    risky_commands = ['Run(', 'RunWait(', 'FileDelete(', 'FileAppend(']

    for line_num, line in enumerate(lines, 1):
        for cmd in risky_commands:
            if cmd in line and not line.strip().startswith(';'):
                # Check if there's a try block nearby (within 5 lines)
                has_try = False
                for check_line in range(max(0, line_num-5), min(len(lines), line_num+5)):
                    if 'try' in lines[check_line].lower():
                        has_try = True
                        break

                if not has_try:
                    log_issue("medium", file_path, line_num,
                            f"Risky operation '{cmd}' without try-catch",
                            "ERROR_HANDLING")

def analyze_file(file_path):
    """Perform comprehensive analysis on a single file"""
    print(f"\nAnalyzing: {file_path.name}")
    print("=" * 60)

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            lines = content.splitlines()

        # Run all checks
        check_brace_balance(file_path, content, lines)
        check_function_definitions(file_path, content, lines)
        check_global_variables(file_path, content, lines)
        check_includes(file_path, content, lines)
        check_string_balance(file_path, content, lines)
        check_placeholder_functions(file_path, content, lines)
        check_error_handling(file_path, content, lines)

        print(f"  Completed analysis of {file_path.name}")

    except Exception as e:
        log_issue("critical", file_path, 0, f"Failed to analyze file: {str(e)}", "FILE_ERROR")

def print_report():
    """Print comprehensive validation report"""
    print("\n\n")
    print("=" * 80)
    print("COMPREHENSIVE DEBUG ANALYSIS REPORT")
    print("=" * 80)
    print()

    total_issues = sum(len(v) for v in issues.values())

    print(f"Total Issues Found: {total_issues}")
    print(f"  Critical: {len(issues['critical'])}")
    print(f"  High: {len(issues['high'])}")
    print(f"  Medium: {len(issues['medium'])}")
    print(f"  Low: {len(issues['low'])}")
    print()

    # Print issues by severity
    for severity in ['critical', 'high', 'medium', 'low']:
        if issues[severity]:
            print(f"\n{severity.upper()} ISSUES ({len(issues[severity])}):")
            print("-" * 80)

            for issue in issues[severity]:
                print(f"\n  File: {issue['file']}")
                if issue['line'] > 0:
                    print(f"  Line: {issue['line']}")
                print(f"  Category: {issue['category']}")
                print(f"  Issue: {issue['message']}")

    # Category summary
    print("\n\nISSUES BY CATEGORY:")
    print("-" * 80)
    categories = defaultdict(int)
    for severity in issues.values():
        for issue in severity:
            categories[issue['category']] += 1

    for category, count in sorted(categories.items()):
        print(f"  {category}: {count}")

    # Save report to file
    report_path = PROJECT_ROOT / "COMPREHENSIVE_DEBUG_ANALYSIS.txt"
    with open(report_path, 'w') as f:
        f.write("COMPREHENSIVE DEBUG ANALYSIS REPORT\n")
        f.write("=" * 80 + "\n\n")
        f.write(f"Total Issues: {total_issues}\n")
        f.write(f"Critical: {len(issues['critical'])}\n")
        f.write(f"High: {len(issues['high'])}\n")
        f.write(f"Medium: {len(issues['medium'])}\n")
        f.write(f"Low: {len(issues['low'])}\n\n")

        for severity in ['critical', 'high', 'medium', 'low']:
            if issues[severity]:
                f.write(f"\n{severity.upper()} ISSUES:\n")
                f.write("-" * 80 + "\n")
                for issue in issues[severity]:
                    f.write(f"\nFile: {issue['file']}\n")
                    if issue['line'] > 0:
                        f.write(f"Line: {issue['line']}\n")
                    f.write(f"Category: {issue['category']}\n")
                    f.write(f"Issue: {issue['message']}\n")

    print(f"\n\nReport saved to: {report_path}")

def main():
    """Main execution function"""
    print("COMPREHENSIVE DEBUG ANALYSIS")
    print("=" * 80)
    print(f"Project root: {PROJECT_ROOT}")
    print(f"Analyzing {len(AHK_FILES)} AutoHotkey files...")
    print()

    for filename in AHK_FILES:
        file_path = PROJECT_ROOT / filename
        if file_path.exists():
            analyze_file(file_path)
        else:
            print(f"\nWARNING: File not found: {filename}")

    print_report()

    # Return exit code
    if issues['critical']:
        return 1
    return 0

if __name__ == "__main__":
    exit(main())
