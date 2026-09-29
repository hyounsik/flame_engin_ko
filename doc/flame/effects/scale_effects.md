<a id="scale-effects"></a>

# 스케일 이펙트

스케일 이펙트는 시간에 따라 컴포넌트의 스케일을 변경하는 데 사용됩니다. 컴포넌트를 커지게 하거나,
작아지게 하거나, 특정 방향으로 스케일을 바꾸는 데 사용할 수 있습니다. 스케일은 `Vector2` 값으로
지정하며, x는 너비 배율을, y는 높이 배율을 나타냅니다. 이 이펙트는 `PositionComponent`처럼 스케일
속성을 가진 모든 컴포넌트에 적용할 수 있습니다.
크기 이펙트와 스케일 이펙트의 차이는, 크기 이펙트는 대상 컴포넌트의 크기만 변경하는 반면 스케일
이펙트는 모든 자식들의 "크기"도 함께 변경한다는 점입니다.


## `ScaleEffect.by`

이 이펙트는 대상의 스케일을 지정된 양만큼 변경합니다. 예를 들어 다음은 컴포넌트를 50% 더 크게
만듭니다.

 ```{flutter-app}
 :sources: ../flame/examples
 :page: scale_by_effect
 :show: widget code infobox
 :width: 180
 :height: 160
 ```

```dart
final effect = ScaleEffect.by(
  Vector2.all(1.5),
  EffectController(duration: 0.3),
);
```


## `ScaleEffect.to`

이 이펙트는 `ScaleEffect.by`와 비슷하게 동작하지만, 대상 스케일의 절대값을 설정합니다.

 ```{flutter-app}
 :sources: ../flame/examples
 :page: scale_to_effect
 :show: widget code infobox
 :width: 180
 :height: 160
 ```

```dart
final effect = ScaleEffect.to(
  Vector2.all(0.5),
  EffectController(duration: 0.5),
);
```
