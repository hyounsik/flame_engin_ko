<a id="2-scaffolding"></a>

# 2. 뼈대 잡기

이 섹션에서는 게임의 주요 요소를 큰 틀에서 개략적으로 잡아 봅니다. 여기에는
메인 게임 클래스와 전체 레이아웃이 포함됩니다.


## KlondikeGame

Flame 세계에서 **FlameGame** 클래스는 대부분의 게임에서 초석이 되는 클래스입니다.
이 클래스는 게임 루프를 실행하고, 이벤트를 전달하며, 게임을 구성하는 모든 컴포넌트
(컴포넌트 트리)를 소유하고, 보통은 게임 상태를 담는 중앙 저장소
역할도 합니다.

그럼 `lib/` 폴더 안에 `klondike_game.dart`라는 새 파일을 만들고,
그 안에 `KlondikeGame` 클래스를 선언하세요.

```dart
import 'package:flame/game.dart';
import 'package:flame/flame.dart';

class KlondikeGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await Flame.images.load('assets/images/klondike-sprites.png');
  }
}
```

지금은 `onLoad` 메서드만 선언했습니다. 이 메서드는 게임 인스턴스가 Flutter 위젯 트리에
처음 붙을 때 호출되는 특별한 핸들러입니다. 지연된 비동기 생성자라고
생각해도 됩니다.
현재 `onLoad`가 하는 일은 스프라이트 이미지를 게임에 불러오는 것뿐이지만,
곧 더 많은 내용을 추가할 것입니다. 게임에서 사용하려는 이미지나 기타 리소스는
모두 먼저 불러와야 하는데, 이는 비교적 느린 I/O 작업이므로
`await` 키워드가 필요합니다.

여기서는 이미지를 전역 `Flame.images` 캐시에 불러오고 있습니다. 대안으로
`Game.images` 캐시에 불러올 수도 있지만, 그러면 다른 클래스에서
그 이미지에 접근하기가 더 어려워집니다.

또한 게임의 다른 부분을 초기화하기 전에 이미지 로딩이 끝나기를 `await`하고
있다는 점에 주목하세요. 이는 편의를 위한 것입니다. 다른 모든 컴포넌트가
초기화될 즈음에는 스프라이트 시트가 이미 로드되었다고 가정할 수 있다는 뜻이기 때문입니다.
공통 스프라이트 시트에서 스프라이트를 추출하는 헬퍼 함수를 추가할 수도 있습니다.

```dart
Sprite klondikeSprite(double x, double y, double width, double height) {
  return Sprite(
    Flame.images.fromCache('assets/images/klondike-sprites.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}
```

이 헬퍼 함수는 이번 장에서는 필요하지 않지만, 다음 장에서
많이 사용됩니다.

이 클래스가 고립되지 않도록 프로젝트에 포함시켜 봅시다.
`main.dart`를 열어 `final game = FlameGame();`이라고 적힌 줄을 찾아
`FlameGame`을 `KlondikeGame`으로 바꾸세요. 클래스도 import해야 합니다.
모두 마치면 파일은 다음과 같아야 합니다.

```dart
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'klondike_game.dart';

void main() {
  final game = KlondikeGame();
  runApp(GameWidget(game: game));
}
```


<a id="other-classes"></a>

## 다른 클래스들

지금까지 메인 `KlondikeGame` 클래스를 만들었으니, 이제 게임에 추가할 객체들을
만들어야 합니다. Flame에서는 이러한 객체를 *컴포넌트*라고 부르며,
게임에 추가되면 "게임 컴포넌트 트리"를 이룹니다. 게임에 존재하는
모든 개체는 컴포넌트여야 합니다.

앞 장에서 이미 언급했듯이, 우리 게임은 주로
`Card` 컴포넌트로 구성됩니다. 하지만 카드를 그리는 데는 어느 정도 품이 들기 때문에,
그 클래스의 구현은 다음 장으로 미루겠습니다.

지금은 스케치에 표시된 컨테이너 클래스들을 만들어 봅시다. 바로
`Stock`, `Waste`, `Pile`, `Foundation`입니다. `lib/` 폴더 안에
`components` 하위 디렉터리를 만들고, 이어서 `lib/components/stock.dart` 파일을 만드세요. 그
파일에 다음과 같이 작성합니다.

```dart
import 'package:flame/components.dart';

class Stock extends PositionComponent {
  @override
  bool get debugMode => true;
}
```

여기서는 `Stock` 클래스를 `PositionComponent`(위치와 크기를 가진 컴포넌트)로
선언합니다. 또한 아직 렌더링 로직이 없더라도 화면에서 볼 수 있도록
이 클래스의 디버그 모드를 켭니다.

