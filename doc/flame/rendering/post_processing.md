<a id="post-processing-and-shaders"></a>

# 포스트 프로세싱과 셰이더

포스트 프로세싱은 컴포넌트 트리가 렌더링된 후 시각 효과를 적용하기 위해 게임 개발에서 사용하는
기법입니다. 프레임이 직접 렌더링되거나 이미지로 래스터화되고 나면,
포스트 프로세싱으로 시각적 결과물을 수정하거나 향상시킬 수 있습니다.

포스트 프로세싱은 프래그먼트 셰이더를 활용해 블러, 블룸,
컬러 그레이딩, 왜곡, 조명 조정 같은 동적인 시각 효과를 만들어 냅니다.

Flame의 포스트 프로세싱 시스템은 모듈화되어 있고 유연하여, 개발자는 다음과 같은 작업을 할 수 있습니다.

- 추상 클래스 `PostProcess`를 상속해 사용자 정의 포스트 프로세스를 정의합니다.
- 단일 포스트 프로세스 효과를 적용하거나, 그룹을 사용해 여러 효과를 체인으로 연결합니다.
- `CameraComponent`로 효과를 전역적으로 관리하거나, `PostProcessComponent`로 국소적으로 관리합니다.


<a id="key-components-of-the-post-processing-system"></a>

## 포스트 프로세싱 시스템의 주요 구성 요소

- **`PostProcess`**: 사용자 정의 포스트 프로세싱 효과를 정의하기 위한 추상 기반 클래스입니다.
  `postProcess` 메서드에 효과 로직을 구현합니다.

- **`PostProcessComponent`**: 자신의 자식들에게만 포스트 프로세스를 적용해
  국소적인 효과를 구현할 수 있게 합니다.

- **`CameraComponent`**: 장면 전체 또는 월드 전체에 포스트 프로세스를 전역적으로 적용합니다.

- **`PostProcessGroup`**: 여러 포스트 프로세스를 병렬로 적용합니다. 각 효과를 독립적으로
  적용할 수 있을 때 유용합니다.

- **`PostProcessSequentialGroup`**: 포스트 프로세스를 순차적으로 적용하며, 각 프로세스는
  이전 프로세스의 출력을 사용합니다.


## PostProcessComponent

```{dartdoc}
:package: flame
:symbol: PostProcessComponent
:file: src/post_process/post_process_component.dart
```


<a id="creating-a-custom-post-process"></a>

## 사용자 정의 포스트 프로세스 만들기

사용자 정의 포스트 프로세스를 구현하려면 다음과 같이 합니다.

1. `PostProcess`를 상속합니다.
2. `postProcess` 메서드를 오버라이드하고, `renderSubtree`나
   `rasterizeSubtree`를 사용해 렌더링 로직을 구현합니다.
3. 필요하다면 리소스를 관리하고 매 프레임 효과를 업데이트하기 위해 `onLoad`와 `update` 메서드를
   구현합니다.

이 시스템을 사용하면 Flame 게임에 창의적이고 유용한 시각 효과를 쉽게 추가할 수 있습니다.


<a id="example-pixelation"></a>

## 예제: 픽셀화

다음은 프래그먼트 셰이더를 사용해 픽셀화 효과를 만드는 예제입니다.

```dart
class PostProcessGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    world.add(
      PostProcessComponent(
        postProcess: PixelationPostProcess(),
        anchor: Anchor.center,
        children: [
          EmberPlayer(size: Vector2(100, 100)),
        ],
      ),
    );
  }
}

class PixelationPostProcess extends PostProcess {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _fragmentProgram = await FragmentProgram.fromAsset(
      'packages/flutter_shaders/shaders/pixelation.frag',
    );
  }

  late final FragmentProgram _fragmentProgram;
  late final FragmentShader _fragmentShader = _fragmentProgram.fragmentShader();

  double _time = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  late final myPaint = Paint()..shader = _fragmentShader;

  @override
  void postProcess(Vector2 size, Canvas canvas) {
    final preRenderedSubtree = rasterizeSubtree();

    _fragmentShader.setFloatUniforms((value) {
      value
        ..setVector(size / (20 * sin(_time)))
        ..setVector(size);
    });

    _fragmentShader.setImageSampler(0, preRenderedSubtree);

    canvas
      ..save()
      ..drawRect(Offset.zero & size.toSize(), myPaint)
      ..restore();
  }
}

```

이 예제에서는 다음과 같은 일이 일어납니다.

- 프래그먼트 셰이더(`pixelation.frag`)를 로드해 픽셀화 효과를 적용하는 데 사용합니다.

- `rasterizeSubtree` 메서드는 컴포넌트 트리의 렌더링 결과를 텍스처로 캡처하고,
  셰이더는 이를 사용해 픽셀화된 출력을 만들어 냅니다.

- 효과가 시간에 따라 동적으로 변하면서 애니메이션되는 픽셀화 효과가 만들어집니다.

이 예제는 포스트 프로세싱 시스템을 사용해 Flame 게임에 시각 효과를 추가하는 것이 얼마나 간단한지
보여 줍니다.

```{flutter-app}
:sources: ../flame/examples
:page: post_process
:show: widget code infobox
:width: 180
:height: 180
```

픽셀화 셰이더 파일은 다음과 같습니다.

```glsl
#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uPixels;
uniform vec2 uSize;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec2 puv = round(uv * uPixels) / uPixels;
  fragColor = texture(uTexture, puv);
}
```


<a id="advanced-example-crystal-ball"></a>

## 고급 예제: Crystal Ball

포스트 프로세싱의 좀 더 고급 활용 사례는
[Crystal Ball 예제](https://examples.flame-engine.org/)를 참고하세요. 이 예제는 카메라 수준의 포스트
프로세싱과 `PostProcessSequentialGroup`을 사용한 여러 효과의 체이닝을 보여 줍니다.

![Crystal Ball 예제](../images/crystal_ball.png)

다음은 카메라에서 여러 포스트 프로세싱 효과를 조합하는 방법입니다.

```dart
class CrystalBallGame extends FlameGame<CrystalBallGameWorld> {

  CrystalBallGame() : super(
          camera: CameraComponent.withFixedResolution(
            width: kCameraSize.x,
            height: kCameraSize.y,
          ),
          world: CrystalBallGameWorld(),
        ) {
    camera.postProcess = PostProcessGroup(
      postProcesses: [
        PostProcessSequentialGroup(
          postProcesses: [
            FireflyPostProcess(),
            WaterPostProcess(),
          ],
        ),
        ForegroundFogPostProcess(),
      ],
    );
  }
}
```

이 코드에서는 다음과 같은 일이 일어납니다.

- 카메라가 여러 효과를 담은 `PostProcessGroup`을 적용합니다.
- `PostProcessSequentialGroup`이 두 효과(`FireflyPostProcess`와 `WaterPostProcess`)를
  순차적으로 연결합니다.
- 순차 그룹과 함께 추가적인 병렬 효과(`ForegroundFogPostProcess`)가
  적용됩니다.

소스 코드는 [GitHub](https://github.com/flame-engine/flame/tree/main/examples/games/crystal_ball)에서 살펴볼 수 있습니다.
