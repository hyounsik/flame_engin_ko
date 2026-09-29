<a id="effects"></a>

# 이펙트

게임 개발에서는 시간에 따라 속성을 부드럽게 애니메이션하는 일(캐릭터 이동, 요소 페이드, 파워업
크기 변화 등)이 늘 필요합니다. 매번 `update` 메서드에 보간 코드를 직접 작성하는 것은 반복적이고
실수하기 쉽습니다. 이펙트는 이러한 시간 기반 변화를 선언적으로 기술하는 방법을 제공합니다.
컴포넌트에 이펙트를 붙이면 애니메이션을 자동으로 처리하고, 끝나면 스스로 제거됩니다.

이펙트는 다른 컴포넌트에 붙어서 그 컴포넌트의 속성이나 모양을 변경할 수 있는 특별한
컴포넌트입니다.

예를 들어, 수집할 수 있는 파워업 아이템이 있는 게임을 만든다고 가정해 봅시다. 이 파워업들이 맵
곳곳에 무작위로 생성되었다가 일정 시간이 지나면 사라지게 하고 싶습니다. 물론 파워업용 스프라이트
컴포넌트를 만들어 맵에 배치할 수도 있지만, 그보다 더 잘할 수 있습니다!

파워업이 처음 나타날 때 아이템이 0에서 100%까지 커지도록 `ScaleEffect`를 추가해 봅시다. 아이템이
위아래로 살짝 움직이도록 무한히 반복되며 왕복하는 `MoveEffect`도 추가합니다. 그런 다음 아이템을
3번 "깜빡이게" 하는 `OpacityEffect`를 추가합니다. 이 이펙트에는 30초(또는 파워업이 그 자리에
머물기를 원하는 시간만큼)의 지연이 내장됩니다. 마지막으로, 지정된 시간이 지나면 게임 트리에서
아이템을 자동으로 제거하는 `RemoveEffect`를 추가합니다(아마 `OpacityEffect`가 끝난 직후로 시간을
맞추고 싶을 것입니다).

보다시피 간단한 이펙트 몇 개로 생기 없는 단순한 스프라이트를 훨씬 흥미로운 아이템으로
바꾸었습니다. 더 중요한 것은 코드 복잡도가 늘어나지 않았다는 점입니다. 이펙트는 일단 추가되면
자동으로 동작하고, 끝나면 게임 트리에서 스스로 제거됩니다.


<a id="overview"></a>

## 개요

`Effect`의 역할은 시간에 걸쳐 어떤 컴포넌트의 속성에 변화를 일으키는 것입니다. 이를 위해
`Effect`는 속성의 초기값, 최종값, 그리고 시간에 따라 어떻게 진행되어야 하는지를 알아야 합니다.
초기값은 보통 이펙트가 자동으로 결정하고, 최종값은 사용자가 명시적으로 제공하며, 시간에 따른
진행은 [EffectController](effect_controllers.md)가 처리합니다.


### Effect

기본 `Effect` 클래스는 그 자체로는 사용할 수 없지만(추상 클래스입니다), 다른 모든 이펙트가
상속하는 몇 가지 공통 기능을 제공합니다. 여기에는 다음이 포함됩니다.

- `effect.pause()`와 `effect.resume()`을 사용해 이펙트를 일시 정지/재개하는 기능. 이펙트가 현재
  일시 정지되어 있는지는 `effect.isPaused`로 확인할 수 있습니다.

- `removeOnFinish` 속성(기본값 true)은 이펙트가 완료되면 이펙트 컴포넌트가 게임 트리에서
  제거되고 가비지 컬렉션되도록 합니다. 이펙트가 끝난 후 재사용할 계획이라면 false로 설정하세요.

- 사용자가 선택적으로 제공하는 `onComplete`. 이펙트가 실행을 막 완료했을 때, 게임에서 제거되기
  전에 호출됩니다.

- 이펙트가 끝날 때 완료되는 `completed` future.

- `reset()` 메서드는 이펙트를 원래 상태로 되돌려 다시 한 번 실행할 수 있게 합니다.

