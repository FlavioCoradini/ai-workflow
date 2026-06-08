# Contributing

Thanks for helping out. This repo is a collection of [Agent
Skills](https://agentskills.io) plus a tiny shell installer — no build, no runtime, no hard
dependencies. PRs that keep it that way are the easiest to merge.

## Anatomy of a skill

A skill is a folder under `skills/` whose entry point is `SKILL.md`:

```
skills/<name>/
├── SKILL.md          # required — frontmatter + instructions
├── references/       # optional — longer docs the skill can pull in
└── scripts/          # optional — helper scripts the skill can run
```

`SKILL.md` must start with YAML frontmatter following the [open
standard](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills):

```markdown
---
name: my-skill
description: What it does, and when an agent should use it.
---

# My Skill

Instructions for the agent…
```

Rules the test enforces:

- The folder name **equals** the `name`.
- `name` is lowercase `a–z`, `0–9`, single hyphens, ≤ 64 chars.
- `description` is present and ≤ 1024 chars — and says both *what* it does and *when* to use it,
  since that's all an agent sees when deciding whether to load the skill.

Keep instructions terse and imperative. Put long material in `references/` and link to it rather
than bloating `SKILL.md`. If a skill is derived from someone else's work, preserve their license and
attribution in the body (see `skills/grill-me/SKILL.md`).

## Dev loop

```sh
git clone https://github.com/flaviocoradini/ai-workflow
cd ai-workflow

./test/run.sh            # validate every SKILL.md (CI runs exactly this)
./install.sh --dry-run   # see where each skill would be linked
./install.sh             # wire skills into your installed harnesses
```

To add a harness or change where one reads skills, edit the single path table at the top of both
`install.sh` and `uninstall.sh`.

## Commits and PRs

Keep commits small and focused, with an imperative subject like "Add code-review skill". Open the PR
against `main` and fill in the template. CI has to be green:

```sh
shellcheck install.sh uninstall.sh test/run.sh
./test/run.sh
```

If you added or changed a skill, add a line to `CHANGELOG.md` under `[Unreleased]`.

By contributing you agree your work is licensed under the [MIT License](LICENSE).
