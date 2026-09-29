<a id="overlays"></a>

# 오버레이

게임에서는 일시 정지 메뉴, 점수 표시, 채팅 인터페이스 같은 것을 위해 게임 캔버스 위에 Flutter 위젯을
표시해야 하는 경우가 많습니다. Flame 게임은 Flutter 위젯 트리 안에 있으므로, 어떤 Flutter 위젯이든
게임 화면 위에 겹쳐 놓을 수 있습니다. 오버레이 API를 사용하면 게임 코드 안에서 이름이 붙은 위젯
오버레이를 켜고 끌 수 있어 이 작업이 특히 편리해집니다.

Flame 게임은 위젯으로 감쌀 수 있으므로 트리 안의 다른 Flutter 위젯과 함께 사용하기가 아주 쉽습니다.
하지만 메시지, 메뉴 화면 같은 위젯을 Flame 게임 위에 손쉽게 표시하고 싶다면, 위젯 오버레이 API를
사용해 더욱 간단하게 처리할 수 있습니다.

`Game.overlays`를 사용하면 어떤 Flutter 위젯이든 게임 인스턴스 위에 표시할 수 있습니다. 이를 통해
일시 정지 메뉴나 인벤토리 화면 같은 것을 매우 쉽게 만들 수 있습니다.

이 기능은 `game.overlays.add`와 `game.overlays.remove` 메서드로 사용할 수 있으며, 각각 오버레이를
식별하는 `String` 인자를 통해 오버레이를 표시하거나 숨기도록 표시합니다. 그런 다음 `GameWidget`
선언에서 `overlayBuilderMap`을 제공하여 각 오버레이를 해당하는 위젯에 매핑할 수 있습니다.

```dart
  // 게임 내부에서:
  final pauseOverlayIdentifier = 'PauseMenu';
  final secondaryOverlayIdentifier = 'SecondaryMenu';

  // 'SecondaryMenu'가 렌더링되도록 표시합니다.
  overlays.add(secondaryOverlayIdentifier, priority: 1);
  // 'PauseMenu'가 렌더링되도록 표시합니다. 기본 우선순위는 0이므로
  // 'PauseMenu'는 'SecondaryMenu' 아래에 표시됩니다.
  overlays.add(pauseOverlayIdentifier);
  // 'PauseMenu'가 렌더링되지 않도록 표시합니다.
  overlays.remove(pauseOverlayIdentifier);
  // 'PauseMenu' 오버레이를 토글합니다.
  overlays.toggle(pauseOverlayIdentifier);
  // 'PauseMenu'가 렌더링되고 있는지 확인합니다.
  final hasPauseMenu = overlays.isActive(pauseOverlayIdentifier);
  // 조건에 따라 'SecondaryMenu'의 활성 상태를 설정합니다.
  overlays.setActive(secondaryOverlayIdentifier, active: !hasPauseMenu);
```

```dart
// 위젯 선언에서
final game = MyGame();

Widget build(BuildContext context) {
  return GameWidget(
    game: game,
    overlayBuilderMap: {
      'PauseMenu': (BuildContext context, MyGame game) {
        return Text('A pause menu');
      },
      'SecondaryMenu': (BuildContext context, MyGame game) {
        return Text('A secondary menu');
      },
    },
  );
}
```

오버레이의 렌더링 순서는 `overlayBuilderMap`의 키 순서에 따라 결정됩니다.

[오버레이 기능 예제](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/system/overlays_example.dart)를 참고하세요.
