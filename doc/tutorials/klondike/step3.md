<a id="3-cards"></a>

# 3. 카드

이번 장에서는 게임에서 가장 눈에 띄는 컴포넌트인 **Card** 컴포넌트의 구현을
시작합니다. 이 컴포넌트는 실제 카드 한 장에 해당합니다.
게임에는 52개의 `Card` 객체가 있습니다.

각 카드에는 **숫자(랭크)**(1부터 13까지로, 1은 에이스, 13은 킹)
와 **무늬**(0부터 3까지: 하트 ♥, 다이아몬드 ♦, 클럽 ♣, 스페이드 ♠)가 있습니다.
또한 각 카드에는 불리언 플래그 **faceUp**이 있어서, 카드가 현재 앞면이
위로 향해 있는지 뒷면이 위로 향해 있는지를 제어합니다. 이 속성은 렌더링에도,
게임플레이 로직의 일부 측면에도 중요합니다.

숫자와 무늬는 카드의 단순한 속성일 뿐 컴포넌트가 아니므로,
이를 어떻게 표현할지 결정해야 합니다. 몇 가지 선택지가 있습니다.
단순한 `int`로 표현할 수도 있고, `enum`이나 객체로 표현할 수도 있습니다.
어떤 것을 고를지는 이 값들로 어떤 연산을 해야 하는지에 달려 있습니다.
숫자의 경우, 어떤 숫자가 다른 숫자보다 하나 높은지/낮은지 판단할 수 있어야 합니다.
또한 주어진 숫자에 대응하는 텍스트 라벨과 스프라이트를
만들어야 합니다. 무늬의 경우, 두 무늬의 색이 서로 다른지 알아야 하고,
역시 텍스트 라벨과 스프라이트를 만들어야 합니다. 이러한 요구 사항을 고려해
`Rank`와 `Suit`를 모두 클래스로 표현하기로 했습니다.


## Suit

`suit.dart` 파일을 만들고, 그 안에 부모 클래스가 없는 `@immutable class Suit`를
선언하세요. 여기서 `@immutable` 어노테이션은 이 클래스의 객체가 생성된 뒤에는
수정되어서는 안 된다는 것을 알려 주는 힌트일 뿐입니다.

다음으로 클래스의 팩토리 생성자 `Suit.fromInt(i)`를 정의합니다.
여기서 팩토리 생성자를 사용하는 이유는 이 클래스에 싱글턴 패턴을
강제하기 위해서입니다. 매번 새 객체를 만드는 대신, `_singletons` 리스트에 저장해 둔
미리 만들어진 객체 중 하나를 반환합니다.

```dart
  factory Suit.fromInt(int index) {
    assert(index >= 0 && index <= 3);
    return _singletons[index];
  }
```

그다음에는 private 생성자 `Suit._()`가 있습니다. 이 생성자는
각 `Suit` 객체의 주요 속성을 초기화합니다. 바로 숫자 값,
문자열 라벨, 그리고 나중에 캔버스에 무늬 기호를 그릴 때 사용할
스프라이트 객체입니다. 스프라이트 객체는 앞 장에서 만든
`klondikeSprite()` 함수를 사용해 초기화합니다.

```dart
  Suit._(this.value, this.label, double x, double y, double w, double h)
      : sprite = klondikeSprite(x, y, w, h);

  final int value;
  final String label;
  final Sprite sprite;
```

이어서 게임의 모든 `Suit` 객체를 담는 static 리스트가 나옵니다. 이 리스트를
static 변수로 정의했기 때문에 지연 평가된다는 점에 유의하세요(마치 `late` 키워드를
붙인 것처럼). 즉, 처음 필요해질 때에만 초기화됩니다.
이 점이 중요합니다. 위에서 볼 수 있듯이 생성자는
전역 캐시에서 이미지를 가져오려고 하므로, 이미지가 캐시에 로드된 뒤에만
호출될 수 있기 때문입니다.

```dart
  static final List<Suit> _singletons = [
    Suit._(0, '♥', 1176, 17, 172, 183),
    Suit._(1, '♦', 973, 14, 177, 182),
    Suit._(2, '♣', 974, 226, 184, 172),
    Suit._(3, '♠', 1178, 220, 176, 182),
  ];
```