마찬가지로 `Foundation`, `Pile`, `Waste` 세 클래스를 각각
해당 파일에 만드세요. 지금은 네 클래스 모두 내부 로직이 완전히 같으며,
이후 장에서 이 클래스들에 기능을 더 추가할 것입니다.

이 시점에서 게임의 디렉터리 구조는 다음과 같아야 합니다.

```text
klondike/
 ├─assets/
 │  └─images/
 │     └─klondike-sprites.png
 ├─lib/
 │  ├─components/
 │  │  ├─foundation.dart
 │  │  ├─pile.dart
 │  │  ├─stock.dart
 │  │  └─waste.dart
 │  ├─klondike_game.dart
 │  └─main.dart
 ├─analysis_options.yaml
 └─pubspec.yaml
```


<a id="game-structure"></a>

## 게임 구조

기본 컴포넌트가 몇 개 준비되었다면 이를 게임에 추가해야 합니다. 이제
게임의 상위 구조를 결정할 때입니다.

여기에는 여러 접근 방식이 있으며, 복잡도, 확장성, 전반적인 철학이
서로 다릅니다. 이 튜토리얼에서 사용할 접근 방식은 [World] 컴포넌트를
[Camera]와 함께 사용하는 것입니다.

이 접근 방식의 아이디어는 다음과 같습니다. 게임 **월드**가 기기와 독립적으로
존재한다고 상상해 보세요. 아직 코딩을 하나도 하지 않았지만, 월드는 이미 우리 머릿속과
스케치 위에 존재합니다. 이 월드는 특정한 크기를 가지며, 월드 안의 각 요소는 특정한 좌표를 가집니다.
월드의 크기를 얼마로 할지, 그 크기의 측정 단위를 무엇으로 할지는
우리가 결정합니다. 중요한 점은 월드가 기기와 독립적으로 존재하며,
그 치수 역시 화면의 픽셀 해상도에 의존하지 않는다는 것입니다.

월드에 속하는 모든 요소는 `World` 컴포넌트에 추가되고,
`World` 컴포넌트는 다시 게임에 추가됩니다.

전체 구조의 두 번째 부분은 **카메라**(`CameraComponent`)입니다.
카메라의 목적은 월드를 바라보면서, 월드가 사용자 기기의 화면에
적절한 크기로 렌더링되도록 하는 것입니다.

따라서 컴포넌트 트리의 전체 구조는 대략 다음과 같습니다.

```text
KlondikeGame
 ├─ World
 │   ├─ Stock
 │   ├─ Waste
 │   ├─ Foundation (×4)
 │   └─ Pile (×7)
 └─ CameraComponent
```

이 게임의 이미지 에셋은 카드 한 장의 크기를 1000×1400 픽셀로 염두에 두고
그렸습니다. 따라서 이 크기가 전체 레이아웃을 결정하는
기준 크기가 됩니다. 레이아웃에 영향을 주는 또 하나의 중요한 치수는
카드 사이의 간격입니다. (카드 너비를 기준으로) 150에서 200 단위 사이가
적당해 보이므로, 필요하면 나중에 조정할 수 있도록 `cardGap`이라는
변수로 선언하겠습니다. 단순하게 하기 위해 카드 사이의 세로 간격과 가로 간격은
같게 하고, 카드와 화면 가장자리 사이의 최소 여백도
`cardGap`과 같게 하겠습니다.

좋습니다, 이제 이 모든 것을 모아 `KlondikeGame` 클래스를 구현해 봅시다.

먼저 카드의 치수와 카드 사이의 간격을 나타내는 전역 상수 몇 개를
선언합니다. 게임 중에 이 값들을 바꿀 계획이 없으므로
상수로 선언합니다.

```dart
  static const double cardWidth = 1000.0;
  static const double cardHeight = 1400.0;
  static const double cardGap = 175.0;
  static const double cardRadius = 100.0;
  static final Vector2 cardSize = Vector2(cardWidth, cardHeight);
```

다음으로 `Stock` 컴포넌트, `Waste`, 네 개의 `Foundation`,
일곱 개의 `Pile`을 만들고 월드에서의 크기와 위치를 설정합니다. 위치는
간단한 산술로 계산합니다. 이 모든 작업은 스프라이트 시트를 불러온 뒤
`onLoad` 메서드 안에서 이루어져야 합니다.

```dart
    final stock = Stock()
      ..size = cardSize
      ..position = Vector2(cardGap, cardGap);
    final waste = Waste()
      ..size = cardSize
      ..position = Vector2(cardWidth + 2 * cardGap, cardGap);
    final foundations = List.generate(
      4,
      (i) => Foundation()
        ..size = cardSize
        ..position =
            Vector2((i + 3) * (cardWidth + cardGap) + cardGap, cardGap),
    );
    final piles = List.generate(
      7,
      (i) => Pile()
        ..size = cardSize
        ..position = Vector2(
          cardGap + i * (cardWidth + cardGap),
          cardHeight + 2 * cardGap,
        ),
    );
```

