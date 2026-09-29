<a id="assets-directory-structure"></a>

# 에셋 디렉터리 구조

게임은 스프라이트용 이미지, 효과음용 오디오 파일, 레벨용 타일 맵 같은 외부 에셋에 크게 의존합니다.
이런 파일을 일관되게 정리해 두면 Flame의 내장 로더(그리고 Flutter 자체의
[에셋 시스템](https://docs.flutter.dev/ui/assets/assets-and-images))가 별도 설정 없이
파일을 찾을 수 있습니다.

모든 Flame 로더는 `pubspec.yaml`에 선언한 그대로의 에셋 **전체 경로**를 받습니다.
앞에 자동으로 붙는 것이 없으므로, 작성한 문자열이 곧 로드되는 문자열입니다.

Flame은 표준 Flutter `assets` 디렉터리와 그 하위 디렉터리인 `audio`, `images`, `tiles`로
이루어진 프로젝트 구조를 제안합니다. 이는 관례일 뿐 필수 사항은 아닙니다.

다음 예제 코드를 사용한다면:

```dart
class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await FlameAudio.play('assets/audio/explosion.mp3');

    // 이미지 몇 개 로드
    await Flame.images.load('assets/images/player.png');
    await Flame.images.load('assets/images/enemy.png');

    // 또는 디렉터리 안의 모든 이미지 로드
    await Flame.images.loadAllImages(directory: 'assets/images/');

    final map1 = await TiledComponent.load('assets/tiles/level.tmx', tileSize);
  }
}
```

다음 파일 구조가 이 경로들과 일치합니다:

```text
.
└── assets
    ├── audio
    │   └── explosion.mp3
    ├── images
    │   ├── enemy.png
    │   ├── player.png
    │   └── spritesheet.png
    └── tiles
        ├── level.tmx
        └── map.json
```

원한다면 `audio` 폴더를 `music`용과 `sfx`용 두 하위 폴더로 나눌 수도 있습니다.

이 파일들을 `pubspec.yaml` 파일에 추가하는 것을 잊지 마세요:

```yaml
flutter:
  assets:
    - assets/audio/explosion.mp3
    - assets/images/player.png
    - assets/images/enemy.png
    - assets/tiles/level.tmx
```

원하는 구조를 자유롭게 사용해도 됩니다. 모든 경로를 전체로 지정하므로, 에셋을 다르게 배치해도
설정은 전혀 필요 없고 문자열만 달라질 뿐입니다:

```dart
await Flame.images.load('gfx/sprites/player.png');
```

경로는 에셋이 캐시될 때 사용하는 키이기도 하므로, `Flame.images.fromCache`와
`Images.containsKey`도 같은 전체 경로를 받습니다.

`AssetsCache`와 `Images`는 커스텀
[`AssetBundle`](https://api.flutter.dev/flutter/services/AssetBundle-class.html)을 받을 수 있습니다.
이를 이용하면 Flame이 `rootBundle`이 아닌 다른 위치(예: 파일 시스템)에서
에셋을 찾도록 할 수 있습니다.
