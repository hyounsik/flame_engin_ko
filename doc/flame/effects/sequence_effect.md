<a id="sequence-effect"></a>

# 시퀀스 이펙트

이 이펙트는 여러 다른 이펙트를 차례로 실행하는 데 사용할 수 있습니다. 구성 이펙트들은 서로 다른
종류여도 됩니다.

시퀀스 이펙트는 왕복하도록 할 수도 있고(시퀀스를 먼저 정방향으로 실행한 뒤 역방향으로 실행합니다),
미리 정한 횟수만큼 또는 무한히 반복할 수도 있습니다.

```{flutter-app}
:sources: ../flame/examples
:page: sequence_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = SequenceEffect([
  ScaleEffect.by(
    Vector2.all(1.5),
    EffectController(
      duration: 0.2,
      alternate: true,
    ),
  ),
  MoveEffect.by(
    Vector2(30, -50),
    EffectController(
      duration: 0.5,
    ),
  ),
  OpacityEffect.to(
    0,
    EffectController(
      duration: 0.3,
    ),
  ),
  RemoveEffect(),
]);
```
