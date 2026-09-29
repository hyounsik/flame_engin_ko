import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/src/game/game_render_box.dart';
import 'package:flame/src/game/game_widget/gesture_detector_builder.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// **GameWidget**은 [Game] 인스턴스를 Flutter 위젯 트리에 삽입하는 데
/// 사용하는 Flutter 위젯입니다.
///
/// `GameWidget`은 Flutter 애플리케이션의 루트로 실행할 수 있을 만큼 기능이
/// 충분합니다. 따라서 `GameWidget`을 사용하는 가장 간단한 방법은
/// 다음과 같습니다.
/// ```dart
/// void main() {
///   runApp(
///     GameWidget(game: MyGame()),
///   );
/// }
/// ```
///
/// 동시에 `GameWidget`은 일반 Flutter 위젯이므로 위젯 트리의 원하는 깊이
/// 어디에든 삽입할 수 있으며, 하나의 앱 안에 여러 개의 `GameWidget`을
/// 둘 수도 있습니다.
///
/// 이 위젯은 사용 가능한 모든 공간을 채우도록 확장되는 레이아웃 동작을
/// 합니다. 따라서 루트 위젯으로 사용하면 앱이 전체 화면이 됩니다.
/// 다른 레이아웃 위젯 안에서는 가능한 한 많은 공간을
/// 차지합니다.
///
/// [Game] 인스턴스를 호스팅하는 것 외에도 `GameWidget`은 다음과 같은
/// 구조적 지원 기능을 제공합니다.
///
/// - [loadingBuilder]: 게임이 로딩되는 동안 무언가를 표시합니다.
/// - [errorBuilder]: 게임에서 오류가 발생하면 표시됩니다.
/// - [backgroundBuilder]: 게임 뒤에 장식을 그립니다.
/// - [overlayBuilderMap]: 게임 위에 하나 이상의 위젯을 그립니다.
///
/// `GameWidget`은 캔버스의 내용을 잘라내지(clip) 않는다는 점에 유의해야
/// 합니다. 즉, 게임이 자신의 경계 밖에도 그려질 수 있습니다
/// (사용하는 카메라에 따라 항상 그런 것은 아닙니다). 이를 원하지 않는다면
/// 위젯을 Flutter의 [ClipRect]로 감싸는 것을 고려하세요.
class GameWidget<T extends Game> extends StatefulWidget {
  /// 전달된 [game] 인스턴스를 렌더링합니다.
  GameWidget({
    required T this.game,
    this.textDirection,
    this.loadingBuilder,
    this.errorBuilder,
    this.backgroundBuilder,
    this.overlayBuilderMap,
    this.initialActiveOverlays,
    this.focusNode,
    this.autofocus = true,
    this.mouseCursor,
    this.addRepaintBoundary = true,
    this.behavior = HitTestBehavior.opaque,
    super.key,
  }) : gameFactory = null {
    _initializeGame(game!);
  }

  /// 전달된 [gameFactory]를 사용해 `Game` 인스턴스를 생성하고 소유하는
  /// `GameWidget`입니다.
  ///
  /// 이 생성자는 `GameWidget`을 다른 위젯 안에 넣고 싶지만 게임
  /// 인스턴스를 직접 저장하고 싶지 않을 때 유용합니다.
  /// 예를 들면 다음과 같습니다.
  /// ```dart
  /// class MyWidget extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return Container(
  ///       padding: EdgeInsets.all(20),
  ///       child: GameWidget.managed(
  ///         gameFactory: MyGame.new,
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  const GameWidget.managed({
    required GameFactory<T> this.gameFactory,
    this.textDirection,
    this.loadingBuilder,
    this.errorBuilder,
    this.backgroundBuilder,
    this.overlayBuilderMap,
    this.initialActiveOverlays,
    this.focusNode,
    this.autofocus = true,
    this.mouseCursor,
    this.addRepaintBoundary = true,
    this.behavior = HitTestBehavior.opaque,
    super.key,
  }) : game = null;

  /// 기본 생성자로 전달된 경우, 이 위젯이 렌더링할 게임 인스턴스입니다.
  /// 반면 [GameWidget.managed]
  /// 생성자를 사용했다면 이 값은 항상 `null`입니다.
  final T? game;

  /// 이 위젯이 렌더링할 [Game]을 생성하는 함수입니다.
  final GameFactory<T>? gameFactory;

  /// 게임 안의 텍스트 요소에 사용할 텍스트 방향입니다.
  final TextDirection? textDirection;

