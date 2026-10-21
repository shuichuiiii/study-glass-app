# 知学 Study Glass

Flutter Android 学习软件原型：学习、词库、设置三个 Tab，悬浮玻璃风格导航、动态主题、深浅色模式与本地保存设置。

## 构建调试 APK

GitHub Actions 会在推送代码或手动运行时构建 Android debug APK。进入仓库的 **Actions**，选择 **Build Android debug APK**，运行成功后在 Artifacts 下载 `study-glass-debug-apk`。

## 当前范围

- 三个主 Tab：学习、词库、设置
- Material 3 与 Android 动态颜色
- 深色、浅色、跟随系统；设置使用 SharedPreferences 保存
- 紧凑悬浮导航底栏，分离外层玻璃面板与选中态高光胶囊
- 词库搜索、示例词条、收藏状态（收藏目前仅保存在当前页面内存）
- 学习首页为演示数据，完整学习记录持久化尚未实现

## 许可证

本项目采用 **GNU General Public License v3.0（GPL-3.0）**，详见仓库根目录的 `LICENSE`。

## FlClash 设计参考与第三方声明

底栏的视觉目标参考 [FlClash](https://github.com/chen08209/FlClash) 的悬浮导航与 Liquid Glass 设计。FlClash 由其上游作者维护，并采用 GPL-3.0。此版本的底栏是为本应用重新编写的 Flutter 实现；没有直接复制 FlClash 的 `navigation_dock.dart`、`liquid_glass.dart` 或着色器文件，也尚未移植其完整的自定义折射着色器管线。外观上的玻璃高光、边缘、半透明面板和弹性选中切换为本项目实现。

FlClash 上游仓库及许可证：
- 源码：https://github.com/chen08209/FlClash
- 许可证：https://github.com/chen08209/FlClash/blob/main/LICENSE

本项目采用 GPL-3.0 不代表 FlClash 上游作者为本项目背书。第三方组件仍受各自许可证约束。
