#!/usr/bin/env python3
"""
Precise brace matching for json_parser.ahk
"""

def check_braces(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    stack = []
    line_num = 0

    for line in lines:
        line_num += 1
        # Remove comments and strings (simple approach)
        clean = ''
        in_string = False
        escape_next = False

        for i, ch in enumerate(line):
            if escape_next:
                escape_next = False
                continue

            if ch == '\\' and in_string:
                escape_next = True
                continue

            if ch == '"':
                in_string = not in_string
                continue

            if not in_string:
                if ch == ';':  # Comment start
                    break
                clean += ch

        # Now count braces in clean line
        for i, ch in enumerate(clean):
            if ch == '{':
                stack.append((line_num, i, ch))
                print(f"Line {line_num:3d}: OPEN  brace at column {i:3d} | Stack depth: {len(stack)}")
            elif ch == '}':
                if stack and stack[-1][2] == '{':
                    opener = stack.pop()
                    print(f"Line {line_num:3d}: CLOSE brace at column {i:3d} | Matches line {opener[0]:3d} | Stack depth: {len(stack)}")
                else:
                    print(f"Line {line_num:3d}: CLOSE brace at column {i:3d} | ERROR: NO MATCHING OPEN BRACE")
                    stack.append(('ERROR', line_num, '}'))

    print(f"\n{'='*60}")
    print(f"FINAL STACK (should be empty): {len(stack)} items")
    if stack:
        print("UNMATCHED BRACES:")
        for item in stack:
            if item[0] == 'ERROR':
                print(f"  Extra close brace at line {item[1]}")
            else:
                print(f"  Unclosed open brace at line {item[0]}")
    else:
        print("ALL BRACES MATCHED!")

check_braces(r"C:\Users\xh1px\xh1px-tidy-bank\json_parser.ahk")