생성자의 마지막 네 숫자는 스프라이트 시트 `klondike-sprites.png` 안에서
스프라이트 이미지의 좌표입니다. 이 숫자를 어떻게 얻었는지 궁금하다면,
무료 온라인 서비스인 [spritecow.com]을 사용했습니다.
스프라이트 시트 안에서 스프라이트의 위치를 찾는 데 편리한 도구입니다.

마지막으로 무늬의 "색"을 판별하는 간단한 getter가 있습니다. 이는 나중에
카드를 색이 번갈아 가도록만 열에 놓을 수 있다는 규칙을 강제해야 할 때
필요합니다.

```dart
  /// 하트와 다이아몬드는 빨간색이고, 클럽과 스페이드는 검은색입니다.
  bool get isRed => value <= 1;
  bool get isBlack => value >= 2;
```


## Rank

`Rank` 클래스는 `Suit`와 매우 비슷합니다. 주요 차이점은 `Rank`가
스프라이트를 하나가 아니라 두 개, 즉 "빨간색"과 "검은색" 숫자용으로 각각
가진다는 것입니다. `Rank` 클래스의 전체 코드는 다음과 같습니다.

```dart
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';

@immutable
class Rank {
  factory Rank.fromInt(int value) {
    assert(value >= 1 && value <= 13);
    return _singletons[value - 1];
  }

  Rank._(
    this.value,
    this.label,
    double x1,
    double y1,
    double x2,
    double y2,
    double w,
    double h,
  )   : redSprite = klondikeSprite(x1, y1, w, h),
        blackSprite = klondikeSprite(x2, y2, w, h);

  final int value;
  final String label;
  final Sprite redSprite;
  final Sprite blackSprite;

  static final List<Rank> _singletons = [
    Rank._(1, 'A', 335, 164, 789, 161, 120, 129),
    Rank._(2, '2', 20, 19, 15, 322, 83, 125),
    Rank._(3, '3', 122, 19, 117, 322, 80, 127),
    Rank._(4, '4', 213, 12, 208, 315, 93, 132),
    Rank._(5, '5', 314, 21, 309, 324, 85, 125),
    Rank._(6, '6', 419, 17, 414, 320, 84, 129),
    Rank._(7, '7', 509, 21, 505, 324, 92, 128),
    Rank._(8, '8', 612, 19, 607, 322, 78, 127),
    Rank._(9, '9', 709, 19, 704, 322, 84, 130),
    Rank._(10, '10', 810, 20, 805, 322, 137, 127),
    Rank._(11, 'J', 15, 170, 469, 167, 56, 126),
    Rank._(12, 'Q', 92, 168, 547, 165, 132, 128),
    Rank._(13, 'K', 243, 170, 696, 167, 92, 123),
  ];
}
```


<a id="card-component"></a>

## Card 컴포넌트

이제 `Rank`와 `Suit` 클래스가 준비되었으니, 드디어 **Card** 컴포넌트를
구현하기 시작할 수 있습니다. `components/card.dart` 파일을 만들고
`PositionComponent`를 확장하는 `Card` 클래스를 선언하세요.

```dart
class Card extends PositionComponent {}
```

이 클래스의 생성자는 정수형 숫자와 무늬를 받아, 카드가 처음에는
뒷면이 위로 향하도록 만듭니다. 또한 컴포넌트의 크기를 `KlondikeGame` 클래스에
정의된 `cardSize` 상수와 같게 초기화합니다.

```dart
  Card(int intRank, int intSuit)
      : rank = Rank.fromInt(intRank),
        suit = Suit.fromInt(intSuit),
        _faceUp = false,
        super(size: KlondikeGame.cardSize);

  final Rank rank;
  final Suit suit;
  bool _faceUp;
```

`_faceUp` 속성은 private(밑줄로 표시)이고 final이 아니므로,
카드의 수명 동안 바뀔 수 있습니다. 이 변수에 대한 public 접근자와
변경자를 만들어야 합니다.

```dart
  bool get isFaceUp => _faceUp;
  bool get isFaceDown => !_faceUp;
  void flip() => _faceUp = !_faceUp;
```

마지막으로 간단한 `toString()` 구현을 추가합시다. 게임을 디버깅해야 할 때
유용할 수 있습니다.

```dart
  @override
  String toString() => rank.label + suit.label; // 예: "Q♠" 또는 "10♦"
```

