---
description: Security-scan, then publish this project to GitHub (push, README, Pages, CI/CD, About section). Usage - /publish <github-repo-url>
argument-hint: <github-repo-url>
allowed-tools: Bash, PowerShell, Read, Write, Edit, Glob, Grep
---

Publish this project to the GitHub repository given in `$ARGUMENTS`.

## Step 0: Validate input and tooling

1. If `$ARGUMENTS` is empty or not a `https://github.com/<owner>/<repo>` (or `.git`, or `git@github.com:`) URL, stop and ask the user for the repo link. Parse `OWNER` and `REPO` from it.
2. Run `gh auth status`. If `gh` is missing or not logged in, stop and tell the user to install it / run `gh auth login`. Never ask for or handle tokens or passwords yourself.
3. Run `gh repo view OWNER/REPO` to confirm the repo exists and the user has access. If it does not exist, ask the user before creating it (and ask public vs private). GitHub Pages on free accounts requires a public repo; say so if the repo is private.
4. Read `CLAUDE.md` and `index.html` so the README and workflows match the real project (single-file vanilla app, no build step, must work from `file://`).

## Step 1: Security scan (runs BEFORE anything is pushed)

Nothing leaves the machine until this passes. Scan every tracked and untracked, non-ignored file (`git ls-files` plus `git ls-files --others --exclude-standard`) and the **full git history** (`git log -p --all`), using Grep/`git grep`:

- Secrets: private keys (`-----BEGIN .* PRIVATE KEY-----`), `AKIA[0-9A-Z]{16}`, `ghp_`/`gho_`/`github_pat_`, `sk-[A-Za-z0-9]{20,}`, `xox[baprs]-`, `AIza[0-9A-Za-z_-]{35}`, JWTs (`eyJ[A-Za-z0-9_-]{10,}\.`), and assignments like `(password|passwd|secret|token|api[_-]?key|authorization)\s*[:=]\s*['"][^'"]+['"]`.
- Personal data: email addresses, phone numbers, IP addresses, internal URLs, Windows user paths (`C:\Users\...`), and real-looking names or account numbers beyond the fictitious seed data.
- Risky files: `.env*`, `*.pem`, `*.key`, `*.p12`, `*.pfx`, `id_rsa*`, `credentials*`, `*.sqlite`, `*.log`, `.claude/settings.local.json`, and anything under `node_modules/`.
- Git metadata: `git config user.email` values leaked in commit authors (report, do not rewrite history).

Rules for the findings:

- Known and intentional: per `CLAUDE.md`, the FormSubmit email appears only in the `FORMSUBMIT_ENDPOINT` constant. Report it as a **notice** (it is publicly visible once pushed and will receive spam/submissions), confirm it appears nowhere else, and ask the user to acknowledge before pushing. Never copy it into the README, workflows, or the About section.
- Any other finding is a **blocker**. Stop, list each one as `file:line` with the secret masked (show at most the first 4 characters), and ask the user how to proceed. Do not push. Do not rewrite history or delete files without asking.
- Create or update `.gitignore` to cover `.env*`, key files, logs, `node_modules/`, OS junk (`.DS_Store`, `Thumbs.db`) and `.claude/settings.local.json`. Do not add `.claude/commands/` to it; the commands are meant to be shared.
- Add `.github/workflows/security.yml` (see Step 5) so the scan keeps running on every push.

End this step with a short report: files scanned, findings by severity, verdict PASS / BLOCKED.

## Step 2: README

Create or update `README.md` (edit in place if it exists, preserving any user-written sections). Include:

- Title, one-line description, and badges for the CI workflow and the live Pages site (use `OWNER/REPO` from Step 0).
- Link to the live demo: `https://OWNER.github.io/REPO/`.
- Features (columns, drag and drop, move menu, filters, Add Task dialog, overdue and priority signals).
- How to run locally: open `index.html` in a browser, no build or install.
- Demo-data note: the board has no persistence, and a refresh resets it to seeded data.
- Tech constraints: vanilla HTML/CSS/JS, no dependencies, no storage, only network call is FormSubmit.
- Project structure, CI/CD summary, and a license placeholder only if the user has chosen one.
- Do not include the notification email address.

## Step 3: CI/CD workflows

Create `.github/workflows/ci.yml` (name it `CI`) triggered on `push` and `pull_request` to `main`, with least-privilege `permissions: contents: read`. The project has no build or test tooling, so CI validates the static page:

