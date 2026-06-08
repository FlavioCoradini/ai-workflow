# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/), and this project adheres to
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- Initial repository: a source-of-truth collection of Agent Skills with a zero-dependency installer.
- `install.sh` — symlinks every skill under `skills/` into each installed AI harness (Claude Code,
  Codex, opencode, Gemini, Cursor, Pi, Qwen) via one editable path table. Idempotent; skips
  harnesses that aren't installed; supports `--all`, `--force`, `--dry-run`, and `--target`.
- `uninstall.sh` — removes only the symlinks that resolve back into this repo.
- `test/run.sh` — validates every `SKILL.md` against the Agent Skills open standard (frontmatter,
  `name` == folder, naming rules, length limits). Wired into CI.
- The `grill-me` skill (derived from Matt Pocock's, MIT) as the first entry.
