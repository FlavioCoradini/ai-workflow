# ai-workflow

Source of truth for my AI workflow: [Agent Skills](https://agentskills.io) and per-harness configs,
symlinked into every tool with one command.

Skills live here once. Most tools — Codex, opencode, Gemini CLI, and the wider agent-compatible
ecosystem — read the shared store `~/.agents/skills/`, so `install.sh` symlinks each skill there.
Claude Code reads only its own dir, so it gets an extra symlink. Edit a skill here and it's live
everywhere.

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
| [`tech-lead`](skills/tech-lead/) | Writes and reviews code like a senior tech lead — clarity-first, DRY/SOLID/KISS/YAGNI, with trade-offs and edge cases surfaced. |
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

`install.sh` links into **one shared store** plus a short list of tools that read only their own dir.

| | Directory | Covers |
|---|---|---|
| **Shared store** (always) | `~/.agents/skills` | Codex, opencode, Gemini CLI, and other [agent-compatible](https://geminicli.com/docs/cli/skills/) tools that read it directly |
| **Own-dir exceptions** | `~/.claude/skills`, `~/.cursor/skills` | Claude Code (reads only its own dir), Cursor |

If you use a tool that reads only its own directory and isn't listed, add a line to the `EXCEPTIONS`
table at the top of `install.sh` / the `SWEEP_DIRS` list in `uninstall.sh`.

## Harness configs

`harnesses/<name>/` holds each tool's config files as the source of truth; `install-configs.sh`
symlinks them into place so edits here are live everywhere. An existing real file is **backed up**
(`.bak.<stamp>`) before it's replaced — never destroyed.

```sh
./install-configs.sh --dry-run   # preview
./install-configs.sh --only claude-agents   # just Claude workflow agents
./install-configs.sh             # symlink configs into installed harnesses (back up originals)
./setup.sh                       # everything: skills + configs in one go
```

| Harness | Config (repo → target) |
|---------|------------------------|
| Claude Code | `harnesses/claude/settings.json` → `~/.claude/settings.json`; `harnesses/claude/agents/*.md` → `~/.claude/agents/*.md` |
| opencode | `harnesses/opencode/opencode.jsonc` → `~/.config/opencode/opencode.jsonc` (+ `plugins/merge-guard.js`) |

The harness configs encode the same policy: no AI co-author trailer on commits/PRs, and **AI agents may
not merge PRs** (a deny rule plus a guard that blocks every merge vector). Claude Code also gets
standards-conformance workflow agents for implementation and independent review. Codex and Pi get added
when they're installed.

These are **my personal** configs (model choice, the guard) — fork or adapt them; they're not meant to
be installed verbatim by anyone but me. They contain no secrets (auth lives in separate files), and
`test/scan-secrets.sh` runs in CI to keep it that way. The Claude merge-guard needs `jq` at runtime.

## License & credits

Tooling is MIT ([LICENSE](LICENSE)). Vendored skills keep their own licenses:
[impeccable](https://github.com/pbakaus/impeccable) (18 design skills),
[vercel-labs/skills](https://github.com/vercel-labs/skills) (`find-skills`),
[vercel-labs/next-skills](https://github.com/vercel-labs/next-skills) (`next-best-practices`),
and [`grill-me`](skills/grill-me/) (derived from [Matt Pocock](https://github.com/mattpocock/skills), MIT).
