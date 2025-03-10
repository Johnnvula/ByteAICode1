

import 'dart:async';

import 'package:byte_ai_code/editorcode/console.dart';
import 'package:byte_ai_code/editorcode/docs.dart';
import 'package:byte_ai_code/editorcode/editor/editor.dart';
import 'package:byte_ai_code/editorcode/embed.dart';
import 'package:byte_ai_code/editorcode/execution/execution.dart';
import 'package:byte_ai_code/editorcode/extensions.dart';
import 'package:byte_ai_code/editorcode/keys.dart';
import 'package:byte_ai_code/editorcode/keys.dart' as keys;
import 'package:byte_ai_code/editorcode/local_storage.dart';
import 'package:byte_ai_code/editorcode/model.dart';
import 'package:byte_ai_code/editorcode/problems.dart';
import 'package:byte_ai_code/editorcode/samples.g.dart';
import 'package:byte_ai_code/editorcode/theme.dart';
import 'package:byte_ai_code/editorcode/versions.dart';
import 'package:byte_ai_code/editorcode/widgets.dart';
import 'package:byte_ai_code/service/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart' show usePathUrlStrategy;
import 'package:flutter/services.dart' ;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:split_view/split_view.dart';
import 'package:vtable/vtable.dart';
import 'dart:ui' as ui;
const appName = 'Byte AI Code';
const smallScreenWidth = 720;


void main() {
  //  Certifique-se de inicializar o binding ANTES de qualquer outra coisa
 // WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy(); // Isso pode vir depois da inicialização

  // Agora, defina as configurações do Google Fonts
  GoogleFonts.config.allowRuntimeFetching = false;

  //  Adicione um listener para evitar a perda de mensagens do canal
   WidgetsFlutterBinding.ensureInitialized();

  //  Adiciona um listener para evitar descarte de mensagens
  ServicesBinding.instance.channelBuffers.setListener(
    'flutter/lifecycle',
    (ByteData? data, PlatformMessageResponseCallback? callback) {
      callback?.call(data); // Encaminha os dados corretamente
    },
  );

  runApp(const DartPadApp());
}








class DartPadApp extends StatefulWidget {
  const DartPadApp({
    super.key,
  });

  @override
  State<DartPadApp> createState() => _DartPadAppState();
}

class _DartPadAppState extends State<DartPadApp> {
  
  late final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: _homePageBuilder,
      ),
      GoRoute(
        path: '/:gistId',
        builder: (context, state) => _homePageBuilder(context, state,
            gist: state.pathParameters['gistId']),
      ),
    ],
  );

  ThemeMode themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();

    router.routeInformationProvider.addListener(_setTheme);
    _setTheme();
   
  }

  @override
  void dispose() {
    router.routeInformationProvider.removeListener(_setTheme);

    super.dispose();
  }

  // Changes the `themeMode` from the system default to either light or dark.
  // Also changes the `theme` query parameter in the URL.
  void handleBrightnessChanged(BuildContext context, bool isLightMode) {
    if (isLightMode) {
      GoRouter.of(context).replaceQueryParam('theme', 'light');
    } else {
      GoRouter.of(context).replaceQueryParam('theme', 'dark');
    }
    _setTheme();
  }

  void _setTheme() {
    final params = router.routeInformationProvider.value.uri.queryParameters;
    final themeParam = params.containsKey('theme') ? params['theme'] : null;

    setState(() {
      switch (themeParam) {
        case 'dark':
          setState(() {
            themeMode = ThemeMode.dark;
          });
        case 'light':
          setState(() {
            themeMode = ThemeMode.light;
          });
        case _:
          setState(() {
            themeMode = ThemeMode.dark;
          });
      }
    });
  }

  Widget _homePageBuilder(BuildContext context, GoRouterState state,
      {String? gist}) {
    final gistId = gist ?? state.uri.queryParameters['id'];
    final builtinSampleId = state.uri.queryParameters['sample'];
    final flutterSampleId = state.uri.queryParameters['sample_id'];
    final channelParam = state.uri.queryParameters['channel'];
    final embedMode = state.uri.queryParameters['embed'] == 'true';
    final runOnLoad = state.uri.queryParameters['run'] == 'true';

    return DartPadMainPage(
      initialChannel: channelParam,
      embedMode: embedMode,
      runOnLoad: runOnLoad,
      gistId: gistId,
      builtinSampleId: builtinSampleId,
      flutterSampleId: flutterSampleId,
      handleBrightnessChanged: handleBrightnessChanged,
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: appName,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: lightPrimaryColor,
          surface: lightSurfaceColor,
          onSurface: Colors.black,
          surfaceContainerHighest: lightSurfaceVariantColor,
          onPrimary: lightLinkButtonColor,
        ),
        brightness: Brightness.light,
        dividerColor: lightDividerColor,
        dividerTheme: const DividerThemeData(
          color: lightDividerColor,
        ),
        scaffoldBackgroundColor: Colors.white,
        menuButtonTheme: MenuButtonThemeData(
          style: MenuItemButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkPrimaryColor,
          brightness: Brightness.dark,
          surface: darkSurfaceColor,
          onSurface: Colors.white,
          surfaceContainerHighest: darkSurfaceVariantColor,
          onSurfaceVariant: Colors.white,
          onPrimary: darkLinkButtonColor,
        ),
        brightness: Brightness.dark,
        dividerColor: darkDividerColor,
        dividerTheme: const DividerThemeData(
          color: darkDividerColor,
        ),
        textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(darkLinkButtonColor),
          ),
        ),
        scaffoldBackgroundColor: darkScaffoldColor,
        menuButtonTheme: MenuButtonThemeData(
          style: MenuItemButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
        ),
      ),
    );
  }
}

