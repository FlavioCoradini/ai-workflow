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

> **It never silently overwrites a skill it doesn't own.** If a name is already taken by a real
> folder *or* by a symlink pointing at someone else's skill (e.g. one installed by `npx skills`),
> `install.sh` **skips** it and tells you. Only symlinks that already point into this repo are
> repointed (so re-runs stay idempotent). Pass `--force` to deliberately replace a conflicting one.

No dependencies — POSIX shell and `ln`, already on every Mac and Linux box.

## Skills

**Workflow**

| Skill | What it does |
|-------|--------------|
| [`grill-me`](skills/grill-me/) | Interviews you relentlessly about a plan or design — one question at a time, with a recommended answer each turn — until every branch of the decision tree is resolved. |
| [`find-skills`](skills/find-skills/) | Discovers and installs agent skills when you ask "is there a skill for X". |
| [`next-best-practices`](skills/next-best-practices/) | Next.js best practices — RSC boundaries, data patterns, async APIs, metadata, routing, image/font optimization, bundling. |

**Design & frontend** (the [impeccable](https://github.com/pbakaus/impeccable) suite — work together as a set)

| Skill | What it does |
|-------|--------------|
| [`teach-impeccable`](skills/teach-impeccable/) | One-time setup that records your project's design context to your AI config (the others read it). |
| [`frontend-design`](skills/frontend-design/) | Create distinctive, production-grade frontend UI that avoids the generic AI look. |
| [`critique`](skills/critique/) | Evaluate design from a UX perspective with actionable feedback. |
| [`audit`](skills/audit/) | Comprehensive UI-quality audit (a11y, performance, theming, responsive) with a severity-rated report. |
| [`adapt`](skills/adapt/) | Adapt designs across screen sizes, devices, contexts, and platforms. |
| [`animate`](skills/animate/) | Add purposeful animations, micro-interactions, and motion. |
| [`bolder`](skills/bolder/) | Amplify safe or boring designs to be more visually interesting. |
| [`quieter`](skills/quieter/) | Tone down overly bold or aggressive designs. |
| [`colorize`](skills/colorize/) | Add strategic color to monochromatic or flat interfaces. |
| [`clarify`](skills/clarify/) | Improve unclear UX copy, error messages, labels, and microcopy. |
| [`delight`](skills/delight/) | Add joy, personality, and unexpected touches. |
| [`distill`](skills/distill/) | Strip designs to their essence; remove unnecessary complexity. |
| [`extract`](skills/extract/) | Extract reusable components and design tokens into a design system. |
| [`normalize`](skills/normalize/) | Normalize a design to match your design system. |
| [`harden`](skills/harden/) | Error handling, i18n, text overflow, and edge cases — production resilience. |
| [`onboard`](skills/onboard/) | Onboarding flows, empty states, and first-run experiences. |
| [`optimize`](skills/optimize/) | UI performance: loading, rendering, animations, images, bundle size. |
| [`polish`](skills/polish/) | Final pre-ship pass: alignment, spacing, and consistency. |

## Adding a skill

**From an existing skill repo (`npx skills`).** Pull any skill from the
[`npx skills`](https://github.com/vercel-labs/skills) ecosystem straight into this repo with the
wrapper. It runs the standard CLI under the hood, then lands the skill in `skills/`, validates it,
and (with `--install`) wires it into your harnesses:

```sh
./scripts/add-skill.sh owner/repo --list                  # see what a source offers
./scripts/add-skill.sh owner/repo --skill some-skill       # import one skill into skills/
./scripts/add-skill.sh owner/repo --skill some-skill --install   # …and link it everywhere
```

(`npx skills add owner/repo` on its own installs into your agent dirs, bypassing the repo — the
wrapper exists so the skill lands in your source of truth instead. Requires Node.js.)

**By hand.** Create `skills/<name>/SKILL.md` with open-standard frontmatter (the folder name
**must** equal the `name`):

```markdown
---
name: my-skill
description: What it does, and when an agent should reach for it.
---

# My Skill

Instructions for the agent…
```

Add `references/` and `scripts/` subfolders if the skill needs them, then validate and wire it up:

```sh
./test/run.sh        # checks frontmatter, naming, and length rules
./install.sh         # symlinks the new skill into every installed harness
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full authoring guide.

## Installing skills *from* this repo

Because the skills use the standard `skills/<name>/SKILL.md` layout, this repo is itself a valid
[`npx skills`](https://github.com/vercel-labs/skills) source — no extra metadata needed. On any
machine, or for anyone who clones nothing at all:

```sh
npx skills add flaviocoradini/ai-workflow                  # interactive picker
npx skills add flaviocoradini/ai-workflow --list           # list everything here
npx skills add flaviocoradini/ai-workflow --skill grill-me # one skill
```

That installs into the agent dirs the CLI manages. Prefer `git clone … && ./install.sh` if you want
the symlink-backed setup where edits to the repo stay live across every harness.

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

## License & credits

The repository tooling (installer, validator, docs) is MIT — see [LICENSE](LICENSE).

Several skills are vendored from upstream projects under their own licenses; credit goes to their
authors:

- The 18 design/frontend skills are from [**pbakaus/impeccable**](https://github.com/pbakaus/impeccable).
- [`find-skills`](skills/find-skills/) is from [**vercel-labs/skills**](https://github.com/vercel-labs/skills).
- [`next-best-practices`](skills/next-best-practices/) is from [**vercel-labs/next-skills**](https://github.com/vercel-labs/next-skills).
- [`grill-me`](skills/grill-me/) is derived from [**Matt Pocock's grill-me**](https://github.com/mattpocock/skills/tree/main/skills/productivity/grill-me)
  (MIT); attribution is preserved in [`skills/grill-me/SKILL.md`](skills/grill-me/SKILL.md).
