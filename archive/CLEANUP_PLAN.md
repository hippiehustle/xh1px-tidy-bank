# Project Cleanup & Reorganization Plan
**Generated**: 2026-03-17
**Project**: xh1px-tidy-bank

---

## 📊 Current State Analysis

### File Count
- **Total files**: 60+
- **Markdown docs**: 30
- **AutoHotkey scripts**: 14
- **Python scripts**: 5
- **JSON files**: 2
- **Temp/log files**: Multiple

### Project Size
- **Total**: 8.1 MB
- **Database**: 4.9 MB (osrs-items-condensed.json)
- **Docs/Code**: 3.2 MB

---

## ⚠️ Problems Identified

### 1. Documentation Bloat (21 REDUNDANT FILES)
**Old Report Files** (to be archived/deleted):
- 100_PERCENT_COMPLETION_REPORT.md
- AUTONOMOUS_STAGE1_REPORT.md
- COMPREHENSIVE_BUG_FIX_REPORT.md
- COMPREHENSIVE_DEBUG_ANALYSIS_REPORT.md
- COMPREHENSIVE_DEBUG_REPORT.md
- COMPREHENSIVE_VALIDATION_REPORT.md
- CRITICAL_BUGS_FIXED_REPORT.md
- DETAILED_ISSUE_FIXES.md
- EXECUTIVE_SUMMARY.md
- FINAL_PRIORITIES_COMPLETION.md
- FULL_DEBUG_ANALYSIS.md
- IMPLEMENTATION_COMPLETE.md
- MAIN_BRANCH_ANALYSIS.md
- PROJECT_CLEANUP_SUMMARY.md
- PROJECT_STATUS.md
- PROJECT_STATUS_REPORT.md
- QUICK_FIX_CHECKLIST.md
- QUICK_START_V2.md (duplicate)
- SEMANTIC_ANALYSIS_REPORT.md
- STAGE_1_VALIDATION_REPORT.md
- SUMMARY.md (duplicate)

### 2. Unused AutoHotkey Files
**Not included in main.ahk**:
- item_grouping.ahk *(may be useful for future)*
- bank_tab_resolver.ahk *(may be useful for future)*
- performance.ahk *(may be useful for future)*
- config_gui.ahk *(standalone GUI, keep)*
- main_template_v2.ahk *(old template)*
- comprehensive_validator.ahk *(testing tool)*

### 3. Test Files (archivable)
- test_syntax.ahk
- test_conflict_resolver.ahk
- test_json_parser.ahk

### 4. Python Validation Scripts (redundant)
- check_braces.py
- comprehensive_validation.py
- tag_items.py
- validate_project.py
- validate_syntax.py

### 5. Temporary/Output Files
- manual_check_json.txt
- validation_output.txt
- ANALYSIS_SUMMARY.txt
- DEBUG_ANALYSIS_SUMMARY.txt
- DEBUG_REPORTS_INDEX.txt
- EXECUTIVE_SUMMARY.txt
- FINAL_PROJECT_STATUS.txt
- IMPLEMENTATION_SUMMARY.txt
- PYTHON_VALIDATION_REPORT.txt

---

## 🎯 Proposed New Structure

```
xh1px-tidy-bank/
├── 📁 src/                          # Source code
│   ├── main.ahk                     # Main bot script
│   ├── config_gui.ahk               # Configuration GUI
│   ├── json_parser.ahk              # JSON parser
│   ├── constants.ahk                # Constants/config
│   ├── 📁 lib/                      # Optional/future libraries
│   │   ├── item_grouping.ahk        # Item classification
│   │   ├── bank_tab_resolver.ahk    # Tab conflict resolution
│   │   └── performance.ahk          # Performance monitoring
│   └── 📁 utils/                    # Utility scripts
│       └── (future Python helpers)
│
├── 📁 data/                         # Data files
│   ├── osrs-items-condensed.json    # Item database
│   └── user_config.json             # User settings
│
├── 📁 docs/                         # Documentation
│   ├── README.md                    # Main documentation
│   ├── QUICKSTART.md                # Quick start guide
│   ├── DEPLOYMENT_GUIDE.md          # Deployment instructions
│   ├── 📁 guides/                   # Implementation guides
│   │   ├── ITEM_GROUPING_GUIDE.md   # Item grouping system
│   │   ├── OCR_IMPLEMENTATION.md    # OCR implementation
│   │   ├── AI_INTEGRATION.md        # AI/ML integration
│   │   └── CONFLICT_RESOLUTION.md   # Conflict resolution
│   └── 📁 api/                      # API documentation
│       └── CONSTANTS_REFERENCE.md   # Constants reference
│
├── 📁 tests/                        # Test files
│   ├── test_syntax.ahk              # Syntax validator
│   ├── test_json_parser.ahk         # JSON parser tests
│   └── test_conflict_resolver.ahk   # Conflict resolver tests
│
├── 📁 archive/                      # Historical documents
│   ├── old_reports/                 # Old development reports
│   └── old_scripts/                 # Deprecated scripts
│
├── 📁 logs/                         # Runtime logs
│   └── tidybank_log.txt             # Application log
│
├── 📁 .claude/                      # Claude Code config
│   ├── settings.local.json
│   ├── README.md
│   ├── agents/
│   └── (reference docs)
│
├── .gitignore                       # Git ignore file
└── LICENSE                          # License file (if any)
```