class DartPadMainPage extends StatefulWidget {
  final String? initialChannel;
  final bool embedMode;
  final bool runOnLoad;
  final void Function(BuildContext, bool) handleBrightnessChanged;
  final String? gistId;
  final String? builtinSampleId;
  final String? flutterSampleId;

  DartPadMainPage({
    required this.initialChannel,
    required this.embedMode,
    required this.runOnLoad,
    required this.handleBrightnessChanged,
    this.gistId,
    this.builtinSampleId,
    this.flutterSampleId,
  }) : super(
          key: ValueKey(
            'sample:$builtinSampleId gist:$gistId flutter:$flutterSampleId',
          ),
        );

  @override
  State<DartPadMainPage> createState() => _DartPadMainPageState();
}

class _DartPadMainPageState extends State<DartPadMainPage>
    with SingleTickerProviderStateMixin {
  late final AppModel appModel;
  late final AppServices appServices;
  late final SplitViewController mainSplitter;
  late final TabController tabController;

  final ValueKey<String> _executionWidgetKey =
      const ValueKey('execution-widget');
  final ValueKey<String> _loadingOverlayKey =
      const ValueKey('loading-overlay-widget');
  final ValueKey<String> _editorKey = const ValueKey('editor');
  final ValueKey<String> _consoleKey = const ValueKey('console');
  final ValueKey<String> _tabBarKey = const ValueKey('tab-bar');
  final ValueKey<String> _executionStackKey = const ValueKey('execution-stack');
  final ValueKey<String> _scaffoldKey = const ValueKey('scaffold');

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this)
      ..addListener(
        () {
          // Rebuild when the user changes tabs so that the IndexedStack updates
          // its active child view.
          setState(() {});
        },
      );

    final leftPanelSize = widget.embedMode ? 0.62 : 0.50;
    mainSplitter =
        SplitViewController(weights: [leftPanelSize, 1.0 - leftPanelSize])
          ..addListener(() {
            appModel.splitDragStateManager.handleSplitChanged();
          });

    final channel = widget.initialChannel != null
        ? Channel.forName(widget.initialChannel!)
        : null;

    appModel = AppModel();
    appServices = AppServices(
      appModel,
      channel ?? Channel.defaultChannel,
    );

    appServices.populateVersions();
    appServices
        .performInitialLoad(
      gistId: widget.gistId,
      sampleId: widget.builtinSampleId,
      flutterSampleId: widget.flutterSampleId,
      channel: widget.initialChannel,
      keybinding: LocalStorage.instance.getUserKeybinding(),
      getFallback: () =>
          LocalStorage.instance.getUserCode() ?? Samples.defaultSnippet(),
    )
        .then((value) {
      // Start listening for inject code messages.
      handleEmbedMessage(appServices, runOnInject: widget.runOnLoad);
      if (widget.runOnLoad) {
        appServices.performCompileAndRun();
      }
    });
    appModel.compilingBusy.addListener(_handleRunStarted);
  }

  @override
  void dispose() {
    appModel.compilingBusy.removeListener(_handleRunStarted);

    appServices.dispose();
    appModel.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final executionWidget = ExecutionWidget(
      appServices: appServices,
      appModel: appModel,
      key: _executionWidgetKey,
    );

    final loadingOverlay = LoadingOverlay(
      appModel: appModel,
      key: _loadingOverlayKey,
    );

    final editor = EditorWithButtons(
      appModel: appModel,
      appServices: appServices,
      onFormat: _handleFormatting,
      onCompileAndRun: appServices.performCompileAndRun,
      onCompileAndReload: appServices.performCompileAndReload,
      key: _editorKey,
    );

    final tabBar = TabBar(
      controller: tabController,
      tabs: const [
        Tab(text: 'Code'),
        Tab(text: 'Output'),
      ],
      // Remove the divider line at the bottom of the tab bar.
      dividerHeight: 0,
      key: _tabBarKey,
    );

    final executionStack = Stack(
      key: _executionStackKey,
      children: [
        ValueListenableBuilder(
          valueListenable: appModel.layoutMode,
          builder: (context, LayoutMode mode, _) {
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final domHeight = mode.calcDomHeight(constraints.maxHeight);
                final consoleHeight =
                    mode.calcConsoleHeight(constraints.maxHeight);

                return Column(
                  children: [
                    SizedBox(height: domHeight, child: executionWidget),
                    SizedBox(
                      height: consoleHeight,
                      child: ConsoleWidget(
                        output: appModel.consoleOutput,
                        showDivider: mode == LayoutMode.both,
                        key: _consoleKey,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        loadingOverlay,
      ],
    );

    final scaffold = LayoutBuilder(builder: (context, constraints) {
      // Use the mobile UI layout for small screen widths.
      if (constraints.maxWidth <= smallScreenWidth) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: widget.embedMode
              ? tabBar
              : DartPadAppBar(
                  theme: theme,
                  appServices: appServices,
                  appModel: appModel,
                  widget: widget,
                  bottom: tabBar,
                ),
          body: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: tabController.index,
                  children: [
                    editor,
                    executionStack,
                  ],
                ),
              ),
              if (!widget.embedMode)
                const StatusLineWidget(mobileVersion: true),
            ],
          ),
        );
      } else {
        // Return the desktop UI.
        return Scaffold(
          key: _scaffoldKey,
          appBar: widget.embedMode
              ? null
              : DartPadAppBar(
                  theme: theme,
                  appServices: appServices,
                  appModel: appModel,
                  widget: widget,
                ),
          body: Column(
            children: [
              Expanded(
                child: SplitView(
                  viewMode: SplitViewMode.Horizontal,
                  gripColor: theme.colorScheme.surface,
                  gripColorActive: theme.colorScheme.surface,
                  gripSize: defaultGripSize,
                  controller: mainSplitter,
                  children: [
                    editor,
                    executionStack,
                  ],
                ),
              ),
              if (!widget.embedMode) const StatusLineWidget(),
            ],
          ),
        );
      }
    });

    return Provider<AppServices>.value(
      value: appServices,
      child: Provider<AppModel>.value(
        value: appModel,
        child: CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            keys.runKeyActivator1: () {
              if (!appModel.compilingBusy.value) {
                appServices.performCompileAndRun();
              }
            },
            keys.runKeyActivator2: () {
              if (!appModel.compilingBusy.value) {
                appServices.performCompileAndRun();
              }
            },
            // keys.findKeyActivator: () {
            //   // TODO:
            //   unimplemented(context, 'find');
            // },
            // keys.findNextKeyActivator: () {
            //   // TODO:
            //   unimplemented(context, 'find next');
            // },
            keys.formatKeyActivator1: () {
              if (!appModel.formattingBusy.value) _handleFormatting();
            },
            keys.formatKeyActivator2: () {
              if (!appModel.formattingBusy.value) _handleFormatting();
            },
            keys.codeCompletionKeyActivator: () {
              appServices.editorService?.showCompletions(autoInvoked: false);
            },
            keys.quickFixKeyActivator1: () {
              appServices.editorService?.showQuickFixes();
            },
            keys.quickFixKeyActivator2: () {
              appServices.editorService?.showQuickFixes();
            },
          },
          child: Focus(
            autofocus: true,
            child: scaffold,
          ),
        ),
      ),
    );
  }

  Future<void> _handleFormatting() async {
    try {
      final source = appModel.sourceCodeController.text;
      final offset = appServices.editorService?.cursorOffset;
      final result = await appServices.format(
        SourceRequest(source: source, offset: offset),
      );

      if (result.source == source) {
        appModel.editorStatus.showToast('No formatting changes');
      } else {
        appModel.editorStatus.showToast('Format successful');
        appModel.sourceCodeController.value = TextEditingValue(
          text: result.source,
          selection: TextSelection.collapsed(offset: result.offset ?? 0),
        );
      }

      appServices.editorService!.focus();
    } catch (error) {
      appModel.editorStatus.showToast('Error formatting code');
      appModel.appendLineToConsole('Formatting issue: $error');
      return;
    }
  }

  void _handleRunStarted() {
    setState(() {
      // Switch to the application output tab.]
      if (appModel.compilingBusy.value) {
        tabController.animateTo(1);
      }
    });
  }
}

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.appModel,
  });

  final AppModel appModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: appModel.compilingBusy,
      builder: (_, bool compiling, __) {
        final color = theme.colorScheme.surface;

        return AnimatedContainer(
          color: color.withValues(alpha: compiling ? 0.8 : 0),
          duration: animationDelay,
          curve: animationCurve,
          child: compiling
              ? const GoldenRatioCenter(
                  child: CircularProgressIndicator(),
                )
              : const SizedBox(width: 1),
        );
      },
    );
  }
}

class DartPadAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DartPadAppBar({
    super.key,
    required this.theme,
    required this.appServices,
    required this.appModel,
    required this.widget,
    this.bottom,
  });

  final ThemeData theme;
  final AppServices appServices;
  final AppModel appModel;
  final DartPadMainPage widget;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: SizedBox(
          height: toolbarItemHeight,
          child: Row(
            children: [
              const Logo(width: 32, type: 'dart'),
              const SizedBox(width: denseSpacing),
              Text(appName,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
              // Hide new snippet buttons when the screen width is too small.
              if (constraints.maxWidth > smallScreenWidth) ...[
                const SizedBox(width: defaultSpacing * 4),
                NewSnippetWidget(appServices: appServices),
                const SizedBox(width: denseSpacing),
                const ListSamplesWidget(),
              ] else ...[
                const SizedBox(width: defaultSpacing),
                NewSnippetWidget(appServices: appServices, smallIcon: true),
                const SizedBox(width: defaultSpacing),
                const ListSamplesWidget(smallIcon: true),
              ],

              const SizedBox(width: defaultSpacing),
              // Hide the snippet title when the screen width is too small.
              if (constraints.maxWidth > smallScreenWidth)
                Expanded(
                  child: Center(
                    child: ValueListenableBuilder<String>(
                      valueListenable: appModel.title,
                      builder: (_, String value, __) => Text(value),
                    ),
                  ),
                ),
              const SizedBox(width: defaultSpacing),
            ],
          ),
        ),
        bottom: bottom,
        actions: [
          // Hide the Install SDK button when the screen width is too small.
       /////   if (constraints.maxWidth > smallScreenWidth)
          ///  ContinueInMenu(
          ///    openInIdx: _openInIDX,
          //  ),
          const SizedBox(width: denseSpacing),
          _BrightnessButton(
            handleBrightnessChange: widget.handleBrightnessChanged,
          ),
      //    const OverflowMenu(),
        ],
      );
    });
  }

  @override
  // kToolbarHeight is set to 56.0 in the framework.
  Size get preferredSize => bottom == null
      ? const Size(double.infinity, 56.0)
      : const Size(double.infinity, 112.0);

  
}

