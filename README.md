# IT PMO Project Board

[![CI](https://github.com/wjlingg/claudeproj/actions/workflows/ci.yml/badge.svg)](https://github.com/wjlingg/claudeproj/actions/workflows/ci.yml)
[![Deploy](https://github.com/wjlingg/claudeproj/actions/workflows/pages.yml/badge.svg)](https://github.com/wjlingg/claudeproj/actions/workflows/pages.yml)

A single-file, Pokémon-style Kanban board for an IT PMO team at a fictitious bank, in a black theme with neon accents. Built with vanilla HTML, CSS and JavaScript, with no dependencies.

**Live demo:** https://wjlingg.github.io/claudeproj/

## Features

- Kanban columns with task cards, moved by drag and drop or a keyboard-friendly move menu
- Filters: search (title, ID, project), project, status, priority, assignee, overdue only, and sort by due date or priority, with a live "Showing N of M" count
- Evolving creatures: each card shows an original inline-SVG creature. Priority picks the line (fire, electric, water, grass) and status picks the stage. Reaching Done plays an evolve animation, and Blocked tasks nap
- Trainer level and XP bar: finishing a task earns XP by priority, with a bonus for on-time delivery, plus a level-up toast
- Team race lane: one racer per assignee advances as their tasks move toward Done
- Add Task dialog with inline validation
- Priority signals and automatic overdue highlighting
- Inline "Delete? Yes / No" confirmation (no browser dialogs)
- Optional email notification for new tasks through [FormSubmit](https://formsubmit.co)

## Run locally

Open `index.html` in a browser. There is no build step or install, and it works from `file://`.

## Demo data

The board has no persistence of any kind: no `localStorage`, cookies or database. Refreshing the page resets the board, XP and level to the seeded demo data, with due dates relative to today so the overdue example is always present.

## Notifications setup

New tasks are posted to FormSubmit. Set `FORMSUBMIT_ENDPOINT` in `index.html` to your own address. Anything you commit to a public repo is public, so consider a FormSubmit alias instead of a raw address. A failed request only shows a warning and never breaks the board.

## Technical constraints

- Vanilla HTML/CSS/JS only: no frameworks, bundlers, CDN scripts, web fonts or image files
- All creature art is original inline SVG, with no image files
- CSS custom properties for palette and spacing, no `!important`
- No `alert()` or `confirm()`
- The only network call is the FormSubmit endpoint

## Project structure

```
index.html                 the whole app (markup, styles, script)
CLAUDE.md                  guidance for Claude Code
.claude/commands/          project slash commands
.claude/skills/            project skills (design, animation review, Kanban gamification)
.github/workflows/         CI, security scan, Pages deploy
```

## CI/CD

| Workflow | Trigger | What it does |
| --- | --- | --- |
| `ci.yml` | push, pull request | Checks the project constraints and that the inline script parses |
| `security.yml` | push, pull request, weekly | Scans the repo and history for secrets with gitleaks |
| `pages.yml` | push to `main` | Runs CI, then deploys `index.html` to GitHub Pages |
