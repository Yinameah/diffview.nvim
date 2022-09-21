local Window = require("diffview.scene.window").Window
local Diff2 = require("diffview.scene.layouts.diff_2").Diff2
local oop = require("diffview.oop")

local api = vim.api
local M = {}

---@class Diff2Ver : Diff2
---@field a Window
---@field b Window
local Diff2Ver = oop.create_class("Diff2Ver", Diff2)

---@class Diff2Hor.init.Opt
---@field a git.File
---@field b git.File
---@field winid_a integer
---@field winid_b integer

---@param opt Diff2Hor.init.Opt
function Diff2Ver:init(opt)
  Diff2Ver:super().init(self, opt)
end

---@override
---@param pivot integer?
function Diff2Ver:create(pivot)
  self.emitter:emit("create_pre", self)
  local curwin

  pivot = pivot or self:find_pivot()
  assert(api.nvim_win_is_valid(pivot), "Layout creation requires a valid window pivot!")

  for _, win in ipairs(self.windows) do
    if win.id ~= pivot then
      win:close(true)
    end
  end

  api.nvim_win_call(pivot, function()
    vim.cmd("aboveleft sp")
    curwin = api.nvim_get_current_win()

    if self.a then
      self.a:set_id(curwin)
    else
      self.a = Window({ id = curwin })
    end
  end)

  api.nvim_win_call(pivot, function()
    vim.cmd("aboveleft sp")
    curwin = api.nvim_get_current_win()

    if self.b then
      self.b:set_id(curwin)
    else
      self.b = Window({ id = curwin })
    end
  end)

  api.nvim_win_close(pivot, true)
  self.windows = { self.a, self.b }
  self.emitter:emit("create_post", self)
end

M.Diff2Ver = Diff2Ver
return M
