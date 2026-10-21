# Changelog

本项目遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。

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

[1.1.4]: https://github.com/JerommeWEI/Cursor-Type/releases/tag/v1.1.4
[1.1.3]: https://github.com/JerommeWEI/Cursor-Type/releases/tag/v1.1.3
[1.1.2]: https://github.com/JerommeWEI/Cursor-Type/releases/tag/v1.1.2
[1.1.1]: https://github.com/JerommeWEI/Cursor-Type/releases/tag/v1.1.1
[1.1.0]: https://github.com/JerommeWEI/Cursor-Type/releases/tag/v1.1.0
[1.0.0]: https://github.com/JerommeWEI/Cursor-Type/releases/tag/v1.0.0
