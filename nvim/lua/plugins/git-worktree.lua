return {
  {
    "polarmutex/git-worktree.nvim",
    version = "^2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local Hooks = require("git-worktree.hooks")
      local cfg = require("git-worktree.config")

      Hooks.register(Hooks.type.SWITCH, function(path, prev_path)
        -- label = last folder name (e.g. "features", "agent", "hotfix")
        vim.g.worktree_label = vim.fn.fnamemodify(path, ":t")

        Hooks.builtins.update_current_buffer_on_switch(path, prev_path)
        vim.cmd("redrawstatus")
      end)
      -- Recommended: keep your current buffer in sync when switching worktrees
      Hooks.register(Hooks.type.SWITCH, Hooks.builtins.update_current_buffer_on_switch)
      -- If you have something like a filetree/statusline needing refresh after delete:
      Hooks.register(Hooks.type.DELETE, function()
        vim.cmd(cfg.update_on_change_command)
      end)

      local function has(mod)
        return package.loaded[mod] or pcall(require, mod)
      end

      -- Minimal worktree list via git (works regardless of Telescope/Snacks)
      local function list_worktrees()
        local out = vim.system({ "git", "worktree", "list", "--porcelain" }, { text = true }):wait()
        if out.code ~= 0 then
          vim.notify(out.stderr or "git worktree list failed", vim.log.levels.ERROR)
          return {}
        end

        local items = {}
        local current = {}
        for line in (out.stdout or ""):gmatch("[^\n]+") do
          local k, v = line:match("^(%S+)%s+(.*)$")
          if k == "worktree" then
            if current.path then
              table.insert(items, current)
            end
            current = { path = v }
          elseif k == "branch" then
            -- line looks like: branch refs/heads/foo
            current.branch = v:gsub("^refs/heads/", "")
          elseif k == "bare" then
            current.bare = true
          end
        end
        if current.path then
          table.insert(items, current)
        end

        -- Filter out bare entry if present
        local filtered = {}
        for _, it in ipairs(items) do
          if not it.bare then
            table.insert(filtered, it)
          end
        end
        return filtered
      end

      local function pick_worktree(prompt, cb)
        local wts = list_worktrees()
        if #wts == 0 then
          return
        end

        -- 1) Snacks picker (if you have it)
        local ok_snacks, Snacks = pcall(require, "snacks")
        if ok_snacks and Snacks.picker then
          local items = {}
          for i, it in ipairs(wts) do
            local branch = it.branch or "(detached)"
            items[#items + 1] = {
              idx = i,
              score = i,
              -- Snacks uses `text` for matching; keep it simple + searchable
              text = branch .. " " .. it.path,
              branch = branch,
              path = it.path,
              value = it,
            }
          end

          Snacks.picker({
            title = prompt,
            items = items,
            format = function(item)
              local ret = {}
              ret[#ret + 1] = { item.branch .. "  ", "SnacksPickerLabel" }
              ret[#ret + 1] = { item.path, "SnacksPickerComment" }
              return ret
            end,
            confirm = function(picker, item)
              picker:close()
              if item and item.value then
                cb(item.value)
              end
            end,
          })
          return
        end

        -- 2) Telescope (if installed)
        local ok_telescope, telescope = pcall(require, "telescope")
        if ok_telescope then
          pcall(telescope.load_extension, "git_worktree") -- required when using Telescope UI  [oai_citation:2‡GitHub](https://github.com/polarmutex/git-worktree.nvim)
          -- Use the extension’s UI directly
          telescope.extensions.git_worktree.git_worktrees()
          return
        end

        -- 3) Fallback: vim.ui.select
        vim.ui.select(wts, {
          prompt = prompt,
          format_item = function(it)
            return (it.branch or "(detached)") .. "  —  " .. it.path
          end,
        }, function(choice)
          if choice then
            cb(choice)
          end
        end)
      end

      vim.keymap.set("n", "<leader>gwc", function()
        local git_worktree = require("git-worktree")
        vim.ui.input({ prompt = "Worktree path (relative to repo or absolute): " }, function(path)
          if not path or path == "" then
            return
          end
          vim.ui.input({ prompt = "New branch name: " }, function(branch)
            if not branch or branch == "" then
              return
            end
            vim.ui.input({ prompt = "Upstream branch (e.g. main): ", default = "main" }, function(upstream)
              if not upstream or upstream == "" then
                return
              end
              vim.ui.input({ prompt = "Remote (e.g. origin): ", default = "origin" }, function(remote)
                if not remote or remote == "" then
                  return
                end
                git_worktree.create_worktree(path, upstream, remote, branch)
              end)
            end)
          end)
        end)
      end, { desc = "Git Worktree: create" })

      vim.keymap.set("n", "<leader>gws", function()
        local git_worktree = require("git-worktree")
        pick_worktree("Switch worktree", function(it)
          git_worktree.switch_worktree(it.path)
        end)
      end, { desc = "Git Worktree: switch" })

      vim.keymap.set("n", "<leader>gwd", function()
        local git_worktree = require("git-worktree")
        pick_worktree("Delete worktree", function(it)
          git_worktree.delete_worktree(it.path)
        end)
      end, { desc = "Git Worktree: delete" })
    end,
  },
}
