<a id="size-effects"></a>

# 크기 이펙트

크기 이펙트는 시간에 따라 컴포넌트의 크기를 변경하는 데 사용됩니다. 컴포넌트를 커지게 하거나,
작아지게 하거나, 특정 방향으로 크기를 바꾸는 데 사용할 수 있습니다. 크기는 `Vector2` 값으로
지정하며, x는 너비를, y는 높이를 나타냅니다. 이 이펙트는 `PositionComponent`처럼 `SizeProvider`
인터페이스를 구현하는 모든 컴포넌트에 적용할 수 있습니다. 크기 이펙트와 스케일 이펙트의 차이는,
크기 이펙트는 대상 컴포넌트의 크기만 변경하는 반면 스케일 이펙트는 모든 자식들의 "크기"도 함께
변경한다는 점입니다.


## `SizeEffect.by`

이 이펙트는 대상 컴포넌트의 크기를 현재 크기를 기준으로 변경합니다. 예를 들어 대상의 크기가
`Vector2(100, 100)`이라면, 다음 이펙트가 적용되어 끝까지 실행된 후 새 크기는
`Vector2(120, 50)`이 됩니다.

 ```{flutter-app}
 :sources: ../flame/examples
 :page: size_by_effect
 :show: widget code infobox
 :width: 180
 :height: 160
 ```

```dart
final effect = SizeEffect.by(
   Vector2(-15, 30),
   EffectController(duration: 1),
);
```

`PositionComponent`의 크기는 음수일 수 없습니다. 이펙트가 크기를 음수 값으로 설정하려고 하면
크기는 0으로 제한됩니다.

이 이펙트가 동작하려면 대상 컴포넌트가 `SizeProvider` 인터페이스를 구현하고 렌더링할 때 `size`를
고려해야 한다는 점에 유의하세요. 이 API를 구현하는 내장 컴포넌트는 몇 개뿐이지만, 클래스 선언에
`implements SizeEffect`를 추가하면 언제든지 여러분의 컴포넌트가 크기 이펙트와 함께 동작하도록 만들
수 있습니다.

`SizeEffect`의 대안으로 `ScaleEffect`가 있습니다. 이는 더 일반적으로 동작하며, 대상 컴포넌트와
그 자식들을 모두 스케일합니다.


## `SizeEffect.to`

대상 컴포넌트의 크기를 지정된 크기로 변경합니다. 목표 크기는 음수일 수 없습니다.


 ```{flutter-app}
 :sources: ../flame/examples
 :page: size_to_effect
 :show: widget code infobox
 :width: 180
 :height: 160
 ```

```dart
final effect = SizeEffect.to(
  Vector2(90, 80),
  EffectController(duration: 1),
);
```
