# 蓝海小站（Blue Ocean）— 个人网站

Hugo 静态站，托管 GitHub Pages + 自定义域名（不备案、无服务器，只花域名钱）。

| 名称 | 值 |
|---|---|
| 中文名 | 蓝海小站 |
| 英文名 | Blue Ocean |
| 域名 | ztsblueocean.cn（域名里的 "blue ocean" 即站名来源） |

## 现状

| 项 | 值 |
|---|---|
| 站点 | https://ztsblueocean.cn |
| 域名 | `ztsblueocean.cn`（阿里云注册，2027-11-04 到期） |
| 本地目录 | `~/dsh-workspace/projects/personal-site` |
| GitHub 仓库 | https://github.com/zzzz1212121/personal-site （public） |
| 分支 | `main` = 源码；`gh-pages` = 构建产物（Pages 发布这个分支） |
| 生成器 | Hugo v0.169.0（Homebrew） |
| 版式 | `layouts/` 手写极简模板，无外部主题依赖 |
| HTTPS | ⚠️ 证书曾长期只有 `*.github.io`，需在 Pages 设置里确认域名并开 Enforce HTTPS |

## 目录

```
hugo.toml                 站点配置（baseURL / 站名 / 参数）
content/posts/            文章（Markdown）
content/about.md          关于页
layouts/                  模板：baseof / index / list / single / robots.txt
assets/css/style.css      样式（Hugo Pipes：resources.Get "css/style.css" | minify | fingerprint；⚠ 不是 static/css/）
static/CNAME              自定义域名（Hugo 原样拷到 public/）
static/photography/index.html 摄影技能树（来源 learning/摄影技能树.html 的副本）
static/design-prompt/index.html 设计提示词技能树（来源 learning/设计提示词技能树.html 的副本）
static/economics/index.html  宏观经济学知识树（来源 learning/宏观经济学知识树.html 的副本）
deploy.sh                 构建 + 强制推送 gh-pages
publish_heatmap.sh        已停用（原热力图发布脚本，现直接 exit 0）
logs/publish.log          发布日志
```

## 日常写作

```bash
cd ~/dsh-workspace/projects/personal-site
hugo new posts/文章名.md      # 新建
hugo server -D                # 本地预览 http://localhost:1313
bash deploy.sh                # 发布（构建 + 推送 gh-pages）
```

## 已下线：板块策略热力图（2026-11-24）

原「板块策略仪表盘」已按用户要求从站点删除：

- 首页「工具」区入口已移除
- `static/heatmap/index.html` 已删除（`/heatmap/` 现为 404）
- `robots.txt` 里的 `Disallow: /heatmap/` 已去掉
- `publish_heatmap.sh` 开头加了 `exit 0` 停用；**Mac 上若还挂着 launchd 任务 `com.user.site-heatmap`，
  需要在那台机器上 `launchctl unload ~/Library/LaunchAgents/com.user.site-heatmap.plist`**，
  否则它仍会每天跑（脚本现已直接退出，不会再发布，但会留下执行记录）

如需恢复：`git revert` 本次提交，并从 git 历史取回 `static/heatmap/index.html` 与 `layouts/index.html` 里的入口。

## 环境注意

- 本机直连 `github.com` 网页被拦（`api.github.com` 和 SSH 正常）。**改仓库设置需要开代理**；`git push` 走 SSH，不需要代理。
- brew 安装必须带 `HOMEBREW_NO_AUTO_UPDATE=1`，否则卡在 auto-update。
- 写得快的命令：`dig +short ztsblueocean.cn` 验解析；`openssl s_client -connect ztsblueocean.cn:443 -servername ztsblueocean.cn | openssl x509 -noout -subject` 验证书。

## 已下线：进站口令（2026-11-24）

原「叫哥才给进」欢迎界面已按用户要求删除：

- `layouts/_default/baseof.html` 里的 `{{ partial "gate.html" . }}` 注入已移除
- `layouts/partials/gate.html` 已删除
- `assets/css/style.css` 末尾「进站口令」样式段已删除

现在所有页面直接可访问，不再有欢迎屏。
