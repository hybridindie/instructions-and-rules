export const WarnPointerEdit = async ({ client, $ }) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "edit" && input.tool !== "write") return

      const filePath = output.args?.filePath ?? output.args?.path ?? ""
      if (!filePath) return

      const lower = filePath.toLowerCase()

      let message: string | null = null
      if (
        lower.includes("/.opencode/") ||
        lower.includes("/.claude/") ||
        lower.includes("/.github/copilot-instructions.md") ||
        lower.includes("/.github/skills/")
      ) {
        message = `Editing harness pointer file: ${filePath}. Edit canonical content in .agents/ instead.`
      } else if (lower.includes("/.agents/doctrine/")) {
        message = `Editing load-bearing doctrine file: ${filePath}. Multiple skills and rubrics reference it by path — edits here propagate everywhere. Confirm the change is intended for all callers; if a rule needs to diverge per skill, it does not belong in shared doctrine.`
      } else if (lower.includes("/templates/_shared/doctrine/")) {
        message = `Editing load-bearing genesis doctrine file: ${filePath}. Multiple articles and agents reference it by path, and it renders into target projects at .claude/rules/doctrine/. Edits here propagate everywhere. Confirm the change is intended for all callers; if a rule needs to diverge per article, it does not belong in shared doctrine.`
      }

      if (message === null) return

      await client.app.log({
        body: {
          service: "warn-pointer-edit",
          level: "warn",
          message,
        },
      })
    },
  }
}