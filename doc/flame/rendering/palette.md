<a id="palette"></a>

# 팔레트

게임 곳곳에서 색상을 사용해야 합니다. `dart:ui`에는 이를 위해 사용할 수 있는 두 가지 클래스,
`Color`와 `Paint`가 있습니다.

`Color` 클래스는 16진수 정수 형식의 ARGB 색상을 나타냅니다.
따라서 `Color` 인스턴스를 만들려면 ARGB 형식의 정수로 색상을 전달하기만 하면 됩니다.

<!--- cSpell:ignore AARRGGBB -->
Dart의 16진수 표기법을 사용하면 아주 쉽습니다. 예를 들어 `0xFF00FF00`은 완전히
불투명한 초록색입니다("마스크"는 `0xAARRGGBB`입니다).

**참고**: 일반적인(A가 없는) RGB와 달리, 처음 두 자리의 16진수는
알파 채널(투명도)을 나타냅니다. 처음 두 자리가 최댓값(FF = 255)이면 완전히 불투명하고,
최솟값(00 = 0)이면 완전히 투명합니다.

Material Flutter 패키지에는 자주 쓰는 색상을 상수로 제공하는 `Colors` 클래스가 있습니다.

```dart
import 'package:flutter/material.dart' show Colors;

const black = Colors.black;
```

좀 더 복잡한 메서드는 `Paint` 객체를 받기도 합니다. `Paint`는 선(stroke), 색상, 필터, 블렌드와 관련된
요소를 설정할 수 있는 보다 완전한 구조체입니다.
하지만 복잡한 API를 사용할 때에도 보통은 단순한 단색 하나를 나타내는 `Paint`
객체 인스턴스만 있으면 됩니다.

**참고:** 특정 `Paint`가 필요할 때마다 새로운 `Paint` 객체를 만드는 것은 권장하지 않습니다.
불필요한 객체가 많이 생성될 수 있기 때문입니다. 더 나은 방법은
`Paint` 객체를 어딘가에 정의해 두고 재사용하거나(단, `Color`와 달리 `Paint`
클래스는 변경 가능(mutable)하다는 점에 주의하세요), `Palette` 클래스를 사용해 게임에서 사용할
모든 색상을 정의하는 것입니다.

이런 객체는 다음과 같이 만들 수 있습니다.

```dart
Paint green = Paint()..color = const Color(0xFF00FF00);
```

이를 돕고 게임의 색상 팔레트를 일관되게 유지할 수 있도록 Flame은 `Palette`
클래스를 제공합니다. 이 클래스를 사용하면 필요한 곳에서 `Color`와 `Paint`에 모두 쉽게 접근할 수 있고,
게임에서 사용하는 색상을 상수로 정의해 서로 헷갈리지 않게 할 수 있습니다.

`BasicPalette` 클래스는 팔레트가 어떤 모습일 수 있는지 보여주는 예시로, 검은색과 흰색을
색상으로 제공합니다. 따라서 `BasicPalette`에서 검은색이나 흰색에 바로 접근할 수 있습니다. 예를 들어
`color`를 사용하면 다음과 같습니다.

```dart
TextConfig regular = TextConfig(color: BasicPalette.white.color);
```

또는 `paint`를 사용하면 다음과 같습니다.

```dart
canvas.drawRect(rect, BasicPalette.black.paint);
```

하지만 핵심은 `BasicPalette` 예시를 따라 직접 팔레트를 만들고, 게임의 색상 팔레트/스킴을
추가하는 것입니다. 그러면 컴포넌트와 클래스 어디에서든 정적으로 원하는 색상에 접근할 수 있습니다.
아래는 [예제
게임 BGUG](https://github.com/bluefireteam/bgug/blob/master/lib/palette.dart)에서 가져온 `Palette` 구현 예시입니다.

```dart
import 'dart:ui';

import 'package:flame/palette.dart';

class Palette {
  static PaletteEntry white = BasicPalette.white;

  static PaletteEntry toastBackground = PaletteEntry(Color(0xFFAC3232));
  static PaletteEntry toastText = PaletteEntry(Color(0xFFDA9A00));

  static PaletteEntry grey = PaletteEntry(Color(0xFF404040));
  static PaletteEntry green = PaletteEntry(Color(0xFF54a286));
}
```

`PaletteEntry`는 색상 정보를 담는 `const` 클래스이며, 다음과 같은
멤버를 가집니다.

- `color`: 지정된 `Color`를 반환합니다.
- `paint`: 지정된 색상으로 새로운 `Paint`를 생성합니다. `Paint`는 `const`가 아닌 클래스이므로, 이
  메서드는 호출될 때마다 완전히 새로운 인스턴스를 생성합니다. 따라서 여기에 캐스케이드로 변경을 적용해도 안전합니다.

또한 `withRed`나 `lighten`처럼 내부 색상을 변환해 새로운 `PaletteEntry`를 만드는
헬퍼 메서드도 제공합니다.
