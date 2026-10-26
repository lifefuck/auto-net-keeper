#!/system/bin/sh
# ============================================================
# 自动网络保持器 (Auto Net Keeper) - 安装脚本
# 作者: life
# ============================================================

ui_print() {
  echo "$1"
}

# 检测面具环境
detect_manager() {
  if [ -x /data/adb/ksud ] || [ -x /data/adb/ksu ] || [ -f /data/adb/ksu ]; then
      echo "ksu"
      return 0
  fi

  if [ -x /data/adb/apd ] || [ -f /data/adb/apd ] || [ -x /data/adb/kpatch ]; then
      echo "apatch"
      return 0
  fi

  if [ -x /data/adb/magisk/magisk ] || command -v magisk >/dev/null 2>&1 || [ -f /data/adb/magisk ]; then
      if [ -x /data/adb/magisk/magisk ]; then
          if strings /data/adb/magisk/magisk 2>/dev/null | grep -qi "kitsune"; then
              echo "kitsune"
              return 0
          fi
      fi
      VER=$(magisk -v 2>/dev/null || /data/adb/magisk/magisk -v 2>/dev/null)
      case "$VER" in
          *[Dd]elta*|*[Kk]itsune*) echo "kitsune" ;;
          *) echo "magisk" ;;
      esac
      return 0
  fi

  echo "unknown"
  return 1
}

# 按键监听：音量上=确认(0)，音量下=取消(1)，15秒超时=取消(1)
wait_for_key() {
  local START=$(date +%s)
  local NOW=$START
  while [ $((NOW - START)) -lt 15 ]; do
      EVENT=$(timeout 1 getevent -c 1 2>/dev/null | grep -E "VOLUME(UP|DOWN)|0073|0072" | head -1)
      case "$EVENT" in
          *VOLUMEUP*|*"0073"*) return 0 ;;
          *VOLUMEDOWN*|*"0072"*) return 1 ;;
      esac
      NOW=$(date +%s)
  done
  return 1
}

# 主流程
MANAGER=$(detect_manager)

ui_print "======================================"
ui_print "  Auto Net Keeper 1.0"
ui_print "  作者: life"
ui_print "======================================"
ui_print ""
ui_print "  功能："
ui_print "    - 每3分钟自动开启数据流量与WiFi"
ui_print "    - 支持在管理器中直接开关模块完成热启停"
ui_print ""
ui_print "  临时 Root 说明："
ui_print "  - 本模块不修改系统分区（仅运行于 /data/adb）"
ui_print "  - 临时 Root 重启后失效，需持久 Root 保持开机自启"
ui_print "  - 卸载干净无残留"
ui_print ""

case "$MANAGER" in
  ksu)
      ui_print "  检测到：KernelSU (KSU)"
      ;;
  apatch)
      ui_print "  检测到：APatch"
      ;;
  kitsune)
      ui_print "  检测到：狐狸面具 (Kitsune Mask)"
      ;;
  magisk)
      ui_print "  检测到：Magisk 官方版"
      ;;
  *)
      ui_print "  未检测到已知面具环境！终止安装。"
      exit 1
      ;;
esac

ui_print ""
ui_print "  此模块为 AI 模块，可能会有奇怪的 bug"
ui_print ""
ui_print "  确认安装吗？"
ui_print "  [音量+] = 确认安装"
ui_print "  [音量-] = 取消安装"
ui_print "  (15 秒无操作自动取消)"
ui_print ""
ui_print "  请按键..."

if wait_for_key; then
  ui_print ""
  ui_print "  已确认，开始安装..."
else
  ui_print ""
  ui_print "  已取消安装（音量- 或超时）"
  exit 1
fi

# 设置权限
chmod 755 "$MODPATH/service.sh" 2>/dev/null
chmod 755 "$MODPATH/daemon.sh" 2>/dev/null

ui_print ""
ui_print "  安装完成，重启手机后生效。"
ui_print "  可直接在 KSU/APatch 管理器勾选/关闭模块热启停守护！"
ui_print ""
