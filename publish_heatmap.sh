#!/bin/bash
# 把每日板块热力图同步到个人网站并发布
# 由 launchd 任务 com.user.site-heatmap 在工作日 15:45 调起；也可手动跑
set -uo pipefail

SITE="/Users/zzz/dsh-workspace/projects/personal-site"
SRC="/Users/zzz/dsh-workspace/trading-system/sector-dashboard/output/strategy_heatmap.html"
DEST="$SITE/static/heatmap/index.html"
LOG="$SITE/logs/publish.log"
LARK="/Users/zzz/.npm-global/bin/lark-cli"
CHAT="oc_e79ab7f93069ff36458cce1bc906a647"

mkdir -p "$(dirname "$LOG")"

NOTIFIED=0
notify_once() {
  [ "$NOTIFIED" = 1 ] && return 0
  NOTIFIED=1
  [ -x "$LARK" ] && "$LARK" im +messages-send --as bot --chat-id "$CHAT" --text "$1" >/dev/null 2>&1
  return 0
}

# 任何未预期退出都告警一次（含 set -u 之类的脚本错误）
trap 'c=$?; if [ "$c" -ne 0 ]; then echo "[$(date "+%F %T")] TRAP exit=$c" >>"$LOG"; notify_once "🌐 网站热力图脚本异常退出（code ${c}）"; fi' EXIT

fail() {
  echo "[$(date '+%F %T')] FAIL: $1" >>"$LOG"
  notify_once "🌐 网站热力图发布失败：$1"
  exit 1
}

echo "[$(date '+%F %T')] ===== start =====" >>"$LOG"

[ -f "$SRC" ] || fail "源文件不存在"
[ -s "$SRC" ] || fail "源文件是空的"

# 防呆：只发布今天生成的文件，避免把昨天的旧数据顶上线
SRC_DATE="$(date -r "$SRC" '+%Y-%m-%d')"
[ "$SRC_DATE" = "$(date '+%Y-%m-%d')" ] || fail "源文件不是今天生成的（${SRC_DATE}）"

mkdir -p "$(dirname "$DEST")"
cp "$SRC" "$DEST" || fail "复制到站点目录失败"

cd "$SITE" || fail "进不去站点目录"
export PATH="/opt/homebrew/bin:$PATH"
bash deploy.sh >>"$LOG" 2>&1 || fail "构建或推送失败（详见 ${LOG}）"

echo "[$(date '+%F %T')] 推送完成，60 秒后校验线上" >>"$LOG"
sleep 60

TODAY="$(date '+%Y%m%d')"
# 只取前 64KB 校验（页面 3.7MB，这条线路拉全量要一两分钟）
SNIP="$(curl -sk -m 40 -r 0-65535 "https://ztsblueocean.cn/heatmap/")"
if [[ "$SNIP" == *"${TODAY}"* ]]; then
  echo "[$(date '+%F %T')] OK 线上校验通过（${TODAY}）" >>"$LOG"
else
  echo "[$(date '+%F %T')] WARN 线上校验未通过（${TODAY}）" >>"$LOG"
  notify_once "🌐 热力图已推送，但线上校验未通过，可能是 GitHub Pages 延迟，稍后自查"
fi

echo "[$(date '+%F %T')] ===== end =====" >>"$LOG"
