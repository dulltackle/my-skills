# my-skills

在 [mattpocock/skills](https://github.com/mattpocock/skills) 基础上的自定义 skill，面向 GitHub PR 工作流：工单的验收标准先逐条验证、写回工单，PR 再根据验收结果决定是 draft 还是 ready，合并时由 `Closes` 关闭工单。

上游文件不做任何修改。`implement` 和 `implement-spec` 以同名方式覆盖上游，正文保持上游原文，只改动少量明确的位置（见[覆盖与漂移检查](#覆盖与漂移检查)）。

## Skill 一览

### User-invoked

只能由你手动输入调用（`disable-model-invocation: true`，Codex 端为 `policy.allow_implicit_invocation: false`）。

- **[implement](./implement/SKILL.md)**：覆盖上游。实现单个工单，用 `open-code-review-delegate` 做审查，最后调用 `to-commit` 和 `to-pr`。
- **[implement-spec](./implement-spec/SKILL.md)**：覆盖上游。在一条集成分支上并行实现整个 spec，用 `open-code-review-delegate` 做审查，最后调用 `to-pr`。

### Model-invoked

既可由模型调用，也可手动调用。按上游约定，user-invoked skill 只能调用 model-invoked skill，所以下面三个不能设为 user-invoked。

- **[to-commit](./to-commit/SKILL.md)**：一个工单一个 Conventional Commit，提交与验收写回同时成功或同时不发生。不 push，不开 PR。
- **[to-pr](./to-pr/SKILL.md)**：把当前分支交付为关闭其工单的 PR。仍有未勾选条目时调用 `verify-acceptance`，再根据验收结果决定 draft 或 ready。可重复运行。
- **[verify-acceptance](./verify-acceptance/SKILL.md)**：按 `ran` / `read` / 未验证三类逐条验证验收标准，把挣得的勾选写回工单（GitHub 或本地 markdown），回归时撤销勾选。

## 流程

```text
单工单   /implement #42
           tdd → open-code-review-delegate → to-commit → to-pr

多工单   /implement-spec #10
           并行实现 → 合并 → draft PR（Closes 各工单）
           → open-code-review-delegate → to-pr（验证、写回，决定 draft/ready）
```

## 依赖

- 上游 skill：`tdd`、`pr`、`setup-matt-pocock-skills`（每个仓库先运行一次，生成 `docs/agents/issue-tracker.md`）。
- [`open-code-review-delegate`](https://github.com/alibaba/open-code-review) 及 `ocr` CLI。缺少 `ocr` 时审查步骤会报告阻塞，不会静默跳过。
- `gh` CLI。

## 安装

按用户级安装（`~/.claude/skills/`、`~/.codex/skills/`），所有项目通用。

**注意**：`implement`、`implement-spec` 与上游同名，同一目录下只能装本仓库的版本，不要同时装上游的这两个 skill。

## 维护

### 覆盖与漂移检查

```bash
scripts/check-upstream.sh
```

脚本拉取上游锁定提交（`PINNED`）和 `main` 的 `implement`、`implement-spec`，检查两件事：

1. 上游自锁定提交以来是否改过这些文件。改过就打印 diff 并退出 1。
2. 本地覆盖版本相对锁定提交的改动块数是否在允许范围内（`SKILL.md` 各 2 处，`openai.yaml` 不允许改动）。

上游更新后：把新原文合入本地覆盖文件，保留允许的改动，再把 `PINNED` 改成新提交，重新运行脚本直到通过。

当前允许的改动：

| 文件 | 改动 |
|---|---|
| `implement/SKILL.md` | 审查从 `code-review` 改为 `open-code-review-delegate`；末尾从直接提交改为 `to-commit` → `to-pr` |
| `implement-spec/SKILL.md` | 第 7 步审查改为 `open-code-review-delegate`；第 8 步从直接标记 ready 改为调用 `to-pr` |

### 引用检查

```bash
python3 scripts/check-references.py            # 检查全部 skill
python3 scripts/check-references.py to-commit  # 只检查一个
```

检查各 skill Markdown 正文中的本地文件链接，要求目标位于该 skill 目录内且可读，避免安装后出现指向包外的悬空引用。

### Evals

[`evals/`](./evals) 按 skill 存放场景（`scenarios.md`）和预期结果（`expectations.md`）。修改 `to-commit`、`to-pr` 或 `verify-acceptance` 的行为后，在只读取相关 skill 文件的隔离上下文中逐个跑场景，并与预期对照。

### 写作约定

与上游保持一致：skill 正文和模板使用英文，输出语言跟随用户指令和仓库历史；调用其他 skill 统一写 "Call the Skill tool with …"；正文不使用破折号（em dash）。
