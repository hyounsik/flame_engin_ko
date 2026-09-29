<a id="1-sprite-component"></a>

# 1. 스프라이트 컴포넌트


<a id="architecture-and-responsibilities"></a>

## 구조와 역할

스프라이트를 렌더링하고 셰이더를 적용할 컴포넌트를 만들어 봅시다. 이를 두 개의 클래스로
나눕니다.

- 이미지를 로드하고 입력 이벤트를 처리하는 `SpriteComponent` 하위 클래스
- 스프라이트를 감싸고 셰이더를 적용하는 `PostProcessComponent` 하위 클래스

이렇게 분리하면 셰이더를 변경할 때는 래퍼 클래스만 수정하면 되고, 입력 이벤트 믹스인이나 추가 자식을
넣는 것 같은 스프라이트 변경은 스프라이트 클래스만
수정하면 됩니다.


<a id="image-resource"></a>

## 이미지 리소스

이 튜토리얼에서는 외곽선 셰이더를 적용할, 배경이 투명한 이미지가 필요합니다.
프로젝트에 `assets/images/` 디렉터리를 만들고 그 안에 `.png` 이미지를 넣습니다.

`pubspec.yaml`에 에셋 폴더를 등록하는 것을 잊지 마세요.

```yaml
flutter:
  assets:
    - assets/images/
```


<a id="sprite"></a>

## 스프라이트

`sword_component.dart`라는 새 파일을 만듭니다("sword"는 여러분의 이미지 이름으로 바꾸세요).

```dart
import 'package:flame/components.dart';

class SwordSprite extends SpriteComponent {
  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('assets/images/sword.png');
    size = sprite!.srcSize;
  }
}
```


<a id="wrapper"></a>

## 래퍼

다음으로 포스트 프로세스를 적용하는 래퍼 클래스를 추가합니다. 같은 파일에 다음을 작성합니다.

```dart
import 'package:flame/components.dart';
import 'package:flame/post_process.dart';

import 'package:basic_shader_tutorial/outline_postprocess.dart';

class OutlinedSwordSprite extends PostProcessComponent {
  OutlinedSwordSprite({super.position, super.anchor})
    : super(
        children: [SwordSprite()],
        postProcess: OutlinePostProcess(anchor: anchor ?? Anchor.topLeft),
      );
}
```


<a id="result"></a>

## 결과

최종 `sword_component.dart` 파일은 다음과 같습니다.

```dart
import 'package:flame/components.dart';
import 'package:flame/post_process.dart';

import 'package:basic_shader_tutorial/outline_postprocess.dart';

class OutlinedSwordSprite extends PostProcessComponent {
  OutlinedSwordSprite({super.position, super.anchor})
    : super(
        children: [SwordSprite()],
        postProcess: OutlinePostProcess(anchor: anchor ?? Anchor.topLeft),
      );
}

class SwordSprite extends SpriteComponent {
  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('assets/images/sword.png');
    size = sprite!.srcSize;
  }
}
```

아직 `OutlinePostProcess`가 없으므로 컴파일되지 않습니다. 다음 단계에서 만들어 봅시다!
