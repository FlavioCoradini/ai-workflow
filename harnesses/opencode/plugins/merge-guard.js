// merge-guard — opencode parity with the Claude PreToolUse merge guard.
//
// AI agents are not allowed to merge PRs. The native `permission.bash` deny in
// opencode.jsonc blocks the literal `gh pr merge`; this plugin also blocks the
// alternative vectors a deny pattern can't express — the REST merge endpoint
// (/pulls/<n>/merge) and the GraphQL mergePullRequest mutation — including when
// they're buried in a composed command.
//
// Docs: https://opencode.ai/docs/plugins/

const MERGE_PATTERN =
  /gh\s+pr\s+merge|\/pulls\/[0-9]+\/merge|mergePullRequest/i;

export const MergeGuard = async () => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return;
      const command = (output && output.args && output.args.command) || "";
      if (MERGE_PATTERN.test(command)) {
        throw new Error(
          "AI agents are not allowed to merge PRs (opencode merge-guard).",
        );
      }
    },
  };
};