렌더링 구현으로 넘어가기 전에 게임에 카드를 몇 장 추가해야 합니다.
`KlondikeGame` 클래스로 가서 `onLoad` 메서드의 맨 아래에 다음을
추가하세요.

```dart
    final random = Random();
    for (var i = 0; i < 7; i++) {
      for (var j = 0; j < 4; j++) {
        final card = Card(random.nextInt(13) + 1, random.nextInt(4))
          ..position = Vector2(100 + i * 1150, 100 + j * 1500)
          ..addToParent(world);
        if (random.nextDouble() < 0.9) { // 90% 확률로 앞면이 위로 가도록 뒤집습니다
          card.flip();
        }
      }
    }
```

이 코드 조각은 임시 코드로 다음 장에서 제거할 것이지만,
지금은 테이블 위에 무작위 카드 28장을 깔아 주며, 대부분은 앞면이 위로 향해 있습니다.


<a id="rendering"></a>

### 렌더링

카드를 볼 수 있으려면 `render()` 메서드를 구현해야 합니다.
카드에는 앞면이 위인 상태와 뒷면이 위인 상태라는 두 가지 뚜렷한 상태가 있으므로,
두 상태의 렌더링을 따로 구현하겠습니다. `Card` 클래스에 다음 메서드를
추가하세요.

```dart
  @override
  void render(Canvas canvas) {
    if (_faceUp) {
      _renderFront(canvas);
    } else {
      _renderBack(canvas);
    }
  }

  void _renderFront(Canvas canvas) {}
  void _renderBack(Canvas canvas) {}
```


### renderBack()

카드 뒷면을 렌더링하는 것이 더 간단하므로 이것부터 하겠습니다.

`PositionComponent`의 `render()` 메서드는 로컬 좌표계에서 동작합니다.
즉, 카드가 화면의 어디에 있는지 신경 쓸 필요가 없습니다.
이 로컬 좌표계는 컴포넌트의 왼쪽 위 모서리를 원점으로 하며,
오른쪽으로 `width`, 아래쪽으로 `height` 픽셀만큼
뻗어 있습니다.

카드 뒷면을 어떻게 그릴지에는 예술적 자유가 많지만, 제
구현은 단색 배경, 테두리, 가운데의 Flame 로고,
그리고 또 하나의 장식용 테두리로 이루어져 있습니다.

```dart
  void _renderBack(Canvas canvas) {
    canvas.drawRRect(cardRRect, backBackgroundPaint);
    canvas.drawRRect(cardRRect, backBorderPaint1);
    canvas.drawRRect(backRRectInner, backBorderPaint2);
    flameSprite.render(canvas, position: size / 2, anchor: Anchor.center);
  }
```

여기서 가장 흥미로운 부분은 스프라이트 렌더링입니다. 스프라이트를
가운데(`size/2`)에 렌더링하고 싶으므로, `Anchor.center`를 사용해 스프라이트의
*중심*이 그 지점에 오도록 하고 싶다고 엔진에 알려 줍니다.

`_renderBack()` 메서드에서 사용하는 여러 속성은 다음과 같이 정의합니다.

```dart
  static final Paint backBackgroundPaint = Paint()
    ..color = const Color(0xff380c02);
  static final Paint backBorderPaint1 = Paint()
    ..color = const Color(0xffdbaf58)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  static final Paint backBorderPaint2 = Paint()
    ..color = const Color(0x5CEF971B)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 35;
  static final RRect cardRRect = RRect.fromRectAndRadius(
    KlondikeGame.cardSize.toRect(),
    const Radius.circular(KlondikeGame.cardRadius),
  );
  static final RRect backRRectInner = cardRRect.deflate(40);
  static final Sprite flameSprite = klondikeSprite(1367, 6, 357, 501);
```

이 속성들을 static으로 선언한 이유는 52개의 카드 객체 모두에서 같기 때문입니다.
그러니 한 번만 초기화해서 리소스를 조금이라도 아끼는 편이
낫습니다.


### renderFront()

카드 앞면을 렌더링할 때는 표준 카드 디자인을 따릅니다. 서로 반대편의 두 모서리에
숫자와 무늬를 넣고, 숫자 값만큼 무늬 기호(pip)를 넣습니다. 그림 카드(잭, 퀸, 킹)는
가운데에 특별한 이미지를 넣습니다.

