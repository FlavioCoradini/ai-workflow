# ai-workflow

The source of truth for my AI tooling — the [Agent Skills](https://agentskills.io) I use every
day, in one place, wired into every AI harness on the machine with a single command.

Skills live here once. `install.sh` symlinks each one into Claude Code, Codex, opencode, Gemini,
Cursor, Pi, and Qwen — so editing a skill in this repo is instantly live in all of them, and a new
machine (or a new contributor) is one clone and one command away from the full set.

## How your harnesses see it

Every skill is a folder with a `SKILL.md` written to the [Agent Skills open
standard](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
(Anthropic, Dec 2025; adopted by ~30 tools). The standard fixes the *file format* but not the
*install path* — each harness reads its own directory. So this repo is the canonical copy, and
`install.sh` drops a **symlink** into each harness's skills dir:

```
ai-workflow/skills/grill-me  ──┬─→  ~/.claude/skills/grill-me      (Claude Code)
                               ├─→  ~/.agents/skills/grill-me      (Codex + the cross-tool store)
                               ├─→  ~/.config/opencode/skill/...   (opencode)
                               └─→  ~/.gemini/skills/grill-me       (Gemini)  …and so on
```

Because they're symlinks, there's no copy to keep in sync: edit `skills/<name>/SKILL.md` and every
harness picks it up immediately.

## Install

```sh
git clone https://github.com/flaviocoradini/ai-workflow
cd ai-workflow
./install.sh
```

`install.sh` links every skill into each harness that's **installed** on your machine and skips the
rest (re-run it after you install a new harness). It's idempotent — safe to run again after pulling
new skills.

```
./install.sh --dry-run     # show what it would do, change nothing
./install.sh --all         # also create dirs for harnesses not yet installed
./install.sh --force       # replace a real (non-symlink) skill dir of the same name
./install.sh --target DIR  # also link into an extra skills directory
./uninstall.sh             # remove only the symlinks that point back into this repo
```

> If you already have a hand-made skill of the same name in a harness dir (e.g. an existing
> `~/.agents/skills/grill-me` folder), `install.sh` will **skip** it and tell you. Run once with
> `--force` to convert it into a repo-backed symlink.

No dependencies — POSIX shell and `ln`, already on every Mac and Linux box.

## Skills

| Skill | What it does |
|-------|--------------|
| [`grill-me`](skills/grill-me/) | Interviews you relentlessly about a plan or design — one question at a time, with a recommended answer each turn — until every branch of the decision tree is resolved. |

## Adding a skill

1. Create `skills/<name>/SKILL.md` with open-standard frontmatter (the folder name **must** equal
   the `name`):

   ```markdown
   ---
   name: my-skill
   description: What it does, and when an agent should reach for it.
   ---

   # My Skill

   Instructions for the agent…
   ```

   Add `references/` and `scripts/` subfolders if the skill needs them.

2. Validate and wire it up:

   ```sh
   ./test/run.sh        # checks frontmatter, naming, and length rules
   ./install.sh         # symlinks the new skill into every installed harness
   ```

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full authoring guide.

## Supported harnesses

The skills dir for each is set in one editable table at the top of `install.sh` / `uninstall.sh`.

| Harness | Skills directory |
|---------|------------------|
| Claude Code | `~/.claude/skills` |
| Codex | `~/.agents/skills` *(also the cross-tool store many others read)* |
| opencode | `~/.config/opencode/skill` |
| Gemini | `~/.gemini/skills` |
| Cursor | `~/.cursor/skills` |
| Pi | `~/.pi/skills` |
| Qwen | `~/.qwen/skills` |

The Claude Code and Codex (`~/.agents`) paths are verified; the others follow each tool's documented
convention — adjust the relevant line if a tool moves its directory.

## License

MIT — see [LICENSE](LICENSE).

`grill-me` is derived from [Matt Pocock's grill-me skill](https://github.com/mattpocock/skills/tree/main/skills/productivity/grill-me)
(MIT); attribution is preserved in [`skills/grill-me/SKILL.md`](skills/grill-me/SKILL.md).
