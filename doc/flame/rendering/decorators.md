<a id="decorators"></a>

# 데코레이터

**데코레이터(Decorator)**는 특정 시각 효과를 캡슐화한 다음, 그 시각 효과를 일련의 캔버스 그리기 작업에
적용할 수 있는 클래스입니다. 데코레이터는 [Component]가 아니지만, 수동으로 또는 [HasDecorator] 믹스인을 통해
컴포넌트에 적용할 수 있습니다. 마찬가지로 데코레이터는 [Effect]도 아니지만,
특정 `Effect`를 구현하는 데 사용될 수 있습니다.

Flame에는 여러 가지 데코레이터가 준비되어 있으며, 필요하다면 직접 데코레이터를 추가하는 것도 간단합니다.
Flutter가 웹에서 셰이더를 완전히 지원하게 되면 셰이더 기반 데코레이터도 추가할
계획입니다.


<a id="performance-considerations"></a>

## 성능 고려 사항

컴포넌트에 데코레이터를 적용하면 상당한 성능 오버헤드가 발생할 수 있으며, 특히
`canvas.saveLayer()`가 관련된 경우 더욱 그렇습니다.

- **데코레이터**: 렌더링을 분리하고 필터를 적용하기 위해 기본적으로 `canvas.saveLayer()`를
  사용합니다. 이를 위해 오프스크린 버퍼 할당과 GPU 컨텍스트 전환이 필요합니다. 계산 비용이
  크지만, 복잡한 객체를 시각적으로 올바르게 합성하려면 반드시 필요합니다(아래
  참고).
- **이펙트**(예: `OpacityEffect`, `ColorEffect`): 컴포넌트의 속성이나
  `Paint`를 직접 수정합니다. 매우 빠르고 하드웨어 가속되지만, 각 자식에
  개별적으로 적용됩니다.


<a id="decorators-vs-effects-visual-composition"></a>

### 데코레이터 vs 이펙트: 시각적 합성

핵심적인 차이는 합성 객체(여러 자식이 겹쳐 있는 컴포넌트)를 처리하는
방식에 있습니다.

1. **이펙트(개별 블렌딩)**: 부모 컴포넌트에 `OpacityEffect`를 적용하면
   Flame은 각 자식을 해당 불투명도로 렌더링합니다. 자식들이 겹치면 그 자식들을 통해
   배경과 다른 자식들이 비쳐 보여 "이중 노출" 같은
   모습이 됩니다.
2. **데코레이터(그룹 블렌딩)**: 데코레이터는 `saveLayer`를 사용하므로, 먼저 전체
   서브트리를 하나의 평평한 버퍼에 렌더링한 다음 그 버퍼에 효과를
   적용합니다. 그 결과 겹친 부분이 보이지 않는 균일한 모습이 되어,
   그룹이 하나의 단단한 객체처럼 보입니다.

**권장 사항**:

- 단순한 속성 애니메이션이나 많은 수의 유닛에 대한 고성능 색상 변화에는
  **이펙트**를 사용하세요.
- 고급 포스트 프로세싱(블러, 틴트)이 필요하거나 여러 컴포넌트를 하나의 시각적 단위로
  다뤄야 할 때는 **데코레이터**를 사용하세요.


<a id="flame-built-in-decorators"></a>

## Flame 내장 데코레이터


### PaintDecorator.blur

```{flutter-app}
:sources: ../flame/examples
:page: decorator_blur
:show: widget code infobox
:width: 180
:height: 160
```

이 데코레이터는 대상 컴포넌트에 가우시안 블러를 적용합니다. 블러의 양은
X 방향과 Y 방향이 다를 수 있지만, 그렇게 쓰는 경우는 흔하지 않습니다.

```dart
final decorator = PaintDecorator.blur(3.0);
```

활용 예:

- 부드러운 그림자
- 멀리 있거나 카메라에 아주 가까이 있는 "초점이 맞지 않는" 객체
- 모션 블러 효과
- 팝업 대화상자를 표시할 때 콘텐츠를 덜 강조하거나 가리기
- 캐릭터가 취했을 때의 흐릿한 시야


### PaintDecorator.grayscale

```{flutter-app}
:sources: ../flame/examples
:page: decorator_grayscale
:show: widget code infobox
:width: 180
:height: 160
```

이 데코레이터는 대상 이미지를 흑백 사진처럼 회색 음영으로
변환합니다. 또한 원하는 `opacity` 수준으로 이미지를 반투명하게 만들 수도
있습니다.

```dart
final decorator = PaintDecorator.grayscale(opacity: 0.5);
```

활용 예:

- NPC에 적용해 돌이나 유령으로 만들기!
- 장면에 적용해 과거의 기억임을 나타내기
- 흑백 사진


### PaintDecorator.tint

```{flutter-app}
:sources: ../flame/examples
:page: decorator_tint
:show: widget code infobox
:width: 180
:height: 160
```

이 데코레이터는 색유리를 통해 보는 것처럼 대상 이미지를 지정된 색상으로 *틴트(tint)* 처리합니다.
아래 이미지의 세부 사항이 보이도록, 이 데코레이터에 사용하는 `color`는
반투명한 색상을 권장합니다.

```dart
final decorator = PaintDecorator.tint(const Color(0xAAFF0000));
```

활용 예:

- 특정 종류의 마법에 걸린 NPC
- 그림자 속에 있는 아이템/캐릭터를 검은색으로 틴트
- 장면을 빨간색으로 틴트해 광폭화 상태나 캐릭터의 체력이 낮음을 표현
- 초록색으로 틴트해 캐릭터가 중독되었거나 아픈 상태임을 표현
- 밤 시간대에 장면을 짙은 파란색으로 틴트


