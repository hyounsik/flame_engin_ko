<a id="color-effects"></a>

# 색상 이펙트

색상 이펙트는 시간에 따라 컴포넌트의 색상을 변경하는 데 사용됩니다. 컴포넌트에 색조를 입히거나,
불투명도를 바꾸거나, 색상 필터를 적용하는 데 사용할 수 있습니다.


## ColorEffect

이 이펙트는 paint의 기본 색상을 변경하여, 렌더링된 컴포넌트가 주어진 범위 안에서 지정된 색상으로
물들게 합니다.

사용 예시:

```{flutter-app}
:sources: ../flame/examples
:page: color_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = ColorEffect(
  const Color(0xFF00FF00),
  EffectController(duration: 1.5),
  opacityFrom: 0.2,
  opacityTo: 0.8,
);
```

`opacityFrom`과 `opacityTo` 인자는 컴포넌트에 색상을 "얼마나" 적용할지를 결정합니다. 이 예제에서
이펙트는 20%에서 시작하여 80%까지 올라갑니다.

**참고:** 이 이펙트의 구현 방식과 Flutter의 `ColorFilter` 클래스가 동작하는 방식 때문에, 이
이펙트는 다른 `ColorEffect`와 섞어 쓸 수 없습니다. 컴포넌트에 둘 이상을 추가하면 마지막 것만
적용됩니다.


## `OpacityToEffect`

이 이펙트는 시간에 따라 대상의 불투명도를 지정된 알파 값으로 변경합니다.
`OpacityProvider`를 구현하는 컴포넌트에만 적용할 수 있습니다.

```{flutter-app}
:sources: ../flame/examples
:page: opacity_to_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = OpacityEffect.to(
  0.2,
  EffectController(duration: 0.75),
);
```

컴포넌트가 여러 paint를 사용한다면, `target` 파라미터를 사용해 이펙트가 그중 하나 이상의 paint를
대상으로 하도록 할 수 있습니다. `HasPaint` 믹스인은 `OpacityProvider`를 구현하며, 원하는 paintId에
대한 provider를 쉽게 만들 수 있는 API를 제공합니다. paintId가 하나라면 `opacityProviderOf`를,
여러 개라면 `opacityProviderOfList`를 사용할 수 있습니다.


```{flutter-app}
:sources: ../flame/examples
:page: opacity_effect_with_target
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = OpacityEffect.to(
  0.2,
  EffectController(duration: 0.75),
  target: component.opacityProviderOfList(
    paintIds: const [paintId1, paintId2],
  ),
);
```

불투명도 값 0은 완전히 투명한 컴포넌트에, 불투명도 값 1은 완전히 불투명한 컴포넌트에 해당합니다.
편의 생성자 `OpacityEffect.fadeOut()`과 `OpacityEffect.fadeIn()`은 각각 대상을 완전히 투명하게 /
완전히 보이게 애니메이션합니다.


## `OpacityByEffect`

이 이펙트는 대상의 불투명도를 지정된 알파 값만큼 상대적으로 변경합니다. 예를 들어 다음 이펙트는
대상의 불투명도를 `90%`만큼 변경합니다.

```{flutter-app}
:sources: ../flame/examples
:page: opacity_by_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = OpacityEffect.by(
  0.9,
  EffectController(duration: 0.75),
);
```

현재 이 이펙트는 `HasPaint` 믹스인을 가진 컴포넌트에만 적용할 수 있습니다. 대상 컴포넌트가 여러
paint를 사용한다면, `paintId` 파라미터를 사용해 이펙트가 개별 색상 중 어느 것이든 대상으로 하도록
할 수 있습니다.


## GlowEffect

```{note}
이 이펙트는 현재 실험적이며, API가 향후 변경될 수 있습니다.
```

이 이펙트는 지정된 `glow-strength`에 따라 대상 주위에 빛나는 그림자를 적용합니다. 그림자의 색상은
대상의 paint 색상입니다. 예를 들어 다음 이펙트는 강도 `10`으로 대상 주위에 빛나는 그림자를
적용합니다.

```{flutter-app}
:sources: ../flame/examples
:page: glow_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = GlowEffect(
  10.0,
  EffectController(duration: 3),
);
```

현재 이 이펙트는 `HasPaint` 믹스인을 가진 컴포넌트에만 적용할 수 있습니다.


## `HueToEffect`

이 이펙트는 시간에 따라 대상의 색조(hue)를 지정된 각도(라디안)로 변경합니다.
`HueProvider`를 구현하는 컴포넌트에만 적용할 수 있습니다.

```dart
final effect = HueEffect.to(
  pi / 2,
  EffectController(duration: 3),
);
```


## `HueByEffect`

이 이펙트는 대상의 색조를 지정된 각도(라디안)만큼 상대적으로 회전시킵니다.
`HueProvider`를 구현하는 컴포넌트에만 적용할 수 있습니다.

```{flutter-app}
:sources: ../flame/examples
:page: hue_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = HueEffect.by(
  2 * pi,
  EffectController(duration: 3),
);
```

두 이펙트 모두 `HueProvider`를 구현하는 모든 컴포넌트를 대상으로 할 수 있습니다. `HasPaint`
믹스인은 `HueProvider`를 구현하며, 필요한 `ColorFilter` 업데이트를 자동으로 처리합니다.

> [!TIP]
> **성능 참고**: `HueEffect`는 `Paint`의 `colorFilter`를 직접 수정하므로 매우 효율적입니다.
> 컴포넌트가 많다면 `saveLayer()`를 사용해 오버헤드가 훨씬 큰 `HueDecorator`보다 이 이펙트를
> 사용하는 것이 좋습니다.
