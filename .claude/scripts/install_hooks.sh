#!/bin/bash
# Install Git Hooks for AutoHotkey Project

echo "Installing Git hooks..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Install pre-commit hook
if [ -f ".git/hooks/pre-commit" ]; then
    echo "Warning: pre-commit hook already exists"
    read -p "Overwrite? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping pre-commit hook installation"
        exit 0
    fi
fi

cp .claude/scripts/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

echo "✅ Pre-commit hook installed successfully"
echo ""
echo "The hook will run validation checks before each commit."
echo "To bypass the hook (not recommended), use: git commit --no-verify"