- Checkout, then assert `index.html` exists.
- Constraint checks with `grep`, failing the job on a match: `localStorage`, `sessionStorage`, `indexedDB`, `document.cookie`, `!important`, `alert(`, `confirm(`, external `<script src=` / `<link href=` to `http(s)://`, and `@import url(`.
- Check the FormSubmit email is not present outside the `FORMSUBMIT_ENDPOINT` line (match on the generic pattern `[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}` and allow only that line).
- Optionally parse the inline script with `node --check` after extracting it, or run `npx --yes html-validate index.html` (non-blocking if noisy).

Create `.github/workflows/security.yml` (name it `Security Scan`) on `push`, `pull_request` and weekly `schedule`, running gitleaks (`gitleaks/gitleaks-action@v2` with `fetch-depth: 0`, `GITHUB_TOKEN` only). Pin actions to a major version.

Create `.github/workflows/pages.yml` (name it `Deploy to GitHub Pages`) triggered on `push` to `main` and `workflow_dispatch`, with `permissions: contents: read, pages: write, id-token: write`, a `concurrency: pages` group, and:

1. `actions/checkout@v4`
2. Stage only the deployable files into `_site/` (`index.html`, plus a `.nojekyll`), never the whole repo.
3. `actions/configure-pages@v5`, `actions/upload-pages-artifact@v3` with `path: _site`
4. A `deploy` job using `actions/deploy-pages@v4` and `environment: github-pages`.

Make the deploy job depend on the CI checks passing (e.g. `needs:` a validate job, or `workflow_run`), so a failing constraint check blocks the release.

## Step 4: Wire up GitHub Pages

Enable Pages with the Actions build source (idempotent):

```
gh api -X POST repos/OWNER/REPO/pages -f build_type=workflow
```

If it returns 409 (already exists), run `gh api -X PUT repos/OWNER/REPO/pages -f build_type=workflow` instead. If it fails because the plan or visibility does not allow Pages, report that clearly and continue without failing the whole command. The Pages URL is `https://OWNER.github.io/REPO/`. Confirm the real URL from `gh api repos/OWNER/REPO/pages --jq .html_url` after the first deploy.

## Step 5: Commit and push

1. Show `git status` and the list of files to be committed. Confirm none are flagged by Step 1.
2. If no `origin` remote exists, add it: `git remote add origin <url>`. If `origin` exists and points elsewhere, ask the user before changing it.
3. Commit the new and changed files (README, `.gitignore`, `.github/`, `.claude/commands/`) with a clear message ending with the required attribution line from the session's system reminder.
4. Ensure the branch is `main`, then `git push -u origin main`. Use a plain push. **Never force-push**; if the remote has diverged, stop and ask. Never use `--no-verify`.
5. Because the push triggers the workflows, wait for them with `gh run list --repo OWNER/REPO --limit 5` and `gh run watch <id>` (do not poll in a loop). If a run fails, read `gh run view <id> --log-failed`, fix the cause, and push a follow-up commit.

## Step 6: Repo About section

Set description, homepage (the Pages link) and topics in one call, once the Pages URL is known:

```
gh repo edit OWNER/REPO \
  --description "<one-line summary of the Kanban board>" \
  --homepage "https://OWNER.github.io/REPO/" \
  --add-topic kanban --add-topic pmo --add-topic vanilla-js --add-topic github-pages
```

Keep the description under 350 characters, with no email addresses or secrets. Preserve any existing description if the user has customised it: show the current one (`gh repo view --json description,homepageUrl,repositoryTopics`) and only overwrite when it is empty or generic.

## Step 7: Verify and report

- `curl -sI https://OWNER.github.io/REPO/` should return 200 (Pages can take a minute or two on the first deploy; retry a few times and report if it is still pending).
- `gh repo view OWNER/REPO --json description,homepageUrl` confirms the About section holds the Pages link.
- Final summary: security verdict, repo URL, Pages URL, workflow run statuses, files created or changed, and any items the user must handle manually (acknowledging the public FormSubmit email, enabling Pages in Settings if the API call was refused, FormSubmit email activation).

## Guardrails

- Run steps in order. A BLOCKED security verdict stops the command before any push.
- Ask before any destructive or outward-facing action not listed here: creating the repo, changing remotes, force-pushing, deleting files or branches, rewriting history.
- Never print, log, or commit tokens, secrets, or the notification email.
- Keep `index.html` unchanged unless the security scan requires a fix the user approved.
