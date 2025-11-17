#!/usr/bin/env python3
"""
Comprehensive Project Validator for xh1px-tidy-bank
Performs deep syntax, semantic, and structural analysis of AutoHotkey v2.0 code
"""

import re
import os
from collections import defaultdict
from typing import Dict, List, Tuple, Set

class Issue:
    def __init__(self, severity: str, file: str, line: int, message: str):
        self.severity = severity
        self.file = file
        self.line = line
        self.message = message

    def __str__(self):
        return f"{self.severity:10} | {self.file:30} | Line {self.line:4} | {self.message}"

class ProjectValidator:
    def __init__(self, project_dir: str):
        self.project_dir = project_dir
        self.issues: List[Issue] = []
        self.warnings: List[Issue] = []
        self.info: List[Issue] = []

        # Track all functions across all files
        self.all_functions: Dict[str, List[Tuple[str, int]]] = defaultdict(list)
        self.file_contents: Dict[str, str] = {}

        # Built-in AutoHotkey functions
        self.builtins = {
            'MsgBox', 'FileExist', 'FileRead', 'FileAppend', 'FileDelete', 'DirExist', 'DirCreate',
            'Sleep', 'Run', 'RunWait', 'Trim', 'SubStr', 'StrLen', 'StrSplit', 'InStr', 'StrReplace',
            'Round', 'Floor', 'Random', 'Number', 'String', 'Map', 'Array', 'RegExMatch',
            'FormatTime', 'WinExist', 'WinActivate', 'ComObject', 'ExitApp', 'SetTimer',
            'Integer', 'StrLower', 'StrUpper', 'Sqrt', 'IsNumber', 'IsNaN', 'Error', 'Clone',
            'Push', 'Pop', 'Length', 'Count', 'Has', 'Delete', 'Get', 'Set', 'GetText',
            'Add', 'Modify', 'Choose', 'Opt', 'SetFont', 'Show', 'Value', 'Text', 'GetCount'
        }

    def add_issue(self, severity: str, file: str, line: int, message: str):
        issue = Issue(severity, file, line, message)
        if severity in ('CRITICAL', 'ERROR'):
            self.issues.append(issue)
        elif severity == 'WARNING':
            self.warnings.append(issue)
        else:
            self.info.append(issue)

    def validate_brace_balance(self, file: str, content: str):
        """Validate that all braces, brackets, and parentheses are balanced"""
        lines = content.split('\n')
        stack = []

        for line_num, line in enumerate(lines, 1):
            # Skip comment lines
            trimmed = line.strip()
            if trimmed.startswith(';'):
                continue

            # Simple state tracking (doesn't handle all edge cases)
            in_string = False
            i = 0
            while i < len(line):
                char = line[i]

                # Track strings
                if char == '"' and (i == 0 or line[i-1] != '\\'):
                    in_string = not in_string

                if not in_string:
                    if char == '{':
                        stack.append(('{', line_num))
                    elif char == '}':
                        if not stack or stack[-1][0] != '{':
                            self.add_issue('ERROR', file, line_num, 'Unmatched closing brace }')
                        else:
                            stack.pop()
                    elif char == '[':
                        stack.append(('[', line_num))
                    elif char == ']':
                        if not stack or stack[-1][0] != '[':
                            self.add_issue('ERROR', file, line_num, 'Unmatched closing bracket ]')
                        else:
                            stack.pop()
                    elif char == '(':
                        stack.append(('(', line_num))
                    elif char == ')':
                        if not stack or stack[-1][0] != '(':
                            self.add_issue('ERROR', file, line_num, 'Unmatched closing parenthesis )')
                        else:
                            stack.pop()

                i += 1

        # Check for unclosed braces
        for brace, line_num in stack:
            self.add_issue('ERROR', file, line_num, f'Unclosed {brace}')

    def extract_functions(self, file: str, content: str) -> Dict[str, int]:
        """Extract all function definitions from a file"""
        functions = {}
        lines = content.split('\n')

        for line_num, line in enumerate(lines, 1):
            trimmed = line.strip()

            # Match function definition: FunctionName(params) {
            match = re.match(r'^([A-Z_][A-Z0-9_]*)\s*\(', trimmed, re.IGNORECASE)
            if match:
                func_name = match.group(1)
                functions[func_name] = line_num

            # Match static method: static MethodName(params) {
            match = re.match(r'^static\s+([A-Z_][A-Z0-9_]*)\s*\(', trimmed, re.IGNORECASE)
            if match:
                func_name = match.group(1)
                functions[func_name] = line_num

        return functions

    def find_function_calls(self, file: str, content: str) -> Dict[str, List[int]]:
        """Find all function calls in a file"""
        calls = defaultdict(list)
        lines = content.split('\n')

        for line_num, line in enumerate(lines, 1):
            trimmed = line.strip()

            # Skip comment lines
            if trimmed.startswith(';'):
                continue

            # Find all function calls: FunctionName(
            for match in re.finditer(r'([A-Z_][A-Z0-9_]*)\s*\(', line, re.IGNORECASE):
                func_name = match.group(1)
                calls[func_name].append(line_num)

        return calls

    def validate_function_calls(self, file: str, content: str):
        """Validate that all function calls have definitions"""
        calls = self.find_function_calls(file, content)

        for func_name, line_nums in calls.items():
            # Skip built-in functions
            if func_name in self.builtins:
                continue

            # Skip class names (simple heuristic: starts with capital letter)
            if func_name[0].isupper() and func_name in ['JSON', 'Map', 'Array', 'Error']:
                continue

            # Check if function is defined anywhere
            if func_name not in self.all_functions:
                for line_num in line_nums:
                    self.add_issue('ERROR', file, line_num, f'Call to undefined function: {func_name}')

    def validate_string_quotes(self, file: str, content: str):
        """Validate that all string quotes are balanced"""
        lines = content.split('\n')

        for line_num, line in enumerate(lines, 1):
            # Skip comment lines
            if line.strip().startswith(';'):
                continue

            # Count quotes (simple approach)
            quote_count = line.count('"')

            # Odd number of quotes = unbalanced
            if quote_count % 2 != 0:
                self.add_issue('ERROR', file, line_num, 'Unbalanced quotes in line')

    def validate_map_access(self, file: str, content: str):
        """Validate Map access patterns"""
        lines = content.split('\n')

        for line_num, line in enumerate(lines, 1):
            # Skip comment lines
            if line.strip().startswith(';'):
                continue

            # Look for potential incorrect map access (heuristic)
            # This is a simplified check
            if re.search(r'\bmap\.\w+\b(?!\()', line, re.IGNORECASE):
                # Could be incorrect dot notation instead of bracket notation
                self.add_issue('WARNING', file, line_num, 'Potential incorrect Map access - use bracket notation map["key"]')

    def check_error_handling(self, file: str, content: str):
        """Check for error handling around risky operations"""
        lines = content.split('\n')

        risky_functions = ['FileRead', 'FileAppend', 'FileDelete', 'DirCreate', 'Run', 'RunWait']

        for line_num, line in enumerate(lines, 1):
            # Skip comment lines
            if line.strip().startswith(';'):
                continue

            # Check if risky function is used
            for risky_func in risky_functions:
                if risky_func in line:
                    # Check if there's a try-catch nearby (within 5 lines before)
                    has_try = False
                    for check_line in range(max(0, line_num - 6), line_num):
                        if check_line < len(lines) and 'try' in lines[check_line].lower():
                            has_try = True
                            break

                    if not has_try:
                        self.add_issue('WARNING', file, line_num,
                                     f'Risky operation {risky_func} without try-catch')

    def validate_includes(self, file: str, content: str):
        """Validate #Include statements"""
        lines = content.split('\n')

        for line_num, line in enumerate(lines, 1):
            trimmed = line.strip()

            # Match #Include statement
            match = re.match(r'^#Include\s+(.+)', trimmed, re.IGNORECASE)
            if match:
                include_file = match.group(1).strip()
                include_path = os.path.join(self.project_dir, include_file)

                if not os.path.exists(include_path):
                    self.add_issue('ERROR', file, line_num, f'Included file not found: {include_file}')

    def check_placeholder_functions(self, file: str, content: str):
        """Check for placeholder/incomplete functions"""
        lines = content.split('\n')

        for line_num, line in enumerate(lines, 1):
            trimmed = line.strip()

            # Look for placeholder comments
            if 'placeholder' in trimmed.lower() and trimmed.startswith(';'):
                self.add_issue('INFO', file, line_num, 'Placeholder function detected - needs implementation')

            # Look for functions that just return true/false without logic
            if trimmed == 'return true' or trimmed == 'return false':
                self.add_issue('INFO', file, line_num, 'Function returns constant - verify implementation')

    def validate_all_files(self):
        """Main validation routine"""
        # Get all AHK files
        ahk_files = [
            'main.ahk',
            'constants.ahk',
            'item_grouping.ahk',
            'bank_tab_resolver.ahk',
            'config_gui.ahk',
            'json_parser.ahk',
            'performance.ahk'
        ]

        # First pass: Read all files and extract functions
        for file in ahk_files:
            file_path = os.path.join(self.project_dir, file)

            if not os.path.exists(file_path):
                self.add_issue('ERROR', file, 0, f'File not found: {file_path}')
                continue

            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    self.file_contents[file] = content

                    # Extract functions
                    functions = self.extract_functions(file, content)
                    for func_name, line_num in functions.items():
                        self.all_functions[func_name].append((file, line_num))

            except Exception as e:
                self.add_issue('ERROR', file, 0, f'Failed to read file: {str(e)}')

        # Second pass: Validate each file
        for file, content in self.file_contents.items():
            print(f"Validating: {file}")

            # Stage 1: Syntax validation
            self.validate_brace_balance(file, content)
            self.validate_string_quotes(file, content)

            # Stage 2: Semantic validation
            self.validate_function_calls(file, content)
            self.validate_includes(file, content)
            self.validate_map_access(file, content)

            # Stage 3: Error handling
            self.check_error_handling(file, content)

            # Stage 4: Logic validation
            self.check_placeholder_functions(file, content)

    def generate_report(self) -> str:
        """Generate comprehensive validation report"""
        report = []
        report.append("=" * 80)
        report.append("COMPREHENSIVE PROJECT VALIDATION REPORT")
        report.append("=" * 80)
        report.append(f"\nGenerated: {os.popen('date').read().strip()}\n")

        report.append("SUMMARY:")
        report.append(f"  Critical/Errors: {len(self.issues)}")
        report.append(f"  Warnings: {len(self.warnings)}")
        report.append(f"  Info: {len(self.info)}")
        report.append("")

        if self.issues:
            report.append("=" * 80)
            report.append("CRITICAL ISSUES & ERRORS")
            report.append("=" * 80)
            for issue in sorted(self.issues, key=lambda x: (x.file, x.line)):
                report.append(str(issue))
            report.append("")

        if self.warnings:
            report.append("=" * 80)
            report.append("WARNINGS")
            report.append("=" * 80)
            for warning in sorted(self.warnings, key=lambda x: (x.file, x.line)):
                report.append(str(warning))
            report.append("")

        if self.info:
            report.append("=" * 80)
            report.append("INFORMATIONAL")
            report.append("=" * 80)
            for info in sorted(self.info, key=lambda x: (x.file, x.line)):
                report.append(str(info))
            report.append("")

        report.append("=" * 80)
        report.append("VALIDATION COMPLETE")
        report.append("=" * 80)

        return '\n'.join(report)

def main():
    project_dir = '/home/xh1px/xh1px-tidy-bank'

    validator = ProjectValidator(project_dir)
    validator.validate_all_files()

    report = validator.generate_report()

    # Print to console
    print(report)

    # Save to file
    report_file = os.path.join(project_dir, 'PYTHON_VALIDATION_REPORT.txt')
    with open(report_file, 'w') as f:
        f.write(report)

    print(f"\n\nReport saved to: {report_file}")

    # Exit with error code if critical issues found
    if validator.issues:
        exit(1)
    else:
        exit(0)

if __name__ == '__main__':
    main()
