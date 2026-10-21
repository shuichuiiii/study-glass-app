import 'dart:ui';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_glass/flclash/liquid_glass.dart';

void main() => runApp(const StudyGlassApp());

class StudyGlassApp extends StatefulWidget {
  const StudyGlassApp({super.key});
  @override
  State<StudyGlassApp> createState() => _StudyGlassAppState();
}

class _StudyGlassAppState extends State<StudyGlassApp> {
  ThemeMode mode = ThemeMode.system;
  bool dynamicColor = true;
  bool motion = true;
  bool floatingBar = true;
  String glass = 'ultra';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      mode = ThemeMode.values[p.getInt('themeMode') ?? 0];
      dynamicColor = p.getBool('dynamicColor') ?? true;
      motion = p.getBool('motion') ?? true;
      floatingBar = p.getBool('floatingBar') ?? true;
      glass = p.getString('glassMode') ?? 'ultra';
    });
  }

  Future<void> _save(String key, Object value) async {
    final p = await SharedPreferences.getInstance();
    if (value is bool) await p.setBool(key, value);
    if (value is int) await p.setInt(key, value);
    if (value is String) await p.setString(key, value);
  }

  @override
  Widget build(BuildContext context) => DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          final light = lightDynamic ??
              ColorScheme.fromSeed(seedColor: const Color(0xFF7778C9));
          final dark = darkDynamic ??
              ColorScheme.fromSeed(
                seedColor: const Color(0xFFAAA9FF),
                brightness: Brightness.dark,
              );
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: '知学',
            theme: ThemeData(useMaterial3: true, colorScheme: dynamicColor ? light : ColorScheme.fromSeed(seedColor: const Color(0xFF7778C9))),
            darkTheme: ThemeData(useMaterial3: true, colorScheme: dynamicColor ? dark : ColorScheme.fromSeed(seedColor: const Color(0xFFAAA9FF), brightness: Brightness.dark)),
            themeMode: mode,
            home: StudyHome(
              mode: mode,
              dynamicColor: dynamicColor,
              motion: motion,
              floatingBar: floatingBar,
              glass: glass,
              onMode: (v) { setState(() => mode = v); _save('themeMode', v.index); },
              onDynamicColor: (v) { setState(() => dynamicColor = v); _save('dynamicColor', v); },
              onMotion: (v) { setState(() => motion = v); _save('motion', v); },
              onFloatingBar: (v) { setState(() => floatingBar = v); _save('floatingBar', v); },
              onGlass: (v) { setState(() => glass = v); _save('glassMode', v); }
            ),
          );
        },
      );
}

class StudyHome extends StatefulWidget {
  const StudyHome({super.key, required this.mode, required this.dynamicColor, required this.motion, required this.floatingBar, required this.glass, required this.onMode, required this.onDynamicColor, required this.onMotion, required this.onFloatingBar, required this.onGlass});
  final ThemeMode mode;
  final bool dynamicColor;
  final bool motion;
  final bool floatingBar;
  final String glass;
  final ValueChanged<ThemeMode> onMode;
  final ValueChanged<bool> onDynamicColor;
  final ValueChanged<bool> onMotion;
  final ValueChanged<bool> onFloatingBar;
  final ValueChanged<String> onGlass;

  @override
  State<StudyHome> createState() => _StudyHomeState();
}

