# FlameIsolate

[integral_isolates](https://pub.dev/packages/integral_isolates)의 강력한 기능을 Flame 게임에서 쓸 수 있도록
[flame_isolate](https://pub.dev/packages/flame_isolate)에 깔끔하게 담았습니다.

[compute](https://api.flutter.dev/flutter/foundation/compute-constant.html) 함수를 사용해 본 적이 있다면
금방 익숙해질 것입니다. 이 믹스인을 사용하면 CPU 집약적인 코드를 isolate에서
실행할 수 있습니다.

게임에서 사용하려면 pubspec.yaml에 `flame_isolate`를 추가하기만 하면 됩니다.


<a id="usage"></a>

## 사용법

컴포넌트에 `FlameIsolate` 믹스인을 추가하기만 하면,
[compute](https://api.flutter.dev/flutter/foundation/compute-constant.html) 함수를 실행하는 것만큼 간단하게
isolate의 강력한 기능을 활용할 수 있습니다.

예시:

```dart
class MyGame extends FlameGame with FlameIsolate {
  ...
  @override
  void update(double dt) {
    if (shouldRecalculate) {
      isolate(recalculateWorld, worldData).then(updateWorld);
    }
    ...
  }
  ...
}
```


<a id="performance-note"></a>

### 성능 관련 참고

`FlameIsolate` 믹스인을 가진 컴포넌트를 만들어 게임에 추가할 때마다 새 isolate가 생성된다는 점을
기억하세요. 따라서 많은 "단순한" 컴포넌트들을 관리하는 관리자 컴포넌트를 만드는 것이 좋습니다.
여왕개미가 일개미들을 통제하는 개미 집단을 떠올려 보세요. 일개미 하나하나가 각자 isolate를 가진다면
완전한 자원 낭비일 것입니다. 그래서 isolate는 여왕개미에게 두고, 여왕개미가 모든 일개미에게 할 일을 알려 주는 것입니다.

이에 대한 간단한 예시는 FlameIsolate 패키지의 예제 애플리케이션에서 찾을 수 있습니다.


<a id="backpressure-strategies"></a>

### 백프레셔 전략

백프레셔 전략은 isolate가 처리할 수 있는 속도보다 작업 항목이 더 빠르게 생성될 때 작업 큐에 대처하는
방법입니다. 이 경우 계속 쌓여 가는 미처리 작업을 어떻게 할 것인가 하는 문제가 생깁니다.
이 문제를 완화하기 위해 이 라이브러리는 모든 작업을 작업 큐 핸들러를 통해 전달합니다.
이를 `BackpressureStrategy`라고도 합니다.

현재 지원되는 전략은 다음과 같습니다.

- `NoBackPressureStrategy`: 기본적으로 백프레셔를 처리하지 않습니다. 미처리 작업을 쌓아 두기 위해
FIFO 스택을 사용합니다.
-`ReplaceBackpressureStrategy`: 크기가 1인 작업 큐를 가지며, 새 작업이 추가되면
큐를 비웁니다.
- `DiscardNewBackPressureStrategy`: 크기가 1인 작업 큐를 가지며, 큐가 채워져 있는 동안에는
새 작업이 추가되지 않습니다.

`backpressureStrategy` 필드를 오버라이드해 백프레셔 전략을 지정할 수 있습니다. 그러면 컴포넌트가
마운트될 때 지정한 전략으로 isolate가 생성됩니다.

```dart
class MyGame extends FlameGame with FlameIsolate {
  @override
  BackpressureStrategy get backpressureStrategy => ReplaceBackpressureStrategy();
  ...
}
```
