#!/bin/bash
# 构建并发布到 GitHub Pages（gh-pages 分支）
# 用法：bash deploy.sh
set -e
cd "$(dirname "$0")"

REPO="${SITE_REPO:-git@github.com:zzzz1212121/personal-site.git}"
GIT_ID=(-c user.name="zzzz1212121" -c user.email="15539819327@163.com")

echo "==> 1/3 构建"
hugo --minify --cleanDestinationDir

echo "==> 2/3 打包产物"
TMP=$(mktemp -d)
cp -R public/. "$TMP/"
cd "$TMP"
git init -q -b gh-pages
git add -A
git "${GIT_ID[@]}" commit -q -m "deploy: $(date '+%Y-%m-%d %H:%M:%S')"

echo "==> 3/3 推送到 gh-pages"
# 用 --force-with-lease 代替 --force：只在远端仍是本地看到的那个 commit 时才覆盖，
# 避免在别人（或另一台机器）刚推送过之后静默覆盖掉对方的产物。
git fetch -q "$REPO" gh-pages:refs/remotes/origin/gh-pages 2>/dev/null || true
if git rev-parse --verify -q refs/remotes/origin/gh-pages >/dev/null; then
  git push --force-with-lease=gh-pages:refs/remotes/origin/gh-pages "$REPO" gh-pages
else
  git push "$REPO" gh-pages
fi

cd - >/dev/null
rm -rf "$TMP"
echo "==> 完成：https://ztsblueocean.cn"