---

## 🔧 Cleanup Actions

### Phase 1: Archive Old Reports
**Action**: Move 21 old markdown files to `archive/old_reports/`
**Impact**: Cleaner root directory, preserves history

### Phase 2: Reorganize Source Code
**Actions**:
- Create `src/` directory
- Move main.ahk, config_gui.ahk, json_parser.ahk, constants.ahk → `src/`
- Create `src/lib/` for optional libraries
- Move item_grouping.ahk, bank_tab_resolver.ahk, performance.ahk → `src/lib/`

### Phase 3: Reorganize Data Files
**Actions**:
- Create `data/` directory
- Move osrs-items-condensed.json, user_config.json → `data/`

### Phase 4: Organize Documentation
**Actions**:
- Create `docs/` and `docs/guides/`
- Keep in root: README.md only (main entry point)
- Move to `docs/`:
  - QUICKSTART.md
  - DEPLOYMENT_GUIDE.md
- Move to `docs/guides/`:
  - ITEM_GROUPING_SYSTEM.md → ITEM_GROUPING_GUIDE.md
  - ITEM_GROUPING_USAGE.md → (merge into ITEM_GROUPING_GUIDE.md)
  - OCR_IMPLEMENTATION_GUIDE.md → OCR_IMPLEMENTATION.md
  - AI_INTEGRATION_GUIDE.md → AI_INTEGRATION.md
  - CONFLICT_RESOLUTION_GUIDE.md → CONFLICT_RESOLUTION.md

### Phase 5: Archive Test Files
**Actions**:
- Create `tests/` directory
- Move test_*.ahk → `tests/`

### Phase 6: Remove Temporary Files
**Actions**:
- Delete all .txt analysis/validation files
- Delete Python validation scripts (no longer needed)
- Delete main_template_v2.ahk (superseded)
- Delete comprehensive_validator.ahk (archived)

### Phase 7: Update References
**Actions**:
- Update #Include paths in all AHK files
- Update README.md with new structure
- Create .gitignore for logs/screenshots
- Update file paths in constants.ahk

### Phase 8: Create Master Documentation
**Actions**:
- Create comprehensive README.md (navigation hub)
- Create CONTRIBUTING.md (for contributors)
- Create CHANGELOG.md (version history)
- Update QUICKSTART.md with new paths

---

## 📈 Expected Improvements

### Before
- 30 markdown files in root
- 14 .ahk files scattered
- 5 Python scripts (mostly unused)
- 10+ temp/output files
- Hard to navigate
- Unclear what's important

### After
- **Root**: README.md + 5 directories
- **src/**: All source code organized
- **docs/**: All documentation in one place
- **tests/**: All tests isolated
- **archive/**: Historical preservation
- **Clean, professional structure**
- **Easy to navigate**
- **Clear separation of concerns**

---

## 🎯 Success Metrics

✅ Root directory: <10 files
✅ All code in `src/`
✅ All docs in `docs/`
✅ No temporary files
✅ No duplicate documentation
✅ Clear navigation
✅ Professional appearance
✅ Bot still works after reorganization

---

## 📝 Files to Keep in Root

1. **README.md** - Main entry point
2. **.gitignore** - Git configuration
3. **LICENSE** - License (if applicable)
4. **CHANGELOG.md** - Version history (to be created)

Everything else moves to subdirectories!

---

**Status**: PLAN READY FOR EXECUTION
**Next Step**: Execute cleanup in phases with commits
