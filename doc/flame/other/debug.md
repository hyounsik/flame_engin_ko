<a id="debug-features"></a>

# 디버그 기능


<a id="flamegame-features"></a>

## FlameGame 기능

Flame은 `FlameGame` 클래스에 몇 가지 디버깅 기능을 제공합니다. 이 기능들은 `debugMode` 속성이
`true`로 설정되어 있을 때(또는 `true`가 되도록 오버라이드했을 때) 활성화됩니다.
`debugMode`가 활성화되면 각 `PositionComponent`는 자신의 경계 크기와 함께 렌더링되고, 화면에
위치가 표시됩니다. 이렇게 하면 컴포넌트의 경계와 위치를 눈으로 확인할 수 있습니다.

[`FlameGame`의 디버깅 기능을 보여 주는 동작 예제](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/components/debug_example.dart)를 확인해 보세요.


<a id="devtools-extension"></a>

## Devtools 확장

[Flutter DevTools](https://docs.flutter.dev/tools/devtools/overview)를 열면 "Flame"이라는 새
탭이 보입니다. 이 탭에서는 현재 게임에 대한 정보를 보여 줍니다. 예를 들어 컴포넌트 트리 시각화,
게임을 재생, 일시 정지, 한 단계씩 진행하는 기능, 선택한 컴포넌트에 대한 정보 등을 제공합니다.


## FPS

Flame이 보고하는 FPS는 대상 플랫폼에 따라 Flutter DevTools 등에서 보고하는 값보다 약간 낮을 수
있습니다. 게임이 실제로 몇 FPS로 실행되고 있는지는 Flame이 보고하는 FPS를 기준으로 삼아야 합니다.
게임 루프가 바로 그 값에 묶여 있기 때문입니다.


### FpsComponent

`FpsComponent`는 컴포넌트 트리의 어디에든 추가할 수 있으며, 게임이 현재 몇 FPS로 렌더링되고 있는지
추적합니다. 이 값을 게임 안에 텍스트로 표시하고 싶다면 [](#fpstextcomponent)를 사용하세요.


### FpsTextComponent

`FpsTextComponent`는 `FpsComponent`를 감싼 [TextComponent]일 뿐입니다. `FpsComponent`를 사용할
때는 대개 현재 FPS를 어딘가에 표시하고 싶어 하기 때문입니다.


[TextComponent]: ../rendering/text_rendering.md#textcomponent


### ChildCounterComponent

`ChildCounterComponent`는 어떤 컴포넌트(`target`)가 가진 `T` 타입 자식의 수를 매초 렌더링하는
컴포넌트입니다.
예를 들어, 다음 코드는 게임 `world`의 자식인 `SpriteAnimationComponent`의 수를 렌더링합니다.

```dart
add(
  ChildCounterComponent<SpriteAnimationComponent>(
    target: world,
  ),
);
```


### TimeTrackComponent

이 컴포넌트를 사용하면 개발자가 코드 안에서 소요된 시간을 추적할 수 있습니다. 코드의 특정 부분에서
소요되는 시간을 성능 디버깅할 때 유용합니다.

사용하려면 게임의 어딘가에 추가합니다(디버그 기능이므로 디버그 빌드/플레이버에서만 컴포넌트를
추가하기를 권장합니다).

```dart
add(TimeTrackComponent());
```

그런 다음 시간을 추적하고 싶은 코드 구간에서 다음과 같이 합니다.

```dart
void update(double dt) {
  TimeTrackComponent.start('MyComponent.update');
  // ...
  TimeTrackComponent.end('MyComponent.update');
}
```

위와 같이 호출하면 추가된 `TimeTrackComponent`가 경과 시간을 마이크로초 단위로 렌더링합니다.
