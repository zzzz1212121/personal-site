#!/bin/bash
# 构建并发布到 GitHub Pages（gh-pages 分支）
# 用法：bash deploy.sh
set -e
cd "$(dirname "$0")"

REPO="git@github.com:zzzz1212121/personal-site.git"
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
git push -f "$REPO" gh-pages

cd - >/dev/null
rm -rf "$TMP"
echo "==> 完成：https://ztsblueocean.cn"
