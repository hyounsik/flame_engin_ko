<a id="effect-controllers"></a>

# 이펙트 컨트롤러

`EffectController`는 이펙트가 시간에 따라 어떻게 변화해야 하는지를 기술하는 객체입니다. 이펙트의
초기값을 진행도 0%, 최종값을 진행도 100%로 생각한다면, 이펙트 컨트롤러의 역할은 초 단위로 측정되는
"물리적" 시간을 0에서 1까지 변하는 "논리적" 시간으로 매핑하는 것입니다.

Flame 프레임워크는 여러 이펙트 컨트롤러를 제공합니다.

- [`EffectController`](#effectcontroller)
- [`LinearEffectController`](#lineareffectcontroller)
- [`ReverseLinearEffectController`](#reverselineareffectcontroller)
- [`CurvedEffectController`](#curvedeffectcontroller)
- [`ReverseCurvedEffectController`](#reversecurvedeffectcontroller)
- [`PauseEffectController`](#pauseeffectcontroller)
- [`RepeatedEffectController`](#repeatedeffectcontroller)
- [`InfiniteEffectController`](#infiniteeffectcontroller)
- [`SequenceEffectController`](#sequenceeffectcontroller)
- [`SpeedEffectController`](#speedeffectcontroller)
- [`DelayedEffectController`](#delayedeffectcontroller)
- [`NoiseEffectController`](#noiseeffectcontroller)
- [`RandomEffectController`](#randomeffectcontroller)
- [`SineEffectController`](#sineeffectcontroller)
- [`ZigzagEffectController`](#zigzageffectcontroller)


## `EffectController`

기본 `EffectController` 클래스는 다양한 일반적인 컨트롤러를 만들 수 있는 팩토리 생성자를
제공합니다. 생성자의 문법은 다음과 같습니다.

```dart
EffectController({
    required double duration,
    Curve curve = Curves.linear,
    double? reverseDuration,
    Curve? reverseCurve,
    bool alternate = false,
    double atMaxDuration = 0.0,
    double atMinDuration = 0.0,
    int? repeatCount,
    bool infinite = false,
    double startDelay = 0.0,
    VoidCallback? onMax,
    VoidCallback? onMin,
});
```

- *`duration`*: 이펙트의 주요 부분의 길이, 즉 0에서 100%까지 가는 데 걸리는 시간입니다. 이
  파라미터는 음수일 수 없지만 0일 수는 있습니다. 이 파라미터만 지정하면 이펙트는 `duration`초
  동안 선형으로 증가합니다.

- *`curve`*: 주어지면, 제공된 [curve](https://api.flutter.dev/flutter/animation/Curves-class.html)에
  따라 0에서 100%까지 증가하는 비선형 이펙트를 만듭니다.

- *`reverseDuration`*: 제공되면 컨트롤러에 단계가 하나 추가됩니다. 이펙트가 `duration`초 동안
  0에서 100%까지 증가한 뒤, `reverseDuration`초 동안 100%에서 0으로 거꾸로 돌아갑니다. 또한
  이펙트는 진행도 0에서 완료됩니다(보통 이펙트는 진행도 1에서 완료됩니다).

- *`reverseCurve`*: 이펙트의 "역방향" 단계에서 사용할 curve입니다. 주어지지 않으면 기본값은
  `curve.flipped`입니다.

- *`alternate`*: true로 설정하면 `reverseDuration`을 `duration`과 같게 지정하는 것과 같습니다.
  `reverseDuration`이 이미 설정되어 있다면 이 플래그는 효과가 없습니다.

- *`atMaxDuration`*: 0이 아니면, 이펙트가 최대 진행도에 도달한 후 역방향 단계 전에 일시 정지를
  삽입합니다. 이 시간 동안 이펙트는 진행도 100%로 유지됩니다. 역방향 단계가 없다면, 이는 단순히
  이펙트가 완료로 표시되기 전의 일시 정지가 됩니다.

- *`atMinDuration`*: 0이 아니면, 역방향 단계의 끝에서 이펙트가 가장 낮은 진행도(0)에 도달한 후
  일시 정지를 삽입합니다. 이 시간 동안 이펙트의 진행도는 0%입니다. 역방향 단계가 없다면, 이
  일시 정지는 "at-max" 일시 정지가 있으면 그 뒤에, 없으면 정방향 단계 뒤에 삽입됩니다. 또한
  이펙트는 이제 진행도 0에서 완료됩니다.

- *`repeatCount`*: 1보다 크면 이펙트가 지정된 횟수만큼 반복됩니다. 각 반복은 정방향 단계, 최대
  지점에서의 일시 정지, 역방향 단계, 최소 지점에서의 일시 정지로 구성됩니다(지정되지 않은 것은
  건너뜁니다).

- *`infinite`*: true이면 이펙트가 무한히 반복되며 완료에 도달하지 않습니다. 이는 `repeatCount`를
  무한대로 설정한 것과 같습니다.

- *`startDelay`*: 이펙트 시작 전에 삽입되는 추가 대기 시간입니다. 이 대기 시간은 이펙트가
  반복되더라도 한 번만 실행됩니다. 이 시간 동안 이펙트의 `.started` 속성은 false를 반환합니다.
  이펙트의 `onStart()` 콜백은 이 대기 시간이 끝날 때 실행됩니다.

  이 파라미터를 사용하는 것이 차례로(또는 겹쳐서) 실행되는 이펙트 체인을 만드는 가장 간단한
  방법입니다.

- *`onMax`*: 최대 진행도에 도달한 직후, 선택적인 일시 정지와 역방향 단계 전에 호출되는 콜백
  함수입니다.

- *`onMin`*: 역방향 단계의 끝에서 가장 낮은 진행도에 도달한 직후, 선택적인 일시 정지와 정방향
  단계 전에 호출되는 콜백 함수입니다.

이 팩토리 생성자가 반환하는 이펙트 컨트롤러는 아래에서 설명하는 여러 개의 더 단순한 이펙트
컨트롤러로 조합됩니다. 이 생성자가 필요에 비해 너무 제한적이라면, 언제든지 같은 구성 요소로
직접 조합을 만들 수 있습니다.

팩토리 생성자 외에도, `EffectController` 클래스는 모든 이펙트 컨트롤러에 공통인 여러 속성을
정의합니다. 이 속성들은 다음과 같습니다.

- `.started`: 이펙트가 이미 시작되었으면 true입니다. 대부분의 이펙트 컨트롤러에서 이 속성은
  항상 true입니다. 유일한 예외는 `DelayedEffectController`로, 이펙트가 대기 단계에 있는 동안
  false를 반환합니다.

- `.completed`: 이펙트 컨트롤러가 실행을 마치면 true가 됩니다.

- `.progress`: 이펙트 컨트롤러의 현재 값으로, 0에서 1 사이의 부동소수점 값입니다. 이 변수가
  이펙트 컨트롤러의 주요 "출력" 값입니다.

- `.duration`: 이펙트의 전체 지속 시간이며, 지속 시간을 결정할 수 없는 경우(예: 지속 시간이
  무작위이거나 무한한 경우)에는 `null`입니다.


## `LinearEffectController`

지정된 `duration` 동안 0에서 1까지 선형으로 증가하는 가장 간단한 이펙트 컨트롤러입니다.

```dart
final controller = LinearEffectController(3);
```


## `ReverseLinearEffectController`

`LinearEffectController`와 비슷하지만 반대 방향으로 진행하여, 지정된 지속 시간 동안 1에서 0으로
선형으로 변합니다.

```dart
final controller = ReverseLinearEffectController(1);
```


## `CurvedEffectController`

이 이펙트 컨트롤러는 지정된 `duration` 동안 제공된 `curve`를 따라 0에서 1까지 비선형으로
증가합니다.

```dart
final controller = CurvedEffectController(0.5, Curves.easeOut);
```


## `ReverseCurvedEffectController`

`CurvedEffectController`와 비슷하지만, 컨트롤러가 제공된 `curve`를 따라 1에서 0으로 감소합니다.

```dart
final controller = ReverseCurvedEffectController(0.5, Curves.bounceInOut);
```


## `PauseEffectController`

이 이펙트 컨트롤러는 지정된 시간 동안 진행도를 일정한 값으로 유지합니다.
일반적으로 `progress`는 0 또는 1입니다.

```dart
final controller = PauseEffectController(1.5, progress: 0);
```


## `RepeatedEffectController`

복합 이펙트 컨트롤러입니다. 다른 이펙트 컨트롤러를 자식으로 받아 여러 번 반복하며, 매 다음
사이클이 시작되기 전에 초기화합니다.

```dart
final controller = RepeatedEffectController(LinearEffectController(1), 10);
```

자식 이펙트 컨트롤러는 무한할 수 없습니다. 자식이 무작위라면, 매 반복마다 새로운 무작위 값으로
다시 초기화됩니다.


## `InfiniteEffectController`

`RepeatedEffectController`와 비슷하지만, 자식 컨트롤러를 무기한 반복합니다.

```dart
final controller = InfiniteEffectController(LinearEffectController(1));
```


## `SequenceEffectController`

이펙트 컨트롤러들의 시퀀스를 차례로 실행합니다. 컨트롤러 목록은 비어 있을 수 없습니다.

```dart
final controller = SequenceEffectController([
  LinearEffectController(1),
  PauseEffectController(0.2),
  ReverseLinearEffectController(1),
]);
```


## `SpeedEffectController`

이펙트가 미리 정의된 속도로 진행되도록 자식 이펙트 컨트롤러의 지속 시간을 변경합니다. 자식
EffectController의 초기 지속 시간은 무관합니다. 자식 컨트롤러는 `DurationEffectController`의
서브클래스여야 합니다.

`SpeedEffectController`는 속도 개념이 잘 정의된 이펙트에만 적용할 수 있습니다. 이러한 이펙트는
`MeasurableEffect` 인터페이스를 구현해야 합니다. 예를 들어 다음 이펙트들이 해당됩니다.

- [`MoveByEffect`](move_effects.md#movebyeffect)
- [`MoveToEffect`](move_effects.md#movetoeffect)
- [`MoveAlongPathEffect`](move_effects.md#movealongpatheffect)
- [`RotateEffect.by`](rotate_effects.md#rotateeffectby)
- [`RotateEffect.to`](rotate_effects.md#rotateeffectto)

`speed` 파라미터의 단위는 초당 단위(units per second)이며, "단위"의 의미는 대상 이펙트에 따라
다릅니다. 예를 들어 이동 이펙트에서는 이동한 거리를 뜻하고, 회전 이펙트에서는 단위가 라디안입니다.

```dart
final speedController =
    SpeedEffectController(LinearEffectController(0), speed: 1);
final controller =
    EffectController(speed: 1); // speedController와 같습니다
```


## `DelayedEffectController`

지정된 `delay` 후에 자식 컨트롤러를 실행하는 이펙트 컨트롤러입니다. 컨트롤러가 "지연" 단계를
실행하는 동안 이펙트는 "시작되지 않은" 것으로 간주되며, 즉 `.started` 속성이 `false`를
반환합니다.

```dart
final controller = DelayedEffectController(LinearEffectController(1), delay: 5);
```


## `NoiseEffectController`

이 이펙트 컨트롤러는 노이즈 같은 동작을 보입니다. 즉, 0 주변에서 무작위로 진동합니다. 이런 이펙트
컨트롤러는 다양한 흔들림 이펙트를 구현하는 데 사용할 수 있습니다.

```dart
final controller = NoiseEffectController(duration: 0.6, frequency: 10);
```


## `RandomEffectController`

이 컨트롤러는 다른 컨트롤러를 감싸서 그 지속 시간을 무작위로 만듭니다. 지속 시간의 실제 값은
초기화될 때마다 다시 생성되므로, 이 컨트롤러는 [](#repeatedeffectcontroller)나
[](#infiniteeffectcontroller)처럼 반복되는 맥락에서 특히 유용합니다.

```dart
final controller = RandomEffectController.uniform(
  LinearEffectController(0),  // 여기서의 duration은 무관합니다
  min: 0.5,
  max: 1.5,
);
```

사용자는 어떤 `Random` 소스를 사용할지, 그리고 생성되는 무작위 지속 시간의 정확한 분포를 제어할
수 있습니다. `.uniform`과 `.exponential` 두 가지 분포가 포함되어 있으며, 그 외의 분포는 사용자가
직접 구현할 수 있습니다.


## `SineEffectController`

사인 함수의 한 주기를 나타내는 이펙트 컨트롤러입니다. 자연스러워 보이는 조화 진동을 만들 때
사용하세요. 주기가 서로 다른 `SineEffectControllers`로 제어되는 두 개의 수직 이동 이펙트는
[Lissajous curve]를 만듭니다.

```dart
final controller = SineEffectController(period: 1);
```


## `ZigzagEffectController`

단순한 왕복 이펙트 컨트롤러입니다. 한 `period` 동안 이 컨트롤러는 0에서 1로, 다시 -1로, 그리고
다시 0으로 선형으로 진행합니다. 진동의 시작 위치가 (표준 왕복 `EffectController`처럼) 극단이
아니라 진동의 중심이어야 하는 진동 이펙트에 사용하세요.

```dart
final controller = ZigzagEffectController(period: 2);
```

[Lissajous curve]: https://en.wikipedia.org/wiki/Lissajous_curve
