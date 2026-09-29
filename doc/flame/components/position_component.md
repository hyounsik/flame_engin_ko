# PositionComponent

게임에서 눈에 보이는 대부분의 객체에는 위치, 크기, 회전이 필요합니다. `PositionComponent`는 이러한
변환 속성을 제공하므로, 스프라이트, 애니메이션, 도형, 직접 만든 커스텀 컴포넌트 등 Flame의 거의 모든
시각 요소의 기반 클래스가 됩니다. Flutter의
[`Positioned`](https://api.flutter.dev/flutter/widgets/Positioned-class.html) 위젯과 같은 개념이지만,
게임에 맞춘 좌표계를 사용합니다.

이 클래스는 떠다니는 사각형이든, 회전하는 스프라이트든, 위치와 크기를 가진 무엇이든 화면에 배치된
객체를 나타냅니다. 자식을 추가하면 배치된 컴포넌트들의 그룹을 나타낼 수도 있습니다.

`PositionComponent`의 기본은 컴포넌트가 렌더링되는 방식을 변환하는 `position`, `size`, `scale`,
`angle`, `anchor`를 가진다는 것입니다.


<a id="position"></a>

## 위치

`position`은 부모를 기준으로 한 컴포넌트 앵커의 위치를 나타내는 `Vector2`일 뿐입니다. 부모가
`FlameGame`이면 뷰포트를 기준으로 합니다.


<a id="size"></a>

## 크기

`size`는 카메라의 줌 레벨이 1.0(줌 없음, 기본값)일 때의 컴포넌트 크기입니다.
`size`는 컴포넌트의 부모를 기준으로 하지 *않습니다*.


<a id="scale"></a>

## 스케일

`scale`은 컴포넌트와 그 자식들을 얼마나 확대/축소할지를 나타냅니다. `Vector2`로 표현되므로 `x`와
`y`를 같은 양만큼 바꿔 균일하게 스케일링하거나, `x`나 `y`를 서로 다른 양만큼 바꿔 불균일하게
스케일링할 수 있습니다.


<a id="angle"></a>

## 각도

`angle`은 앵커를 중심으로 한 회전 각도이며, 라디안 단위의 double로 표현됩니다. 부모의 각도를
기준으로 합니다.


<a id="native-angle"></a>

## 기본 각도(Native Angle)

`nativeAngle`은 시계 방향으로 측정한 라디안 단위의 각도로, 컴포넌트의 기본 방향을 나타냅니다.
[angle](#각도)이 0일 때 컴포넌트가 바라보는 방향을 정의하는 데 사용할 수 있습니다.

스프라이트 기반 컴포넌트가 특정 대상을 바라보게 할 때 특히 유용합니다. 스프라이트의 원본 이미지가
위/북쪽 방향을 향하고 있지 않다면, 컴포넌트가 대상을 바라보도록 계산한 각도에 오프셋을 더해야 올바르게
보입니다. 이런 경우 `nativeAngle`을 사용해 원본 이미지가 어느 방향을 향하고 있는지 컴포넌트에 알려 줄
수 있습니다.

예를 들어 동쪽 방향을 가리키는 총알 이미지가 있다면 `nativeAngle`을 pi/2 라디안으로 설정할 수
있습니다. 다음은 자주 쓰이는 방향과 그에 해당하는 기본 각도 값입니다.

방향 | 기본 각도 | 도(degree) 단위
----------|--------------|-------------
위/북쪽  | 0            | 0
아래/남쪽| pi 또는 -pi    | 180 또는 -180
왼쪽/서쪽 | -pi/2        | -90
오른쪽/동쪽| pi/2         | 90


<a id="anchor"></a>

## 앵커

```{flutter-app}
:sources: ../../flame/examples
:page: anchor
:show: widget code infobox
이 예제는 부모(빨간색) 컴포넌트와 자식(파란색) 컴포넌트의
`anchor` 지점을 바꿨을 때의 효과를 보여 줍니다. 컴포넌트를 탭하면
앵커 지점이 순서대로 바뀝니다. 자식 컴포넌트의 로컬 위치는
항상 (0, 0)이라는 점에 주목하세요.
```

`anchor`는 컴포넌트에서 위치와 회전의 기준이 되는 지점입니다(기본값은 `Anchor.topLeft`). 따라서
앵커를 `Anchor.center`로 설정하면 화면상의 컴포넌트 위치는 컴포넌트의 중심이 되고, `angle`을 적용하면
앵커를 중심으로, 즉 이 경우 컴포넌트의 중심을 기준으로 회전합니다. Flame이 컴포넌트를 "잡는"
컴포넌트 내부의 지점이라고 생각하면 됩니다.

컴포넌트의 `position`이나 `absolutePosition`을 조회하면 반환되는 좌표는 컴포넌트 `anchor`의
좌표입니다. 컴포넌트의 실제 `anchor`가 아닌 특정 앵커 지점의 위치를 알고 싶다면
`positionOfAnchor`와 `absolutePositionOfAnchor` 메서드를 사용할 수 있습니다.

```dart
final comp = PositionComponent(
  size: Vector2.all(20),
  anchor: Anchor.center,
);

// (0,0)을 반환합니다
final p1 = component.position;

// (10, 10)을 반환합니다
final p2 = component.positionOfAnchor(Anchor.bottomRight);
```

`anchor`를 사용할 때 흔히 하는 실수는 이를 자식 컴포넌트가 붙는 지점으로 착각하는 것입니다. 예를 들어
부모 컴포넌트의 `anchor`를 `Anchor.center`로 설정한다고 해서 자식 컴포넌트가 부모의 중심을 기준으로
배치되는 것은 아닙니다.

```{note}
자식 컴포넌트의 로컬 원점은 `anchor` 값과 관계없이
항상 부모 컴포넌트의 왼쪽 위 모서리입니다.
```


<a id="positioncomponent-children"></a>

## PositionComponent 자식

`PositionComponent`의 모든 자식은 부모를 기준으로 변환됩니다. 즉 `position`, `angle`, `scale`은
부모의 상태에 상대적입니다.
예를 들어 자식을 부모의 중심에 배치하고 싶다면 다음과 같이 합니다:

```dart
@override
void onLoad() {
  final parent = PositionComponent(
    position: Vector2(100, 100),
    size: Vector2(100, 100),
  );
  final child = PositionComponent(
    position: parent.size / 2,
    anchor: Anchor.center,
  );
  parent.add(child);
}
```

화면에 렌더링되는 대부분의 컴포넌트는 `PositionComponent`라는 점을 기억하세요. 따라서 이 패턴은
[SpriteComponent](sprite_components.md#spritecomponent)나
[SpriteAnimationComponent](sprite_components.md#spriteanimationcomponent) 등에서도 사용할 수 있습니다.


<a id="render-positioncomponent"></a>

## PositionComponent 렌더링

`PositionComponent`를 상속하는 컴포넌트의 `render` 메서드를 구현할 때는 왼쪽 위 모서리(0.0)를
기준으로 렌더링해야 한다는 점을 기억하세요. render 메서드는 컴포넌트가 화면의 어디에 렌더링될지를
처리해서는 안 됩니다. 컴포넌트를 어디에 어떻게 렌더링할지는 `position`, `angle`, `anchor` 속성으로
처리하면 나머지는 Flame이 자동으로 처리해 줍니다.

컴포넌트의 바운딩 박스가 화면의 어디에 있는지 알고 싶다면 `toRect` 메서드를 사용할 수 있습니다.

컴포넌트의 렌더링 방향을 바꾸고 싶다면 `flipHorizontally()`와 `flipVertically()`를 사용해
`render(Canvas canvas)` 중에 캔버스에 그려지는 모든 것을 앵커 지점을 기준으로 뒤집을 수도 있습니다.
이 메서드들은 모든 `PositionComponent` 객체에서 사용할 수 있으며, 특히 `SpriteComponent`와
`SpriteAnimationComponent`에서 유용합니다.

앵커를 `Anchor.center`로 바꾸지 않고 컴포넌트를 중심 기준으로 뒤집고 싶다면
`flipHorizontallyAroundCenter()`와 `flipVerticallyAroundCenter()`를 사용할 수 있습니다.
