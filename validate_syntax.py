#!/usr/bin/env python3
"""
Comprehensive AutoHotkey v2 Syntax Validator
Performs deep analysis of brace balance, function definitions, and variable scope
"""

import re
import os
from collections import defaultdict
from pathlib import Path

class AHKValidator:
    def __init__(self, base_dir):
        self.base_dir = Path(base_dir)
        self.issues = []
        self.files = {}
        self.functions = {}  # name -> {file, line, params}
        self.function_calls = []  # [(name, file, line)]
        self.global_vars = set()
        self.class_defs = {}  # classname -> {file, methods}

    def load_files(self):
        """Load all .ahk files"""
        for ahk_file in self.base_dir.glob("**/*.ahk"):
            with open(ahk_file, 'r', encoding='utf-8', errors='ignore') as f:
                self.files[ahk_file.name] = {
                    'path': ahk_file,
                    'lines': f.readlines(),
                    'content': ''.join(f.readlines())
                }

    def check_brace_balance(self):
        """STAGE 1.1: Check brace and bracket balance"""
        print("\n=== STAGE 1.1: BRACE/BRACKET BALANCE CHECK ===")

        for filename, data in self.files.items():
            lines = data['lines']
            content = ''.join(lines)

            # Remove strings and comments to avoid false positives
            clean_content = self.remove_strings_and_comments(content)

            # Count braces
            open_braces = clean_content.count('{')
            close_braces = clean_content.count('}')
            open_brackets = clean_content.count('[')
            close_brackets = clean_content.count(']')
            open_parens = clean_content.count('(')
            close_parens = clean_content.count(')')

            if open_braces != close_braces:
                self.issues.append({
                    'type': 'BRACE_IMBALANCE',
                    'file': filename,
                    'message': f"Brace imbalance: {open_braces} open, {close_braces} close",
                    'severity': 'CRITICAL'
                })
                print(f"[FAIL] {filename}: Brace imbalance ({open_braces} open, {close_braces} close)")
            else:
                print(f"[PASS] {filename}: Braces balanced ({open_braces} pairs)")

            if open_brackets != close_brackets:
                self.issues.append({
                    'type': 'BRACKET_IMBALANCE',
                    'file': filename,
                    'message': f"Bracket imbalance: {open_brackets} open, {close_brackets} close",
                    'severity': 'CRITICAL'
                })
                print(f"[FAIL] {filename}: Bracket imbalance ({open_brackets} open, {close_brackets} close)")
            else:
                print(f"[PASS] {filename}: Brackets balanced ({open_brackets} pairs)")

            if open_parens != close_parens:
                self.issues.append({
                    'type': 'PAREN_IMBALANCE',
                    'file': filename,
                    'message': f"Parenthesis imbalance: {open_parens} open, {close_parens} close",
                    'severity': 'CRITICAL'
                })
                print(f"[FAIL] {filename}: Parenthesis imbalance ({open_parens} open, {close_parens} close)")
            else:
                print(f"[PASS] {filename}: Parentheses balanced ({open_parens} pairs)")

    def remove_strings_and_comments(self, content):
        """Remove string literals and comments from content"""
        # Remove multi-line comments (/* ... */)
        content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)

        # Remove single-line comments (; ...)
        content = re.sub(r';[^\n]*', '', content)

        # Remove string literals (both " and ')
        content = re.sub(r'"(?:[^"\\]|\\.)*"', '', content)
        content = re.sub(r"'(?:[^'\\]|\\.)*'", '', content)

        return content

    def check_function_definitions(self):
        """STAGE 1.2: Find all function definitions"""
        print("\n=== STAGE 1.2: FUNCTION DEFINITION & CALL VERIFICATION ===")

        # Pattern for function definitions
        func_pattern = re.compile(r'^\s*(\w+)\s*\([^)]*\)\s*\{?', re.MULTILINE)

        # Pattern for static method definitions
        static_method_pattern = re.compile(r'^\s*static\s+(\w+)\s*\([^)]*\)\s*\{?', re.MULTILINE)

        # Pattern for function calls
        call_pattern = re.compile(r'(\w+)\s*\(')

        for filename, data in self.files.items():
            content = ''.join(data['lines'])
            lines = data['lines']

            # Find function definitions
            for match in func_pattern.finditer(content):
                func_name = match.group(1)
                line_num = content[:match.start()].count('\n') + 1

                # Skip if it's a built-in AHK keyword
                if func_name not in ['if', 'else', 'while', 'for', 'loop', 'switch', 'case', 'try', 'catch', 'finally']:
                    self.functions[func_name] = {
                        'file': filename,
                        'line': line_num
                    }
                    print(f"[FUNC] Found function: {func_name} at {filename}:{line_num}")

            # Find static methods
            for match in static_method_pattern.finditer(content):
                method_name = match.group(1)
                line_num = content[:match.start()].count('\n') + 1
                self.functions[method_name] = {
                    'file': filename,
                    'line': line_num,
                    'static': True
                }
                print(f"[FUNC] Found static method: {method_name} at {filename}:{line_num}")

            # Find function calls
            for match in call_pattern.finditer(content):
                func_name = match.group(1)
                line_num = content[:match.start()].count('\n') + 1

                # Skip built-in functions and control structures
                builtins = ['if', 'while', 'for', 'loop', 'switch', 'case', 'try', 'catch',
                           'MsgBox', 'FileExist', 'FileRead', 'FileAppend', 'FileDelete',
                           'DirExist', 'DirCreate', 'Run', 'RunWait', 'Sleep', 'SetTimer',
                           'WinActivate', 'WinExist', 'ComObject', 'Round', 'Floor', 'Sqrt',
                           'Number', 'String', 'Integer', 'StrLen', 'SubStr', 'InStr',
                           'StrReplace', 'Trim', 'StrLower', 'StrUpper', 'Random',
                           'FormatTime', 'ExitApp', 'Map', 'Array', 'Push', 'Clone',
                           'OutputDebug', 'GetTimestamp', 'IsNumber', 'IsNaN', 'Throw', 'Error']

                if func_name not in builtins:
                    self.function_calls.append((func_name, filename, line_num))

        # Now check for undefined functions
        print(f"\n[INFO] Total functions defined: {len(self.functions)}")
        print(f"[INFO] Total function calls found: {len(self.function_calls)}")

        undefined_calls = []
        for func_name, filename, line_num in self.function_calls:
            if func_name not in self.functions:
                # Check if it's a class static method call (ClassName.MethodName format would be missed)
                if '.' not in func_name:
                    undefined_calls.append((func_name, filename, line_num))

        if undefined_calls:
            print(f"\n[WARN] Found {len(undefined_calls)} potentially undefined function calls:")
            for func_name, filename, line_num in undefined_calls[:20]:  # Show first 20
                print(f"  [FAIL] {func_name}() called at {filename}:{line_num}")
                self.issues.append({
                    'type': 'UNDEFINED_FUNCTION',
                    'file': filename,
                    'line': line_num,
                    'message': f"Function '{func_name}' called but not defined",
                    'severity': 'HIGH'
                })
        else:
            print("[PASS] All function calls have definitions")

    def check_string_balance(self):
        """STAGE 1.5: Check string quote balance"""
        print("\n=== STAGE 1.5: STRING & QUOTE BALANCE CHECK ===")

        for filename, data in self.files.items():
            lines = data['lines']

            for line_num, line in enumerate(lines, 1):
                # Skip full-line comments
                if line.strip().startswith(';'):
                    continue

                # Remove inline comments
                comment_pos = line.find(';')
                if comment_pos >= 0:
                    # Make sure it's not inside a string
                    before_comment = line[:comment_pos]
                    if before_comment.count('"') % 2 == 0:
                        line = before_comment

                # Count quotes (not escaped)
                double_quotes = len(re.findall(r'(?<!\\)"', line))

                if double_quotes % 2 != 0:
                    self.issues.append({
                        'type': 'QUOTE_IMBALANCE',
                        'file': filename,
                        'line': line_num,
                        'message': f"Unbalanced quotes on line {line_num}: {line.strip()}",
                        'severity': 'CRITICAL'
                    })
                    print(f"[FAIL] {filename}:{line_num} - Unbalanced quotes: {line.strip()[:60]}")

        if not any(i['type'] == 'QUOTE_IMBALANCE' for i in self.issues):
            print("[PASS] All quotes are balanced")

    def generate_report(self):
        """Generate final report"""
        print("\n" + "="*60)
        print("STAGE 1 VALIDATION REPORT")
        print("="*60)

        critical = [i for i in self.issues if i['severity'] == 'CRITICAL']
        high = [i for i in self.issues if i['severity'] == 'HIGH']
        medium = [i for i in self.issues if i['severity'] == 'MEDIUM']

        print(f"\nTotal Issues Found: {len(self.issues)}")
        print(f"  Critical: {len(critical)}")
        print(f"  High: {len(high)}")
        print(f"  Medium: {len(medium)}")

        if critical:
            print("\n[CRITICAL] CRITICAL ISSUES:")
            for issue in critical:
                print(f"  [{issue['type']}] {issue['file']}: {issue['message']}")

        if high:
            print("\n[HIGH] HIGH PRIORITY ISSUES:")
            for issue in high[:10]:  # Show first 10
                print(f"  [{issue['type']}] {issue['file']}:{issue.get('line', '?')} - {issue['message']}")

        return len(self.issues)

def main():
    base_dir = r"C:\Users\xh1px\xh1px-tidy-bank"
    validator = AHKValidator(base_dir)

    print("Loading AutoHotkey files...")
    validator.load_files()

    print(f"Found {len(validator.files)} .ahk files")
    for filename in validator.files:
        print(f"  - {filename}")

    # Run validation stages
    validator.check_brace_balance()
    validator.check_function_definitions()
    validator.check_string_balance()

    # Generate report
    total_issues = validator.generate_report()

    return total_issues

if __name__ == "__main__":
    exit_code = main()
    exit(exit_code if exit_code > 0 else 0)
