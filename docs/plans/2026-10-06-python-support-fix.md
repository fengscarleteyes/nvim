# python 支持一致性修复: Implementation Plan

**Spec:** docs/specs/2026-10-06-python-support-fix-design.md **Goal:** 让 Python
支持三处一致：mason 不再误列 basedpyright，conform 只保留一条保存时格式化，ruff
格式化器去重排序。 **Architecture:**
三处小改，无新文件、无新依赖。`lua/plugins/mason.lua`
删两行，`lua/plugins/conform.lua` 删一个 autocmd
块并改一行，`docs/DEPENDENCIES.md` 的 B 段补 basedpyright。

## Global constraints

- mason 保留，继续管 stylua、lua-language-server、panache、ruff。
- basedpyright 由 uv 提供：`uv tool install basedpyright`（全局）或
  `uv add --dev basedpyright`（项目内）。
- 不改 `ruff.toml`，不新增依赖。
- 行尾 LF。

### Task 1: mason.lua 删掉 basedpyright 与 ty 两行 → verify: `nvim --headless -u NONE "+lua assert(loadfile('lua/plugins/mason.lua'))" +qa` 退出码 0，且 `grep -qE 'basedpyright|"ty"' lua/plugins/mason.lua` 退出码 1

**Files:**

- Modify: `lua/plugins/mason.lua`

- [x] Step 1: 删掉 `ensure_installed` 里的 `"basedpyright", -- python lsp` 与
  `-- "ty", -- python type checker lsp` 两行，其余不动。

- [x] Step 2: Run
  `nvim --headless -u NONE "+lua assert(loadfile('lua/plugins/mason.lua'))" +qa`，期望退出码
  0。

- [x] Step 3: Run
  `grep -qE 'basedpyright|"ty"' lua/plugins/mason.lua`，期望退出码 1。

- [x] Step 4: Commit（只提交 `lua/plugins/mason.lua`）。

### Task 2: conform.lua 去掉重复保存格式化并重排 ruff 格式化器 → verify: `nvim --headless -u NONE "+lua assert(loadfile('lua/plugins/conform.lua'))" +qa` 退出码 0，且 `grep -qE 'nvim_create_autocmd|ruff_organize_imports' lua/plugins/conform.lua` 退出码 1

**Files:**

- Modify: `lua/plugins/conform.lua`

- [x] Step 1: 删掉末尾整段手写 autocmd：

  ```lua
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function(args)
      require("conform").format({ bufnr = args.buf })
    end,
  })
  ```

- [x] Step 2: 把
  `python = { "ruff_format", "ruff_fix", "ruff_organize_imports" },` 改成
  `python = { "ruff_fix", "ruff_format" },`。

- [x] Step 3: Run
  `nvim --headless -u NONE "+lua assert(loadfile('lua/plugins/conform.lua'))" +qa`，期望退出码
  0。

- [x] Step 4: Run
  `grep -qE 'nvim_create_autocmd|ruff_organize_imports' lua/plugins/conform.lua`，期望退出码
  1。

- [x] Step 5: Commit（只提交 `lua/plugins/conform.lua`）。

### Task 3: DEPENDENCIES.md 的 B 段补 basedpyright → verify: `grep -q basedpyright docs/DEPENDENCIES.md` 退出码 0，且 `panache lint docs/DEPENDENCIES.md` 退出码 0

**Files:**

- Modify: `docs/DEPENDENCIES.md`

- [x] Step 1: B 强烈建议总览表加一行
  `[basedpyright](https://github.com/DetachHead/basedpyright)`，功能写
  `Python 的 LSP`，备注写 `由 uv 提供`。

- [x] Step 2: B 强烈建议的通用表加一行 `basedpyright`，安装写
  `uv add --dev basedpyright` 或 `uv tool install basedpyright`。

- [x] Step 3: Run `panache format docs/DEPENDENCIES.md`，再 Run
  `panache lint docs/DEPENDENCIES.md`，期望退出码 0。

- [x] Step 4: Run `grep -q basedpyright docs/DEPENDENCIES.md`，期望退出码 0。

- [x] Step 5: Commit（只提交 `docs/DEPENDENCIES.md`）。
