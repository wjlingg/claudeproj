---
name: kanban-pokemon-gamification
description: Add Pokémon-themed gamification and filtering to the IT PMO Kanban board in index.html: evolving task cards, XP and levels, a race lane, and filter options. Use when adding or changing Pokémon, XP, evolution, race or filter features on the board.
---

# Kanban Pokémon gamification (project skill)

Read `CLAUDE.md` first; its hard constraints apply to everything below.

## Hard rules for this feature set
- Vanilla JS in `index.html`. Pokémon art is inline SVG / Unicode only: no image files, CDN, fonts or sprites from the web. Use original, simplified creature shapes ("Pokémon-style"); do not copy official artwork.
- No persistence. XP, levels and race positions are derived from `state.tasks` on each render (or kept in `state`) and reset on refresh. Say so in the UI, as the board already does.
- Rendering stays in `renderBoard()`; every user string goes through `escapeHtml()`. New actions use `data-action` in `handleBoardClick`, and re-rendering actions must be covered by `focusSelector()`.
- No `alert()`/`confirm()`; no `!important`; palette via CSS custom properties. Red/amber/grey remain priority/overdue signals only.

## Features
1. **Evolution:** each card shows a creature whose stage follows its column (`STAGE` map): Backlog = stage 1, In Progress = stage 2, Blocked = stage 2 with sleepy eyes, Done = stage 3 with a one-time evolve animation (`state.evolvedId`). The creature family follows priority (`FAMILIES`), drawn by `creatureSvg()`.
2. **XP and levels:** completing a task awards XP by priority (e.g. High 30, Medium 20, Low 10) with a bonus for finishing on or before the due date. Show a team trainer level and an XP bar in the header. Overdue tasks award no bonus.
3. **Race lane:** a collapsible lane above the board, one racer per assignee/team. Position = share of that person's tasks that are Done (or weighted by column). Animate with `transform` only; honour `prefers-reduced-motion`.
4. **Filters:** extend `state.filters` and `applyFilters()` with priority, assignee, status, overdue-only and text search. Add a clear-all control and a visible "showing N of M" count. Filters affect only what renders; they must never mutate tasks.
5. **Seed data:** keep `seedTasks()` relative to today so overdue demos work; make sure the seed shows every evolution stage and at least one overdue task.

## Tone
Fun but professional: short, plain-language copy ("Task evolved", "Level 3"), one memorable moment (evolution), everything else calm. Pair with the `frontend-design`, `review-animations` and `web-design-guidelines` skills.

## Done checklist
- Opens from `file://` with no console errors; refresh resets the board.
- Keyboard can reach filters, move menu and race lane; focus survives re-render.
- Reduced motion respected; contrast checked on type badges and priority chips.
