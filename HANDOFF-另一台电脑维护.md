# 蓝海小站 · 另一台电脑维护交接

> 给接手 agent 的完整说明。读完这份就能在**任意一台 Mac** 上维护 https://ztsblueocean.cn 。
> 一句话：**Hugo 静态站**，源码在 GitHub 的 `main` 分支，构建产物强推 `gh-pages`，GitHub Pages + 自定义域名对外服务，没有服务器、没有数据库、不备案。

---

## 0. 你要接手的是什么

| 项 | 值 |
|---|---|
| 站点 | 蓝海小站 / Blue Ocean |
| 线上地址 | https://ztsblueocean.cn |
| 域名 | `ztsblueocean.cn`（阿里云注册，**2027-11-04 到期**；DNS 指向 GitHub Pages：185.199.108/109/110.153） |
| GitHub 仓库 | `git@github.com:zzzz1212121/personal-site.git`（public） |
| 分支 | **`main` = 源码**（人看的）；**`gh-pages` = 构建产物**（Pages 发布的那个，由脚本强推，不要手工改） |
| 生成器 | Hugo **v0.169.0 extended**（Homebrew 安装） |
| 版式 | `layouts/` 手写极简模板，**无外部主题依赖** |
| 密码学/密钥 | 仓库里**没有任何密钥**，可以放心 clone |

---

## 1. 从零搭好另一台电脑（按顺序做）

```bash
# 1) 装 Hugo（必须有 extended；brew 已装可跳过第一步的 brew 安装）
HOMEBREW_NO_AUTO_UPDATE=1 brew install hugo
hugo version      # 应输出 v0.169.0 ... extended

# 2) 配 SSH（GitHub 账号 zzzz1212121）
ssh-keygen -t ed25519 -C "另一台电脑"      # 已有 key 就跳过
cat ~/.ssh/id_ed25519.pub                 # 把内容加到 GitHub → Settings → SSH and GPG keys
ssh -T git@github.com                     # 应返回 "Hi zzzz1212121! You've successfully authenticated"

# 3) 克隆（路径建议与原地一致，脚本里有绝对路径）
mkdir -p ~/dsh-workspace/projects
git clone git@github.com:zzzz1212121/personal-site.git ~/dsh-workspace/projects/personal-site
cd ~/dsh-workspace/projects/personal-site

# 4) 验证构建（不发布）
hugo --minify --cleanDestinationDir       # 无报错即成功，产物在 public/

# 5) 本地预览
hugo server -D                            # 打开 http://localhost:1313
```

> ⚠️ **Hugo 版本别乱升**。0.169 已经会报 `languageCode was deprecated` 的警告（不影响构建）。大版本升级可能改模板行为，升之前先在本地跑 `hugo` 看有无报错。

---

---

## 1.5 凭证：**这份文档本身不带任何权限**

**先把话说清楚**：拿到这份 MD 文件 ≠ 能上传。文档只是"怎么做"，真正决定能不能推送的是**那台电脑上有没有被 GitHub 认可的凭证**。

| 动作 | 需要什么 | 拿不到会怎样 |
|---|---|---|
| clone 仓库（只读） | 不需要凭证（public 仓库，https 也行） | — |
| `git push`（main / gh-pages） | **该账号对该仓库的写权限** | 报 `Permission to zzzz1212121/personal-site.git denied` |
| 改 Pages 设置 / 域名 / Enforce HTTPS | **账号登录**（网页操作，本机需开代理） | 页面打不开、证书异常 |

> GitHub **早已不支持用账号密码 push**（2021 年取消）。可用凭证只有三种：SSH key、Personal Access Token、`gh auth login`。

### 三种方式，按安全性从高到低

| 方式 | 怎么配 | 适用 | 风险 |
|---|---|---|---|
| **Deploy Key**（仓库级、只给这一个仓库） | 那台机器 `ssh-keygen -t ed25519` → 公钥贴到 GitHub 仓库 `Settings → Deploy keys`，勾 **Allow write access** | 只想让它发这一个站（推荐给非本人机器/临时代理） | 只能推这一个仓库；`gh-pages` 够用，`main` 提交要看分支保护 |
| **账号 SSH key** | 公钥贴到 GitHub 个人 `Settings → SSH keys` | 本人长期使用的机器（**本机就是这样**） | 对该账号所有仓库可写 —— 机器被入侵损失大 |
| **fine-grained PAT** | GitHub 个人设置里签发，限定仓库 + `Contents: Read and write`，clone 用 `https://<token>@github.com/...` | 不想配 SSH、或要给脚本用 | token 明文存在本地，容易泄漏；用完应吊销 |

