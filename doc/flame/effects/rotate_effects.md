<a id="rotate-effects"></a>

# 회전 이펙트

회전 이펙트는 시간에 따라 컴포넌트의 방향을 변경하는 데 사용됩니다. 컴포넌트를 빙글빙글 돌리거나,
대상 쪽으로 돌리거나, 한 점을 중심으로 회전시키는 데 사용할 수 있습니다. 회전은 라디안 단위로
지정하며, 이 이펙트는 `PositionComponent`처럼 회전 속성을 가진 모든 컴포넌트에 적용할 수 있습니다.


## `RotateEffect.by`

대상을 현재 방향을 기준으로 지정된 각도만큼 시계 방향으로 회전시킵니다. 각도는 라디안 단위입니다.
예를 들어 다음 이펙트는 대상을 시계 방향으로 90º(라디안으로 =[tau]/4) 회전시킵니다.

```{flutter-app}
:sources: ../flame/examples
:page: rotate_by_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = RotateEffect.by(
  tau/4,
  EffectController(duration: 2),
);
```


## `RotateEffect.to`

대상을 지정된 각도까지 시계 방향으로 회전시킵니다. 예를 들어 다음은 대상이 동쪽을 바라보도록
회전시킵니다(0º는 북쪽, 90º=[tau]/4는 동쪽, 180º=tau/2는 남쪽, 270º=tau*3/4는 서쪽).

```{flutter-app}
:sources: ../flame/examples
:page: rotate_to_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = RotateEffect.to(
  tau/4,
  EffectController(duration: 2),
);
```


## `RotateAroundEffect`

대상을 지정된 중심점을 기준으로, 현재 방향에서 지정된 각도만큼 시계 방향으로 회전시킵니다. 각도는
라디안 단위입니다. 예를 들어 다음 이펙트는 대상을 (100, 100)을 중심으로 시계 방향으로
90º(라디안으로 =[tau]/4) 회전시킵니다.

```{flutter-app}
:sources: ../flame/examples
:page: rotate_around_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = RotateAroundEffect(
  tau/4,
  center: Vector2(100, 100),
  EffectController(duration: 2),
);
```

[tau]: https://en.wikipedia.org/wiki/Tau_(mathematical_constant)
