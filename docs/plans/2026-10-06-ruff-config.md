# ruff 标准配置: Implementation Plan

**Spec:** docs/specs/2026-10-06-ruff-config-design.md **Goal:**
在仓库根目录新增带按族注释的 `ruff.toml`，启用 E/F/I/UP/B/SIM 六族与四条
ignore，并验证 lint 与 format 行为。 **Architecture:** 单文件
`ruff.toml`，三个区（顶层 target-version 与
line-length、`[lint]`、`[format]`）。conform 的 ruff_format 与 nvim-lint 的 ruff
已由用户在外部接入，本计划只落这个配置文件。

## Global constraints

- ruff 0.16.10
- target-version py315，行宽 88，双引号
- py315 会触发 ruff 的"3.15 开发中"警告，接受
- ignore 四条：E111、E114、E117、E501

### Task 1: 创建 ruff.toml → verify: `ruff.toml` 存在，且 `ruff check --config ruff.toml` 对 Step 2 的样例退出码为 1，且 `ruff format --config ruff.toml` 之后 `ruff format --check --config ruff.toml` 对该样例退出码为 0

**Files:**

- Create: `ruff.toml`

- [x] Step 1: 在仓库根目录写 `ruff.toml`，内容如下：
  ```toml
  # ruff.toml
  # ruff 标准配置：lint + format，供 `ruff check` / `ruff format` 读取
  # 编辑本仓库根目录下的 Python 文件时，nvim-lint 的 ruff 会自动套用这套规则

  # 目标 Python 版本：UP 规则据此决定建议升级到哪一代语法（本机 .venv 是 3.15）
  target-version = "py315"

  # 行宽：formatter 换行阈值，lint 与 format 共用
  line-length = 88

  [lint]
  # 启用的规则族（按族注释，具体规则用 `ruff rule <code>` 查）：
  #   E    pycodestyle 风格错误（空白、缩进、行长等）
  #   F    pyflakes 真实错误（未定义名、未用导入、未用变量等）
  #   I    isort 导入排序与分组
  #   UP   pyupgrade 用新版更简洁的语法替代旧写法
  #   B    flake8-bugbear 常见 bug 模式（可变默认参数、裸 except 等）
  #   SIM  flake8-simplify 更简洁写法的建议
  select = ["E", "F", "I", "UP", "B", "SIM"]

  # 忽略的规则：这些交给 formatter 统一处理，留着会和 `ruff format` 冲突
  ignore = [
    "E111", # 缩进未按 4 的倍数：formatter 统一缩进
    "E114", # 注释缩进不对齐：formatter 统一缩进
    "E117", # 过度缩进：formatter 统一缩进
    "E501", # 行太长：长字符串/注释无法自动换行，行长交给 formatter
  ]

  [format]
  # 字符串引号：双引号（Black 风格）
  quote-style = "double"
  # 未显式设置的项走 ruff 默认：4 空格缩进、LF 行尾、行宽继承上面的 line-length
  ```

- [x] Step 2: 建临时样例 `/tmp/ruff_sample.py`，内容为 `import sys` 加
  `import os` 加一行 `print(sys.version)`，运行
  `ruff check --config ruff.toml /tmp/ruff_sample.py`，期望退出码 1。

- [x] Step 3: 运行 `ruff format --config ruff.toml /tmp/ruff_sample.py`，再运行
  `ruff format --check --config ruff.toml /tmp/ruff_sample.py`，期望退出码
  0。

- [x] Step 4: 运行 `ruff check --config ruff.toml` 对仓库根目录（无 Python
  源码），确认无配置解析错误。

- [x] Step 5: Commit（只提交 `ruff.toml`）。