### 三条铁律

1. **私钥永不外传、永不入仓库**。公钥（`.pub`）可以随便贴；私钥（无后缀那个，本机在 `~/.ssh/id_ed25519`，权限 600）必须留在生成它的那台机器上。
2. **不要"把本机私钥拷到另一台机器"**。正确做法是在那台机器上新生成一对，再把公钥贴到 GitHub —— 这样任何一台出事都能单独吊销。
3. **给 agent 的机器用最小权限**：优先 Deploy Key（单仓库），别直接给它账号级 SSH key。

### 验证是否已具备写权限

```bash
ssh -T git@github.com                 # 认出来是哪个账号
git ls-remote origin                 # 能列出分支 = 读通
git push --dry-run origin main       # 不实际推送，只验证权限
```

## 2. 日常维护只有三类活

| 任务 | 做法 |
|---|---|
| **写文章** | `hugo new posts/文章名.md` → front matter 只需 `title` / `date`（`YYYY-MM-DD`）/ `description` → 正文写 Markdown |
| **加一个独立 HTML 页面** | ① 文件放 `static/<路径>/index.html`；② 在 `layouts/index.html` 的「工具」区加一条 `<li><a href="{{ "/<路径>/" | relURL }}">…</a></li>`；③ 在 `README.md` 的「目录」表补一行；④ 发布 |
| **改样式 / 模板** | 样式在 `static/css/style.css`（Hugo Pipes 带内容指纹，改完浏览器自动失效缓存，**不需要手动清缓存**）；模板在 `layouts/`（`baseof.html` / `index.html` / `_default/single.html` / `_default/list.html` / `partials/gate.html` / `robots.txt`） |

---

## 3. 现有页面清单（改之前先认清楚）

| 路径 | 实际来源 | 说明 |
|---|---|---|
| `/heatmap/` | **交易系统产出**（非本仓库生成） | 3.7MB 单页，每日更新，见第 5 节 |
| `/photography/` | `learning/摄影技能树.html` 的**副本** | 静态裸页，进度存 localStorage |
| `/design-prompt/` | `learning/设计提示词技能树.html` 的副本 | 同上 |
| `/economics/` | `learning/宏观经济学知识树.html` 的副本 | 同上 |
| 首页四个入口 | `layouts/index.html` → section「工具」 | 加页面必须同步这里，否则线上"看不见" |

> **副本机制**：摄影/设计提示词/宏观三个页面，**原文件在工作区的 `learning/` 目录**，`static/` 下是拷贝。改内容要改原件再复制过来，否则下次有人同步会覆盖。

---

## 4. 发布与验证

```bash
bash deploy.sh
```

`deploy.sh` 干三件事（失败会直接退出）：

1. `hugo --minify --cleanDestinationDir` 构建
2. 把 `public/` 拷进临时目录，`git init -b gh-pages` + commit
3. `git push -f` 到 `gh-pages`（**强推，正常现象**）

**验证发布是否成功**（Pages 有 30–90 秒构建延迟，别立刻判失败）：

```bash
curl -sI https://ztsblueocean.cn/ | head -1                     # 期望 HTTP/2 200
curl -s https://ztsblueocean.cn/economics/ | grep -c "宏观经济学知识树"   # 期望 ≥1
dig +short ztsblueocean.cn                                       # 期望 185.199.10x.153
git log --oneline -1                                             # 确认源码已提交（deploy 不提交 main！）
```

> ⚠️ **`deploy.sh` 只推 `gh-pages`，不提交 `main`**。改完源码要自己 `git add / commit / push origin main`，否则另一台机器 clone 下来看不到你的改动。

---

## 5. 热力图：**只在原机产出，另一台机器做不到**

`publish_heatmap.sh` 的完整链路：

