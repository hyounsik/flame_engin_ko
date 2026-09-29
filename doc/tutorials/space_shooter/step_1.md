<a id="getting-started"></a>

# 시작하기

이 튜토리얼은 완전한 Flame 게임을 처음부터 한 단계씩 개발하는 과정을
안내합니다. 튜토리얼을 마치면 애니메이션, 제스처 입력, 마우스와 키보드 조작, 충돌 감지 등을
갖춘 고전적인 Space Shooter 게임을 만들게 됩니다.

이 첫 번째 파트에서는 다음을 소개합니다.

- `FlameGame`: Flame 컴포넌트 시스템을 사용하는 게임의 기본 클래스입니다.
- `GameWidget`: 게임을 Flutter 위젯 트리에 삽입하는 `Widget`입니다.
- `PositionComponent`: 가장 기본적인 Flame 컴포넌트 중 하나로, 게임 공간에서의 위치와
크기를 모두 가집니다.

게임 클래스와 그 게임을 실행할 `GameWidget`을 만드는 것부터 시작해 봅시다.

```dart
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

class SpaceShooterGame extends FlameGame {
}

void main() {
  runApp(GameWidget(game: SpaceShooterGame()));
}
```

이게 전부입니다! 이것을 실행하면 지금은 빈 검은 화면만 보이지만, 여기서부터
게임을 구현해 나갈 수 있습니다.

다음으로 플레이어 컴포넌트를 만들어 봅시다. 이를 위해 Flame의
`PositionComponent`를 기반으로 하는 새 클래스를 만듭니다. 이 컴포넌트는 게임 화면에서 위치와 크기를 가지는
모든 컴포넌트의 기반입니다. 지금은 컴포넌트가 흰색 사각형만 렌더링하도록 하겠습니다. 다음과 같이
구현할 수 있습니다.

```dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Player extends PositionComponent {
  static final _paint = Paint()..color = Colors.white;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }
}
```

이제 새 컴포넌트를 게임에 추가해 봅시다. 게임 시작 시 컴포넌트를 추가하는 작업은
`onLoad` 메서드에서 해야 하므로, `FlameGame.onLoad`를 오버라이드하고 그 안에 로직을 추가합시다. 수정된
코드는 다음과 같습니다.

```dart
class SpaceShooterGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      Player()
        ..position = size / 2
        ..width = 50
        ..height = 100
        ..anchor = Anchor.center,
    );
  }
}
```

이것을 실행하면 이제 화면 가운데에 흰색 사각형이 렌더링되는 것을 볼 수 있습니다.

짚고 넘어갈 만한 점이 몇 가지 있습니다.

- `size`는 게임 클래스의 `Vector2` 변수로, 게임 영역의 현재 크기를 담고 있습니다.
`x`는 가로 크기, 즉 너비이고, `y`는 세로 크기, 즉
높이입니다.
- 기본적으로 Flame은 Flutter의 캔버스 앵커링을 따릅니다. 즉, (0, 0)이 캔버스의
왼쪽 위 모서리에 고정됩니다. 따라서 게임과 모든 컴포넌트는 기본적으로 같은 앵커를 사용합니다.
컴포넌트의 `anchor` 속성을 `Anchor.center`로 바꾸면 이를 변경할 수 있으며, 화면에서 컴포넌트를
가운데에 두고 싶을 때 훨씬 편해집니다.

이것으로 첫 번째 파트는 끝입니다! 이 첫 단계에서는 게임 클래스를 만들고,
Flutter 위젯 트리에 삽입하고, 간단한 컴포넌트를 렌더링하는 기본을 배웠습니다.


<a id="preparing-the-assets-folder"></a>

## 에셋 폴더 준비

다음으로 넘어가기 전에, 다음 단계에서 사용할 그래픽을 위해 프로젝트를 준비해 봅시다.
게임에는 이미지, 스프라이트, 애니메이션 같은 에셋이 필요하며, Space Shooter도 예외는 아닙니다.

먼저 프로젝트 루트에 `assets/images/` 폴더를 만듭니다. 그런 다음 `pubspec.yaml`에
다음 줄을 추가해 Flutter에 알립니다.

```yaml
flutter:
  assets:
    - assets/images/
```

프로젝트 구조는 다음과 같아야 합니다.

```text
space_shooter/
 ├─assets/
 │  └─images/
 ├─lib/
 │  └─main.dart
 └─pubspec.yaml
```

다음 단계들에서 `assets/images/` 폴더에 저장해야 하는 이미지 파일을
제공합니다. 나올 때마다 빠짐없이 저장하세요.

```{flutter-app}
:sources: ../tutorials/space_shooter/app
:page: step1
:show: popup code
```

[다음 단계: 플레이어 조작과 그래픽 추가](./step_2.md)