Flame 1.9.0 버전부터 `FlameGame`은 기본 `world`와 `camera`
객체를 설정합니다. `KlondikeGame`은 `FlameGame`을 확장한 것이므로, 방금 만든
모든 컴포넌트를 그 `world`에 추가할 수 있습니다.

```dart
    world.add(stock);
    world.add(waste);
    world.addAll(foundations);
    world.addAll(piles);
```

```{note}
`add()`의 결과를 언제 `await`해야 하고 언제 하지 않아도 되는지 궁금할 수
있습니다. 짧게 답하자면, 보통은 기다릴 필요가 없지만 기다리고
싶다면 그렇게 해도 문제는 없습니다.

`.add()` 메서드의 문서를 확인해 보면, 반환된 future는 컴포넌트가
실제로 게임에 마운트될 때까지가 아니라 로딩을 마칠 때까지만 기다린다는 것을 알 수 있습니다.
따라서 로직상 컴포넌트가 완전히 로드된 뒤에야 다음으로 진행할 수 있는 경우에만
`.add()`의 future를 기다리면 됩니다. 이런 경우는 흔하지 않습니다.

`.add()`의 future를 `await`하지 않더라도 컴포넌트는 어쨌든 게임에
추가되며, 걸리는 시간도 같습니다.
```

마지막으로 FlameGame의 `camera` 객체를 사용해 `world`를 바라봅니다. 내부적으로
카메라는 **뷰포트**와 **뷰파인더**의 두 부분으로 구성됩니다.
기본 뷰포트는 `MaxViewport`로, 사용 가능한 화면 크기 전체를
차지합니다. 이는 우리 게임에 딱 필요한 것이므로 아무것도 바꿀
필요가 없습니다. 반면 뷰파인더는 그 아래에 있는 월드의 치수를
고려하도록 설정해야 합니다.

우리는 스크롤하지 않고도 카드 레이아웃 전체가 화면에 보이기를 원합니다.
이를 위해 월드 전체 크기(`7*cardWidth + 8*cardGap` × `4*cardHeight + 3*cardGap`)가
화면에 들어맞도록 지정합니다. `.visibleGameSize` 설정은
기기의 크기와 관계없이, 지정한 게임 월드 영역이 보이도록
줌 레벨이 조정되게 합니다.

게임 크기는 다음과 같이 계산합니다. 태블로에는 카드 7장과 그 사이의
간격 6개가 있고, 여백을 위해 "간격" 2개를 더하면
`7*cardWidth + 8*cardGap`의 너비가 됩니다. 세로로는 카드가 두 줄이지만,
아래쪽 줄에는 높이 쌓인 파일(pile)을 표시할 수 있도록 여유 공간이 필요합니다.
제 대략적인 추정으로는 카드 높이의 세 배면 충분합니다.
그러면 게임 월드의 전체 높이는
`4*cardHeight + 3*cardGap`이 됩니다.

다음으로 월드의 어느 부분이 뷰포트의 "중앙"에 올지 지정합니다.
여기서는 뷰포트의 "중앙"이 화면의 위쪽 가운데에 있도록 지정하고,
이에 대응하는 게임 월드 안의 지점은
`[(7*cardWidth + 8*cardGap)/2, 0]` 좌표에 있습니다.

뷰파인더의 위치와 앵커를 이렇게 선택한 이유는
게임 크기가 너무 넓어지거나 너무 높아졌을 때 어떻게 반응하기를 원하는지와
관련이 있습니다. 너무 넓은 경우에는 화면 가운데에 오기를 원하지만,
화면이 너무 높은 경우에는 내용이 위쪽에
정렬되기를 원합니다.

```dart
    camera.viewfinder.visibleGameSize =
           Vector2(cardWidth * 7 + cardGap * 8, 4 * cardHeight + 3 * cardGap);
    camera.viewfinder.position = Vector2(cardWidth * 3.5 + cardGap * 4, 0);
    camera.viewfinder.anchor = Anchor.topCenter;
```

지금 게임을 실행하면 여러 컴포넌트가 놓일 자리를 나타내는 플레이스홀더가
보일 것입니다. 브라우저에서 게임을 실행 중이라면 창 크기를
바꿔 보면서 게임이 어떻게 반응하는지 확인해 보세요.

```{flutter-app}
:sources: ../tutorials/klondike/app
:page: step2
:show: popup code
```

이번 단계는 여기까지입니다. 앞으로 모든 것이 그 위에 세워질 기본 게임 구조를
만들었습니다. 다음 단계에서는 이 게임에서 가장 중요한 시각적 객체인
카드 객체를 렌더링하는 방법을 배웁니다.

[World]: ../../flame/camera#world
[Camera]: ../../flame/camera#cameracomponent