  /// 게임이 로딩되는 동안 표시할 위젯을 제공하는 빌더입니다.
  /// 기본값은 빈 `Container`입니다.
  ///
  /// [FlameGame]의 경우 초기 컴포넌트 트리 전체가 로드되고 마운트될
  /// 때까지 게임이 로딩 중인 것으로 간주되므로, [Game.onLoad]에서 추가한
  /// 모든 컴포넌트가 준비될 때까지 게임이 시작되지 않습니다.
  final GameLoadingWidgetBuilder? loadingBuilder;

  /// 설정하면 게임 로딩 중 발생한 오류를 잡아서 이 위젯을
  /// 표시합니다. 제공하지 않으면 오류가 평소대로 전파됩니다.
  final GameErrorWidgetBuilder? errorBuilder;

  /// 게임 요소와 [Game.backgroundColor]로 지정한 배경색 사이에 빌드될
  /// 위젯 트리를 제공하는 빌더입니다.
  final WidgetBuilder? backgroundBuilder;

  /// 게임 화면 위에 표시할 수 있는 위젯 모음입니다.
  /// 이 위젯들은 [Game.overlays] 속성을 통해 게임 안에서
  /// 동적으로 켜고 끌 수 있습니다.
  ///
  /// ```dart
  /// void main() {
  ///   runApp(
  ///     GameWidget(
  ///       game: MyGame(),
  ///       overlayBuilderMap: {
  ///         'PauseMenu': (context, game) {
  ///           return Container(
  ///             color: const Color(0xFF000000),
  ///             child: Text('A pause menu'),
  ///           );
  ///         },
  ///       },
  ///     ),
  ///   );
  /// }
  /// ```
  final Map<String, OverlayWidgetBuilder<T>>? overlayBuilderMap;

  /// 게임이 시작될 때(단, 로드가 끝난 후) 표시할
  /// 오버레이 목록입니다.
  final List<String>? initialActiveOverlays;

  /// 이벤트 입력을 받기 위해 게임의 포커스를 제어하는 [FocusNode]입니다.
  /// 생략하면 내부에서 제어하는 포커스 노드를 기본으로 사용합니다.
  final FocusNode? focusNode;

  /// 게임이 마운트되었을 때 [focusNode]가 포커스를 요청할지 여부입니다.
  /// 기본값은 true입니다.
  final bool autofocus;

  /// 마우스 커서가 게임 캔버스 위에 있을 때의 커서 모양입니다.
  /// 이 속성은 [Game.mouseCursor]를 통해 동적으로 변경할 수 있습니다.
  final MouseCursor? mouseCursor;

  /// 게임이 [RepaintBoundary]처럼 동작할지 여부이며,
  /// 기본값은 `true`입니다.
  final bool addRepaintBoundary;

  /// 히트 테스트 중 게임 위젯이 어떻게 동작할지 지정합니다.
  ///
  /// - [HitTestBehavior.opaque] (기본값): 게임이 자신의 영역에서 발생하는 모든
  ///   포인터 이벤트를 흡수하여 뒤에 있는 위젯이 이벤트를 받지 못하게 합니다.
  /// - [HitTestBehavior.deferToChild]: 이벤트 콜백을 가진 컴포넌트(예:
  ///   [TapCallbacks])가 있는 위치에서만 게임이 이벤트를 가로챕니다.
  ///   다른 위치의 이벤트는 뒤에 있는 위젯으로 전달됩니다.
  /// - [HitTestBehavior.translucent]: 게임은 이벤트 처리 컴포넌트가 있는 곳에서
  ///   이벤트를 받지만, 뒤에 있는 위젯도 항상
  ///   히트 테스트될 수 있도록 허용합니다.
  final HitTestBehavior behavior;

  /// Flutter 위젯 트리에서 위젯 오버레이와 함께 [game]을 렌더링합니다.
  ///
  /// 오버레이를 사용하려면 게임 서브클래스에 HasWidgetsOverlay를 믹스인해야 합니다.
  @override
  GameWidgetState<T> createState() => GameWidgetState<T>();

  void _initializeGame(T game) {
    if (mouseCursor != null) {
      game.mouseCursor = mouseCursor!;
    }
    if (overlayBuilderMap != null) {
      for (final kv in overlayBuilderMap!.entries) {
        game.overlays.addEntry(
          kv.key,
          (ctx, game) => kv.value(ctx, game as T),
        );
      }
    }
    if (initialActiveOverlays != null) {
      game.overlays.addAll(initialActiveOverlays!);
    }
  }
}