Flame은 미리 만들어진 여러 이펙트를 제공하며,
[직접 만들 수도 있습니다](#새-이펙트-만들기). 포함된 이펙트는 다음과 같습니다.

- [`MoveByEffect`](move_effects.md#movebyeffect)
- [`MoveToEffect`](move_effects.md#movetoeffect)
- [`MoveAlongPathEffect`](move_effects.md#movealongpatheffect)
- [`RotateAroundEffect`](rotate_effects.md#rotatearoundeffect)
- [`RotateEffect.by`](rotate_effects.md#rotateeffectby)
- [`RotateEffect.to`](rotate_effects.md#rotateeffectto)
- [`ScaleEffect.by`](scale_effects.md#scaleeffectby)
- [`ScaleEffect.to`](scale_effects.md#scaleeffectto)
- [`SizeEffect.by`](size_effects.md#sizeeffectby)
- [`SizeEffect.to`](size_effects.md#sizeeffectto)
- [`AnchorByEffect`](anchor_effects.md#anchorbyeffect)
- [`AnchorToEffect`](anchor_effects.md#anchortoeffect)
- [`OpacityToEffect`](color_effects.md#opacitytoeffect)
- [`OpacityByEffect`](color_effects.md#opacitybyeffect)
- [`ColorEffect`](color_effects.md#coloreffect)
- [`SequenceEffect`](sequence_effect.md)
- [`CombinedEffect`](combined_effect.md)
- [`RemoveEffect`](remove_effect.md)
- [`FunctionEffect`](function_effect.md)


<a id="creating-new-effects"></a>

## 새 이펙트 만들기

Flame은 다양한 내장 이펙트를 제공하지만, 결국에는 그것만으로 부족하다고 느낄 수도 있습니다.
다행히 새 이펙트를 만드는 것은 매우 간단합니다.

모든 이펙트는 기본 `Effect` 클래스를 상속하며, `ComponentEffect<T>`나 `Transform2DEffect`처럼 더
특화된 추상 서브클래스 중 하나를 거쳐 상속할 수도 있습니다.

`Effect` 클래스의 생성자는 인자로 `EffectController` 인스턴스를 요구합니다. 대부분의 경우 이
컨트롤러를 여러분의 생성자에서 전달받아 넘기고 싶을 것입니다. 다행히 이펙트 컨트롤러는 이펙트
구현의 복잡성 대부분을 캡슐화하므로, 그 기능을 다시 만드는 것을 걱정할 필요가 없습니다.

마지막으로, 이펙트가 활성 상태인 동안 매 업데이트 틱마다 호출되는 `apply(double progress)`
메서드 하나를 구현해야 합니다. 이 메서드에서 이펙트의 대상에 변경을 가하면 됩니다.

또한 이펙트가 시작하거나 끝날 때 수행해야 할 동작이 있다면 `onStart()`와 `onFinish()` 콜백을
구현할 수도 있습니다.

`apply()` 메서드를 구현할 때는 상대적인 업데이트만 사용하는 것을 권장합니다. 즉, 대상 속성을
고정된 값으로 직접 설정하기보다는 현재 값을 증가/감소시키는 방식으로 변경하세요. 이렇게 하면 여러
이펙트가 서로 간섭하지 않고 같은 컴포넌트에 작용할 수 있습니다.


<a id="effects-vs-decorators"></a>

## 이펙트 vs 데코레이터

이펙트와 데코레이터는 때때로 비슷한 시각적 결과(불투명도나 색상 변경 등)를 낼 수 있지만, 성능과
시각적 특성이 다릅니다.

- **이펙트**는 빠르며 일반적으로 단일 컴포넌트의 속성을 변경합니다. 그룹에 적용하면 각 자식에
  개별적으로 영향을 줍니다.
- **데코레이터**는 더 강력하지만 느립니다. 이펙트를 적용하기 전에 `saveLayer`를 사용해 컴포넌트
  서브트리 전체를 하나의 레이어로 평탄화합니다. 이는 투명도나 복잡한 필터가 있는 복합 객체를
  올바르게 렌더링하는 데 필수적입니다.

더 자세한 비교는 [데코레이터 문서](../rendering/decorators.md)를 참고하세요.


<a id="see-also"></a>

## 함께 보기

- [다양한 이펙트 예제](https://examples.flame-engine.org/).

```{toctree}
:hidden:

이펙트 컨트롤러        <effect_controllers.md>
이동 이펙트              <move_effects.md>
회전 이펙트            <rotate_effects.md>
스케일 이펙트             <scale_effects.md>
크기 이펙트              <size_effects.md>
앵커 이펙트            <anchor_effects.md>
색상 이펙트             <color_effects.md>
시퀀스 이펙트           <sequence_effect.md>
결합 이펙트           <combined_effect.md>
제거 이펙트             <remove_effect.md>
함수 이펙트           <function_effect.md>
```