앞에서처럼 렌더링에 사용할 상수 몇 개를 선언하는 것으로 시작합니다.
카드 배경은 검은색이고, 테두리는 카드가 "빨간색" 무늬인지 "검은색" 무늬인지에
따라 달라집니다.

```dart
  static final Paint frontBackgroundPaint = Paint()
    ..color = const Color(0xff000000);
  static final Paint redBorderPaint = Paint()
    ..color = const Color(0xffece8a3)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  static final Paint blackBorderPaint = Paint()
    ..color = const Color(0xff7ab2e8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
```

다음으로 그림 카드용 이미지도 필요합니다.

```dart
  static final Sprite redJack = klondikeSprite(81, 565, 562, 488);
  static final Sprite redQueen = klondikeSprite(717, 541, 486, 515);
  static final Sprite redKing = klondikeSprite(1305, 532, 407, 549);
```

이 스프라이트들을 `redJack`, `redQueen`, `redKing`이라고 부르고 있다는 점에 주목하세요.
몇 번 시도해 보니 제가 가진 이미지가 검은색 무늬 카드에서는
그다지 보기 좋지 않았기 때문입니다. 그래서 이 이미지들을 가져와
푸르스름한 색조로 *틴트(tint)* 하기로 했습니다. 스프라이트의 틴트는
`colorFilter`를 지정한 색과 `srcATop` 블렌딩 모드로 설정한 paint를
사용해 구현할 수 있습니다.

```dart
  static final blueFilter = Paint()
    ..colorFilter = const ColorFilter.mode(
      Color(0x880d8bff),
      BlendMode.srcATop,
    );
  static final Sprite blackJack = klondikeSprite(81, 565, 562, 488)
    ..paint = blueFilter;
  static final Sprite blackQueen = klondikeSprite(717, 541, 486, 515)
    ..paint = blueFilter;
  static final Sprite blackKing = klondikeSprite(1305, 532, 407, 549)
    ..paint = blueFilter;
```

이제 render 메서드 자체를 코딩할 수 있습니다. 먼저 배경과
카드 테두리를 그립니다.

```dart
  void _renderFront(Canvas canvas) {
    canvas.drawRRect(cardRRect, frontBackgroundPaint);
    canvas.drawRRect(
      cardRRect,
      suit.isRed ? redBorderPaint : blackBorderPaint,
    );
  }
```

카드의 나머지 부분을 그리려면 헬퍼 메서드가 하나 더 필요합니다. 이
메서드는 주어진 스프라이트를 캔버스의 지정된 위치(카드 치수에 대한
상대 위치)에 그립니다. 스프라이트는 선택적으로
스케일할 수 있습니다. 또한 `rotate=true` 플래그를 전달하면 스프라이트가
카드 중심을 기준으로 180º 회전한 것처럼 그려집니다.

```dart
  void _drawSprite(
    Canvas canvas,
    Sprite sprite,
    double relativeX,
    double relativeY, {
    double scale = 1,
    bool rotate = false,
  }) {
    if (rotate) {
      canvas.save();
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(pi);
      canvas.translate(-size.x / 2, -size.y / 2);
    }
    sprite.render(
      canvas,
      position: Vector2(relativeX * size.x, relativeY * size.y),
      anchor: Anchor.center,
      size: sprite.srcSize.scaled(scale),
    );
    if (rotate) {
      canvas.restore();
    }
  }
```

카드 모서리에 숫자와 무늬 기호를 그려 봅시다. `_renderFront()` 메서드에
다음을 추가하세요.

```dart
    final rankSprite = suit.isBlack ? rank.blackSprite : rank.redSprite;
    final suitSprite = suit.sprite;
    _drawSprite(canvas, rankSprite, 0.1, 0.08);
    _drawSprite(canvas, rankSprite, 0.1, 0.08, rotate: true);
    _drawSprite(canvas, suitSprite, 0.1, 0.18, scale: 0.5);
    _drawSprite(canvas, suitSprite, 0.1, 0.18, scale: 0.5, rotate: true);
```

카드 가운데도 같은 방식으로 렌더링합니다. 카드의 숫자에 대한 큰
switch 문을 만들고, 그에 맞게 무늬 기호를 그립니다. 아래 코드는
길어 보일 수 있지만, 실제로는 상당히 반복적이며 카드 앞면의 여러 위치에
다양한 스프라이트를 그리는 것뿐입니다.

