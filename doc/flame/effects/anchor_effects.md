<a id="anchor-effects"></a>

# 앵커 이펙트

앵커 이펙트는 시간에 따라 컴포넌트의 앵커 지점을 변경하는 데 사용됩니다. 앵커 지점은 컴포넌트가
회전하고 스케일되는 기준점입니다.


## `AnchorByEffect`

대상 앵커의 위치를 지정된 오프셋만큼 변경합니다. 이 이펙트는 `AnchorEffect.by()`를 사용해 만들
수도 있습니다.

```{flutter-app}
:sources: ../flame/examples
:page: anchor_by_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = AnchorByEffect(
  Vector2(0.1, 0.1),
  EffectController(speed: 1),
);
```


## `AnchorToEffect`

대상 앵커의 위치를 변경합니다. 이 이펙트는 `AnchorEffect.to()`를 사용해 만들 수도 있습니다.

```{flutter-app}
:sources: ../flame/examples
:page: anchor_to_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = AnchorToEffect(
  Anchor.center,
  EffectController(speed: 1),
);
```
