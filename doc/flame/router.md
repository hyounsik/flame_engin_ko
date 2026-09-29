```{flutter-app}
:sources: ../flame/examples
:page: router
:show: widget code infobox

이 예제 앱은 `RouterComponent`를 사용해 게임 안에서 여러 화면을 오가는 방법을 보여 줍니다.
또한 "pause" 버튼을 누르면 시간이 멈추고 그 아래 페이지의 내용에 시각 효과가 적용됩니다.
```


# RouterComponent

대부분의 게임은 화면 하나로 이루어지지 않습니다. 메인 메뉴, 설정 페이지, 게임플레이 화면, 팝업
다이얼로그 등이 있습니다. 이런 화면 간의 전환을 관리하다 보면 금방 복잡해집니다. `RouterComponent`는
스택 기반의 내비게이션 모델을 제공하여 이 문제를 해결합니다. 개념적으로는 Flutter의
[Navigator][Flutter Navigator] 클래스와 비슷하지만, Flutter 위젯 대신 Flame 컴포넌트를 다룹니다.

일반적인 게임은 보통 여러 페이지로 구성됩니다. 스플래시 화면, 시작 메뉴 페이지, 설정 페이지, 크레딧,
메인 게임 페이지, 여러 팝업 등입니다. 라우터는 이 모든 목적지를 정리하고 그 사이를 전환할 수 있게
해 줍니다.

내부적으로 `RouterComponent`는 라우트 스택을 가지고 있습니다. 어떤 라우트를 표시하도록 요청하면, 그
라우트는 스택의 다른 모든 페이지 위에 놓입니다. 나중에 `pop()`을 호출해 스택의 맨 위 페이지를 제거할
수 있습니다. 라우터의 페이지는 고유한 이름으로 식별됩니다.

라우터의 각 페이지는 투명하거나 불투명할 수 있습니다. 페이지가 불투명하면 스택에서 그 아래에 있는
페이지는 렌더링되지 않으며 포인터 이벤트(탭이나 드래그 등)도 받지 않습니다. 반대로 페이지가 투명하면
그 아래 페이지도 정상적으로 렌더링되고 이벤트를 받습니다. 이런 투명 페이지는 모달 다이얼로그,
인벤토리나 대화 UI 등을 구현할 때 유용합니다. 라우트를 시각적으로는 투명하게 하되 아래 라우트는
이벤트를 받지 않게 하고 싶다면, [이벤트 캡처 믹스인](inputs/inputs.md) 중 하나를 사용해 이벤트를
캡처하는 배경 컴포넌트를 라우트에 추가하세요.

사용 예:

```dart
class MyGame extends FlameGame {
  late final RouterComponent router;

  @override
  void onLoad() {
    add(
      router = RouterComponent(
        routes: {
          'home': Route(HomePage.new),
          'level-selector': Route(LevelSelectorPage.new),
          'settings': Route(SettingsPage.new, transparent: true),
          'pause': PauseRoute(),
          'confirm-dialog': OverlayRoute.existing(),
        },
        initialRoute: 'home',
      ),
    );
  }
}

class PauseRoute extends Route { ... }
```

```{note}
가져온 패키지 중에 `Route`라는 이름의 다른 클래스를 export하는 패키지가 있다면
`hide Route`를 사용하세요.

예: `import 'package:flutter/material.dart' hide Route;`
```


[Flutter Navigator]: https://api.flutter.dev/flutter/widgets/Navigator-class.html


## Route

**Route** 컴포넌트는 특정 페이지의 내용에 대한 정보를 담고 있습니다. `Route`는 `RouterComponent`의
자식으로 마운트됩니다.

`Route`의 주요 속성은 `builder`로, 해당 페이지의 내용을 담은 컴포넌트를 생성하는 함수입니다.

또한 라우트는 투명하거나 불투명(기본값)할 수 있습니다. 불투명한 라우트는 그 아래 라우트가
렌더링되거나 포인터 이벤트를 받지 못하게 하지만, 투명한 라우트는 그렇지 않습니다. 경험적으로,
전체 화면을 차지하는 라우트는 불투명하게, 화면의 일부만 덮는 라우트는 투명하게 선언하세요.

기본적으로 라우트는 스택에서 pop된 뒤에도 페이지 컴포넌트의 상태를 유지하며, `builder` 함수는
라우트가 처음 활성화될 때만 호출됩니다. `maintainState`를 `false`로 설정하면 라우트가 라우트
스택에서 pop된 뒤 페이지 컴포넌트를 버리고, 라우트가 활성화될 때마다 `builder` 함수를 호출합니다.

현재 라우트는 `pushReplacementNamed`나 `pushReplacement`로 교체할 수 있습니다. 각 메서드는 단순히
현재 라우트에 `pop`을 실행한 다음 `pushNamed` 또는 `pushRoute`를 실행합니다.


