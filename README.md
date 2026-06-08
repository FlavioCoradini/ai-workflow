# ai-workflow

My AI [Agent Skills](https://agentskills.io) in one place, symlinked into every harness with one command.

Skills live here once. `install.sh` links each into Claude Code, Codex, opencode, Gemini, Cursor, Pi,
and Qwen — edit a skill here and it's live everywhere. The `SKILL.md` open standard fixes the file
format; `install.sh` handles the per-harness paths.

## Install

```sh
git clone https://github.com/FlavioCoradini/ai-workflow
cd ai-workflow
./install.sh
```

Links every skill into each installed harness and skips the rest. Idempotent, no dependencies
(POSIX shell + `ln`).

```sh
./install.sh --dry-run   # preview, change nothing
./install.sh --all       # also create dirs for harnesses not yet installed
./install.sh --force     # replace a conflicting skill of the same name
./uninstall.sh           # remove only symlinks pointing into this repo
```

It never overwrites a skill it doesn't own: a name held by a real folder or a foreign symlink is
skipped (use `--force`); only its own symlinks are repointed.

## Skills

**Workflow**

| Skill | What it does |
|-------|--------------|
| [`grill-me`](skills/grill-me/) | Interviews you about a plan one question at a time until every decision is resolved. |
| [`find-skills`](skills/find-skills/) | Finds and installs agent skills on request. |
| [`next-best-practices`](skills/next-best-practices/) | Next.js best practices — RSC, data patterns, metadata, routing, optimization. |

**Design & frontend** — the [impeccable](https://github.com/pbakaus/impeccable) suite (work together as a set):
[`teach-impeccable`](skills/teach-impeccable/) ·
[`frontend-design`](skills/frontend-design/) ·
[`critique`](skills/critique/) ·
[`audit`](skills/audit/) ·
[`adapt`](skills/adapt/) ·
[`animate`](skills/animate/) ·
[`bolder`](skills/bolder/) ·
[`quieter`](skills/quieter/) ·
[`colorize`](skills/colorize/) ·
[`clarify`](skills/clarify/) ·
[`delight`](skills/delight/) ·
[`distill`](skills/distill/) ·
[`extract`](skills/extract/) ·
[`normalize`](skills/normalize/) ·
[`harden`](skills/harden/) ·
[`onboard`](skills/onboard/) ·
[`optimize`](skills/optimize/) ·
[`polish`](skills/polish/)

## Adding a skill

From the [`npx skills`](https://github.com/vercel-labs/skills) ecosystem (lands it in `skills/`, not
your agent dirs; needs Node.js):

```sh
./scripts/add-skill.sh owner/repo --skill some-skill --install
```

By hand: create `skills/<name>/SKILL.md` (folder name **must** equal `name`), then `./test/run.sh`
and `./install.sh`. See [CONTRIBUTING.md](CONTRIBUTING.md).

This repo is itself a valid `npx skills` source: `npx skills add FlavioCoradini/ai-workflow`.

## Harnesses

Paths live in one editable table at the top of `install.sh` / `uninstall.sh`.

| Harness | Skills directory |
|---------|------------------|
| Claude Code | `~/.claude/skills` |
| Codex | `~/.agents/skills` |
| opencode | `~/.config/opencode/skill` |
| Gemini | `~/.gemini/skills` |
| Cursor | `~/.cursor/skills` |
| Pi | `~/.pi/skills` |
| Qwen | `~/.qwen/skills` |

## License & credits

Tooling is MIT ([LICENSE](LICENSE)). Vendored skills keep their own licenses:
[impeccable](https://github.com/pbakaus/impeccable) (18 design skills),
[vercel-labs/skills](https://github.com/vercel-labs/skills) (`find-skills`),
[vercel-labs/next-skills](https://github.com/vercel-labs/next-skills) (`next-best-practices`),
and [`grill-me`](skills/grill-me/) (derived from [Matt Pocock](https://github.com/mattpocock/skills), MIT).
