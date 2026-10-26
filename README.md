# Auto Net Keeper

一个简单的 Magisk / KernelSU / APatch 模块。主要用来防止手机息屏或后台休眠时断网，每 3 分钟自动补开一次 WiFi 和移动数据。

## 功能

- 每 3 分钟自动开一次 WiFi 和移动数据（底层调用 `svc wifi enable` / `svc data enable`）。
- 支持在管理器里随开随关，关掉模块后台脚本就暂停，不需要重启手机。
- 日志限制在 50KB 以内，不会无限写入占空间。
- 卸载模块后后台进程自动退出，不留残留。

## 安装

1. 在 Releases 下载打包好的 zip 模块。
2. 打开 KernelSU / APatch / Magisk 管理器选择本地安装。
3. 按音量键确认，刷完重启手机即可。

## 作者

- life