## WorldRoute

**WorldRoute**는 라우터를 통해 게임의 활성 월드를 설정할 수 있게 해 주는 특별한 라우트입니다.
예를 들어 게임에서 별도의 월드로 구현된 레벨을 교체할 때 이 유형의 라우트를 사용할 수 있습니다.

기본적으로 `WorldRoute`는 현재 월드를 새 월드로 교체하며, 스택에서 pop된 뒤에도 월드의 상태를
유지합니다. 라우트가 활성화될 때마다 월드를 다시 생성하고 싶다면 `maintainState`를 `false`로
설정하세요.

내장 `CameraComponent`를 사용하지 않는다면, 사용하려는 카메라를 생성자에 명시적으로 전달할 수
있습니다.

```dart
final router = RouterComponent(
  routes: {
    'level1': WorldRoute(MyWorld1.new),
    'level2': WorldRoute(MyWorld2.new, maintainState: false),
  },
);

class MyWorld1 extends World {
  @override
  Future<void> onLoad() async {
    add(BackgroundComponent());
    add(PlayerComponent());
  }
}

class MyWorld2 extends World {
   @override
   Future<void> onLoad() async {
      add(BackgroundComponent());
      add(PlayerComponent());
      add(EnemyComponent());
   }
}
```


## OverlayRoute

**OverlayRoute**는 라우터를 통해 게임 오버레이를 추가할 수 있게 해 주는 특별한 라우트입니다. 이
라우트는 기본적으로 투명합니다.

`OverlayRoute`에는 두 가지 생성자가 있습니다. 첫 번째 생성자는 오버레이의 위젯을 어떻게 빌드할지
기술하는 builder 함수를 받습니다. 두 번째 생성자는 builder 함수가 이미 `GameWidget` 안에 지정되어
있을 때 사용할 수 있습니다:

```dart
final router = RouterComponent(
  routes: {
    'ok-dialog': OverlayRoute(
      (context, game) {
        return Center(
          child: DecoratedContainer(...),
        );
      },
    ),  // OverlayRoute
    'confirm-dialog': OverlayRoute.existing(),
  },
);
```

`GameWidget` 안에 정의된 오버레이는 미리 routes 맵에 선언할 필요조차 없습니다.
`RouterComponent.pushOverlay()` 메서드가 대신 처리해 줍니다. 오버레이 라우트가 등록되면 일반적인
`.pushNamed()` 메서드나 `.pushOverlay()`로 활성화할 수 있습니다. 두 메서드는 완전히 같은 동작을
하지만, 두 번째 메서드를 사용하면 일반 라우트가 아닌 오버레이를 추가한다는 것을 코드에서 더 명확하게
드러낼 수 있습니다.

현재 오버레이는 `pushReplacementOverlay`로 교체할 수 있습니다. 이 메서드는 push되는 오버레이의
상태에 따라 `pushReplacementNamed` 또는 `pushReplacement`를 실행합니다.


## ValueRoute

```{flutter-app}
:sources: ../flame/examples
:page: value_route
:show: widget code infobox
:width: 280
```

**ValueRoute**는 최종적으로 스택에서 pop될 때 값을 반환하는 라우트입니다. 예를 들어 사용자에게
어떤 응답을 요청하는 다이얼로그 상자에 이런 라우트를 사용할 수 있습니다.

`ValueRoute`를 사용하려면 두 단계가 필요합니다:

1. `ValueRoute<T>` 클래스를 상속하는 라우트를 만듭니다. 여기서 `T`는 라우트가 반환할 값의
   타입입니다. 그 클래스 안에서 `build()` 메서드를 오버라이드하여 표시할 컴포넌트를 구성합니다.
   컴포넌트는 `completeWith(value)` 메서드를 사용해 라우트를 pop하고 지정한 값을 반환해야 합니다.

   ```dart
   class YesNoDialog extends ValueRoute<bool> {
     YesNoDialog(this.text) : super(value: false);
     final String text;

     @override
     Component build() {
       return PositionComponent(
         children: [
           RectangleComponent(),
           TextComponent(text: text),
           Button(
             text: 'Yes',
             action: () => completeWith(true),
           ),
           Button(
             text: 'No',
             action: () => completeWith(false),
           ),
         ],
       );
     }
   }
   ```

2. `Router.pushAndWait()`를 사용해 라우트를 표시합니다. 이 메서드는 라우트가 반환한 값으로
   완료되는 future를 반환합니다.

   ```dart
   Future<void> foo() async {
     final result = await game.router.pushAndWait(YesNoDialog('Are you sure?'));
     if (result) {
       // ... 사용자가 확신함
     } else {
       // ... 사용자가 확신하지 못함
     }
   }
   ```
