# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

A single-file IT PMO Kanban board for a fictitious bank: `index.html` holds all markup, a `<style>` block and a `<script>` block. There is no build, lint or test tooling. To run it, open `index.html` directly in a browser (double-click; it must keep working from `file://`).

## Hard constraints (from the original brief)

- Vanilla HTML/CSS/JS only: no frameworks, bundlers, npm, CDN scripts, web fonts or image files. System font stack and inline SVG/Unicode glyphs only.
- No persistence of any kind: no `localStorage`, `sessionStorage`, IndexedDB or cookies. A refresh must reset the board to the seeded demo data (the UI says so).
- The only network call is the FormSubmit AJAX endpoint (`FORMSUBMIT_ENDPOINT`). The email address appears only in that constant and must not be sent anywhere else.
- CSS uses custom properties for the palette and spacing, with no `!important`. Theme is black with neon accents (cyan primary, violet secondary, green for XP/evolution); neon red/amber/grey appear only for priority and overdue signals.
- No `alert()` or `confirm()`: validation errors are inline, and delete confirmation is the inline "Delete? Yes / No" row.

## Architecture

- **State:** a single `state` object (`tasks`, `filters`, plus UI-only `moveOpenId`, `confirmDeleteId`, `nextId`) is the source of truth.
- **Rendering:** `renderBoard()` is the only function that writes card and column markup (`innerHTML`). Mutators (`addTask`, `moveTask`, `deleteTask`) change state and then call it. Filters are applied inside it via `applyFilters()`. Every user-supplied string must go through `escapeHtml()` before it enters an HTML string.
- **Events:** the board uses delegated listeners. Clicks are routed through `data-action` attributes in `handleBoardClick`. Drag and drop uses native HTML5 events on the `#board` container. After a re-render replaces the DOM, `focusSelector()` restores keyboard focus, so keep it in any new action that re-renders.
- **Add Task:** it is a `<dialog>` modal. `handleSubmit` validates, then adds the card optimistically, resets the form, and awaits `notifyNewTask()` in `try/catch`. A FormSubmit failure only produces a warning toast and never breaks the board.
- **Seed data:** `seedTasks()` uses due dates relative to today so the overdue demo is always present. IDs are `ABC-ITPM-####` from `state.nextId`.
- **Gamification:** XP, level, creature stage and race position are derived from `state.tasks` at render time (`taskXp`, `totalXp`, `levelFor`, `raceRows`). Tasks store only `doneOn` (set when moved to Done, used for the on-time bonus). Creatures are original inline SVG from `creatureSvg()`. Project skills in `.claude/skills/` (see `kanban-pokemon-gamification`) carry the detailed rules.
- **Overdue:** it is computed by comparing ISO date strings (`dueDate < todayISO()` and status not Done). It is not stored on tasks.