class GameWidgetState<T extends Game> extends State<GameWidget<T>> {
  late T currentGame;

  Future<void> get loaderFuture => _loaderFuture ??= (() async {
    final game = currentGame;
    final gameGeneration = _gameGeneration;
    assert(game.hasLayout);
    await game.load();
    if (_isStale(gameGeneration)) {
      return;
    }
    game.mount();
    // Wait for the whole component tree to be loaded and mounted, so that
    // the game does not start, and the loading widget is not removed,
    // until every component added during the initial load is ready.
    await game.ready();
    if (_isStale(gameGeneration)) {
      return;
    }
    if (!game.isPaused) {
      game.update(0);
    }
  })();

  /// [gameGeneration]을 캡처한 로더가 더 이상 최신이 아닌지 여부입니다.
  /// 위젯이 dispose되었거나 그 이후 게임 인스턴스가 교체된 경우가
  /// 해당합니다. 게임의 동일성을 비교하는 대신 세대(generation) 카운터를 사용하므로,
  /// 원래 게임이 아직 로딩 중일 때 다른 게임으로 교체했다가 다시
  /// 원래 게임으로 돌아와도 이전 로더가 무효화됩니다.
  bool _isStale(int gameGeneration) =>
      !mounted || gameGeneration != _gameGeneration;

  /// [initCurrentGame]이 게임 인스턴스를 설치할 때마다 증가합니다.
  int _gameGeneration = 0;

  Future<void>? _loaderFuture;

  late FocusNode _focusNode;

  /// 현재 실행 중인 `build()` 함수의 개수입니다.
  int _buildDepth = 0;

  /// true이면 현재 빌드가 끝난 후 새 빌드가 예약됩니다.
  /// 이 값은 [_buildDepth]가 0이 아닐 때만
  /// true로 설정해야 합니다.
  bool _requiresRebuild = false;

  /// [build]가 실행되는 동안 `_buildDepth > 0`이 되도록 하고, 빌드 중에
  /// [_requiresRebuild] 플래그가 설정되었다면 다시 빌드를 예약하는
  /// 헬퍼 메서드입니다.
  ///
  /// 이 메서드가 필요한 이유는 build 함수가 사용자 코드를 호출하고, 그 코드가
  /// [Game]의 속성을 변경하여 [GameWidget]을 다시 빌드해야 할 수 있기
  /// 때문입니다. 하지만 Flutter는 빌드 중인 위젯을 dirty로 표시하는 것을
  /// 허용하지 않습니다. 그래서 이 메서드로 이러한 제약을 피하고, 사용자 코드가
  /// [Game]의 속성을 자유롭게 설정할 수 있으며 그 변경이 가능한 한 빨리
  /// [GameWidget]에 전파되도록
  /// 보장합니다.
  Widget _protectedBuild(Widget Function() build) {
    late final Widget result;
    try {
      _buildDepth++;
      result = build();
    } finally {
      _buildDepth--;
    }
    if (_requiresRebuild && _buildDepth == 0) {
      Future.microtask(_onGameStateChange);
    }
    return result;
  }

  void _onGameStateChange() {
    if (_buildDepth > 0) {
      _requiresRebuild = true;
    } else {
      setState(() => _requiresRebuild = false);
    }
  }

  void initCurrentGame() {
    if (widget.game == null) {
      currentGame = widget.gameFactory!.call();
      widget._initializeGame(currentGame);
    } else {
      currentGame = widget.game!;
    }
    initGameStateListener(currentGame, _onGameStateChange);
    _gameGeneration++;
    _loaderFuture = null;
  }

  /// 다음 이슈의 테스트를 위해 공개되어 있습니다:
  /// https://github.com/flame-engine/flame/issues/2771.
  @visibleForTesting
  static void initGameStateListener(
    Game currentGame,
    void Function() onGameStateChange,
  ) {
    currentGame.addGameStateListener(onGameStateChange);

    // See https://github.com/flame-engine/flame/issues/2771
    // for why we aren't using [WidgetsBinding.instance.lifecycleState].
    currentGame.lifecycleStateChange(AppLifecycleState.resumed);
  }

