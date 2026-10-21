# Cursor-Type

一套风格统一的 Windows 鼠标指针主题：**Kimi 小箭头（青碧色）** 主光标 + **[Bibata Modern Classic](https://github.com/ful1e5/Bibata_Cursor)** 全套配套光标，一键安装、立即生效、无需管理员权限。

![overview](docs/previews/overview.png)

## 光标形态一览

普通箭头采用 KimiCU 同款箭头（当前为青碧色 `#14B8A6`，白色描边保留），其余角色使用 Bibata Modern Classic—— 同为深色填充 + 白色描边的圆角设计语言。

| 形态 | 预览 | 场景 |
|------|------|------|
| Normal（箭头） | ![arrow](docs/previews/arrow-teal.png) | 常规指针 |
| Busy（忙碌） | ![busy](docs/previews/busy.png) | 程序无响应/加载中 |
| Working（后台忙碌） | ![work](docs/previews/work.png) | 后台任务进行中 |
| Link（手型） | ![hand](docs/previews/hand.png) | 悬停链接 |
| Text（I 型） | ![text](docs/previews/text.png) | 文本输入 |
| Crosshair（十字） | ![crosshair](docs/previews/crosshair.png) | 精确选择 |
| Help（帮助） | ![help](docs/previews/help.png) | 帮助选择 |
| Unavailable（禁止） | ![unavailable](docs/previews/unavailable.png) | 不可放置/不可用 |
| Move（移动） | ![move](docs/previews/move.png) | 移动对象 |
| 缩放（四方向） | ![nwse](docs/previews/resize-nwse.png) | 调整窗口/对象大小 |
| Pin / Person | ![pin](docs/previews/pin.png) | Windows 位置/联系人角色 |

> 箭头共收录 3 个颜色版本：青碧（当前默认 `kimi_arrow_teal.cur`）、黑色（`kimi_arrow_black.cur`）、蓝色（`kimi_arrow.cur`），可随时切换。

## 安装

克隆本仓库后，在仓库目录运行（普通用户权限即可）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

脚本会：

1. 把光标文件复制到 `%USERPROFILE%\Cursors`
2. 写入 `HKCU\Control Panel\Cursors` 的全部 17 个角色
3. 调用 `SystemParametersInfo(SPI_SETCURSORS)` 让新光标**立即生效**，无需重启

## 卸载 / 还原

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\uninstall.ps1
```

或在 **设置 → 蓝牙和设备 → 鼠标 → 其他鼠标设置 → 指针** 中把方案改回系统方案。光标文件会保留在 `%USERPROFILE%\Cursors`，可手动删除。

## 自定义

| 需求 | 做法 |
|------|------|
| 换回黑色箭头 | 把 `install.ps1` 中 `Arrow` 映射改为 `kimi_arrow_black.cur`，重新运行 |
| 换回蓝色箭头 | 把 `Arrow` 改为 `kimi_arrow.cur`，重新运行 |
| 完全统一为 Bibata | 把 `Arrow` 改为 `bibata\Pointer.cur` |
| 调整指针大小 | 设置 → 辅助功能 → 鼠标指针和触控 → 大小 |

## 目录结构

```
cursors/
├── kimi_arrow_black.cur   # 主光标：Kimi 箭头（黑色）
├── kimi_arrow.cur         # 主光标备用：Kimi 箭头（蓝色）
└── bibata/                # Bibata Modern Classic Regular 全套（.cur + .ani）
docs/previews/             # README 预览图（由 make_previews.py 生成）
install.ps1                # 一键安装
uninstall.ps1              # 还原默认
make_previews.py           # 从 .cur/.ani 提取预览图
```

## 版本

当前版本：**v1.1.5**（见 [CHANGELOG](CHANGELOG.md) 与 Releases）

## 致谢与许可

- 配套光标来自 [Bibata_Cursor](https://github.com/ful1e5/Bibata_Cursor)（GPL-3.0），感谢作者 [@ful1e5](https://github.com/ful1e5)
- Kimi 箭头提取自 KimiCU 的本地资源，仅作个人桌面美化用途
- 本仓库整体以 [GPL-3.0](LICENSE) 发布
