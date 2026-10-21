import 'dart:ui';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      body: Stack(
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

class LiquidDock extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final disabled = glass == 'off';
    final ultra = glass == 'ultra';
    final blur = ultra ? 18.0 : 12.0;
    final radius = floatingBar ? 34.0 : 0.0;
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(radius), bottom: Radius.circular(radius)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: disabled ? 0 : blur, sigmaY: disabled ? 0 : blur),
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            color: disabled ? cs.surfaceContainerHigh : cs.surface.withValues(alpha: ultra ? (dark ? .76 : .86) : (dark ? .80 : .90)),
            borderRadius: BorderRadius.vertical(top: Radius.circular(radius), bottom: Radius.circular(radius)),
            border: Border.all(color: cs.onSurface.withValues(alpha: ultra ? .16 : .12), width: 1.1),
            boxShadow: floatingBar ? [
              BoxShadow(color: Colors.black.withValues(alpha: dark ? .12 : .06), blurRadius: ultra ? 22 : 18, offset: const Offset(0, 6)),
            ] : const [],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth / 3;
              return Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedPositioned(
                    duration: Duration(milliseconds: animate ? 420 : 0),
                    curve: Curves.easeOutBack,
                    left: index * width + 6,
                    top: 5,
                    bottom: 5,
                    width: width - 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: disabled ? cs.primary : cs.primary.withValues(alpha: dark ? .28 : .12),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: cs.primary.withValues(alpha: dark ? .12 : .04)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(items.length, (i) => Expanded(
                      child: Semantics(
                        button: true,
                        selected: index == i,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: () => onSelect(i),
                          child: SizedBox(
                            height: 88,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  scale: index == i ? 1.08 : 1,
                                  duration: Duration(milliseconds: animate ? 220 : 0),
                                  child: Icon(index == i ? items[i].selected : items[i].icon, size: 34, color: index == i ? (disabled ? cs.onPrimary : (dark ? Colors.white : cs.primary)) : cs.onSurfaceVariant),
                                ),
                                const SizedBox(height: 6),
                                Text(items[i].label, style: TextStyle(fontSize: 17, fontWeight: index == i ? FontWeight.w600 : FontWeight.w500, color: index == i ? (disabled ? cs.onPrimary : (dark ? Colors.white : cs.primary)) : cs.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
