# my-skills

在 [mattpocock/skills](https://github.com/mattpocock/skills) 基础上的自定义 skill，面向 GitHub PR 工作流：工单的验收标准先逐条验证、写回工单，PR 再根据验收结果决定是 draft 还是 ready，合并时由 `Closes` 关闭工单。

上游文件不做任何修改。`implement` 和 `implement-spec` 以同名方式覆盖上游，正文保持上游原文，只改动少量明确的位置（见[覆盖与漂移检查](#覆盖与漂移检查)）。

## Skill 一览

### User-invoked

只能由你手动输入调用（`disable-model-invocation: true`，Codex 端为 `policy.allow_implicit_invocation: false`）。

- **[implement](./implement/SKILL.md)**：覆盖上游。实现单个工单，用 `open-code-review-delegate` 做审查，提交后调用 `to-pr`。
- **[implement-spec](./implement-spec/SKILL.md)**：覆盖上游。在一条集成分支上并行实现整个 spec，用 `open-code-review-delegate` 做审查，最后调用 `to-pr`。

### Model-invoked

既可由模型调用，也可手动调用。按上游约定，user-invoked skill 只能调用 model-invoked skill，所以下面两个不能设为 user-invoked。

- **[to-pr](./to-pr/SKILL.md)**：把当前分支交付为关闭其工单的 PR。仍有未勾选条目时调用 `verify-acceptance`，再根据验收结果决定 draft 或 ready。可重复运行。
- **[verify-acceptance](./verify-acceptance/SKILL.md)**：按 `ran` / `read` / `judge` / 未验证四类逐条验证验收标准，把挣得的勾选写回工单（GitHub 或本地 markdown），回归时撤销勾选。`ran` 靠执行、`read` 靠能指出出处的阅读，由代理直接勾选；只有 `judge`（要求人工批准、含主观标准，或用户曾拒绝）才询问用户。GitHub 工单的验收区标题限定为 `## Acceptance criteria`（不区分大小写）、`## 验收标准`、`## 验收条件`，按原样识别，不改写；出现多个视为不匹配，不写回。没有验收区时扫描正文和评论中的勾选框，作为候选报告，不勾选。

## 流程

```text
单工单   /implement #42
           tdd → open-code-review-delegate → 提交 → to-pr（验证、写回，决定 draft/ready）

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

脚本每次拉取上游最新的 `main`（也可传入其他 ref），把 `implement`、`implement-spec` 的本地覆盖版本与之对比：改动块数超出允许范围（`SKILL.md` 各 2 处，`openai.yaml` 不允许改动），说明上游在别处有更新，脚本会打印 diff 并退出 1。

上游更新后：把新原文合入本地覆盖文件，只保留允许的改动，重新运行脚本直到通过。上游如果恰好改的就是被覆盖的那几行，改动块数不会变，脚本发现不了，所以合入时要顺带看一眼这几处的上游原文。

当前允许的改动：

| 文件 | 改动 |
|---|---|
| `implement/SKILL.md` | 审查从 `code-review` 改为 `open-code-review-delegate`；提交前在默认分支或 detached HEAD 上先建 `issue-<n>` 分支，提交后调用 `to-pr` |
| `implement-spec/SKILL.md` | 第 7 步审查改为 `open-code-review-delegate`；第 8 步从直接标记 ready 改为调用 `to-pr` |

### 引用检查

```bash
python3 scripts/check-references.py            # 检查全部 skill
python3 scripts/check-references.py to-pr      # 只检查一个
```

检查各 skill Markdown 正文中的本地文件链接，要求目标位于该 skill 目录内且可读，避免安装后出现指向包外的悬空引用。

### Evals

[`evals/`](./evals) 按 skill 存放场景（`scenarios.md`）和预期结果（`expectations.md`）。修改 `to-pr` 或 `verify-acceptance` 的行为后，在只读取相关 skill 文件的隔离上下文中逐个跑场景，并与预期对照。

### 写作约定

与上游保持一致：skill 正文和模板使用英文，输出语言跟随用户指令和仓库历史；调用其他 skill 统一写 "Call the Skill tool with …"；正文不使用破折号（em dash）。
