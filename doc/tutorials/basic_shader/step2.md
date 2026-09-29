<a id="2-outline-post-process"></a>

# 2. 외곽선 포스트 프로세스


<a id="responsibility"></a>

## 역할

`PostProcess` 클래스는 프래그먼트(픽셀) 셰이더를 관리합니다. 셰이더 프로그램을 로드하고,
GPU 리소스를 만들고, 매 프레임 uniform 변수를 최신 상태로 유지하는 역할을 합니다.
또한 uniform을 통해 이펙트를 켜거나 끄는 것 같은 런타임 설정을 노출할 수도 있습니다.


<a id="post-process"></a>

## 포스트 프로세스

`outline_postprocess.dart`라는 새 파일을 만듭니다. 이 클래스는 `onLoad()`에서 셰이더 프로그램을
로드하고, `postProcess()`에서 매 프레임 uniform 값을 GPU에 전달합니다.

```dart
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flame/components.dart';
import 'package:flame/post_process.dart';

extension on Color {
  Vector4 toVector4() {
    return Vector4(r, g, b, a);
  }
}

class OutlinePostProcess extends PostProcess {
  final double outlineSize;
  Color outlineColor;
  final Anchor anchor;

  OutlinePostProcess({
    this.outlineSize = 7.0,
    this.outlineColor = Colors.purpleAccent,
    this.anchor = Anchor.topLeft,
  });

  late final FragmentProgram _fragmentProgram;
  late final FragmentShader _fragmentShader =
      _fragmentProgram.fragmentShader();
  late final Paint _myPaint = Paint()..shader = _fragmentShader;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _fragmentProgram =
        await FragmentProgram.fromAsset('assets/shaders/outline.frag');
  }

  @override
  void postProcess(Vector2 size, Canvas canvas) {
    final preRenderedSubtree = rasterizeSubtree();

    _fragmentShader.setFloatUniforms((value) {
      value
        ..setVector(size)
        ..setFloat(outlineSize)
        ..setVector(outlineColor.toVector4());
    });

    _fragmentShader.setImageSampler(0, preRenderedSubtree);

    canvas
      ..save()
      ..translate(-size.x * anchor.x, -size.y * anchor.y)
      ..drawRect(Offset.zero & size.toSize(), _myPaint)
      ..restore();
  }
}
```

이 파일을 추가하면 이전 단계의 구문 오류가 사라집니다.

`PostProcessComponent`가 `SpriteComponent`의 부모이므로, 포스트 프로세스가 먼저 렌더링되고
그 위에 스프라이트가 그려집니다. `rasterizeSubtree()` 호출은 모든 자식을 셰이더가 샘플링할 수 있는
이미지로 캡처합니다.


<a id="usage"></a>

## 사용법

이제 모든 것을 연결해야 합니다. `main.dart`를 열고 일반 스프라이트와 외곽선이 적용된 스프라이트를
모두 월드에 추가해 나란히 비교할 수 있게 합니다.

```dart
import 'package:flutter/material.dart';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'package:basic_shader_tutorial/sword_component.dart';

void main() {
  runApp(
    GameWidget(game: MyGame()),
  );
}

class MyGame extends FlameGame {
  MyGame() : super(world: MyWorld());

  @override
  Color backgroundColor() => Colors.green;
}

class MyWorld extends World {
  @override
  Future<void> onLoad() async {
    add(
      SwordSprite()
        ..position = Vector2(-200, 0)
        ..anchor = Anchor.center,
    );

    add(
      OutlinedSwordSprite(
        position: Vector2(200, 0),
        anchor: Anchor.center,
      ),
    );
  }
}
```

여기서는 배경색을 오버라이드하기 위해 커스텀 `FlameGame` 하위 클래스를 사용합니다. 위치와 색상은
여러분의 이미지에 맞게 조정하세요.

애플리케이션을 실행합니다. 스프라이트가 하나만 보이고 외곽선이 적용된 스프라이트는 보이지 않을 것입니다.
콘솔에서 그 이유를 확인할 수 있습니다.
`[...] Unhandled Exception: Exception: Asset 'assets/shaders/outline.frag' not found [...]`

아직 셰이더 파일을 만들지 않았기 때문입니다. 다음 단계에서 만들어 봅시다.
