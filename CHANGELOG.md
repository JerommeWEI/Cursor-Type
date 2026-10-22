# Changelog

本项目遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。

## [2.2.0] - 2026-10-22

### 修复

- **根因修复：辅助功能"鼠标指针大小"滑块顶掉主题**。拖滑块时 Windows 会用内置 aero 源重建 `%LocalAppData%\Microsoft\Windows\Cursors\*_eoa.cur`（17 个，内容与滑块值无关）并把方案重定向过去。现在：`cursors/eoa/` 内置主题版 eoa 光标（矢量渲染箭头 + Bibata 角色 + 动画代表帧，48–192 五档），安装时覆盖既有 eoa 文件；新增登录自启守护任务 `CursorType-EoaWatch`（`watch-eoa.ps1`），监听 eoa 目录并每 3 秒自检注册表，滑块重建后数秒内自动恢复主题，滑块调大小功能不受影响

### 新增

- `make_eoa.py`：从仓库光标源烘焙 17 个主题版 `*_eoa.cur`
- `watch-eoa.ps1`：EoA 守护进程（eoa 文件监听 + 方案自检自愈）
- `install.ps1`：自动安装 eoa payload、覆盖既有 eoa 文件、注册并启动守护任务
- `uninstall.ps1` / `uninstall-autostart.ps1`：卸载时清理守护任务
- 全部 ps1 脚本补 UTF-8 BOM，中文输出不再乱码

## [2.1.0] - 2026-10-21

### 新增

- `install-autostart.ps1` / `uninstall-autostart.ps1`：登录时自动重应用主题的计划任务，防止系统更新/主题同步重置光标配置
- README 补充覆盖范围说明（系统方案光标 vs 应用自带光标）

## [2.0.0] - 2026-10-21

首个正式版（Official Release）。整套光标全部来自矢量渲染：

- 主箭头：Kimi 箭头矢量描摹源（`kimi_arrow.svg`）+ resvg 渲染，青碧 `#14B8A6` 默认，黑 / 蓝备选
- 配套光标：Bibata Modern Classic 全套染为青碧色，彩色徽章保留原色
- 忙碌 / 后台忙碌动画：从官方 SVG 帧改色后逐帧矢量渲染，54 帧、帧率、热点与官方一致
- 一键安装 / 还原脚本，免管理员权限，立即生效

## [1.3.0] - 2026-10-21

### 变更

- 主箭头改为**矢量描摹重建**（vtracer 描摹 + resvg 渲染），青/黑两色版均从矢量源生成，各尺寸边缘完美抗锯齿
- 矢量源文件收录于 `cursors/kimi_arrow.svg`

## [1.2.0] - 2026-10-21

### 变更

- 忙碌 / 后台忙碌动画改为**矢量管线**：从 Bibata 官方 SVG 源文件改色（占位符替换），用 resvg 按 14 个尺寸逐帧重新渲染，矢量级抗锯齿
- 动画帧热点（hotspot）与原动画参数（54 帧、帧率）保持与官方一致

## [1.1.5] - 2026-10-21

### 变更

- 忙碌 / 后台忙碌动画：色彩提亮（亮度 +14%、饱和度 +10%）
- 每帧增加 4 倍超采样抗锯齿处理，边缘更柔和

## [1.1.4] - 2026-10-21

### 修正

- 忙碌 / 后台忙碌动画改为软过渡混色：按饱和度与亮度连续加权，消除青色圆环与彩色扇区之间的生硬暗边

## [1.1.3] - 2026-10-21

### 修正

- 三个主箭头（青/黑/蓝）从 Kimi 原始资源用平滑渐变算法重建，消除边缘灰色过渡带；青色箭头填充保留轻微明暗渐变

## [1.1.2] - 2026-10-21

### 修正

- 换色算法改为按亮度在青色与白色间平滑渐变，消除青色填充与白色描边之间的灰色过渡带（锯齿感）
- 附带效果：No / Pin / Person 等光标的彩色徽章恢复原版颜色

## [1.1.1] - 2026-10-21

### 修正

- 忙碌（Busy）/ 后台忙碌（Working）动画：彩色旋转扇区恢复为原版彩色，仅黑色部分（外圈、箭头）染为青碧色

## [1.1.0] - 2026-10-21

### 变更

- 主光标颜色：黑色 → 青碧色 `#14B8A6`（`kimi_arrow_teal.cur`）
- 全套 Bibata 配套光标（14 个 .cur + 2 个 .ani 全部帧）同步染为青碧色，白色描边保留，忙碌/后台忙碌动画明暗对比保留
- README 预览图全部更新为青色版本

## [1.0.0] - 2026-10-20

### 新增

- 主光标：KimiCU 同款箭头（黑色版 `kimi_arrow_black.cur`，蓝色原版 `kimi_arrow.cur` 备用），多分辨率 32~256px
- 配套光标：Bibata Modern Classic v2.0.7 全套 17 个角色（含 Busy / Working 动画）
- `install.ps1` 一键安装：复制到 `%USERPROFILE%\Cursors` + 写入注册表 + 立即生效，无需管理员权限
- `uninstall.ps1` 一键还原 Windows 默认方案
- README 光标形态预览图（`make_previews.py` 自动生成）

[2.1.0]: https://github.com/JerommeWEI/Cursor-Type/releases/tag/v2.1.0
[2.0.0]: https://github.com/JerommeWEI/Cursor-Type/releases/tag/v2.0.0
[1.3.0]: https://github.com/JerommeWEI/Cursor-Type/releases/tag/v1.3.0
[1.2.0]: https://github.com/JerommeWEI/Cursor-Type/releases/tag/v1.2.0
[1.1.5]: https://github.com/JerommeWEI/Cursor-Type/releases/tag/v1.1.5
[1.1.4]: https://github.com/JerommeWEI/Cursor-Type/releases/tag/v1.1.4
[1.1.3]: https://github.com/JerommeWEI/Cursor-Type/releases/tag/v1.1.3
[1.1.2]: https://github.com/JerommeWEI/Cursor-Type/releases/tag/v1.1.2
[1.1.1]: https://github.com/JerommeWEI/Cursor-Type/releases/tag/v1.1.1
[1.1.0]: https://github.com/JerommeWEI/Cursor-Type/releases/tag/v1.1.0
[1.0.0]: https://github.com/JerommeWEI/Cursor-Type/releases/tag/v1.0.0