class EditorWithButtons extends StatelessWidget {
  const EditorWithButtons({
    super.key,
    required this.appModel,
    required this.appServices,
    required this.onFormat,
    required this.onCompileAndRun,
    required this.onCompileAndReload,
  });

  final AppModel appModel;
  final AppServices appServices;
  final VoidCallback onFormat;
  final VoidCallback onCompileAndRun;
  final VoidCallback onCompileAndReload;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SectionWidget(
            child: Stack(
              children: [
                EditorWidget(
                  appModel: appModel,
                  appServices: appServices,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: denseSpacing,
                    horizontal: defaultSpacing,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    // We use explicit directionality here in order to have the
                    // format and run buttons on the right hand side of the
                    // editing area.
                    textDirection: TextDirection.ltr,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dartdoc help button
                      ValueListenableBuilder<bool>(
                        valueListenable: appModel.docHelpBusy,
                        builder: (_, bool value, __) {
                          return PointerInterceptor(
                            child: MiniIconButton(
                              icon: Icons.help_outline,
                              tooltip: 'Show docs',
                              // small: true,
                              onPressed:
                                  value ? null : () => _showDocs(context),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: denseSpacing),
                      // Format action
                      ValueListenableBuilder<bool>(
                        valueListenable: appModel.formattingBusy,
                        builder: (_, bool value, __) {
                          return PointerInterceptor(
                            child: MiniIconButton(
                              icon: Icons.format_align_left,
                              tooltip: 'Format',
                              small: true,
                              onPressed: value ? null : onFormat,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: defaultSpacing),
                      // Run action
                      ValueListenableBuilder(
                          valueListenable: appModel.showReload,
                          builder: (_, bool value, __) {
                            if (!value) return const SizedBox();
                            return ValueListenableBuilder<bool>(
                              valueListenable: appModel.canReload,
                              builder: (_, bool value, __) {
                                return PointerInterceptor(
                                  child: ReloadButton(
                                    onPressed:
                                        value ? onCompileAndReload : null,
                                  ),
                                );
                              },
                            );
                          }),
                      const SizedBox(width: defaultSpacing),
                      // Run action
                      ValueListenableBuilder<bool>(
                        valueListenable: appModel.compilingBusy,
                        builder: (_, bool value, __) {
                          return PointerInterceptor(
                            child: RunButton(
                              onPressed: value ? null : onCompileAndRun,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(denseSpacing),
                  child: StatusWidget(
                    status: appModel.editorStatus,
                  ),
                ),
              ],
            ),
          ),
        ),
        ValueListenableBuilder<List<AnalysisIssue>>(
          valueListenable: appModel.analysisIssues,
          builder: (context, issues, _) {
            return ProblemsTableWidget(problems: issues);
          },
        ),
      ],
    );
  }

  static final RegExp identifierChar = RegExp(r'[\w\d_<=>]');

  void _showDocs(BuildContext context) async {
    try {
      final source = appModel.sourceCodeController.text;
      final offset = appServices.editorService?.cursorOffset ?? -1;

      var valid = true;
      if (offset < 0 || offset >= source.length) {
        valid = false;
      } else {
        valid = identifierChar.hasMatch(source.substring(offset, offset + 1));
      }

      if (!valid) {
        appModel.editorStatus.showToast('No docs at location.');
        return;
      }

      final result = await appServices.document(
        SourceRequest(source: source, offset: offset),
      );

      if (result.elementKind == null) {
        appModel.editorStatus.showToast('No docs at location.');
        return;
      } else if (context.mounted) {
        // show result

        showDialog<void>(
          context: context,
          builder: (context) {
            const longTitle = 40;

            var title = result.cleanedUpTitle ?? 'Dartdoc';
            if (title.length > longTitle) {
              title = '${title.substring(0, longTitle)}…';
            }
            return MediumDialog(
              title: title,
              child: DocsWidget(
                appModel: appModel,
                documentResponse: result,
              ),
            );
          },
        );
      }

      appServices.editorService!.focus();
    } catch (error) {
      appModel.editorStatus.showToast('Error retrieving docs');
      appModel.appendLineToConsole('$error');
      return;
    }
  }
}

class StatusLineWidget extends StatelessWidget {
  final bool mobileVersion;

  const StatusLineWidget({
    this.mobileVersion = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final appModel = Provider.of<AppModel>(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: denseSpacing,
        horizontal: defaultSpacing,
      ),
      child: Row(
        children: [
          Tooltip(
            message: 'Keyboard shortcuts',
            waitDuration: tooltipDelay,
            child: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => MediumDialog(
                  title: 'Keyboard shortcuts',
                  smaller: true,
                  child: KeyBindingsTable(
                    bindings: keys.keyBindings,
                    appModel: appModel,
                  ),
                ),
              ),
              child: Icon(
                Icons.keyboard,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: defaultSpacing),
   
          const Expanded(child: SizedBox(width: defaultSpacing)),
          VersionInfoWidget(appModel.runtimeVersions),
          const SizedBox(width: defaultSpacing),
          const SizedBox(height: 26, child: SelectChannelWidget()),
        ],
      ),
    );
  }
}

class SectionWidget extends StatelessWidget {
  final String? title;
  final Widget? actions;
  final Widget child;

  const SectionWidget({
    this.title,
    this.actions,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var finalChild = child;

    if (title != null || actions != null) {
      finalChild = Column(
        children: [
          Row(
            children: [
              if (title != null) Text(title!, style: subtleText),
              const Expanded(child: SizedBox(width: defaultSpacing)),
              if (actions != null) actions!,
            ],
          ),
          const Divider(),
          Expanded(child: child),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(denseSpacing),
      child: finalChild,
    );
  }
}

class NewSnippetWidget extends StatelessWidget {
  final AppServices appServices;
  final bool smallIcon;

  static const _menuItems = [
    (
      label: 'Dart snippet',
      icon: Logo(type: 'dart'),
      kind: 'dart',
    ),
    (
      label: 'Flutter snippet',
      icon: Logo(type: 'flutter'),
      kind: 'flutter',
    ),
  ];

  const NewSnippetWidget({
    required this.appServices,
    this.smallIcon = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: (context, MenuController controller, Widget? child) {
        if (smallIcon) {
          return IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: () => controller.toggleMenuState(),
          );
        }
        return TextButton.icon(
          onPressed: () => controller.toggleMenuState(),
          icon: const Icon(Icons.add_circle),
          label: const Text('New'),
        );
      },
      menuChildren: [
        for (final item in _menuItems)
          PointerInterceptor(
            child: MenuItemButton(
              leadingIcon: item.icon,
              child: Padding(
                padding: const EdgeInsets.only(right: 32),
                child: Text(item.label),
              ),
              onPressed: () => appServices.resetTo(type: item.kind),
            ),
          )
      ],
    );
  }
}

class ListSamplesWidget extends StatelessWidget {
  final bool smallIcon;
  const ListSamplesWidget({this.smallIcon = false, super.key});

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: (context, MenuController controller, Widget? child) {
        if (smallIcon) {
          return IconButton(
            icon: const Icon(Icons.playlist_add_outlined),
            onPressed: () => controller.toggleMenuState(),
          );
        }
        return TextButton.icon(
          onPressed: () => controller.toggleMenuState(),
          icon: const Icon(Icons.playlist_add_outlined),
          label: const Text('Samples'),
        );
      },
      menuChildren: _buildMenuItems(context),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final menuItems = [
      for (final MapEntry(key: category, value: samples)
          in Samples.categories.entries) ...[
        MenuItemButton(
          onPressed: null,
          child: Text(
            category,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        for (final sample in samples)
          MenuItemButton(
            leadingIcon: Logo(type: sample.icon),
            onPressed: () =>
                GoRouter.of(context).replaceQueryParam('sample', sample.id),
            child: Padding(
              padding: const EdgeInsets.only(right: 32),
              child: Text(sample.name),
            ),
          ),
      ]
    ];

    return menuItems.map((e) => PointerInterceptor(child: e)).toList();
  }
}

class SelectChannelWidget extends StatelessWidget {
  const SelectChannelWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final appServices = Provider.of<AppServices>(context);
    final channels = Channel.valuesWithoutLocalhost;

    return ValueListenableBuilder<Channel>(
      valueListenable: appServices.channel,
      builder: (context, Channel value, _) => MenuAnchor(
        builder: (context, MenuController controller, Widget? child) {
          return TextButton.icon(
            onPressed: () => controller.toggleMenuState(),
            icon: const Icon(Icons.tune, size: smallIconSize),
            label: Text('${value.displayName} channel'),
          );
        },
        menuChildren: [
          for (final channel in channels)
            PointerInterceptor(
              child: MenuItemButton(
                onPressed: () => _onTap(context, channel),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 32, 0),
                  child: Text('${channel.displayName} channel'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, Channel channel) async {
    final appServices = Provider.of<AppServices>(context, listen: false);

    // update the url
    GoRouter.of(context).replaceQueryParam('channel', channel.name);

    final version = await appServices.setChannel(channel);

    appServices.appModel.editorStatus.showToast(
      'Switched to Dart ${version.dartVersion} '
      'and Flutter ${version.flutterVersion}',
    );
  }
}

class KeyBindingsTable extends StatelessWidget {
  final List<(String, List<ShortcutActivator>)> bindings;
  final AppModel appModel;

  const KeyBindingsTable({
    required this.bindings,
    required this.appModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        Expanded(
          child: VTable<(String, List<ShortcutActivator>)>(
            showToolbar: false,
            showHeaders: false,
            startsSorted: true,
            items: bindings,
            columns: [
              VTableColumn(
                label: 'Command',
                width: 100,
                grow: 0.5,
                transformFunction: (binding) => binding.$1,
              ),
              VTableColumn(
                label: 'Keyboard shortcut',
                width: 100,
                grow: 0.5,
                alignment: Alignment.centerRight,
                styleFunction: (binding) => subtleText,
                renderFunction: (context, binding, _) {
                  final children = <Widget>[];
                  var first = true;
                  for (final shortcut in binding.$2) {
                    if (!first) {
                      children.add(
                        const Padding(
                          padding: EdgeInsets.only(left: 4, right: 8),
                          child: Text(','),
                        ),
                      );
                    }
                    first = false;
                    children.add(
                        (shortcut as SingleActivator).renderToWidget(context));
                  }
                  return Row(children: children);
                },
              ),
            ],
          ),
        ),
        const Divider(),
        _VimModeSwitch(
          appModel: appModel,
        ),
      ],
    );
  }
}

class VersionInfoWidget extends StatefulWidget {
  final ValueListenable<VersionResponse?> versions;

  const VersionInfoWidget(
    this.versions, {
    super.key,
  });

  @override
  State<VersionInfoWidget> createState() => _VersionInfoWidgetState();
}

class _VersionInfoWidgetState extends State<VersionInfoWidget> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VersionResponse?>(
      valueListenable: widget.versions,
      builder: (content, versions, _) {
        if (versions == null) {
          return const SizedBox();
        }

        return TextButton(
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (context) {
                return MediumDialog(
                  title: 'Runtime versions',
                  child: VersionTable(version: versions),
                );
              },
            );
          },
          child: Text(versions.label),
        );
      },
    );
  }
}

class _BrightnessButton extends StatelessWidget {
  const _BrightnessButton({
    required this.handleBrightnessChange,
  });

  final void Function(BuildContext, bool) handleBrightnessChange;

  @override
  Widget build(BuildContext context) {
    final isBright = Theme.of(context).brightness == Brightness.light;
    return Tooltip(
      preferBelow: true,
      message: 'Toggle brightness',
      child: IconButton(
        icon: Theme.of(context).brightness == Brightness.light
            ? const Icon(Icons.dark_mode_outlined)
            : const Icon(Icons.light_mode_outlined),
        onPressed: () {
          handleBrightnessChange(context, !isBright);
        },
      ),
    );
  }
}

class _VimModeSwitch extends StatelessWidget {
  final AppModel appModel;

  const _VimModeSwitch({
    required this.appModel,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appModel.vimKeymapsEnabled,
      builder: (BuildContext context, bool value, Widget? child) {
        return SwitchListTile(
          value: value,
          title: const Text('Use Vim Key Bindings'),
          onChanged: _handleToggle,
        );
      },
    );
  }

  void _handleToggle(bool value) {
    appModel.vimKeymapsEnabled.value = value;
  }
}

extension MenuControllerToggleMenu on MenuController {
  void toggleMenuState() {
    if (isOpen) {
      close();
    } else {
      open();
    }
  }
}
