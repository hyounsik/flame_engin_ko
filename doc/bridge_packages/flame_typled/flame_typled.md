# flame_typled

flame_typled는 [Typled](https://pub.dev/packages/typled) 스프라이트 아틀라스와 Flame을 연동하는 기능을
제공합니다.

Typled는 스프라이트 시트, 타일셋, 타일맵을 매핑하기 위한 간단한 텍스트 기반 포맷입니다. 텍스트 파일을
사용 가능한 Dart 모델로 파싱하는 Dart 패키지와, 파일을 시각화할 수 있는 애플리케이션을
제공합니다.

`'package:flame_typled/flame_typled.dart'`에서 `TypledSpriteAtlas` 클래스를 import하고 아틀라스를
불러옵니다.

```dart
final atlas = await TypledSpriteAtlas.load('assets/atlas.typled');
```

그런 다음 typled id로 개별 스프라이트를 가져옵니다.

```dart
final mySprite = atlas.sprite('player_idle');
```

이 코드는 Sprite의 새 인스턴스를 생성하므로, 저장해 두는 것이 좋을 수 있습니다.

또는 효율적인 배치 렌더링을 위해 `SpriteBatch`를 만들 수 있습니다.

```dart
final batch = atlas.toBatch(useAtlas: false);
```

기본적으로 Flame Typled는 각 타일의 사방에 1픽셀(총 2픽셀)의 Ghost Line 방지용 패딩을
추가합니다. `TypledSpriteAtlas.load()`에 `disablePadding: true`를 전달하면
이 동작을 바꿀 수 있습니다.
