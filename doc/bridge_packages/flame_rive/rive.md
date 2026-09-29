# flame_rive

`flame_rive`는 Flame 게임에서 [rive](https://rive.app/) 애니메이션을 사용하기 위한 브릿지 라이브러리입니다.
Rive는 실시간 인터랙티브 디자인 및 애니메이션 도구로, 애니메이션을 만드는 데 사용합니다.

Rive로 만든 파일을 게임에서 사용하려면 pubspec.yaml에 `flame_rive`를 추가해야 합니다.
자세한 내용은
[Flame Rive 예제](https://github.com/flame-engine/flame/tree/main/packages/flame_rive/example)와
pub.dev의 [설치 안내](https://pub.dev/packages/flame_rive)에서 확인할 수 있습니다.


<a id="how-to-use-it"></a>

## 사용 방법

먼저 assets 폴더에 `animation.riv` 파일을 추가합니다. 그다음 `loadArtboard` 메서드를 사용해
애니메이션의 artboard를 게임에 불러옵니다. 그런 다음 artboard에서
`StateMachine`을 만들어 `RiveComponent`에 전달합니다. 컴포넌트가
state machine을 자동으로 진행시켜 줍니다.

Rive 0.14.x에서 state machine 입력은 지원 중단(deprecated)되었으므로, 상호작용은 state machine 입력 대신
[Data Binding](https://rive.app/docs/runtimes/data-binding)으로 처리해야 합니다.

```{flutter-app}
:sources: ../flame/examples
:page: rive_example
:show: widget code infobox
:width: 200
:height: 200
```

```dart
class RiveExampleGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final file = await File.asset(
      'assets/rewards.riv', 
      riveFactory: Factory.rive,
    );

    final artboard = await loadArtboard(file!);
    final stateMachine = artboard.defaultStateMachine();

    if (stateMachine != null) {
      final viewModel = file.defaultArtboardViewModel(artboard);
      if (viewModel != null) {
        final viewModelInstance = viewModel.createDefaultInstance();
        if (viewModelInstance != null) {
          stateMachine.bindViewModelInstance(viewModelInstance);
          final coinAmount =
              viewModelInstance.viewModel('Coin')?.number('Item_Value');
          coinAmount?.value = 100;
        }
      }
    }

    add(
      RiveComponent(
        artboard: artboard,
        stateMachine: stateMachine,
        size: Vector2.all(550),
      ),
    );
  }
}
```

state machine과 data binding을 사용해 애니메이션의 상태를 관리할 수 있습니다.
자세한 내용은 예제를 확인하세요.


<a id="full-example"></a>

## 전체 예제

예제는
[여기](https://github.com/flame-engine/flame/tree/main/packages/flame_rive/example)에서 확인할 수 있습니다.
