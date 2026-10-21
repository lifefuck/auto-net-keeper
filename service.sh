#!/system/bin/sh
# ============================================================
# 自动网络保持器 - 开机引导脚本
# 作者: life
# ============================================================

MODDIR=${0%/*}
case "$MODDIR" in
    /*) : ;;
    *) MODDIR="/data/adb/modules/auto_net_keeper" ;;
esac

# 延迟 20 秒，等待系统网络与关键服务就绪
sleep 20

# 模块已被标记删除（KSU / Magisk 卸载）则不自启
if [ ! -f "$MODDIR/module.prop" ] || [ -f "$MODDIR/remove" ] || [ -f "$MODDIR/.remove" ]; then
    exit 0
fi

# 清理可能残留的旧守护进程（防止重复实例）
if [ -f "$MODDIR/.daemon.pid" ]; then
    OLD_PID=$(cat "$MODDIR/.daemon.pid" 2>/dev/null | tr -d ' ')
    if [ -n "$OLD_PID" ]; then
        kill "$OLD_PID" 2>/dev/null
    fi
    rm -f "$MODDIR/.daemon.pid"
fi

# 启动常驻守护进程
setsid sh "$MODDIR/daemon.sh" >/dev/null 2>&1 &
