#!/system/bin/sh
# ============================================================
# 自动网络保持器 - 核心守护进程
# 作者: life
# 功能: 每3分钟自动启用 WiFi 与数据流量，监听 KSU 状态实现热开关
# ============================================================

MODDIR=${0%/*}
case "$MODDIR" in
    /*) : ;;
    *) MODDIR="/data/adb/modules/auto_net_keeper" ;;
esac

LOG="$MODDIR/daemon.log"
PID_FILE="$MODDIR/.daemon.pid"

# 日志写入与大小轮转（限制50KB以内，防止挤占存储）
log() {
    if [ -f "$LOG" ]; then
        SIZE=$(wc -c < "$LOG" 2>/dev/null | tr -d ' ')
        if [ -n "$SIZE" ] && [ "$SIZE" -gt 51200 ] 2>/dev/null; then
            tail -n 50 "$LOG" > "$LOG.tmp" 2>/dev/null
            mv "$LOG.tmp" "$LOG" 2>/dev/null
        fi
    fi
    echo "[$(date '+%m-%d %H:%M:%S')] $1" >> "$LOG" 2>/dev/null
}

# 进程退出清理
cleanup() {
    rm -f "$PID_FILE"
    exit 0
}
trap cleanup EXIT TERM INT HUP

echo $$ > "$PID_FILE"
log "守护进程启动 (PID: $$)"

# 执行开启网络动作
trigger_network_enable() {
    # 启用 WiFi（双指令保证全版本兼容）
    svc wifi enable
    cmd wifi set-wifi-enabled enabled >/dev/null 2>&1
    # 启用移动数据流量
    svc data enable
    log "已触发自动开启 WiFi 与移动数据"
}

# 5秒探测心跳，36次心跳即180秒（3分钟）
INTERVAL_STEP=5
TARGET_SECONDS=180
ELAPSED=0
LAST_STATE="unknown"

# 首次启动：如果不处于禁用状态，则立即触发一次
if [ ! -f "$MODDIR/disable" ]; then
    trigger_network_enable
    LAST_STATE="enabled"
fi

while true; do
    # 1. 模块被卸载或删除时自愈退出
    if [ ! -f "$MODDIR/module.prop" ] || [ -f "$MODDIR/remove" ] || [ -f "$MODDIR/.remove" ]; then
        log "检测到模块被卸载，退出守护进程"
        cleanup
    fi

    # 2. 检查 KSU 模块禁用标记（disable 文件）
    if [ -f "$MODDIR/disable" ]; then
        if [ "$LAST_STATE" != "disabled" ]; then
            log "模块在 KSU 中被关闭，挂起热等待"
            LAST_STATE="disabled"
        fi
        ELAPSED=0
        sleep $INTERVAL_STEP
        continue
    fi

    # 3. 从禁用切回启用状态时秒级响应
    if [ "$LAST_STATE" = "disabled" ]; then
        log "模块在 KSU 中重新开启，立即热恢复"
        LAST_STATE="enabled"
        trigger_network_enable
        ELAPSED=0
    fi

    # 4. 周期计时与触发
    sleep $INTERVAL_STEP
    ELAPSED=$((ELAPSED + INTERVAL_STEP))

    if [ "$ELAPSED" -ge "$TARGET_SECONDS" ]; then
        trigger_network_enable
        ELAPSED=0
    fi
done
