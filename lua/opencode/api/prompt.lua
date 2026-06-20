local M = {}

---@param prompt string
---@param context opencode.context.Context
---@return Promise
function M.prompt(prompt, context)
  return (prompt:match("%.%.%.$") and require("opencode.ui.ask").ask(prompt:gsub("%.%.%.$", ""), context) or require(
    "opencode.promise"
  ).resolve(prompt))
    :next(function(_prompt) ---@param _prompt string
      local plaintext = context:render(_prompt).output:plaintext()

      return context.server:tui_append_prompt(plaintext):next(function()
        if not _prompt:match(" $") then
          return context.server:tui_execute_command("prompt.submit")
        end
      end)
    end)
    :next(function()
      context:clear()
    end)
    :catch(function(err)
      context:resume()
      return require("opencode.promise").reject(err)
    end)
end

return M
