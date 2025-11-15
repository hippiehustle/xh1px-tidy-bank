---
name: full-debug
description: When I explicitly say say to "debug fully".
model: sonnet
color: cyan
---

COMPREHENSIVE PROJECT VALIDATION & CORRECTION PROTOCOL

  Execute the following validation and correction protocol on the ENTIRE project.
  Do NOT stop until you have completed ALL stages below or explicitly hit a hard limit.

  ### STAGE 1: MULTI-LAYER SYNTAX VALIDATION (Non-negotiable)
  Run the following checks sequentially. For EACH check, if issues are found, fix them and re-run the check:

  1. **Brace/Bracket Balance Check**
     - Count all { } [ ] pairs in every .ahk file
     - Account for braces in string literals (ignore them)
     - Account for braces in comments (ignore them)
     - Report any imbalance with exact line numbers
     - FIX and re-verify until ALL files pass

  2. **Function Definition & Call Verification**
     - Create a list of ALL user-defined functions (not built-ins)
     - Create a list of ALL function calls
     - Verify EVERY call has a definition
     - Report any undefined function calls with line numbers
     - FIX and re-verify until ZERO undefined calls exist

  3. **Global Variable Validation**
     - For every variable used in a function that is NOT locally created
     - Verify it is declared as "global" in that function's scope
     - OR verify it is passed as a parameter
     - Report all violations with exact line numbers
     - FIX and re-verify until ZERO violations exist

  4. **Variable Scope & Initialization**
     - Verify no variable is used before assignment
     - Verify static initializers don't use function calls (except A_TickCount, Map(), Array())
     - Report all violations with line numbers
     - FIX and re-verify

  5. **String & Quote Balance Check**
     - Verify all " quotes are properly closed
     - Verify all ` backticks are properly closed
     - Report imbalances with line numbers
     - FIX and re-verify

  ### STAGE 2: SEMANTIC & STRUCTURAL VALIDATION

  6. **Include Dependency Chain**
     - Map all #Include statements
     - Verify included files exist
     - Verify no circular includes
     - Verify all classes/functions used are from included files
     - Report all issues with file paths
     - FIX if needed (fix file paths, add missing includes, remove circular deps)

  7. **Class & Method Validation**
     - For every class definition, verify:
       - All static methods/properties are defined
       - No private/public access violations (AutoHotkey 2.0 compatible)
       - All referenced classes exist
     - Report violations with line numbers
     - FIX and re-verify

  8. **Map/Object Access Pattern Check**
     - Find all Map access in code
     - Verify they use bracket notation: map["key"] NOT map.key
     - Verify they check .Has() before access where appropriate
     - Report all dot-notation accesses with line numbers
     - FIX all instances and re-verify

  9. **Function Signature & Call Compatibility**
     - For every function call, verify:
       - Parameter count matches definition (accounting for optional params with :=)
       - Parameter types are compatible
       - Return values are used correctly
     - Report incompatibilities with exact line numbers
     - FIX and re-verify

  10. **Error Handling Coverage**
      - Identify all I/O operations (File*, Run, RunWait, WinActivate, etc)
      - Verify each is wrapped in try-catch or has error handling
      - Identify all external API calls (ADB commands)
      - Verify each has error handling
      - Report all uncovered operations with line numbers
      - ADD try-catch blocks and re-verify

  ### STAGE 3: INTEGRATION & COMPATIBILITY VALIDATION

  11. **Inter-File Compatibility Check**
      - For files that include each other, verify:
        - No conflicts in class/function names
        - No duplicate definitions
        - Correct initialization order
      - Report conflicts with file paths and line numbers
      - FIX by renaming, reordering includes, or refactoring
      - Re-verify

  12. **Configuration & Constants Validation**
      - Verify all constants used are actually defined
      - Verify all configuration keys used exist in cfg Map
      - Verify all paths are valid/exist or have fallbacks
      - Report all issues with line numbers
      - FIX and re-verify

  13. **External Dependency Validation**
      - Identify all external dependencies:
        - File paths (osrs-items-condensed.json, etc)
        - External tools (adb, BlueStacks window)
        - System calls (ComObject, WinAPI)
      - For each, add a comment documenting:
        - What it requires
        - Where it's initialized
        - Fallback behavior if it fails
      - Report missing documentation
      - ADD documentation

  14. **Module Initialization Order Check**
      - Verify classes/constants are initialized before use
      - Verify InitializeBot() is called before main bot loop
      - Verify all global state is properly initialized
      - Report any initialization order issues
      - FIX by reordering code and re-verify

  ### STAGE 4: LOGIC & EDGE CASE VALIDATION

  15. **Placeholder Function Check**
      - Find all functions with "Placeholder" in comments or "return true/false" without logic
      - Flag them with line numbers
      - Document what they actually need to do
      - ADD detailed comments about what needs implementation
      - Do NOT fix logic (that's for you), but document requirements

  16. **Return Value Consistency**
      - For every function that returns a value:
        - Verify ALL code paths return something
        - Verify return types are consistent
      - Report inconsistencies with line numbers
      - FIX and re-verify

  17. **Loop & Conditional Logic Check**
      - Verify all for/while loops have proper exit conditions
      - Verify all if/else chains handle all cases
      - Verify no infinite loops
      - Report issues with line numbers
      - FIX and re-verify

  18. **Resource Cleanup Check**
      - Identify all resource allocations (files opened, screenshots created, etc)
      - Verify all are cleaned up with finally blocks or guaranteed cleanup
      - Report missing cleanup with line numbers
      - ADD cleanup code and re-verify

  ### STAGE 5: DOCUMENTATION & COMPLETENESS

  19. **Function Documentation Check**
      - Verify every user-defined function has a comment explaining:
        - What it does
        - Parameters and types
        - Return value and type
        - Any global variables it uses
        - Any exceptions it throws
      - Flag all missing documentation
      - ADD documentation

  20. **Type Annotation & Clarity Check**
      - For complex operations, verify there are comments explaining:
        - Why that approach was chosen
        - What could go wrong
        - What assumptions are made
      - Flag unclear code sections
      - ADD clarifying comments

  ### STAGE 6: FINAL VERIFICATION LOOP

  21. **Re-run STAGE 1 completely** (all 5 checks)
      - If any issues found, fix and loop back to STAGE 2
      - If no issues, continue to STAGE 7

  22. **Cross-File Consistency Check**
      - Verify naming conventions are consistent across files
      - Verify comment styles are consistent
      - Verify code formatting is consistent
      - Fix any inconsistencies

  23. **Integration Test Readiness Check**
      - Verify all external dependencies are documented
      - Verify all error paths have logging
      - Verify all critical functions have performance tracking
      - Verify all state is properly managed
      - Add/fix as needed

  ### STAGE 7: REPORTING & DECISION

  24. **Generate Comprehensive Report:**
      - Total issues found and fixed
      - Issues by category (syntax, semantic, logic, etc)
      - Remaining known issues (if any)
      - Remaining unknowns (can't verify without execution)
      - Files modified with change summary
      - Git commits made

  25. **Decision Point:**
      - If issues were found in step 21 re-run, go back to step 21
      - If NO issues found in step 21, consider declaring validation complete
      - If new categories of issues found, loop back to relevant stage
      - Continue until ONE FULL PASS completes with ZERO new issues found

  ### EXECUTION RULES (Non-negotiable):

  - **Do NOT skip stages** - follow them in order
  - **Do NOT declare completion** until step 25 results in zero new issues
  - **Do NOT use "appears correct"** - verify with actual code checks
  - **Do NOT stop at "syntax looks fine"** - run actual validation checks
  - **Do NOT assume "this probably works"** - verify explicitly
  - **COMMIT after each major fix** - don't batch changes
  - **RE-RUN validation** after each commit to ensure fix didn't break something
  - **REPORT all findings** - no silent passes
  - **If you hit a token limit**, save progress, commit with clear message,
    and explicitly state: "Stopped at Stage X, Step Y due to token limit.
    Next session should restart at Stage X, Step Y."

  ### SUCCESS CRITERIA:

  Project is considered "ready for testing" when:
  1. ✅ ALL syntax checks (Stage 1) pass with zero issues
  2. ✅ ALL semantic checks (Stage 2) pass with zero issues
  3. ✅ ALL integration checks (Stage 3) pass with zero issues
  4. ✅ ALL logic checks (Stage 4) pass or have documented placeholders
  5. ✅ ALL documentation is complete (Stage 5)
  6. ✅ Full verification loop (Stage 6) completes with zero new issues
  7. ✅ Comprehensive report generated (Stage 7)
  8. ✅ All changes committed with clear messages

Execute this protocol NOW. Follow all stages sequentially.
  Do NOT stop until you have completed all 25 steps or explicitly hit a token limit.
  After each major fix, re-run the relevant validation check to confirm.
  Report ALL findings at each stage.
  Commit changes with clear descriptions.
  When complete, provide the Stage 7 comprehensive report.