```dart
    switch (rank.value) {
      case 1:
        _drawSprite(canvas, suitSprite, 0.5, 0.5, scale: 2.5);
      case 2:
        _drawSprite(canvas, suitSprite, 0.5, 0.25);
        _drawSprite(canvas, suitSprite, 0.5, 0.25, rotate: true);
      case 3:
        _drawSprite(canvas, suitSprite, 0.5, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.5);
        _drawSprite(canvas, suitSprite, 0.5, 0.2, rotate: true);
      case 4:
        _drawSprite(canvas, suitSprite, 0.3, 0.25);
        _drawSprite(canvas, suitSprite, 0.7, 0.25);
        _drawSprite(canvas, suitSprite, 0.3, 0.25, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.25, rotate: true);
      case 5:
        _drawSprite(canvas, suitSprite, 0.3, 0.25);
        _drawSprite(canvas, suitSprite, 0.7, 0.25);
        _drawSprite(canvas, suitSprite, 0.3, 0.25, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.25, rotate: true);
        _drawSprite(canvas, suitSprite, 0.5, 0.5);
      case 6:
        _drawSprite(canvas, suitSprite, 0.3, 0.25);
        _drawSprite(canvas, suitSprite, 0.7, 0.25);
        _drawSprite(canvas, suitSprite, 0.3, 0.5);
        _drawSprite(canvas, suitSprite, 0.7, 0.5);
        _drawSprite(canvas, suitSprite, 0.3, 0.25, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.25, rotate: true);
      case 7:
        _drawSprite(canvas, suitSprite, 0.3, 0.2);
        _drawSprite(canvas, suitSprite, 0.7, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.35);
        _drawSprite(canvas, suitSprite, 0.3, 0.5);
        _drawSprite(canvas, suitSprite, 0.7, 0.5);
        _drawSprite(canvas, suitSprite, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.2, rotate: true);
      case 8:
        _drawSprite(canvas, suitSprite, 0.3, 0.2);
        _drawSprite(canvas, suitSprite, 0.7, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.35);
        _drawSprite(canvas, suitSprite, 0.3, 0.5);
        _drawSprite(canvas, suitSprite, 0.7, 0.5);
        _drawSprite(canvas, suitSprite, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.5, 0.35, rotate: true);
      case 9:
        _drawSprite(canvas, suitSprite, 0.3, 0.2);
        _drawSprite(canvas, suitSprite, 0.7, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.3);
        _drawSprite(canvas, suitSprite, 0.3, 0.4);
        _drawSprite(canvas, suitSprite, 0.7, 0.4);
        _drawSprite(canvas, suitSprite, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.3, 0.4, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.4, rotate: true);
      case 10:
        _drawSprite(canvas, suitSprite, 0.3, 0.2);
        _drawSprite(canvas, suitSprite, 0.7, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.3);
        _drawSprite(canvas, suitSprite, 0.3, 0.4);
        _drawSprite(canvas, suitSprite, 0.7, 0.4);
        _drawSprite(canvas, suitSprite, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.5, 0.3, rotate: true);
        _drawSprite(canvas, suitSprite, 0.3, 0.4, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.4, rotate: true);
      case 11:
        _drawSprite(canvas, suit.isRed? redJack : blackJack, 0.5, 0.5);
      case 12:
        _drawSprite(canvas, suit.isRed? redQueen : blackQueen, 0.5, 0.5);
      case 13:
        _drawSprite(canvas, suit.isRed? redKing : blackKing, 0.5, 0.5);
    }
```

`Card` 컴포넌트의 렌더링은 여기까지입니다. 지금 코드를 실행하면
네 줄의 카드가 테이블 위에 가지런히 펼쳐진 것을 볼 수 있습니다. 페이지를
새로 고치면 새로운 카드 세트가 깔립니다. 렌더링이 제대로 동작하는지
확인하기 위해 임시로만 카드를 이렇게 깔았다는 점을
기억하세요.

다음 장에서는 카드와의 상호작용, 즉 카드를 드래그하고 탭할 수 있게
만드는 방법을 구현해 봅니다.

```{flutter-app}
:sources: ../tutorials/klondike/app
:page: step3
:show: popup code
```

[spritecow.com]: http://www.spritecow.com/
