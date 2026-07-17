export const WarnPointerEdit = async ({ client, $ }) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "edit" && input.tool !== "write") return

      const filePath = output.args?.filePath ?? output.args?.path ?? ""
      if (!filePath) return

      const lower = filePath.toLowerCase()
      const isPointer =
        lower.includes("/.opencode/") ||
        lower.includes("/.claude/") ||
        lower.includes("/.github/copilot-instructions.md") ||
        lower.includes("/.github/skills/")

      if (!isPointer) return

      await client.app.log({
        body: {
          service: "warn-pointer-edit",
          level: "warn",
          message: `Editing harness pointer file: ${filePath}. Edit canonical content in .agents/ instead.`,
        },
      })
    },
  }
}