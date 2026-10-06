# IT PMO Project Board

[![CI](https://github.com/wjlingg/claudeproj/actions/workflows/ci.yml/badge.svg)](https://github.com/wjlingg/claudeproj/actions/workflows/ci.yml)
[![Deploy](https://github.com/wjlingg/claudeproj/actions/workflows/pages.yml/badge.svg)](https://github.com/wjlingg/claudeproj/actions/workflows/pages.yml)

A single-file Kanban board for an IT PMO team at a fictitious bank. Built with vanilla HTML, CSS and JavaScript, with no dependencies.

**Live demo:** https://wjlingg.github.io/claudeproj/

## Features

- Kanban columns with task cards, moved by drag and drop or a keyboard-friendly move menu
- Filters to narrow the board
- Add Task dialog with inline validation
- Priority signals and automatic overdue highlighting
- Inline "Delete? Yes / No" confirmation (no browser dialogs)
- Optional email notification for new tasks through [FormSubmit](https://formsubmit.co)

## Run locally

Open `index.html` in a browser. There is no build step or install, and it works from `file://`.

## Demo data

The board has no persistence of any kind: no `localStorage`, cookies or database. Refreshing the page resets it to the seeded demo data, with due dates relative to today so the overdue example is always present.

## Notifications setup

New tasks are posted to FormSubmit. Set `FORMSUBMIT_ENDPOINT` in `index.html` to your own address. Anything you commit to a public repo is public, so consider a FormSubmit alias instead of a raw address. A failed request only shows a warning and never breaks the board.

## Technical constraints

- Vanilla HTML/CSS/JS only: no frameworks, bundlers, CDN scripts, web fonts or image files
- CSS custom properties for palette and spacing, no `!important`
- No `alert()` or `confirm()`
- The only network call is the FormSubmit endpoint

## Project structure

```
index.html                 the whole app (markup, styles, script)
CLAUDE.md                  guidance for Claude Code
.claude/commands/          project slash commands
.github/workflows/         CI, security scan, Pages deploy
```

## CI/CD

| Workflow | Trigger | What it does |
| --- | --- | --- |
| `ci.yml` | push, pull request | Checks the project constraints and that the inline script parses |
| `security.yml` | push, pull request, weekly | Scans the repo and history for secrets with gitleaks |
| `pages.yml` | push to `main` | Runs CI, then deploys `index.html` to GitHub Pages |
