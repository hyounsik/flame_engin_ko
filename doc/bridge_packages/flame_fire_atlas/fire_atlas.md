# Flame fire atlas

Flame fire atlas는 Flame용 텍스처 아틀라스 라이브러리입니다. `flame_fire_atlas`를 사용하면 `.fa` 텍스처
아틀라스에 저장된 이미지와 애니메이션을 이름 키로 참조해 접근할 수 있습니다.


## FireAtlas

FireAtlas는 텍스처 아틀라스를 다루기 위한 도구입니다. 아틀라스는
[Fire Atlas Editor](https://fire-atlas.flame-engine.org)로 만들 수 있습니다.


<a id="creating-atlas"></a>

### 아틀라스 만들기

텍스처 아틀라스를 만들려면 [Fire Atlas Editor](https://fire-atlas.flame-engine.org)를 엽니다.

새 아틀라스를 선택하고 아틀라스 이름, 타일 너비, 타일 높이, 이미지를 지정한 뒤 확인을 누릅니다.
그러면 아틀라스 에디터로 이동합니다.

아틀라스에 새 `Sprite`를 만들려면 영역을 선택하고 왼쪽 위의 더하기 버튼을 클릭한 뒤, 선택 영역에 이름을
지정하고 타입으로 `Sprite`를 선택한 다음 `Create Sprite`를 누릅니다. 이제 에디터 오른쪽 패널에서
미리보기를 볼 수 있습니다.

아틀라스에 새 `SpriteAnimation`을 만들려면 영역을 선택하고 왼쪽 위의 더하기 버튼을 클릭한 뒤,
선택 영역에 이름을 지정하고 타입으로 `Animation`을 선택합니다. 그다음 `frame count`와
`steps times (in milliseconds)`를 입력하고, 애니메이션을 반복하려면 체크박스를 선택한 뒤
`Create Animation`을 누릅니다. 이제 에디터 오른쪽 패널에서 애니메이션 미리보기를 볼 수
있습니다.

편집을 마쳤으면 왼쪽 위의 `download` 아이콘 버튼으로 fire atlas 파일을
다운로드할 수 있습니다.


<a id="texture-atlas"></a>

## 텍스처 아틀라스

[텍스처 아틀라스](https://en.wikipedia.org/wiki/Texture_atlas)는 전체 크기를 줄이기 위해 여러 개의 작은
이미지 데이터를 하나로 묶은 이미지입니다. 이를 사용하면 불러오는 이미지 수가 줄어들어
게임의 로딩 시간을 단축할 수 있습니다.


<a id="usage"></a>

## 사용법

게임에서 이 브릿지 라이브러리를 사용하려면 pubspec.yaml에 `flame_fire_atlas`를 추가하기만 하면 됩니다.
자세한 내용은
[Flame Fire Atlas 예제](https://github.com/flame-engine/flame/tree/main/packages/flame_fire_atlas/example)와
pub.dev의 [설치 안내](https://pub.dev/packages/flame_fire_atlas)에서 확인할 수 있습니다.

그러면 다음 메서드를 사용할 수 있습니다.

```dart
import 'package:flame_fire_atlas/flame_fire_atlas.dart';

// 에셋에서 아틀라스를 불러옵니다
// 파일 위치: assets/atlas.fa
final atlas = await FireAtlas.loadAsset('assets/atlas.fa');

// 또는 게임 인스턴스 내부에서는 loadFireAtlas를 사용할 수 있습니다:
// 파일 위치: assets/atlas.fa
final atlas = await loadFireAtlas('assets/atlas.fa');

// 주어진 키로 Sprite를 가져옵니다.
FireAtlas.getSprite('sprite_name')

// 주어진 키로 SpriteAnimation을 가져옵니다.
FireAtlas.getAnimation('animation_name')
```

게임에서 FireAtlas를 사용하려면 게임이나 컴포넌트의 `onLoad` 메서드에서 fire atlas 파일을 불러옵니다.
그런 다음 `getSprite`와 `getAnimation`을 사용해 매핑된 에셋을 가져올 수 있습니다.

```dart
class ExampleGame extends FlameGame {

  late FireAtlas _atlas;

  @override
  Future<void> onLoad() async {
    _atlas = await loadFireAtlas('assets/atlas.fa');

    add(
      SpriteComponent(
        size: Vector2(50, 50),
        position: Vector2(0, 50),
        sprite: _atlas.getSprite('sprite_name'),
      ),
    );

    add(
      SpriteAnimationComponent(
        size: Vector2(150, 100),
        position: Vector2(150, 100),
        animation: _atlas.getAnimation('animation_name'),
      ),
    );
  }

}
```


<a id="full-example"></a>

## 전체 예제

예제는
[여기](https://github.com/flame-engine/flame/tree/main/packages/flame_fire_atlas/example)에서 확인할 수 있습니다.

