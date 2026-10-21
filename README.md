# Auto Net Keeper

适用于 KernelSU / APatch / Magisk 的自动网络保持器模块。

## 功能特性
- **周期开启**：后台每 3 分钟自动开启系统 WiFi 与移动数据流量。
- **热开关支持**：无需重启手机，在 KernelSU 管理器中开启/关闭模块即可秒级热启停后台循环。
- **卸载自愈**：卸载模块后守护进程自动退出，不残留无用后台与垃圾文件。
- **日志保护**：自带日志轮转机制，控制在 50KB 以内，不挤占存储空间。

## 运作原理
- **网络控制**：底层调用 `svc wifi enable` / `cmd wifi set-wifi-enabled enabled` 与 `svc data enable` 启用网络。
- **热开关监听**：以 5 秒轻量步长轮询监听 `/data/adb/modules/auto_net_keeper/disable` 状态。当检测到 `disable` 文件存在时进入挂起休眠；一旦重新开启立刻热恢复。

## 安装方式
1. 在 Releases 中下载 `auto-net-keeper-v1.0.zip`。
2. 打开 KernelSU / APatch / Magisk 管理器。
3. 进入「模块」页面，选择从本地安装。
4. 按音量上键确认安装，安装完成后重启手机生效。

## 维护者
- 作者: life
