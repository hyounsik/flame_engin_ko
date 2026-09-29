<a id="other-inputs-and-helpers"></a>

# 기타 입력과 헬퍼

이 문서는 키보드와 마우스 외의 입력 방법에 대해 설명합니다.


<a id="joystick"></a>

## 조이스틱

Flame은 게임 입력을 받기 위한 가상 조이스틱을 만들 수 있는 컴포넌트를 제공합니다.
이 기능을 사용하려면 `JoystickComponent`를 만들고 원하는 대로 설정한 뒤 게임에 추가하면 됩니다.

더 잘 이해하려면 다음 예제를 살펴보세요.

```dart
class MyGame extends FlameGame {

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final image = await images.load('assets/images/joystick.png');
    final sheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 6,
      rows: 1,
    );
    final joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: sheet.getSpriteById(1),
        size: Vector2.all(100),
      ),
      background: SpriteComponent(
        sprite: sheet.getSpriteById(0),
        size: Vector2.all(150),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );

    final player = Player(joystick);
    add(player);
    add(joystick);
  }
}

class Player extends SpriteComponent with HasGameRef {
  Player(this.joystick)
    : super(
        anchor: Anchor.center,
        size: Vector2.all(100.0),
      );

  /// 픽셀/초
  double maxSpeed = 300.0;

  final JoystickComponent joystick;

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('assets/images/layers/player.png');
    position = gameRef.size / 2;
  }

  @override
  void update(double dt) {
    if (joystick.direction != JoystickDirection.idle) {
      position.add(joystick.relativeDelta  * maxSpeed * dt);
      angle = joystick.delta.screenAngle();
    }
  }
}
```

이 예제에서는 `MyGame`과 `Player` 클래스를 만들었습니다.
`MyGame`은 조이스틱을 만들고, `Player`를 생성할 때 그 조이스틱을 전달합니다.
`Player` 클래스에서는 조이스틱의 현재 상태에 따라 동작합니다.

조이스틱에는 상태에 따라 값이 바뀌는 필드가 몇 가지 있습니다.

조이스틱의 상태를 알려면 다음 필드를 사용해야 합니다.

- `intensity`: 노브가 중심에서 조이스틱 가장자리(`knobRadius`가 설정되어 있다면 그 값)까지 드래그된
  비율 [0.0, 1.0]입니다.
- `delta`: 노브가 중심에서 드래그된 절대적인 양(`Vector2`로 정의됨)입니다.
- `relativeDelta`: 노브가 현재 기준 위치에서 조이스틱 가장자리 쪽으로 당겨진 비율과 방향을
  `Vector2`로 나타낸 값입니다.

