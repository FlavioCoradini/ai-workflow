# Contributing

A collection of [Agent Skills](https://agentskills.io) plus a shell installer — no build, no
dependencies. Keep it that way.

## Anatomy of a skill

```
skills/<name>/
├── SKILL.md       # required — frontmatter + instructions
├── references/    # optional — longer docs
└── scripts/       # optional — helper scripts
```

`SKILL.md` starts with [open-standard](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
frontmatter:

```markdown
---
name: my-skill
description: What it does, and when an agent should use it.
---

# My Skill

Instructions for the agent…
```

Rules the test enforces: folder name **equals** `name`; `name` is lowercase `a–z0–9` with single
hyphens, ≤ 64 chars; `description` ≤ 1024 chars. Keep instructions terse; put long material in
`references/`. Preserve upstream license/attribution for derived skills (see `skills/grill-me/SKILL.md`).

To vendor from another repo, use `./scripts/add-skill.sh owner/repo --skill name` — it lands the
skill in `skills/` instead of your agent dirs. Keep the `skills/<name>/SKILL.md` layout so this repo
stays a valid `npx skills` source.

## Dev loop

```sh
./test/run.sh            # validate every SKILL.md
./test/test_install.sh   # installer collision handling
./install.sh --dry-run   # preview links
```

Harness paths live in one table at the top of `install.sh` / `uninstall.sh`.

## PRs

Small, focused commits with imperative subjects. CI must be green:

```sh
shellcheck install.sh uninstall.sh test/run.sh test/test_install.sh scripts/add-skill.sh
./test/run.sh && ./test/test_install.sh
```

Add a `CHANGELOG.md` line under `[Unreleased]` for any skill or tooling change. By contributing you
agree your work is licensed under the [MIT License](LICENSE).
