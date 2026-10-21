# 知学 Study Glass

Flutter Android 学习软件首版原型：学习、词库、设置三个 Tab，悬浮液态玻璃风格导航、动态主题、深浅色模式与本地保存设置。

## 构建调试 APK
GitHub Actions 会在推送代码或手动运行时构建 Android debug APK。进入仓库的 **Actions**，选择 **Build Android debug APK**，运行成功后在 Artifacts 下载 `study-glass-debug-apk`。

## 当前范围
- 三个主 Tab：学习、词库、设置
- Material 3 与 Android 动态颜色
- 深色、浅色、跟随系统；设置使用 SharedPreferences 保存
- 半透明模糊导航底座与动画选中镜片
- 词库搜索、示例词条、收藏状态（收藏目前仅保存在当前页面内存）
- 学习首页为演示数据，完整学习记录持久化尚未实现

## 构建说明
此项目独立实现相似的设计语言，没有直接复制 FlClash 源码。液态玻璃采用 Flutter BackdropFilter 和 AnimatedPositioned 实现基础模糊与选中镜片动画；尚未实现真实物理液体形变。首次构建时工作流会生成 Android 平台目录。
