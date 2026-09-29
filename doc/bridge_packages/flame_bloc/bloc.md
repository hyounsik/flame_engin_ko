# flame_bloc

`flame_bloc`은 Flame 게임에서 [Bloc](https://bloclibrary.dev/)을 사용하기 위한 브릿지 라이브러리입니다.
`flame_bloc`은 FlameGame 안에서 bloc과 cubit을 사용하는 간단하고 자연스러운(flutter_bloc과 비슷하다는 의미에서) 방법을
제공합니다. Bloc은 게임 상태 변경이 언제 일어날 수 있는지를 통제해 게임 상태 변경을 예측 가능하게 만들고,
게임 전체에서 게임 상태를 변경하는 단일한 방법을
제공합니다.

게임에서 사용하려면 pubspec.yaml에 `flame_bloc`을 추가하기만 하면 됩니다.
[Flame Bloc 예제](https://github.com/flame-engine/flame/tree/main/packages/flame_bloc/example)와
pub.dev의 [설치 안내](https://pub.dev/packages/flame_bloc)에서 확인할 수 있습니다.


<a id="how-to-use"></a>

## 사용 방법

플레이어 인벤토리를 처리하는 bloc이 있다고 가정해 봅시다. 먼저 이 bloc을 컴포넌트에서 사용할 수 있게
만들어야 합니다.

`FlameBlocProvider` 컴포넌트를 사용하면 됩니다.

```dart
class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    add(
      FlameBlocProvider<PlayerInventoryBloc, PlayerInventoryState>(
        create: () => PlayerInventoryBloc(),
        children: [
          Player(),
          // ...
        ],
      ),
    );
  }
}
```

위와 같이 변경하면 `Player` 컴포넌트가 이제 bloc에 접근할 수 있습니다.

둘 이상의 bloc을 제공해야 한다면 `FlameMultiBlocProvider`를 비슷한 방식으로
사용할 수 있습니다.

```dart
class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    add(
      FlameMultiBlocProvider(
        providers: [
          FlameBlocProvider<PlayerInventoryBloc, PlayerInventoryState>(
            create: () => PlayerInventoryBloc(),
          ),
          FlameBlocProvider<PlayerStatsBloc, PlayerStatsState>(
            create: () => PlayerStatsBloc(),
          ),
        ],
        children: [
          Player(),
          // ...
        ],
      ),
    );
  }
}
```

컴포넌트 수준에서 상태 변경을 수신하는 방법은 두 가지입니다.

`FlameBlocListener` 컴포넌트를 사용하는 방법:

```dart
class Player extends PositionComponent {
  @override
  Future<void> onLoad() async {
    add(
      FlameBlocListener<PlayerInventoryBloc, PlayerInventoryState>(
        listener: (state) {
          updateGear(state);
        },
      ),
    );
  }
}
```

또는 `FlameBlocListenable` 믹스인을 사용하는 방법:

```dart

class Player extends PositionComponent
    with FlameBlocListenable<PlayerInventoryBloc, PlayerInventoryState> {

  @override
  void onNewState(state) {
    updateGear(state);
  }
}

```

컴포넌트가 단순히 bloc에 접근하기만 하면 된다면 컴포넌트에 `FlameBlocReader` 믹스인을
적용할 수 있습니다.

```dart
class Player extends PositionComponent
    with FlameBlocReader<PlayerStatsBloc, PlayerStatsState> {

  void takeHit() {
    bloc.add(const PlayerDamaged());
  }
}

```

이 믹스인은 하나의 bloc에만 접근할 수 있다는 제약이 있다는 점에 유의하세요.


<a id="full-example"></a>

## 전체 예제

예제는
[여기](https://github.com/flame-engine/flame/tree/main/packages/flame_bloc/example)에서 확인할 수 있습니다.