조이스틱과 함께 사용할 버튼을 만들고 싶다면
[`HudButtonComponent`](#hudbuttoncomponent)를 살펴보세요.

조이스틱 구현의 전체 코드는
[Joystick 예제](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/input/joystick_example.dart)를
참고하세요.
또한 [JoystickComponent 동작 모습](https://examples.flame-engine.org/#/Input_Joystick)에서
조이스틱 입력 기능이 게임에 통합된 라이브 예제를 볼 수 있습니다.

더 도전해 보고 싶다면
[Advanced Joystick 예제](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/input/joystick_advanced_example.dart)를
살펴보세요.
고급 기능으로 무엇을 더 할 수 있는지는
[라이브 데모](https://examples.flame-engine.org/#/Input_Joystick_Advanced)에서 확인하세요.


## HudButtonComponent

`HudButtonComponent`는 위치 대신 `Viewport` 가장자리로부터의 여백(margin)으로 정의할 수 있는
버튼입니다. 이 컴포넌트는 `button`과 `buttonDown`이라는 두 개의 `PositionComponent`를 받습니다.
첫 번째는 버튼이 대기 상태일 때 사용되고, 두 번째는 버튼이 눌리고 있을 때 표시됩니다. 버튼이
눌렸을 때 모양을 바꾸고 싶지 않거나 `button` 컴포넌트에서 이를 처리한다면 두 번째는 선택
사항입니다.

이름에서 알 수 있듯이 이 버튼은 기본적으로 hud이므로, 게임의 카메라가 움직여도 화면에 고정되어
있습니다. `hudButtonComponent.respectCamera = true;`로 설정하면 이 컴포넌트를 hud가 아닌 형태로
사용할 수도 있습니다.

버튼이 눌리는 것(흔히 하는 처리입니다)과 떼어지는 것에 반응하고 싶다면, `onPressed`와
`onReleased` 인자로 콜백 함수를 전달하거나, 컴포넌트를 상속하여 `onTapDown`, `onTapUp`,
`onTapCancel`을 오버라이드하고 그곳에 로직을 구현할 수 있습니다.


## SpriteButtonComponent

`SpriteButtonComponent`는 두 개의 `Sprite`로 정의되는 버튼으로, 하나는 버튼이 눌렸을 때를, 다른
하나는 버튼이 떼어졌을 때를 나타냅니다.


## ButtonComponent

`ButtonComponent`는 두 개의 `PositionComponent`로 정의되는 버튼으로, 하나는 버튼이 눌렸을 때를,
다른 하나는 버튼이 떼어졌을 때를 나타냅니다. 버튼에 스프라이트만 사용하고 싶다면 대신
[](#spritebuttoncomponent)를 사용하세요. 하지만 예를 들어 `SpriteAnimationComponent`를 버튼으로
쓰고 싶거나, 순수한 스프라이트가 아닌 다른 것을 쓰고 싶을 때는 이 컴포넌트가 유용합니다.


<a id="gamepad"></a>

## 게임패드

Flame에는 외부 게임 컨트롤러(게임패드)를 지원하는 전용 플러그인이 있습니다.
자세한 내용은 [Gamepads 저장소](https://github.com/flame-engine/gamepads)에서 확인하세요.


## AdvancedButtonComponent

`AdvancedButtonComponent`는 포인터의 각 단계마다 별도의 상태를 가집니다.
각 상태마다 스킨을 커스터마이즈할 수 있으며, 각 스킨은 `PositionComponent`로 표현됩니다.

`AdvancedButtonComponent`의 모양을 커스터마이즈하는 데 사용할 수 있는 필드는 다음과 같습니다.

- `defaultSkin`: 버튼에 기본으로 표시되는 컴포넌트입니다.
- `downSkin`: 버튼을 클릭하거나 탭했을 때 표시되는 컴포넌트입니다.
- `hoverSkin`: 버튼 위에 마우스가 올라가 있을 때 표시되는 컴포넌트입니다(데스크톱과 웹).
- `defaultLabel`: 스킨 위에 표시되는 컴포넌트입니다. 자동으로 가운데 정렬됩니다.
- `disabledSkin`: 버튼이 비활성화되었을 때 표시되는 컴포넌트입니다.
- `disabledLabel`: 버튼이 비활성화되었을 때 스킨 위에 표시되는 컴포넌트입니다.

버튼에 반응하려면 `onPressed`, `onReleased`, `onCancelled` 콜백을 전달하세요. `onCancelled`
콜백은 탭이 취소될 때 호출됩니다. 예를 들어 포인터를 떼기 전에 버튼 밖으로 드래그한 경우이며,
이때 버튼은 기본 상태로 돌아갑니다.


## ToggleButtonComponent

[ToggleButtonComponent]는 선택됨과 선택되지 않음 상태를 전환할 수 있는
[AdvancedButtonComponent]입니다.

기존 스킨 외에도 [ToggleButtonComponent]에는 다음 스킨들이 있습니다.

- `defaultSelectedSkin`: 버튼이 선택되었을 때 표시되는 컴포넌트입니다.
- `downAndSelectedSkin`: 선택 가능한 버튼이 선택된 상태에서 눌렸을 때 표시되는 컴포넌트입니다.
- `hoverAndSelectedSkin`: 선택 가능하고 선택된 버튼 위에 마우스가 올라가 있을 때입니다(데스크톱과
  웹).
- `disabledAndSelectedSkin`: 버튼이 선택된 상태이면서 비활성화 상태일 때입니다.
- `defaultSelectedLabel`: 버튼이 선택되었을 때 스킨 위에 표시되는 컴포넌트입니다.


<a id="ignoreevents-mixin"></a>

## IgnoreEvents 믹스인

컴포넌트 서브트리가 이벤트를 받지 않게 하려면 `IgnoreEvents` 믹스인을 사용할 수 있습니다.
이 믹스인을 추가한 뒤 `ignoreEvents = true`(믹스인을 추가하면 기본값)로 설정하면 이벤트가
컴포넌트와 그 자손에 도달하지 않도록 끌 수 있으며, 다시 이벤트를 받고 싶을 때는 `false`로
설정하면 됩니다.

현재 모든 이벤트는 컴포넌트 트리 전체를 거치므로, 이는 최적화 목적으로 사용할 수 있습니다.
