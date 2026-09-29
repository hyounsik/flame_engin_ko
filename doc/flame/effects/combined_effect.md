<a id="combined-effect"></a>

# 결합 이펙트

이 이펙트는 여러 다른 이펙트를 동시에 실행하는 데 사용할 수 있습니다.

결합 이펙트는 왕복하도록 할 수도 있고(먼저 정방향으로 실행한 뒤 역방향으로 실행합니다), 미리 정한
횟수만큼 또는 무한히 반복할 수도 있습니다.

```{flutter-app}
:sources: ../flame/examples
:page: combined_effect
:show: widget code infobox
:width: 450
:height: 350
```

```dart
final effect = CombinedEffect(
  [
    MoveEffect.by(Vector2(200, 0), EffectController(duration: 1)),
    RotateEffect.by(tau / 4, EffectController(duration: 2)),
    ScaleEffect.by(Vector2.all(1.5), EffectController(duration: 1)),
  ],
  alternate: true,
  infinite: true,
);
```
