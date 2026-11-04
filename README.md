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
static/css/style.css      样式
static/CNAME              自定义域名（Hugo 原样拷到 public/）
static/heatmap/index.html 每日板块热力图（自动写入，勿手改）
static/photography/index.html 摄影技能树（来源 learning/摄影技能树.html 的副本）
deploy.sh                 构建 + 强制推送 gh-pages
publish_heatmap.sh        热力图同步 + 发布 + 线上校验（launchd 调）
logs/publish.log          发布日志
```

## 日常写作

```bash
cd ~/dsh-workspace/projects/personal-site
hugo new posts/文章名.md      # 新建
hugo server -D                # 本地预览 http://localhost:1313
bash deploy.sh                # 发布（构建 + 推送 gh-pages）
```

## 热力图自动发布

launchd 任务 `com.user.site-heatmap`，工作日 **15:45**（在 15:35 仪表盘生成之后）：

```
sector-dashboard/output/strategy_heatmap.html
  → 复制到 static/heatmap/index.html（只接受当天生成的文件，否则报错告警）
  → hugo + 强制推送 gh-pages
  → 60 秒后取前 64KB 校验线上是否含当天日期
  → 任一步失败 → 飞书告警
```

页面入口：首页「工具」区 → `/heatmap/`。`robots.txt` 已 `Disallow: /heatmap/`，不让搜索引擎收录。

**已知代价**：
- 热力图 **3.7MB**（gzip 后约 1.2MB），国内线路拉全量要 1~2 分钟，打开偏慢。
- 每天一份新文件进 git，仓库会慢慢变大（一年约 100~150MB，Pages 上限 1GB）。

## 环境注意

- 本机直连 `github.com` 网页被拦（`api.github.com` 和 SSH 正常）。**改仓库设置需要开代理**；`git push` 走 SSH，不需要代理。
- brew 安装必须带 `HOMEBREW_NO_AUTO_UPDATE=1`，否则卡在 auto-update。
- 写得快的命令：`dig +short ztsblueocean.cn` 验解析；`openssl s_client -connect ztsblueocean.cn:443 -servername ztsblueocean.cn | openssl x509 -noout -subject` 验证书。