class _StudyHomeState extends State<StudyHome> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const LearningPage(),
      const VocabularyPage(),
      SettingsPage(
        mode: widget.mode,
        dynamicColor: widget.dynamicColor,
        motion: widget.motion,
        floatingBar: widget.floatingBar,
        glass: widget.glass,
        onMode: widget.onMode,
        onDynamicColor: widget.onDynamicColor,
        onMotion: widget.onMotion,
        onFloatingBar: widget.onFloatingBar,
        onGlass: widget.onGlass,
      ),
    ];
    return Scaffold(
      body: LiquidGlassScope(
        enabled: widget.glass != 'off',
        quality: widget.glass == 'standard'
            ? LiquidGlassQuality.standard
            : LiquidGlassQuality.ultra,
        child: LiquidGlassHost(
          enabled: widget.glass != 'off',
          child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: widget.motion ? 300 : 0),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, .025), end: Offset.zero).animate(animation),
                  child: child,
                ),
              ),
              child: KeyedSubtree(key: ValueKey(tab), child: pages[tab]),
            ),
          ),
          Positioned(
            left: widget.floatingBar ? 16 : 0,
            right: widget.floatingBar ? 16 : 0,
            bottom: widget.floatingBar ? MediaQuery.paddingOf(context).bottom + 10 : 0,
            child: LiquidDock(
              index: tab,
              glass: widget.glass,
              floatingBar: widget.floatingBar,
              animate: widget.motion,
              onSelect: (i) => setState(() => tab = i),
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
}

class LearningPage extends StatelessWidget {
  const LearningPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 120),
        children: [
          Text('知学 · STUDY GLASS', style: theme.textTheme.labelLarge?.copyWith(color: cs.primary, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          Text('每天进步一点点', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('把今天学会的，变成明天的能力。', style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('今日学习进度'),
                  const SizedBox(height: 12),
                  Text('24 / 40', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(value: .6, minHeight: 8, borderRadius: BorderRadius.all(Radius.circular(8))),
                  const SizedBox(height: 8),
                  Text('已完成 60% · 继续保持', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.auto_stories_rounded, color: cs.primary),
              title: const Text('继续上次学习'),
              subtitle: const Text('高频英语词汇 · 还剩 16 个单词'),
              trailing: const Icon(Icons.arrow_forward_rounded),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('学习卡片功能将在后续版本完善。'))),
            ),
          ),
          const SizedBox(height: 20),
          Text('今日计划', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Card(
            child: Column(
              children: [
                ListTile(leading: Icon(Icons.refresh_rounded), title: Text('复习已学单词'), trailing: Text('15 个')),
                Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(leading: Icon(Icons.flag_outlined), title: Text('学习新词'), trailing: Text('25 个')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VocabularyPage extends StatefulWidget {
  const VocabularyPage({super.key});
  @override
  State<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends State<VocabularyPage> {
  final controller = TextEditingController();
  final Set<String> saved = <String>{};
  final words = const <({String word, String meaning, String part})>[
    (word: 'abandon', meaning: '放弃；抛弃', part: '动词'),
    (word: 'benefit', meaning: '益处；受益', part: '名词 / 动词'),
    (word: 'curious', meaning: '好奇的', part: '形容词'),
    (word: 'discover', meaning: '发现', part: '动词'),
    (word: 'essential', meaning: '必要的；本质的', part: '形容词'),
    (word: 'focus', meaning: '专注；焦点', part: '名词 / 动词'),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final query = controller.text.toLowerCase();
    final filtered = words.where((w) => '${w.word} ${w.meaning}'.toLowerCase().contains(query)).toList();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 120),
        children: [
          Text('我的词库', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('整理词汇，让每一次积累都有意义。', style: TextStyle(color: cs.onSurfaceVariant)),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '搜索单词或释义',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 18),
          Text('全部单词 · ${filtered.length} 条', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...filtered.map((w) => Card(
            child: ListTile(
              title: Text(w.word, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${w.meaning} · ${w.part}'),
              trailing: IconButton(
                onPressed: () => setState(() { if (!saved.add(w.word)) saved.remove(w.word); }),
                icon: Icon(saved.contains(w.word) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: saved.contains(w.word) ? cs.primary : null),
              ),
              onTap: () => showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (ctx) => SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(w.word, style: Theme.of(ctx).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(w.meaning, style: Theme.of(ctx).textTheme.titleLarge),
                        const SizedBox(height: 6),
                        Text('词性：${w.part}'),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.mode, required this.dynamicColor, required this.motion, required this.floatingBar, required this.glass, required this.onMode, required this.onDynamicColor, required this.onMotion, required this.onFloatingBar, required this.onGlass});
  final ThemeMode mode;
  final bool dynamicColor;
  final bool motion;
  final bool floatingBar;
  final String glass;
  final ValueChanged<ThemeMode> onMode;
  final ValueChanged<bool> onDynamicColor;
  final ValueChanged<bool> onMotion;
  final ValueChanged<bool> onFloatingBar;
  final ValueChanged<String> onGlass;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 120),
        children: [
          Text('设置', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('按自己的习惯，调整学习空间。'),
          const SizedBox(height: 24),
          Text('外观主题', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(value: ThemeMode.system, groupValue: mode, onChanged: (v) { if (v != null) onMode(v); }, title: const Text('跟随系统'), secondary: const Icon(Icons.brightness_auto_rounded)),
                RadioListTile<ThemeMode>(value: ThemeMode.light, groupValue: mode, onChanged: (v) { if (v != null) onMode(v); }, title: const Text('浅色模式'), secondary: const Icon(Icons.light_mode_outlined)),
                RadioListTile<ThemeMode>(value: ThemeMode.dark, groupValue: mode, onChanged: (v) { if (v != null) onMode(v); }, title: const Text('深色模式'), secondary: const Icon(Icons.dark_mode_outlined)),
              ],
            ),
          ),
          Card(child: SwitchListTile(value: dynamicColor, onChanged: onDynamicColor, title: const Text('动态主题色'), subtitle: const Text('支持的 Android 设备可使用系统配色'), secondary: const Icon(Icons.color_lens_outlined))),
          const SizedBox(height: 20),
          Text('导航栏样式', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<bool>(value: true, groupValue: floatingBar, onChanged: (v) { if (v != null) onFloatingBar(v); }, title: const Text('悬浮'), subtitle: const Text('圆角底栏与页面保持间距')),
                RadioListTile<bool>(value: false, groupValue: floatingBar, onChanged: (v) { if (v != null) onFloatingBar(v); }, title: const Text('贴底'), subtitle: const Text('底栏贴合屏幕底部')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('液态玻璃', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(value: 'off', groupValue: glass, onChanged: (v) { if (v != null) onGlass(v); }, title: const Text('关闭')),
                RadioListTile<String>(value: 'standard', groupValue: glass, onChanged: (v) { if (v != null) onGlass(v); }, title: const Text('标准')),
                RadioListTile<String>(value: 'ultra', groupValue: glass, onChanged: (v) { if (v != null) onGlass(v); }, title: const Text('极致'), subtitle: const Text('加强背景透射、镜面高光、边缘反光与液态切换')),
                SwitchListTile(value: motion, onChanged: onMotion, title: const Text('页面过渡动画')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const ListTile(leading: Icon(Icons.auto_stories_rounded), title: Text('知学 · Study Glass'), subtitle: Text('学习应用原型 · 0.1.0')),
        ],
      ),
    );
  }
}

class LiquidDock extends StatefulWidget {
  const LiquidDock({super.key, required this.index, required this.glass, required this.floatingBar, required this.animate, required this.onSelect});
  final int index;
  final String glass;
  final bool floatingBar;
  final bool animate;
  final ValueChanged<int> onSelect;

  static const items = <({IconData icon, IconData selected, String label})>[
    (icon: Icons.auto_stories_outlined, selected: Icons.auto_stories_rounded, label: '学习'),
    (icon: Icons.library_books_outlined, selected: Icons.library_books_rounded, label: '词库'),
    (icon: Icons.tune_rounded, selected: Icons.tune_rounded, label: '设置'),
  ];

  @override
  State<LiquidDock> createState() => _LiquidDockState();
}

class _LiquidDockState extends State<LiquidDock> with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    reverseDuration: const Duration(milliseconds: 360),
    lowerBound: 0,
    upperBound: 1,
  );
  double? _dragX;
  int? _hoverIndex;

  int _indexAt(double dx, double width) {
    return (dx / width).floor().clamp(0, LiquidDock.items.length - 1);
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final disabled = widget.glass == 'off';
    final floating = widget.floatingBar;
    final barHeight = floating ? 68.0 : 66.0;
    final radius = floating ? 34.0 : 0.0;
    final outerShadows = floating
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? .24 : .12),
              blurRadius: 22,
              spreadRadius: -2,
              offset: const Offset(0, 7),
            ),
          ]
        : const <BoxShadow>[];

    final content = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth / LiquidDock.items.length;
        final previewIndex = _dragX == null ? widget.index : (_hoverIndex ?? widget.index);
        // While dragging, the glass lens follows the finger continuously.
        // The tab preview may change at boundaries, but the lens must not snap
        // onto each tab; only release commits the page selection.
        final lensLeft = _dragX == null
            ? widget.index * width + 4
            : (_dragX! - (width - 8) / 2).clamp(4.0, constraints.maxWidth - width + 4);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (details) {
            _dragX = details.localPosition.dx;
            _hoverIndex = _indexAt(_dragX!, width);
            if (widget.animate) _press.forward();
            setState(() {});
          },
          onHorizontalDragUpdate: (details) {
            // Use the current pointer position in this detector's local
            // coordinate space. Do not accumulate delta: the lens and hit
            // targets must share the same coordinate system.
            _dragX = details.localPosition.dx.clamp(0.0, constraints.maxWidth);
            final nextHover = _indexAt(_dragX!, width);
            if (nextHover != _hoverIndex) {
              _hoverIndex = nextHover;
              setState(() {});
            }
          },
          onHorizontalDragEnd: (_) {
            final destination = _hoverIndex;
            _dragX = null;
            _hoverIndex = null;
            _press.reverse();
            setState(() {});
            // Match FlClash: keep the current page while dragging; commit only
            // after the finger is released over a destination.
            if (destination != null && destination != widget.index) {
              widget.onSelect(destination);
            }
          },
          onHorizontalDragCancel: () {
            _dragX = null;
            _hoverIndex = null;
            _press.reverse();
            setState(() {});
          },
          child: AnimatedBuilder(
            animation: _press,
            builder: (context, child) {
              return Stack(
                fit: StackFit.expand,
                children: [
                    AnimatedPositioned(
                      duration: Duration(milliseconds: !widget.animate ? 0 : (_dragX == null ? 380 : 0)),
                      curve: Curves.easeOutCubic,
                      left: lensLeft,
                      top: 4 - _press.value * 2,
                      bottom: 4 - _press.value * 2,
                      width: width - 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: disabled
                            ? DecoratedBox(
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              )
                            : LiquidGlass(
                                style: LiquidGlassStyle.lens(
                                  mui.ColorScheme.fromSeed(
                                    seedColor: cs.primary,
                                    brightness: cs.brightness,
                                  ),
                                ),
                                shadows: [
                                  BoxShadow(
                                    color: cs.primary.withValues(alpha: dark ? .24 : .16),
                                    blurRadius: 14 + _press.value * 8,
                                    spreadRadius: _press.value * 1.2,
                                    offset: Offset(0, 2 + _press.value * 2),
                                  ),
                                ],
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withValues(alpha: dark ? .22 : .42),
                                            Colors.white.withValues(alpha: dark ? .06 : .14),
                                            cs.primary.withValues(alpha: dark ? .09 : .035),
                                            Colors.black.withValues(alpha: dark ? .16 : .055),
                                          ],
                                          stops: const [0, .22, .72, 1],
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: dark ? .30 : .62),
                                          width: 0.8,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 10,
                                      right: 10,
                                      top: 1.2,
                                      height: 1.4,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withValues(alpha: 0),
                                              Colors.white.withValues(alpha: dark ? .72 : .94),
                                              Colors.white.withValues(alpha: 0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 8,
                                      right: 8,
                                      bottom: 1,
                                      height: 2,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.black.withValues(alpha: 0),
                                              Colors.black.withValues(alpha: dark ? .28 : .10),
                                              Colors.black.withValues(alpha: 0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    Row(
                      children: List.generate(LiquidDock.items.length, (i) {
                        final selected = previewIndex == i;
                        final activeColor = disabled
                            ? cs.onPrimary
                            : (dark ? const Color(0xFFF4F6FF) : const Color(0xFF1769D2));
                        final idleColor = dark
                            ? const Color(0xFFD0D1DB)
                            : const Color(0xFF555D70);
                        return Expanded(
                          child: Semantics(
                            button: true,
                            selected: selected,
                            label: LiquidDock.items[i].label,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (widget.animate) {
                                  _press.forward().then((_) {
                                    if (mounted) _press.reverse();
                                  });
                                }
                                widget.onSelect(i);
                              },
                              child: SizedBox(
                                height: barHeight,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedScale(
                                      scale: selected ? 1.08 : .96,
                                      duration: Duration(milliseconds: widget.animate ? 260 : 0),
                                      curve: Curves.easeOutBack,
                                      child: Icon(
                                        selected ? LiquidDock.items[i].selected : LiquidDock.items[i].icon,
                                        size: selected ? 28 : 26,
                                        color: selected ? activeColor : idleColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    AnimatedDefaultTextStyle(
                                      duration: Duration(milliseconds: widget.animate ? 180 : 0),
                                      style: TextStyle(
                                        fontSize: selected ? 10.5 : 10,
                                        height: 1.2,
                                        letterSpacing: .1,
                                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                        color: selected ? activeColor : idleColor,
                                      ),
                                      child: Text(LiquidDock.items[i].label, maxLines: 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                ],
              );
            },
          ),
        );
      },
    );

    if (disabled) {
      return AnimatedBuilder(
        animation: _press,
        builder: (context, child) => Transform.scale(
          // Restore the whole dock's subtle press/lift response. Flutter's
          // transformed hit testing keeps pointer coordinates aligned.
          scale: 1 + _press.value * 0.025,
          alignment: Alignment.bottomCenter,
          child: child,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: .5)),
              boxShadow: outerShadows,
            ),
            child: content,
          ),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _press,
      builder: (context, child) => Transform.scale(
        // Keep the overall dock animation without changing the gesture's
        // local coordinate system.
        scale: 1 + _press.value * 0.025,
        alignment: Alignment.bottomCenter,
        child: child,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: LiquidGlass(
          style: LiquidGlassStyle.pill(
            mui.ColorScheme.fromSeed(seedColor: cs.primary, brightness: cs.brightness),
          ),
          shadows: outerShadows,
          child: SizedBox(height: barHeight, child: content),
        ),
      ),
    );
  }
}
