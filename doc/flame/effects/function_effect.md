<a id="function-effect"></a>

# 함수 이펙트

`FunctionEffect` 클래스는 매우 범용적인 이펙트로, 새 이펙트를 정의하지 않고도 거의 모든 일을 할 수
있게 해 줍니다.

이 이펙트는 대상과 이펙트의 진행도를 받는 함수를 실행하며, 사용자는 그 입력으로 무엇을 할지 결정할
수 있습니다.

예를 들어 대부분의 다른 이펙트처럼 시각적이지는 않지만 시간에 걸쳐 일어나는 게임 상태 변화를
만드는 데 사용할 수 있습니다.

다음 예제에는 시간에 따라 변경하고 싶은 `PlayerState` enum이 있습니다. 진행도가 50%를 넘으면
상태를 `yawn`으로 바꾸고, 진행도가 80%를 넘으면 다시 `idle`로 바꾸려고 합니다.

```dart
enum PlayerState {
  idle,
  yawn,
}

final effect = FunctionEffect<SpriteAnimationGroupComponent<PlayerState>>(
  (target, progress) {
    if (progress > 0.5) {
      target.current = PlayerState.yawn;
    } else if(progress > 0.8) {
      target.current = PlayerState.idle;
    }
  },
  EffectController(
    duration: 10,
    infinite: true,
  ),
);
```
