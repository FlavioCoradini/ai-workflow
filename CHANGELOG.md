# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/), and this project adheres to
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- Initial repository: a source-of-truth collection of Agent Skills with a zero-dependency installer.
- `install.sh` — symlinks every skill under `skills/` into the shared store `~/.agents/skills/`
  (read by Codex, opencode, Gemini CLI, and the wider agent-compatible ecosystem) plus a short list
  of own-dir exceptions (Claude Code, Cursor). Idempotent; skips exceptions that aren't installed;
  supports `--all`, `--force`, `--dry-run`, and `--target`.
- `uninstall.sh` — removes only the symlinks that resolve back into this repo.
- `test/run.sh` — validates every `SKILL.md` against the Agent Skills open standard (frontmatter,
  `name` == folder, naming rules, length limits). Wired into CI.
- The `grill-me` skill (derived from Matt Pocock's, MIT) as the first entry.
- Imported 20 more skills as a starting set: the 18-skill design/frontend suite from
  `pbakaus/impeccable`, plus `find-skills` (vercel-labs/skills) and `next-best-practices`
  (vercel-labs/next-skills). Sources credited in the README.
- `scripts/add-skill.sh` — vendor a skill from the `npx skills` ecosystem directly into `skills/`
  (the bare CLI installs into agent dirs, bypassing the repo). Supports `--list`, `--skill`,
  `--force`, and `--install`. The repo's `skills/<name>/SKILL.md` layout also makes it a valid
  `npx skills add <user>/<repo>` source out of the box.

### Changed
- `install.sh` no longer hijacks a skill name it doesn't own. A name held by a real folder *or* by
  a foreign symlink (e.g. one created by `npx skills`) is skipped unless `--force`; only symlinks
  already pointing into this repo are repointed. Covered by `test/test_install.sh`.
- Simplified the linking model from seven per-harness directories to one shared store
  (`~/.agents/skills/`) plus own-dir exceptions. Codex, opencode, and Gemini CLI all read the shared
  store, so their dedicated symlinks were redundant — and the old opencode path (`…/opencode/skill`,
  singular) was wrong (opencode reads `…/skills`). `uninstall.sh` still sweeps the legacy paths so it
  cleans up older installs.
