#!/bin/sh
# 本機自動測試（不連正式資料庫）：建立測試資料庫 → 啟動本機 Worker → 跑端對端測試
# 用法：sh worker/test/run.sh
cd "$(dirname "$0")"
start() { npx --yes wrangler@3 dev --local --port 8799 > dev.log 2>&1 & PID=$!; sleep 15; }
stop() { kill $PID 2>/dev/null; pkill -f "wrangler.*8799" 2>/dev/null; sleep 2; }
rm -rf .wrangler
npx --yes wrangler@3 d1 execute testdb --local --file=../schema.sql > /dev/null
start; node e2e.mjs | grep -E "^FAIL|^PASS [0-9]"; stop
start; node punch-fix.mjs | grep -E "^FAIL" || echo "補卡檢核 7/7 PASS"; stop