```
交易系统产出 sector-dashboard/output/strategy_heatmap.html（3.7MB，含 29 板块 K 线 + MA60 信号）
  → 复制到 static/heatmap/index.html
  → hugo 构建 + 强推 gh-pages
  → 60 秒后取线上前 64KB 校验是否含当天日期
  → 任一步失败 → 飞书告警
```

| 项 | 说明 |
|---|---|
| 数据源 | **另一台电脑上没有**（来自 `trading-system/sector-dashboard`，依赖 akshare/tushare/mootdx） |
| 原机调度 | launchd 任务 `com.user.site-heatmap` **已停用**（plist 改名 `.disabled`，2026-11-11 全停）；现在靠手动跑或 `tools/run_all_on_demand.sh` 调起 |
| 另一台能做什么 | 只能**手动替换** `static/heatmap/index.html` 后走 `bash deploy.sh`；或等原机发布后 `git pull` 拿最新文件再发布 |
| 别做的事 | 不要删 `static/heatmap/index.html`（会成为 404 页面），也不要在别的机器上"重跑热力图" |

---

## 6. 已知坑（都是踩过的，别重犯）

| # | 坑 | 处置 |
|---|---|---|
| 1 | 本机直连 `github.com` **网页**被拦，但 `api.github.com` 和 SSH 正常 | **改仓库设置要开代理；`git push` 不需要代理** |
| 2 | `brew install` 会卡在 auto-update | 必须带 `HOMEBREW_NO_AUTO_UPDATE=1` |
| 3 | 发布后浏览器还在用旧样式 | 已修：CSS 改走 Hugo Pipes **内容指纹**，不用手动清缓存 |
| 4 | 进站欢迎界面「叫哥才给进」 | `layouts/partials/gate.html`，输入**包含「哥」**即通过，`sessionStorage` 记住；**只拦 Hugo 页面，`static/` 裸页（heatmap/photography/design-prompt/economics）完全不受保护**，知道链接就能看 |
| 5 | 热力图打开慢 | 3.7MB（gzip 后约 1.2MB），国内线路 1–2 分钟，属已知代价 |
| 6 | 仓库越来越大 | 每天一个新热力图进 git，一年约 100–150MB，GitHub Pages 上限 1GB |
| 7 | HTTPS 证书异常 | 曾长期只有 `*.github.io` 证书，需在 GitHub Pages 设置里确认域名并勾选 Enforce HTTPS（**改设置要开代理**） |
| 8 | `secrets/` 不存在，但别乱加 | 站点是纯静态公开仓库，任何密钥写进来就等于公开 |

---

## 7. 红线（交给 agent 时请一起转述）

1. **不要 `git push -f origin main`** —— 只有 `gh-pages` 可以强推。
2. **不要把任何 token / 密钥写进仓库或前端代码**。
3. **不要在另一台机器上动交易系统**（`trading-system/`、`stock_sectors.csv` 都不在这台机器的职责范围）。
4. **删除线上页面 = 删 `static/<路径>` + 删首页条目 + 提交 + 发布**，属于不可逆的对外变更，**先问用户**。
5. 改完任何页面，**首页入口和 README 目录表要同步**——不同步就等于线上"不存在"。

---

## 8. 接手后的自检清单

- [ ] `hugo version` 显示 extended
- [ ] `ssh -T git@github.com` 认证成功
- [ ] `git clone` 成功，`git status` 干净
- [ ] `hugo` 本地构建无报错
- [ ] `curl -sI https://ztsblueocean.cn/` 返回 200
- [ ] 能打开 `/heatmap/` `/photography/` `/design-prompt/` `/economics/` 四个页面
- [ ] 首页「工具」区四个入口都在
- [ ] `bash deploy.sh` 能跑通且线上 1 分钟内更新

---

## 附：给 agent 的开场提示（可直接复制）

> 这是「蓝海小站」个人网站，Hugo 静态站，源码在 GitHub 的 `personal-site` 仓库 `main` 分支，构建产物强推 `gh-pages`，线上 https://ztsblueocean.cn 。
> 请先读仓库根目录的 `HANDOFF-另一台电脑维护.md` 与 `README.md`，按里面的流程操作；发布只跑 `bash deploy.sh`，源码改动记得单独提交 `main`。
> 红线：不强推 `main`、不放密钥、不碰交易系统、删除线上页面必须先问我。
