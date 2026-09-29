<a id="widgets"></a>

# 위젯

Flutter로 게임을 개발할 때의 장점 중 하나는 UI를 만들기 위한 Flutter의 방대한 도구를 활용할 수
있다는 점입니다. Flame은 여기에 더해 게임을 염두에 두고 만든 위젯을 제공합니다.

여기에서 Flame이 제공하는 모든 위젯을 확인할 수 있습니다.

[위젯 예제 디렉터리](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/widgets)의
[Dashbook](https://github.com/bluefireteam/dashbook) 샌드박스에서 모든 위젯의 시연을 볼 수도
있습니다.


## NineTileBoxWidget

Nine Tile Box는 그리드 스프라이트를 사용해 그리는 사각형입니다.

그리드 스프라이트는 9개의 블록으로 이루어진 3x3 그리드로, 4개의 모서리, 4개의 변, 그리고 가운데를
나타냅니다.

모서리는 같은 크기로 그려지고, 변은 변의 방향으로 늘어나며, 가운데는 양방향으로 확장됩니다.

`NineTileBoxWidget`은 이 방식을 사용하는 `Container`를 구현합니다. 이 패턴은
`NineTileBoxComponent`라는 컴포넌트로도 구현되어 있어서 이 기능을 `FlameGame`에 직접 추가할 수
있습니다. 자세한 내용은
[NineTileBoxComponent 문서](../components/utility_components.md#ninetileboxcomponent)를 확인하세요.

다음은 (`NineTileBoxComponent`를 사용하지 않고) 사용하는 예시입니다.

```dart
import 'package:flame/widgets';

NineTileBoxWidget(
    image: image, // dart:ui 이미지 인스턴스
    tileSize: 16, // 그리드 이미지에서 타일 하나의 너비/높이
    destTileSize: 50, // 캔버스에 그려질 타일의 크기
    child: SomeWidget(), // 아무 Flutter 위젯
)
```


## SpriteButton

`SpriteButton`은 Flame 스프라이트를 기반으로 버튼을 만드는 간단한 위젯입니다. 기본 모양이 아닌
버튼을 만들 때 아주 유용합니다. 예를 들어 Flutter에서 직접 만드는 것보다 그래픽 편집기에서 버튼을
그리는 편이 원하는 모양을 내기 더 쉬운 경우에 좋습니다.

사용 방법:

```dart
SpriteButton(
    onPressed: () {
      print('Pressed');
    },
    label: const Text('Sprite Button', style: const TextStyle(color: const Color(0xFF5D275D))),
    sprite: _spriteButton,
    pressedSprite: _pressedSprite,
    // 선택 사항이며, onPressed가 null일 때 표시됩니다.
    disabledSprite: _disabledSprite,
    height: _height,
    width: _width,
)
```


## SpriteWidget

`SpriteWidget`은 위젯 트리 안에 [Sprite](../rendering/images.md#sprite)를 표시하는 데 사용하는
위젯입니다.

사용 방법은 다음과 같습니다.

```dart
SpriteWidget(
    sprite: yourSprite,
    anchor: Anchor.center,
)
```


## SpriteAnimationWidget

`SpriteAnimationWidget`은 위젯 트리 안에
[SpriteAnimation](../rendering/images.md#animation)을 표시하는 데 사용하는 위젯입니다.

사용 방법은 다음과 같습니다.

```dart
SpriteAnimationWidget(
    animation: _animation,
    animationTicker: _animationTicker,
    playing: true,
    anchor: Anchor.center,
)
```
