# Issuer

GitHub issue orchestration service backed by OpenClaw and Feishu.

- 源代码：`workspace_assets/`
- 核心模块：`workspace_assets/tools/pending_action.mjs`、`workspace_assets/tools/github_issue_create.mjs`、`workspace_assets/tools/github_issue_update.mjs`、`workspace_assets/tools/github_issue_close.mjs`、`workspace_assets/tools/github_issue_comment.mjs`、`workspace_assets/hooks/confirmation-bridge/handler.ts`
- 配置文件：`config/`
- 运维脚本：`scripts/`
- 运行数据：`data/`
- 文档：`docs/`

## 启动方式

首次或升级后建议先做一次初始化和同步：

```bash
bash scripts/bootstrap.sh
bash scripts/sync_workspace.sh
```

手动启动：

```bash
./scripts/start_gateway.sh
./scripts/status_gateway.sh
```

如果你刚改过 `workspace_assets/`：

```bash
./scripts/sync_workspace.sh
./scripts/stop_gateway.sh
./scripts/start_gateway.sh
```

systemd 部署或升级：

```bash
BOT_USER="$(id -un)" ./scripts/install_systemd.sh
sudo systemctl restart issuer-openclaw-gateway
sudo systemctl status --no-pager issuer-openclaw-gateway
```

详细说明见：

- [部署手册](docs/部署手册.md)
- [使用手册](docs/使用手册.md)

## 附件上传

附件在执行 `github_issue_create.mjs`、`github_issue_update.mjs`、`github_issue_comment.mjs` 时会自动从最新飞书会话中识别，并上传到外部附件存储。

附件默认上传到 WebDAV。在 `config/github-app.config.env` 中至少配置：

```bash
WEBDAV_BASE_URL=https://webdav.your-domain.example/dav/personal/issue-pictures
WEBDAV_USERNAME=your-key-id
WEBDAV_PASSWORD=your-key-secret
WEBDAV_PUBLIC_SHARE_API_URL=https://webdav.your-domain.example/api/v1/public/share/create
WEBDAV_PUBLIC_SHARE_BEARER_TOKEN=your-bearer-token
```

如果你的服务方使用 `Key ID / Key Secret` 命名，也可以改用：

```bash
WEBDAV_KEY_ID=your-key-id
WEBDAV_KEY_SECRET=your-key-secret
```

上传成功后：

- 会先调用公开分享接口生成外链
- 图片会在 GitHub Issue/Comment 中以内联 Markdown 形式展示
- 非图片文件会显示为“查看文件”链接
- 远端目录按 `issuer-attachments/YYYY/MM/DD/<timestamp>-<random>-filename` 自动分层

## 排障查看

你直接这样用就行。

看总览：

```bash
cd /root/code/bot/linked-openclaw/issuer
./scripts/inspect_pending.sh summary
```

看当前所有草案：

```bash
./scripts/inspect_pending.sh list
```

只看某个仓库：

```bash
./scripts/inspect_pending.sh list --repo yeying-community/robot
```

按群查：

```bash
./scripts/inspect_pending.sh conversation --conversation-id chat:oc_xxx
```

按用户查：

```bash
./scripts/inspect_pending.sh requester --requester-id ou_xxx
```

按 `draftId` 查完整详情：

```bash
./scripts/inspect_pending.sh show --draft-id 5d496c27
```