  /// [disposeCurrentGame]은 두 가지 Flutter 이벤트인 `didUpdateWidget`과
  /// `dispose`에서 호출됩니다. [callGameOnDispose] 파라미터가 true이면
  /// `currentGame`의 `onDispose` 메서드가 호출되고, 그렇지 않으면 호출되지 않습니다.
  void disposeCurrentGame({bool callGameOnDispose = false}) {
    currentGame.removeGameStateListener(_onGameStateChange);
    currentGame.lifecycleStateChange(AppLifecycleState.paused);
    currentGame.finalizeRemoval();
    currentGame.widgetBuildContext = null;
    if (callGameOnDispose) {
      currentGame.onDispose();
    }
  }

  @override
  void initState() {
    super.initState();
    initCurrentGame();
    _focusNode = widget.focusNode ?? FocusNode();
    if (widget.autofocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(GameWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.game != widget.game) {
      disposeCurrentGame();
      initCurrentGame();
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    currentGame.onHotReload();
  }

  @override
  void dispose() {
    disposeCurrentGame(callGameOnDispose: true);
    // If we received a focus node from the user, they are responsible
    // for disposing it
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode focusNode, KeyEvent event) {
    final game = currentGame;

    if (!_focusNode.hasPrimaryFocus) {
      return KeyEventResult.ignored;
    }

    if (game is KeyboardEvents) {
      return game.onKeyEvent(
        event,
        HardwareKeyboard.instance.logicalKeysPressed,
      );
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return _protectedBuild(() {
      Widget? internalGameWidget = RenderGameWidget(
        game: currentGame,
        addRepaintBoundary: widget.addRepaintBoundary,
        behavior: widget.behavior,
      );

      internalGameWidget = currentGame.gestureDetectors.build(
        internalGameWidget,
      );

      if (hasMouseDetectors(currentGame)) {
        internalGameWidget = applyMouseDetectors(
          currentGame,
          internalGameWidget,
        );
      }

      final stackedWidgets = [internalGameWidget];
      _addBackground(context, stackedWidgets);
      _addOverlays(context, stackedWidgets);

      // We can use Directionality.maybeOf when that method lands on stable
      final textDir = widget.textDirection ?? TextDirection.ltr;

      return FocusScope(
        child: Focus(
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          descendantsAreFocusable: true,
          onKeyEvent: _handleKeyEvent,
          child: MouseRegion(
            cursor: currentGame.mouseCursor,
            opaque: widget.behavior == HitTestBehavior.opaque,
            child: Directionality(
              textDirection: textDir,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: currentGame.backgroundColor(),
                ),
                child: LayoutBuilder(
                  builder: (layoutContext, BoxConstraints constraints) {
                    return _protectedBuild(() {
                      final size = constraints.biggest.toVector2();
                      if (size.isZero()) {
                        return widget.loadingBuilder?.call(context) ??
                            Container();
                      }
                      currentGame.onGameResize(size);
                      currentGame.widgetBuildContext = layoutContext;
                      // This should only be called if the game has already been
                      // loaded (in the case of resizing for example), since
                      // update otherwise should be called after onMount.
                      if (!currentGame.isPaused && currentGame.isAttached) {
                        currentGame.update(0);
                      }
                      return FutureBuilder(
                        future: loaderFuture,
                        builder: (_, snapshot) {
                          if (snapshot.hasError) {
                            final errorBuilder = widget.errorBuilder;
                            if (errorBuilder == null) {
                              throw Error.throwWithStackTrace(
                                snapshot.error!,
                                snapshot.stackTrace!,
                              );
                            } else {
                              return errorBuilder(context, snapshot.error!);
                            }
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Stack(children: stackedWidgets);
                          }

                          return widget.loadingBuilder?.call(context) ??
                              const SizedBox.expand();
                        },
                      );
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _addBackground(BuildContext context, List<Widget> stackWidgets) {
    if (widget.backgroundBuilder != null) {
      final backgroundContent = KeyedSubtree(
        key: ValueKey(widget.game),
        child: widget.backgroundBuilder!(context),
      );
      stackWidgets.insert(0, backgroundContent);
    }
  }

  void _addOverlays(BuildContext context, List<Widget> stackWidgets) {
    stackWidgets.addAll(
      currentGame.overlays.buildCurrentOverlayWidgets(context),
    );
  }
}

typedef GameLoadingWidgetBuilder = Widget Function(BuildContext);

typedef GameErrorWidgetBuilder = Widget Function(BuildContext, Object error);

typedef OverlayWidgetBuilder<T extends Game> =
    Widget Function(
      BuildContext context,
      T game,
    );

typedef GameFactory<T extends Game> = T Function();