### Rotate3DDecorator

```{flutter-app}
:sources: ../flame/examples
:page: decorator_rotate3d
:show: widget code infobox
:width: 180
:height: 160
```

이 데코레이터는 대상 컴포넌트에 3D 회전을 적용합니다. 회전 각도뿐 아니라
피벗 지점과 적용할 원근 왜곡의 정도도 지정할 수 있습니다.

이 데코레이터는 `isFlipped` 속성도 제공하는데, 이를 통해 현재 컴포넌트를 앞면에서 보고 있는지
뒷면에서 보고 있는지 판단할 수 있습니다. 앞면과 뒷면의 모습이 다른 컴포넌트를
그리고 싶을 때 유용합니다.

```dart
final decorator = Rotate3DDecorator(
  center: component.center,
  angleX: rotationAngle,
  perspective: 0.002,
);
```

활용 예:

- 뒤집을 수 있는 카드
- 책의 페이지
- 앱 라우트 간 전환
- 눈송이나 나뭇잎 같은 3D 낙하 파티클


### Shadow3DDecorator

```{flutter-app}
:sources: ../flame/examples
:page: decorator_shadow3d
:show: widget code infobox
:width: 180
:height: 160
```

이 데코레이터는 컴포넌트가 평면 위에 서 있는 3D 객체인 것처럼 컴포넌트 아래에 그림자를
렌더링합니다. 이 효과는 아이소메트릭 카메라 투영을 사용하는 게임에서 가장 잘 어울립니다.

이 데코레이터가 만드는 그림자는 상당히 유연합니다. 각도, 길이, 불투명도,
블러 등을 조절할 수 있습니다. 이 데코레이터가 가진 속성과 그 의미에 대한 전체 설명은
클래스 문서를 참고하세요.

```dart
final decorator = Shadow3DDecorator(
  base: Vector2(100, 150),
  angle: -1.4,
  xShift: 200,
  yScale: 1.5,
  opacity: 0.5,
  blur: 1.5,
);
```

이 데코레이터의 주 목적은 컴포넌트에 바닥 그림자를 추가하는 것입니다. 가장 큰
한계는 그림자가 평평해서 주변 환경과 상호작용할 수 없다는 점입니다. 예를 들어 이
데코레이터는 벽이나 다른 수직 구조물에 드리우는 그림자를 처리할 수 없습니다.


### HueDecorator

```{flutter-app}
:sources: ../flame/examples
:page: decorator_hue
:show: widget code infobox
:width: 180
:height: 160
```

이 데코레이터는 대상 컴포넌트의 색조(hue)를 지정한 각도(라디안)만큼 이동시킵니다.

```dart
final decorator = HueDecorator(hue: tau / 4);
```

활용 예:

- 적의 대체 색상 스킴("팔레트 스와핑")
- 환경 변화(예: 월드가 보라색/초현실적으로 바뀌는 연출)
- 파워업 표시


<a id="using-decorators"></a>

## 데코레이터 사용하기


<a id="hasdecorator-mixin"></a>

### HasDecorator 믹스인

이 `Component` 믹스인은 초깃값이 `null`인 `decorator` 속성을 추가합니다. 이
속성에 실제 `Decorator` 객체를 설정하면, 컴포넌트를 렌더링하는 동안 해당 데코레이터가 시각 효과를
적용합니다. 이 시각 효과를 제거하려면 `decorator`
속성을 다시 `null`로 설정하면 됩니다.


### PositionComponent

`PositionComponent`(및 이를 상속한 모든 클래스)에는 이미 `decorator` 속성이 있으므로, 이러한
컴포넌트에는 `HasDecorator` 믹스인이 필요하지 않습니다.

사실 `PositionComponent`는 화면에서 컴포넌트를 올바르게 배치하기 위해 자신의 데코레이터를 사용합니다.
따라서 `PositionComponent`에 적용하려는 새 데코레이터는 모두 체인으로
연결해야 합니다(아래 [여러 데코레이터](#여러-데코레이터) 섹션 참고).

컴포넌트가 화면에 배치되는 방식에 대해 다른 로직을 만들고 싶다면
`PositionComponent`의 루트 데코레이터를 교체하는 것도 가능합니다.


<a id="multiple-decorators"></a>

### 여러 데코레이터

같은 컴포넌트에 여러 데코레이터를 동시에 적용할 수 있습니다. `Decorator`
클래스는 체이닝을 지원합니다. 즉, 컴포넌트에 이미 데코레이터가 있는 상태에서 다른 데코레이터를
추가하고 싶다면 `component.decorator.addLast(newDecorator)`를 호출하면 됩니다. 그러면
새 데코레이터가 기존 체인의 끝에 추가됩니다. 나중에 `removeLast()` 메서드로 해당
데코레이터를 제거할 수 있습니다.

이런 방식으로 여러 데코레이터를 체인으로 연결할 수 있습니다. 예를 들어 `A`가 초기 데코레이터라면
`A.addLast(B)` 다음에 `A.addLast(C)`나 `B.addLast(C)` 중 어느 것을 호출해도 두 경우 모두
`A -> B -> C` 체인이 만들어집니다. 실제로는 체인 전체를 루트에서 조작할 수 있다는
의미이며, 루트는 보통 `component.decorator`입니다.


[Component]: ../components/components.md#component
[Effect]: ../effects/effects.md
[HasDecorator]: #hasdecorator-믹스인
