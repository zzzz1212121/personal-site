# personal-site — 个人网站

Hugo 静态站，托管计划：GitHub Pages + 自定义域名（不备案、无服务器）。

## 现状

| 项 | 值 |
|---|---|
| 域名 | `ztsblueocean.cn`（阿里云注册） |
| 本地目录 | `~/dsh-workspace/projects/personal-site` |
| 生成器 | Hugo v0.169.0（Homebrew 装） |
| 主题 | 无主题，`layouts/` 手写极简版式（不依赖外部主题，无 git submodule） |
| GitHub 仓库 | **待建** |
| Pages | **未开启** |
| 上线状态 | 仅本地可看 |

## 目录

```
hugo.toml                站点配置（baseURL / 站名 / 参数）
content/posts/           文章（Markdown）
content/about.md         关于页
layouts/                 手写模板：baseof / index / list / single
static/css/style.css     样式
static/CNAME             自定义域名（Hugo 会原样拷到 public/）
public/                  构建产物（已在 .gitignore，不入库）
```

## 日常写作

```bash
cd ~/dsh-workspace/projects/personal-site
hugo new posts/文章名.md      # 新建
hugo server -D                # 本地预览 http://localhost:1313
hugo                          # 构建到 public/
```

## 待办

1. 建 GitHub 公开仓库，推源码，开 Pages（用 GitHub Actions 构建，或本地构建后部署）
2. 阿里云 DNS 加记录：4 条 A → GitHub Pages IP；`www` CNAME → `<用户名>.github.io`
3. 仓库 Settings → Pages 填 `ztsblueocean.cn`，开 Enforce HTTPS
4. （可选）把每日板块热力图自动推上来 —— 见对话记录，注意仓库体积（3.5MB/天）和公开性问题

## 环境注意

- 本机访问 GitHub 需要代理（当前未启用），国内站直连正常。
- brew 安装需带 `HOMEBREW_NO_AUTO_UPDATE=1`，否则卡在 auto-update。
