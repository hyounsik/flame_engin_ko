

<a id="components"></a>

# 컴포넌트


## FlameBlocProvider

FlameBlocProvider는 bloc을 생성해 자식들에게 제공하는 컴포넌트입니다.  
bloc은 이 컴포넌트가 살아 있는 동안에만 유지됩니다. 하나의 bloc 인스턴스를 서브트리 안의 여러 컴포넌트에
제공할 수 있도록 의존성 주입(DI) 위젯처럼 사용됩니다.

FlameBlocProvider는 서브트리의 나머지 부분에서 사용할 수 있는 새 bloc을 생성할 때
사용해야 합니다.

```dart
FlameBlocProvider<BlocA, BlocAState>(
  create: () => BlocA(),
  children: [...]
);
```

FlameBlocProvider는 기존 bloc을 컴포넌트 트리의 새로운 부분에 제공할 때도 사용할 수 있습니다.

```dart
FlameBlocProvider<BlocA, BlocAState>.value(
  value: blocA,
  children: [...],
);
```


## FlameMultiBlocProvider

FlameBlocProvider와 비슷하지만 여러 bloc을 컴포넌트 트리 아래로 제공합니다.

```dart
FlameMultiBlocProvider(
  providers: [
    FlameBlocProvider<BlocA, BlocAState>(
      create: () => BlocA(),
    ),
    FlameBlocProvider<BlocB, BlocBState>.value(
      create: () => BlocB(),
    ),
    ],
  children: [...],
)
```


## FlameBlocListener

FlameBlocListener는 Bloc 상태의 변경을 수신할 수 있는 컴포넌트입니다. bloc의 상태가 변경되면
`onNewState`를 호출합니다. `onNewState` 함수가 호출되는 시점을 세밀하게 제어하려면 선택적으로
`listenWhen`을 제공할 수 있습니다. `listenWhen`은 이전 bloc 상태와 현재 bloc 상태를 받아 boolean을
반환합니다. `listenWhen`이 true를 반환하면 `onNewState`가 `state`와 함께 호출됩니다. `listenWhen`이
false를 반환하면 `onNewState`는 `state`와 함께
호출되지 않습니다.

또는 `FlameBlocListenable` 믹스인을 사용해 컴포넌트에서 상태 변경을 수신할 수도 있습니다.

```dart
FlameBlocListener<GameStatsBloc, GameStatsState>(
  listenWhen: (previousState, newState) {
      // true/false를 반환해 state와 함께
      // listener를 호출할지 결정합니다
  },
  onNewState: (state) {
          // state에 따라 여기서 작업을 수행합니다
  },
)
```


## FlameBlocListenable

FlameBlocListenable은 상태 변경을 수신하기 위한 FlameBlocListener의 대안입니다.

```dart
class ComponentA extends Component
    with FlameBlocListenable<BlocA, BlocAState> {

  @override
  bool listenWhen(PlayerState previousState, PlayerState newState) {
    // true/false를 반환해 state와 함께
    // listener를 호출할지 결정합니다
  }

  @override
  void onNewState(PlayerState state) {
    super.onNewState(state);
    // state에 따라 여기서 작업을 수행합니다
  }
}
```


## FlameBlocReader

FlameBlocReader는 컴포넌트에서 bloc의 현재 상태를 읽을 수 있게 해 주는 믹스인입니다. bloc의 현재 상태를
읽기만 하거나 bloc에 이벤트를 발생시키기만 하면 되는 컴포넌트에 유용합니다. 하나의 컴포넌트에는
reader를 하나만 둘 수 있습니다.


```dart

class InventoryReader extends Component
    with FlameBlocReader<InventoryCubit, InventoryState> {}

    /// 게임 내부에서
    
    final component = InventoryReader();
    // 현재 상태 읽기
    var state = component.bloc
```
