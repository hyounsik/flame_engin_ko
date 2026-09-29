<a id="move-effects"></a>

# 이동 이펙트

이동 이펙트는 시간에 따라 컴포넌트의 위치를 변경하는 특별한 종류의 이펙트입니다. 예를 들어
캐릭터를 한 지점에서 다른 지점으로 옮기거나, 점프하게 하거나, 경로를 따라가게 하고 싶다면 미리
정의된 이동 이펙트 중 하나를 사용할 수 있습니다.


## `MoveByEffect`

이 이펙트는 `PositionComponent`에 적용되며, 지정된 `offset`만큼 컴포넌트를 이동시킵니다. 이
오프셋은 대상의 현재 위치를 기준으로 합니다.

```{flutter-app}
:sources: ../flame/examples
:page: move_by_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = MoveByEffect(
  Vector2(0, -10),
  EffectController(duration: 0.5),
);
```

컴포넌트가 현재 `Vector2(250, 200)`에 있다면, 이펙트가 끝났을 때 위치는 `Vector2(250, 190)`이
됩니다.

한 컴포넌트에 여러 이동 이펙트를 동시에 적용할 수 있습니다. 결과는 개별 이펙트들을 모두 중첩한
것이 됩니다.


## `MoveToEffect`

이 이펙트는 `PositionComponent`를 현재 위치에서 지정된 목적지까지 직선으로 이동시킵니다.

```{flutter-app}
:sources: ../flame/examples
:page: move_to_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = MoveToEffect(
  Vector2(100, 500),
  EffectController(duration: 3),
);
```

같은 컴포넌트에 이런 이펙트를 여러 개 붙이는 것은 가능하지만 권장하지 않습니다.


## `MoveAlongPathEffect`

이 이펙트는 `PositionComponent`를 컴포넌트의 현재 위치를 기준으로 지정된 경로를 따라
이동시킵니다. 경로에는 비선형 구간이 있어도 되지만, 하나로 이어져 있어야 합니다. 컴포넌트 위치가
갑자기 튀는 것을 피하려면 경로를 `Vector2.zero()`에서 시작하는 것을 권장합니다.

```{flutter-app}
:sources: ../flame/examples
:page: move_along_path_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = MoveAlongPathEffect(
  Path()..quadraticBezierTo(100, 0, 50, -50),
  EffectController(duration: 1.5),
);
```

선택적인 플래그 `absolute: true`를 지정하면 이펙트 안의 경로를 절대 경로로 선언합니다. 즉, 대상은
시작 시 경로의 시작점으로 "점프"한 뒤, 캔버스에 그려진 곡선인 것처럼 그 경로를 따라갑니다.

또 다른 플래그 `oriented: true`는 대상이 곡선을 따라 이동할 뿐만 아니라, 각 지점에서 곡선이 향하는
방향으로 스스로 회전하도록 합니다. 이 플래그를 사용하면 이펙트는 이동 이펙트이자 회전 이펙트가
됩니다.
