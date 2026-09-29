# flame_riverpod


## Riverpod

[Riverpod](https://riverpod.dev/)는 Dart와 Flutter를 위한 반응형 캐싱 및 데이터 바인딩
프레임워크입니다.

`flutter_riverpod`에서는 provider의 상태가 변경될 때 위젯이 다시 빌드되도록
설정할 수 있습니다.

Flame을 사용할 때는 위젯이 *아닌* 컴포넌트와 상호작용합니다.

`flame_riverpod`는 Flame 게임에서 `Provider`의 상태를 쉽게 관리할 수 있도록 `RiverpodAwareGameWidget`,
`RiverpodGameMixin`, `RiverpodComponentMixin`을 제공합니다.


<a id="usage"></a>

## 사용법

Flame `GameWidget`으로 `RiverpodAwareGameWidget`을 사용하고, `FlameGame`을 상속하는 게임에는
`RiverpodGameMixin` 믹스인을, Riverpod provider와 상호작용하는 모든 컴포넌트에는 `RiverpodComponentMixin`을
사용해야 합니다.

provider 구독은 Flame 컴포넌트의 생명주기에 맞춰 관리됩니다.
컴포넌트가 마운트될 때 초기화되고,
컴포넌트가 제거될 때 해제됩니다.

기본적으로 `RiverpodAwareGameWidget`은
Riverpod을 인식하는(즉, `RiverpodComponentMixin`을 사용하는) 컴포넌트가 마운트될 때와
제거될 때 다시 빌드됩니다.

```dart
/// 예제에서 발췌한 코드입니다. 꼭 확인해 보세요!
class RefExampleGame extends FlameGame with RiverpodGameMixin {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(TextComponent(text: 'Flame'));
    add(RiverpodAwareTextComponent());
  }
}

class RiverpodAwareTextComponent extends PositionComponent
    with RiverpodComponentMixin {
  late TextComponent textComponent;
  int currentValue = 0;

  @override
  void onMount() {
    addToGameWidgetBuild(() {
      ref.listen(countingStreamProvider, (p0, p1) {
        if (p1.hasValue) {
          currentValue = p1.value!;
          textComponent.text = '$currentValue';
        }
      });
    });
    super.onMount();
    add(textComponent = TextComponent(position: position + Vector2(0, 27)));
  }
}

```

`Component.onMount`에서의 작업 순서가 중요합니다. `RiverpodComponentMixin`은
(`RiverpodComponentMixin.onMount` 내부에서) `RiverpodGameMixin`과 상호작용하며, 해당 컴포넌트가 마운트되고
제거될 때 각각 리스너를 추가하고 제거하는 작업을 조율합니다.
