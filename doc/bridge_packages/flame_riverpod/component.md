<a id="component"></a>

# 컴포넌트


## ComponentRef

`ComponentRef`는 개별 `Component`에 Riverpod 기능을 노출하며, `flutter_riverpod`의
`WidgetRef`에 해당합니다.


## RiverpodComponentMixin

`RiverpodComponentMixin`은 개별 `Component`를 대신해 리스너의 생명주기를 관리합니다.

이 믹스인을 사용하는 `Component`는 `onMount` 메서드에서 `super.onMount`를 호출하기 *전에*
`addToGameWidgetBuild`를 사용해 리스너(예: `ref.watch` 또는 `ref.listen`)를 추가해야 합니다. `super.onMount`는
대기 중인 리스너를 관리하고, `onRemove` 안에서 사용자를 대신해 리스너를 해제합니다.

```dart

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


## RiverpodGameMixin

`RiverpodGameMixin`은 모든 컴포넌트의 리스너를 `RiverpodAwareGameWidget`의 build 메서드에
제공합니다.
`addToGameWidgetBuild` 메서드는 `RiverpodGameMixin`에서도 사용할 수 있으므로,
Game 클래스에서 `ComponentRef` 메서드에 직접 접근할 수 있습니다.
