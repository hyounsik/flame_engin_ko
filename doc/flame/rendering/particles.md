<a id="particles"></a>

# 파티클

Flame은 많은 수의 파티클을 다루도록 설계된 데이터 지향 파티클 시스템을 제공합니다.
모든 파티클 상태는 미리 할당된 typed-data 버퍼에 저장되며, 내장
렌더러는 한 이미터의 모든 파티클을 한 번의 배치 캔버스 호출로 그립니다.
이펙트는 재사용 가능한 프리셋을 통해 선언적으로 기술되므로, 대부분의
파티클 이펙트는 사용자 정의 클래스도, 프레임마다의 메모리 할당도 필요하지 않습니다.

이 시스템은 세 부분으로 구성됩니다.

- [`ParticleEmitter`](#particleemitter): 무엇을 생성하고 파티클이 수명 동안 어떻게
  동작하는지를 기술하는 선언적이고 재사용 가능한 설명입니다.
- [`ParticleRenderer`](#렌더러): 파티클을 그리는 방식입니다(배치된 원,
  스프라이트, 또는 완전히 사용자 정의된 캔버스 코드).
- [`ParticleEmitterComponent`](#particleemittercomponent): 앞의 두 가지를 하나로 묶어
  파티클을 시뮬레이션하고 렌더링하는 `PositionComponent`입니다.

최소한의 폭발 효과는 다음과 같습니다.

```dart
import 'package:flame/particles.dart';

world.add(
  ParticleEmitterComponent(
    position: Vector2(200, 100),
    emitter: ParticleEmitter(
      bursts: [EmitterBurst(0, 200)],
      lifespan: (0.4, 1.2),
      speed: (50, 150),
      gravity: Vector2(0, 200),
      scaleOverLife: ParticleCurve(1, 0),
      colorOverLife: ColorRamp([Colors.yellow, Colors.red]),
    ),
    renderer: CircleParticleRenderer(),
  ),
);
```

버스트가 발사되고 마지막 파티클이 소멸하면 컴포넌트는 자동으로
스스로를 제거합니다([생명주기](#생명주기) 참고).


<a id="ranges"></a>

## 범위

파티클마다 달라지는 이미터 속성은 `ParticleRange`라고 하는 `(min, max)` 레코드로
표현합니다. 각 파티클은 생성될 때 이 범위에서 균등 분포로 값을
샘플링합니다. 상수 값을 원하면 같은 값을 두 번 사용하세요.

```dart
lifespan: (0.5, 2),  // 0.5초에서 2초 사이
size: (8, 8),        // 항상 정확히 8
```


## ParticleEmitter

`ParticleEmitter`는 여러 이미터 컴포넌트가 공유할 수 있는 재사용 가능한 프리셋입니다.
모든 거리는 컴포넌트의 로컬 단위, 각도는
라디안, 시간은 초 단위입니다.


<a id="emission"></a>

### 방출

파티클은 연속적으로, 버스트로, 또는 두 방식을 함께 사용해 생성할 수 있습니다.

```dart
ParticleEmitter(
  rate: 120,                     // 초당 파티클 수
  bursts: [
    EmitterBurst(0, 50),         // t = 0에 파티클 50개
    EmitterBurst(0.5, 25),       // t = 0.5s에 25개 더
  ],
  duration: 1.5,                 // 1.5초 후 방출 중지
  loop: true,                    // 그리고 타임라인을 다시 시작
  maxParticles: 2048,            // 동시에 존재하는 파티클을 위한 저장 공간
);
```

- `rate`는 연속적으로 방출합니다. 소수점 단위의 양도 프레임에 걸쳐 올바르게
  누적됩니다.
- `bursts`는 방출 타임라인을 한 번 지날 때마다 한 번씩 발사됩니다.
- `duration`은 방출을 끝냅니다. null이면 `rate` 기반 이미터는 계속 실행되고,
  버스트만 있는 이미터는 마지막 버스트 이후 종료됩니다.
- `loop`는 `duration` 이후 타임라인을 다시 시작합니다(이 경우 `duration`을 반드시 설정해야 합니다).
- `maxParticles`는 미리 할당됩니다. 이 수를 넘어서는 생성은 오래된
  파티클이 소멸할 때까지 버려집니다.


<a id="spawn-position-and-velocity"></a>

### 생성 위치와 속도

`shape`는 컴포넌트의 위치를 기준으로 파티클이 나타나는 위치를
제어합니다.

```dart
shape: const PointEmitterShape(),                    // 기본값
shape: const CircleEmitterShape(50),                 // 원 내부
shape: const CircleEmitterShape(50, edgeOnly: true), // 원의 가장자리
shape: const RectangleEmitterShape(100, 20),         // 사각형 내부
```

사용자 정의 생성 패턴은 서브클래스 하나로 만들 수 있습니다. `EmitterShape`를 확장하고
`samplePosition`을 구현하세요.

초기 속도는 극좌표로 지정합니다. `speed` 범위와 `direction`(라디안,
0은 양의 x축 방향, `-tau / 4`는 위쪽 방향), 그리고 그 방향을 중심으로 하는 `spread`
각도를 사용합니다. 기본 spread 값인 `tau`는 모든 방향으로 방출합니다.

```dart
speed: (100, 200),
direction: -tau / 4,   // 위쪽
spread: tau / 8,       // 45도 원뿔 범위
```


<a id="forces-and-rotation"></a>

### 힘과 회전

```dart
gravity: Vector2(0, 300),  // 일정한 가속도
drag: 2,                   // 속도 감쇠, 0 = 없음
rotation: (0, tau),        // 초기 회전
spin: (-5, 5),             // 초당 라디안
rotateToVelocity: true,    // 또는: 항상 진행 방향을 바라봄
```

`rotateToVelocity`는 불꽃이나 화살처럼 방향성이 있는 파티클에 적합합니다.
이 속성은 `rotation`과 `spin`보다 우선합니다.


<a id="behavior-over-a-particles-lifetime"></a>

### 파티클 수명에 따른 동작

세 가지 선택적 속성은 파티클의 수명이 0(생성)에서 1(소멸)로 진행됨에 따라
파티클을 변화시킵니다. 이 속성들은 이미터가 생성될 때 룩업 테이블로 구워지므로,
곡선이 아무리 복잡하더라도 파티클마다, 프레임마다 평가하는 작업은 배열 읽기에 불과합니다.

`scaleOverLife`는 생성 시의 `size`에 곱해집니다.

```dart
size: (10, 20),
scaleOverLife: ParticleCurve(1, 0, curve: Curves.easeOut),  // 줄어들며 사라짐
```

`ParticleCurve`는 두 값 사이를 보간하며, 선택적으로 Flutter 애니메이션 `Curve`로
보간 형태를 조정할 수 있습니다. `ParticleCurve.constant`는 값을 고정하고,
`ParticleCurve.custom`은 임의의 함수를 테이블로 구워 둡니다.

```dart
opacityOverLife: ParticleCurve.custom(
  // 수명의 처음 20% 동안 페이드 인하고, 나머지 동안 페이드 아웃합니다.
  (t) => t < 0.2 ? t / 0.2 : (1 - t) / 0.8,
),
```

`colorOverLife`는 `ColorRamp`입니다. 수명에 걸쳐 보간되는 색상 목록(선택적으로 스톱 포함)입니다.
`opacityOverLife`는 램프의 알파에 곱해지므로 둘은 자연스럽게 조합됩니다.

```dart
colorOverLife: ColorRamp([Colors.white, Colors.orange, Colors.red]),
opacityOverLife: ParticleCurve(1, 0),
```

텍스처 렌더러에서는 색상이 텍스처를 틴트하므로, 흰색 텍스처는
램프 색상을 정확히 띠게 되고, 램프가 설정되지 않은 동안에는 스프라이트가 틴트되지 않습니다.


<a id="renderers"></a>

## 렌더러

렌더러는 파티클을 그리는 방식을 기술하며, 여러 컴포넌트가 공유할 수도
있습니다.


### CircleParticleRenderer

모든 파티클을 원으로 그립니다. 원은 로드 시점에 한 번 텍스처로 래스터화되며,
그 이후 각 파티클은 이 텍스처를 변환하고 틴트한 복사본으로서
한 번의 `drawRawAtlas` 배치로 그려집니다. `softness`는 원을 선명한 상태(0)에서
완전히 부드러운 상태(1)까지 페이드시키며, `blendMode: BlendMode.plus`는 가산 글로우 효과를 주어
불이나 마법에 자연스럽게 어울립니다.

```dart
renderer: CircleParticleRenderer(softness: 0.8, blendMode: BlendMode.plus),
```


### SpriteParticleRenderer

모든 파티클을 `Sprite`(또는 이미지 전체)로 그리며, 이 역시 완전히 배치 처리됩니다.

```dart
renderer: SpriteParticleRenderer.fromImage(await images.load('assets/images/spark.png')),
renderer: SpriteParticleRenderer(sprite),  // 스프라이트 시트의 한 영역
```

파티클은 중심을 기준으로 그려지고, 파티클의 회전값만큼 회전하며,
스프라이트의 너비가 파티클의 현재 크기와 같아지도록 스케일이 조정됩니다.


<a id="custom-rendering"></a>

### 사용자 정의 렌더링

완전한 제어가 필요하면 `CallbackParticleRenderer`를 사용하세요(또는
`ParticleRenderer`를 확장하세요). 콜백은 이미 컴포넌트의 로컬 좌표계로 설정된
캔버스와, 살아 있는 모든 파티클 상태를 평평한 typed-data 배열로 담고 있는
`ParticleBuffer`를 전달받습니다.

```dart
renderer: CallbackParticleRenderer((canvas, particles) {
  for (var i = 0; i < particles.length; i++) {
    canvas.drawCircle(
      Offset(particles.posX[i], particles.posY[i]),
      particles.size[i] / 2,
      paint,
    );
  }
}),
```

콜백 렌더러에서는 아무것도 배치 처리되지 않으므로, 파티클 수가 많을 때는
텍스처 렌더러를 사용하는 것이 좋습니다.


## ParticleEmitterComponent

`ParticleEmitterComponent`는 일반적인 `PositionComponent`입니다. 위치를 지정하고,
우선순위를 부여하고, 컴포넌트 트리 어디에든 추가할 수 있습니다. 런타임에 이펙트를
제어하는 기능도 제공합니다.

```dart
final effect = ParticleEmitterComponent(
  emitter: smokePreset,
  renderer: CircleParticleRenderer(softness: 0.9),
  emitting: false,     // 일시 정지 상태로 시작
);

effect.start();        // 방출 타임라인 실행(종료된 경우 다시 시작)
effect.stop();         // 방출 일시 정지. 살아 있는 파티클은 계속 시뮬레이션됨
effect.emit(30);       // 타임라인과 무관하게 지금 바로 파티클 30개 생성
effect.clearParticles();
effect.particleCount;  // 살아 있는 파티클 수
```

결정론적인 이펙트가 필요하면 시드가 지정된 `Random`을 전달하세요(테스트나
리플레이에 유용합니다).

```dart
ParticleEmitterComponent(emitter: e, renderer: r, random: Random(42));
```


<a id="lifecycle"></a>

### 생명주기

`removeOnFinish`(기본값)를 사용하면, 방출이 자연스럽게 끝나고(즉, 타임라인이
반복 없이 완료되고) 마지막 파티클이 소멸했을 때 컴포넌트가 스스로를 제거합니다.
무한히 방출하는 이미터는 자동으로 제거되지 않습니다. 덕분에 일회성 이펙트는
발사 후 신경 쓸 필요가 없습니다.

```dart
world.add(
  ParticleEmitterComponent(
    position: hitPosition,
    emitter: sparksPreset,   // 버스트만 있는 프리셋, 모든 타격에서 공유
    renderer: sparksRenderer,
  ),
);
```


<a id="moving-emitters-and-trails"></a>

### 움직이는 이미터와 트레일

파티클은 컴포넌트의 로컬 공간에서 시뮬레이션되므로, 컴포넌트를 움직이면
살아 있는 파티클도 함께 움직입니다. 트레일, 배기가스 등의 효과에는
`worldSpace: true`를 설정하세요. 그러면 이미 생성된 파티클은 이미터가 이동하더라도
월드 위치를 유지합니다.

```dart
ship.add(
  ParticleEmitterComponent(
    position: exhaustOffset,
    emitter: exhaustPreset,
    renderer: CircleParticleRenderer(softness: 1),
    worldSpace: true,
  ),
);
```

보정되는 것은 이동뿐입니다. `worldSpace`가 활성화된 동안에는 컴포넌트와 그 조상들을
회전하거나 스케일 조정하면 안 됩니다.


<a id="performance-notes"></a>

## 성능 참고 사항

- 파티클별 상태는 모두 `Float32List`/`Int32List` 열(struct-of-arrays 레이아웃)에
  저장됩니다. 시뮬레이션은 연속된 메모리를 도는 촘촘한 루프이며, 소멸한 파티클은
  상수 시간에 swap-remove로 제거됩니다.
- 텍스처 렌더러는 파티클 수와 관계없이 컴포넌트당 프레임마다 단 한 번의
  `Canvas.drawRawAtlas` 호출만 수행합니다.
- 수명에 따른 곡선과 색상 램프는 이미터를 생성할 때 룩업 테이블로
  구워집니다.
- 저장 공간은 `maxParticles` 크기로 한 번만 할당되며, 실행 중인 이펙트는
  메모리를 할당하지 않습니다. 이펙트가 매우 자주 발생한다면 새 컴포넌트를 생성하는 대신
  일시 정지된 컴포넌트를 재사용하고 `emit()`을 호출하세요.
