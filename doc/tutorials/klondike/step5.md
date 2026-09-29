<a id="5-animations-restarting-buttons-and-a-new-world"></a>

# 5. 애니메이션, 재시작, 버튼, 그리고 새로운 월드

이번 장에서는 클론다이크 게임을 더 재미있고 쉽게 플레이할 수 있게 만드는 여러 방법을
보여 줍니다. 다룰 주제는 다음과 같습니다.

- 클론다이크 Draw 1과 Draw 3
- 이동을 애니메이션하고 자동화하기
- 승리를 감지하고 축하하기
- 게임 종료와 재시작
- 자신만의 FlameGame 월드를 구현하는 방법
- 간단한 액션 버튼
- 앵커와 좌표
- 난수 생성과 시드
- 이펙트와 EffectController


<a id="the-klondike-draw"></a>

## 클론다이크 드로우

클론다이크 페이션스 게임(미국에서는 솔리테어 게임)에는 Draw 3와 Draw 1이라는 두 가지 주요 변형이 있습니다.
현재 클론다이크 Flame 게임은 Draw 3인데, 이는 Draw 1보다 훨씬 어렵습니다.
카드 3장을 볼 수는 있지만 그중 한 장만 옮길 수 있고, 그 이동이 다른 카드들의
"위상"을 바꾸기 때문입니다. 그래서 사용할 수 있게 되는 카드가 달라지므로 쉽지 않습니다.

클론다이크 Draw 1에서는 스톡에서 한 번에 한 장씩만 뽑아 보여 주므로, 스톡의 모든 카드를
사용할 수 있고, 클론다이크 Draw 3와 마찬가지로 스톡을 원하는 만큼 여러 번 넘길 수 있습니다.

그렇다면 클론다이크 Draw 1은 어떻게 구현할까요? 분명히 스톡 파일과 웨이스트 파일만 관련되어 있으니,
KlondikeGame이 두 파일 각각에 1 또는 3이라는 값을 제공하면 될 것 같습니다. 두 클래스 모두
생성자 코드가 있으므로 그 코드에 파라미터를 하나 추가해도 되지만, Flame에는 또 다른
방법이 있습니다. 이 방법은 컴포넌트에 기본 생성자만 있거나(생성자 코드가 없거나) 게임 전역에서
쓰이는 값이 많을 때도 동작합니다. 이 값을 `klondikeDraw`라고 부릅시다. 클래스 선언에
`HasGameRef<MyGame>` 믹스인을 추가하고, 1 또는 3이라는 값이 필요한 곳마다 `gameRef.klondikeDraw`라고 쓰면 됩니다.
StockPile 클래스는 다음과 같습니다.

```dart
class StockPile extends PositionComponent
    with TapCallbacks, HasGameRef<KlondikeGame>
    implements Pile {
```

그리고

```dart
  @override
  void onTapUp(TapUpEvent event) {
    final wastePile = parent!.firstChild<WastePile>()!;
    if (_cards.isEmpty) {
      wastePile.removeAllCards().reversed.forEach((card) {
        card.flip();
        acquireCard(card);
      });
    } else {
      for (var i = 0; i < gameRef.klondikeDraw; i++) {
        if (_cards.isNotEmpty) {
          final card = _cards.removeLast();
          card.flip();
          wastePile.acquireCard(card);
        }
      }
    }
  }
```

WastePile 클래스는 다음과 같습니다.

```dart
class WastePile extends PositionComponent
    with HasGameRef<KlondikeGame>
    implements Pile {
```

그리고

```dart
  void _fanOutTopCards() {
    if (gameRef.klondikeDraw == 1) {   // 클론다이크 Draw 1에서는 부채꼴로 펼치지 않습니다.
      return;
    }
    final n = _cards.length;
    for (var i = 0; i < n; i++) {
      _cards[i].position = position;
    }
    if (n == 2) {
      _cards[1].position.add(_fanOffset);
    } else if (n >= 3) {
      _cards[n - 2].position.add(_fanOffset);
      _cards[n - 1].position.addScaled(_fanOffset, 2);
    }
  }
```

이렇게 하면 스톡 파일과 웨이스트 파일이 클론다이크 Draw 1이나 Draw 3 중 하나로 동작하게 되지만,
어느 변형으로 플레이할지는 어떻게 알려 줄까요? 지금은 KlondikeGame 클래스에 플레이스홀더를 추가하겠습니다.
원하지 않는 쪽을 주석 처리하고 다시 빌드하기만 하면 됩니다.

```dart
  // final int klondikeDraw = 3;
  final int klondikeDraw = 1;
```

설계의 일부를 어떻게 처리할지 아직 정하지 못했을 때 임시 방편으로는 괜찮지만,
결국에는 플레이어가 어떤 방식의 클론다이크를 플레이할지 고를 수 있도록 메뉴 화면, 설정 화면,
버튼 같은 일종의 **입력**을 제공해야 합니다. Flame은 게임 안에 Flutter 위젯을
포함할 수 있으며, 다음 튜토리얼(Ember)의 마지막 단계에서 메뉴 위젯을 추가하는 방법을
보여 줍니다.


<a id="making-cards-move"></a>

## 카드 움직이기

Flame에서 컴포넌트가 무언가를 하게 하려면 `Effect`를 사용합니다. `Effect`는 카드 같은 다른 컴포넌트에
붙어서 그 속성을 수정할 수 있는 특별한 컴포넌트입니다. 여기에는 모든 종류의
움직임(즉, `position`의 변화)이 포함됩니다. 또한 이펙트의 타이밍을 제공하는 `EffectController`도 필요합니다.
언제 시작할지, 얼마 동안 진행할지, 어떤 `Curve`를 따를지를 정합니다. 여기서 `Curve`는 공간상의 곡선이
아닙니다. 이펙트가 진행되는 동안의 가속과 감속을 지정하는 시간 곡선으로, 예를 들어
카드를 빠르게 움직이기 시작해 목적지에 가까워질수록 느려지게 할 수 있습니다.

카드를 움직이기 위해 `Card` 클래스에 `doMove()` 메서드를 추가하겠습니다. 이 메서드에는 이동할
목적지 `to`가 필요합니다. 선택적 파라미터로는 `speed:`(기본값 10.0), `start:`(기본값 0),
`curve:`(기본값 `Curves.easeOutQuad`), `onComplete:`(기본값 `null`, 즉 이동이 끝났을 때
콜백 없음)가 있습니다. 속도의 단위는 초당 카드 너비입니다. 대개는 콜백을 제공하게 되는데,
애니메이션 이동이 끝난 **뒤에** 처리해야 할 게임플레이가 조금 있기 때문입니다. 기본 `curve:` 파라미터는
사람 플레이어가 하는 것처럼 빠르게 들어가 천천히 끝나는 움직임을 만들어 줍니다. 그래서 다음 코드를
`Card` 클래스의 끝에 추가합니다.

```dart
  void doMove(
    Vector2 to, {
    double speed = 10.0,
    double start = 0.0,
    Curve curve = Curves.easeOutQuad,
    VoidCallback? onComplete,
  }) {
    assert(speed > 0.0, 'Speed must be > 0 widths per second');
    final dt = (to - position).length / (speed * size.x);
    assert(dt > 0.0, 'Distance to move must be > 0');
    priority = 100;
    add(
      MoveToEffect(
        to,
        EffectController(duration: dt, startDelay: start, curve: curve),
        onComplete: () {
          onComplete?.call();
        },
      ),
    );
  }
```

이 코드가 컴파일되려면 `components/card.dart` 파일 맨 위에서 `'package:flame/effects.dart'`와
`'package:flutter/animation.dart'`를 import해야 합니다. 그러고 나면
잘못된 위치에 놓인 카드를 원래 있던 곳으로 부드럽게 되돌리는 데 새 메서드를
사용할 수 있습니다. 먼저 드래그 앤 드롭이 시작될 때 카드의 위치를 저장할 private 데이터 항목이 필요합니다.
그러니 아래와 같이 두 곳에 새 줄을 넣읍시다.

```dart
  bool _isDragging = false;
  Vector2 _whereCardStarted = Vector2(0, 0);

  final List<Card> attachedCards = [];
```

```dart
      _isDragging = true;
      priority = 100;
      // 각 좌표를 복사합니다. 그렇지 않으면 position이 바뀔 때 _whereCardStarted도 함께 바뀝니다.
      _whereCardStarted = Vector2(position.x, position.y);
      if (pile is TableauPile) {
```

여기에 `_whereCardStarted = position;`이라고 쓰면 실수입니다. Dart에서 이는 참조만
복사하므로, 드래그가 일어나 카드의 `position` 데이터가 바뀌는 동안 `_whereCardStarted`는
`position`과 같은 데이터를 가리키게 됩니다. 카드의 **현재** X, Y 좌표를
**새** `Vector2` 객체에 복사하면 이 문제를 피할 수 있습니다.

잘못된 드래그 앤 드롭 후 카드가 원래 파일로 돌아가는 모습을 애니메이션하기 위해,
`onDragEnd()` 메서드 끝의 다섯 줄을 다음으로 바꿉니다.

```dart
    // 잘못된 드롭(아무 곳도 아닌 곳, 잘못된 파일, 또는 파일에 맞지 않는 카드).
    doMove(
      _whereCardStarted,
      onComplete: () {
        pile!.returnCard(this);
      },
    );
    if (attachedCards.isNotEmpty) {
      attachedCards.forEach((card) {
        final offset = card.position - position;
        card.doMove(
          _whereCardStarted + offset,
          onComplete: () {
            pile!.returnCard(card);
          },
        );
      });
      attachedCards.clear();
    }
```

두 경우 모두 기본 속도인 초당 카드 너비 10배를 사용합니다.
`onComplete:` 파라미터를 사용해 각 카드를 출발한 파일로 되돌린다는 점에 주목하세요.
그러면 카드는 그 파일의 내용 목록에 다시 추가됩니다. 또한 붙어 있는 카드 목록(있다면)은
애니메이션되는 카드가 움직이기 시작하자마자 즉시 비워진다는 점에도 주목하세요. 이는 문제가 되지 않습니다.
움직이는 각 카드에는 `MoveToEffect`와 `EffectController`가 추가되어 있고, 여기에
올바른 카드를 올바른 시간에 올바른 위치로 옮기는 데 필요한 모든 데이터가 들어 있기 때문입니다. 따라서
붙어 있는 카드 목록을 일찍 비워도 중요한 정보는 사라지지 않습니다. 또한 기본적으로
움직이는 각 카드의 `MoveToEffect`와 `EffectController`는 동작이 끝나면 Flame이 자동으로
떼어 내고 삭제합니다.

그 밖에 시도해 볼 만한 자동 이동과 애니메이션 이동으로는 카드 나눠 주기, 스톡에서
웨이스트 파일로 카드 뒤집기, 태블로 파일에서 카드를 자동으로 뒤집기, 그리고 유효한 드래그 앤 드롭 후
카드를 제자리에 안착시키기가 있습니다. 먼저 카드 뒤집기 애니메이션을 살펴보겠습니다.


<a id="animating-a-card-flip"></a>

## 카드 뒤집기 애니메이션

Flutter와 Flame은 (2023년 10월 기준) 아직 3D 이펙트를 지원하지 않지만, 흉내 낼 수는 있습니다.
카드가 뒤집히는 것처럼 보이게 하려면 뒷면 뷰의 너비를 줄이고, 앞면 뷰로
전환한 다음, 다시 원래 너비로 늘리면 됩니다. 이 코드는 이펙트와 EffectController의
여러 기능을 활용합니다.

```dart
  void turnFaceUp({
    double time = 0.3,
    double start = 0.0,
    VoidCallback? onComplete,
  }) {
    assert(!_isFaceUpView, 'Card must be face-down before turning face-up.');
    assert(time > 0.0, 'Time to turn card over must be > 0');
    _isAnimatedFlip = true;
    anchor = Anchor.topCenter;
    position += Vector2(width / 2, 0);
    priority = 100;
    add(
      ScaleEffect.to(
        Vector2(scale.x / 100, scale.y),
        EffectController(
          startDelay: start,
          curve: Curves.easeOutSine,
          duration: time / 2,
          onMax: () {
            _isFaceUpView = true;
          },
          reverseDuration: time / 2,
          onMin: () {
            _isAnimatedFlip = false;
            _faceUp = true;
            anchor = Anchor.topLeft;
            position -= Vector2(width / 2, 0);
          },
        ),
        onComplete: () {
          onComplete?.call();
        },
      ),
    );
  }
```

그렇다면 이 모든 것이 어떻게 동작할까요? 앞에서처럼 뒤집기에 걸리는 기본 시간 0.3초, 시작 시간,
그리고 완료 시 호출되는 선택적 콜백이 있습니다. 이제 카드에 ScaleEffect를 추가합니다.
이 이펙트는 높이는 그대로 두고 너비를 거의 0까지 줄입니다. 하지만 이는
전체 시간의 절반만 걸려야 하고, 그다음에는 카드를 뒷면 뷰에서 앞면 뷰로 전환해
다시 늘려야 하며, 이것도 절반의 시간이 걸려야 합니다.

바로 여기서 `EffectController` 클래스의 좀 더 고급 파라미터들을 사용합니다.
`duration:`은 `time / 2`로 설정하고, 뷰를 앞면으로 바꾸는 인라인 코드를 담은
`onMax:` 콜백을 사용합니다. 이 콜백은 `time / 2`가 지난 뒤, `Effect`(무엇이든)가
최댓값에 도달했을 때(즉, 이 경우 카드 뷰가 가느다란 세로선으로 줄어들었을 때) 호출됩니다.
앞면 뷰로 전환한 뒤에는 EffectController가 `reverseDuration: time / 2` 동안 Effect를
역방향으로 진행합니다. 모든 것이 거꾸로 진행됩니다. 카드 뷰가 늘어나고, 시간의
`curve:`도 역순으로 적용됩니다. 전체적으로 타이밍은 0부터 pi까지의 사인 곡선을 따르므로,
카드 뷰의 너비가 항상 3D 위치를 2D로 투영한 값이 되는 부드러운 애니메이션이
만들어집니다. 와! 작은 EffectController 하나가 하는 일치고는 정말 많네요!

아직 끝이 아닙니다! 코드에서 `add()` 부분만 실행해 보면 보기 흉한 일들이 벌어지는 것을
볼 수 있습니다. 네, 네, 저도 겪어 봤습니다... 이 코드를 준비하면서요!
우선 카드가 왼쪽 가장자리를 기준으로 선처럼 줄어듭니다. 이 게임의 모든 카드는
`Anchor`가 `topLeft`에 있고, 이 점이 카드의 `position`을 정하는 데 쓰이기 때문입니다. 우리는
카드가 세로 중심선을 기준으로 뒤집히기를 원합니다. 간단합니다. 먼저 `anchor = Anchor.topCenter`를
설정하면 됩니다. 그러면 카드가 실감 나게 뒤집히지만, 뒤집히기 전에 카드 너비의 절반만큼
왼쪽으로 튀어 버립니다.

간단히 말하면, `assert(`와 `add(` 사이의 줄들과, 그것들을 되돌리는 `onMin:` 콜백을
보세요. `onMin:` 콜백은 Effect가 끝났지만 마지막 `onComplete:` 콜백이 호출되기 전에 실행됩니다.
처음에 카드의 렌더링 `priority`를 100으로 설정해서 주변의 다른 모든 카드보다 위에
표시되도록 합니다. 이 값을 항상 저장했다가 복원할 수는 없습니다. 카드를 받는 `Pile`에서
그 카드의 우선순위가 얼마여야 하는지 모를 수 있기 때문입니다. 그래서 파일 안 카드들의
위치와 우선순위를 조정하는 메서드를 사용해, 받는 쪽이 항상 `onComplete:` 옵션에서
호출되도록 했습니다.

마지막으로 중요한 점은, 앞의 코드에서 `_isAnimatedFlip` 변수를 사용한다는 것입니다.
이는 `components/card.dart` 파일의 `Card` 클래스 시작 부분 근처에서 정의하고 초기화하는
`bool` 변수로, 또 다른 새 `bool`인 `_isFaceUpView`와 함께 정의됩니다. 처음에는 기존의
`bool _faceUp = false` 변수와 함께 둘 다 `false`로 설정됩니다. 이 변수들은 어떤 의미가 있을까요?
그 의미는 **엄청납니다**. 몇 줄 아래를 보면 다음과 같은 코드가 있습니다.

```dart
  @override
  void render(Canvas canvas) {
    if (_isFaceUpView) {
      _renderFront(canvas);
    } else {
      _renderBack(canvas);
    }
  }
```

이 코드가 모든 카드를 앞면 또는 뒷면 상태로 화면에 보이게 합니다.
클론다이크 튜토리얼 4단계를 마쳤을 때 `if` 문은 `if (_faceUp) {`였습니다. 이는
(드래그 앤 드롭을 제외하면) 모든 카드 이동이 즉각적이었기 때문에 괜찮았습니다. 카드의
앞면/뒷면 상태가 바뀌면 Flame 엔진의 다음 `tick`이나 그 직후에 렌더링하면 됐습니다.
카드 이동을 애니메이션하기 시작했을 때도, 뒤집기가 포함되지 않는 한 문제가 없었습니다.
하지만 비어 있지 않은 스톡 파일을 탭하면 실행되는 코드는 다음과 같았습니다.

```dart
  final card = _cards.removeLast();
  card.flip;
  wastePile.acquireCard(card);
```

그리고 `wastePile.acquireCard(`가 가장 먼저 하는 일은 `assert(card.isFaceUp);`인데,
뒤집기 애니메이션의 전반부가 진행되는 동안 카드가 뒷면 상태로 유지되고 있다면 이 assert는 실패합니다.


<a id="model-and-view"></a>

## 모델과 뷰

분명히 카드는 동시에 두 가지 상태일 수 없습니다. 슈뢰딩거의 고양이가 아니니까요! 이
딜레마는 "앞면"에 대해 두 가지 정의, 즉 모델 방식과 뷰 방식을 사용해 해결할 수 있습니다. 뷰 버전은
렌더링과 애니메이션(즉, 화면에 보이는 것)에 쓰이고, 모델 버전은 게임 로직, 게임플레이,
오류 검사에 쓰입니다. 이렇게 하면 일부를 애니메이션하기 위해 이 게임의 모든 파일(pile) 로직을
고칠 필요가 없습니다. 더 복잡한 게임이라면 설계와 초기 코딩 단계에서 모델과 뷰를
분리하는 것이, 심지어 별도의 클래스로 분리하는 것이 도움이 될 수 있습니다. 이 게임에서는 모델과 뷰를
아주 조금만 분리합니다. `_isAnimatedFlip` 변수는 뒤집기 애니메이션이 진행 중일 때는 `true`,
그렇지 않으면 `false`이며, `Card` 클래스의 `flip()` 함수는 다음과 같이 확장됩니다.

```dart
  void flip() {
    if (_isAnimatedFlip) {
      // 애니메이션이 FaceUp/FaceDown 상태를 결정하게 합니다.
      _faceUp = _isFaceUpView;
    } else {
      // 애니메이션 없음: 카드를 즉시 뒤집고 렌더링합니다.
      _faceUp = !_faceUp;
      _isFaceUpView = _faceUp;
    }
  }
```

클론다이크 튜토리얼 게임에서는 여전히 뒤집기 애니메이션의 `onComplete:` 콜백에서 모델 업데이트를
트리거해야 합니다. 성급하거나 손이 빠른 플레이어를 위해, 모델에서는 카드를 스톡 파일에서
웨이스트 파일로 즉시 옮기고, 뷰의 애니메이션은 `onComplete:` 콜백 없이 나중에 따라오게
하면 좋을 수도 있습니다. 그러면 빠르게 탭해서 스톡 파일을 아주 빨리
넘길 수 있습니다. 하지만 이는 이 튜토리얼의 범위를 벗어납니다.


<a id="ending-and-restarting-the-game"></a>

## 게임 종료와 재시작

현재로서는 이겼더라도 클론다이크 튜토리얼 게임을 끝내고 새 게임을 시작할 쉬운 방법이
없습니다. 앱을 닫았다가 다시 시작할 수밖에 없습니다. 그리고 이겼을 때 아무런 "보상"도 없습니다.

이 문제에 접근하는 방법은 게임이 얼마나 단순하거나 복잡한지, 그리고
`onLoad()` 메서드가 얼마나 오래 걸릴지에 따라 다양합니다. 자신만의
GameWidget을 작성하는 방법부터, Game 클래스(여기서는 KlondikeGame)에서 몇 가지 간단한
재초기화를 하는 방법까지 있습니다.

GameWidget 방식에서는 Game에 `reset`이나 `restart`라는 이름의 VoidCallback 함수 파라미터를
제공합니다. 이 콜백이 호출되면 Flutter의 `StatefulWidget` 관례(예: `setState(() {});)`)를
사용해 위젯을 강제로 다시 빌드하고 교체하며, 그 결과 현재 Game 인스턴스, 그 상태, 그리고 그 모든 메모리에 대한
참조가 해제됩니다. 메뉴나 다른 시작 화면을 실행하는 Flutter 코드가
있을 수도 있습니다.

재초기화는 관련된 작업이 적고 단순할 때에만 해야 합니다. 그렇지 않으면
코딩 오류로 인해 게임에 미묘한 문제, 메모리 누수, 크래시가 생길 수 있습니다. 클론다이크에서는
(Ember 튜토리얼에서처럼) 이것이 가장 쉬운 방법일 수 있습니다. 기본적으로 모든 `Pile`에서
카드 참조를 모두 비운 다음 다시 섞고(또는 섞지 않고) 다시 나눠 주면 되며, 이때
클론다이크 Draw 3에서 Draw 1로 또는 그 반대로 바꿀 수도 있습니다.

그런데 보기만큼 쉽지 않았습니다! `Pile`들과 각 `Card`를 재초기화하는 것은
충분히 쉬웠지만, 어려운 부분은 그다음이었습니다... 플레이어가 이기든 이기지 못하고 재시작하든,
화면의 여러 파일에 52장의 카드가 흩어져 있고, 일부는 앞면이, 어쩌면 일부는 뒷면이 위로 향해 있습니다.
나중에 카드 나눠 주기를 애니메이션하고 싶으므로, 카드들을 왼쪽 위의 스톡 파일 영역에
뒷면이 위로 향한 가지런한 더미로 모으면 좋을 것입니다. 실제 스톡 파일은 아직 아닙니다. 스톡 파일은
카드를 나눠 주는 동안 만들어지기 때문입니다.

각 `Card`를 뒷면으로 설정하고 `doMove` 메서드로 각자 왼쪽 위로 움직이게 하는
간단한 작은 루프를 작성하면 실패합니다. 앞에서 말한 "미묘한 문제" 중 하나가 생깁니다.
카드들은 모두 같은 속도로 이동하지만 도착하는 시간이 다릅니다. 그러면 카드를 나눠 줄 때
여러 카드가 제자리를 벗어난 엉망인 태블로 파일이 만들어집니다. 또한 모든 카드가 스톡 파일 영역으로
애니메이션되며 이동하는 모습도 조금 보기 흉했습니다.

엉망인 태블로 파일 문제는 고칠 수 있었지만, 이 시점에서 코드와
문서의 리뷰어가 완전히 새로운 접근 방식을 제안했습니다. 아무것도 재초기화하지 않고
모든 컴포넌트를 처음부터 새로 만드는 방식으로, 이것이 Flutter/Flame에서 선호하는 방식입니다.


<a id="a-new-world"></a>

## 새로운 월드


<a id="start-and-restart-actions"></a>

### 시작과 재시작 액션

클론다이크 게임에서 다음 액션을 제공하려고 합니다.

- 첫 시작,
- 새로 나눠 주기로 원하는 만큼 재시작,
- 이전과 같은 배치로 원하는 만큼 재시작,
- 클론다이크 Draw 1과 Draw 3 사이를 전환하고 새로 나눠 주기로 재시작,
- 새로 나눠 주기로 재시작하기 전에 즐기기(이건 나중을 위한 깜짝 선물로 남겨 두겠습니다).

제안은 FlameGame이 제공하는 기본 `world`를 대체하는 새 KlondikeWorld 클래스를 두는 것입니다.
새 월드에는 게임을 플레이하는 데 필요한 (거의) 모든 것이 들어 있으며, 위의 각 액션이 일어날 때마다
생성되거나 다시 생성됩니다.


<a id="a-stripped-down-klondikegame-class"></a>

### 간소화된 KlondikeGame 클래스

다음은 KlondikeGame 클래스의 새 코드(남은 부분)입니다.

```dart
enum Action { newDeal, sameDeal, changeDraw, haveFun }

class KlondikeGame extends FlameGame<KlondikeWorld> {
  static const double cardGap = 175.0;
  static const double topGap = 500.0;
  static const double cardWidth = 1000.0;
  static const double cardHeight = 1400.0;
  static const double cardRadius = 100.0;
  static const double cardSpaceWidth = cardWidth + cardGap;
  static const double cardSpaceHeight = cardHeight + cardGap;
  static final Vector2 cardSize = Vector2(cardWidth, cardHeight);
  static final cardRRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, cardWidth, cardHeight),
    const Radius.circular(cardRadius),
  );

  // Random 시드를 만들 때 사용하는 상수입니다.
  static const int maxInt = 0xFFFFFFFE; // = (2의 32제곱) - 1

  // 이 KlondikeGame 생성자는 첫 번째 KlondikeWorld도 시작합니다.
  KlondikeGame() : super(world: KlondikeWorld());

  // 이 세 값은 게임과 게임 사이에 유지되며, KlondikeWorld에서 플레이할
  // 다음 게임의 시작 조건입니다. 실제 시드는 KlondikeWorld에서
  // 계산하지만, 플레이어가 Action.sameDeal을 선택해 게임을 다시
  // 플레이하는 경우를 위해 여기에 보관합니다.
  int klondikeDraw = 1;
  int seed = 1;
  Action action = Action.newDeal;
}
```

어라! `onLoad()` 메서드는 어떻게 된 걸까요? 그리고 이 `seed`라는 건 뭘까요? KlondikeWorld는
어떻게 끼어드는 걸까요? 예전에 `onLoad()` 메서드에 있던 모든 것은 이제
KlondikeWorld의 `onLoad()` 메서드에 있습니다. KlondikeWorld는 `World` 클래스를 확장한 것이고 `Component`의
한 종류이므로, 다른 모든 `Component` 타입처럼 `onLoad()` 메서드를 가질 수 있습니다.
메서드 내용은 이전과 거의 같지만, `world.add(`가 그냥 `add(`가 되었습니다. 또한
`addButton()` 호출도 몇 개 들어오는데, 이에 대해서는 나중에 더 설명합니다.


<a id="using-a-random-number-generator-seed"></a>

### 난수 생성기 시드 사용하기

`seed`는 어떤 프로그래밍 환경에서든 흔히 쓰이는 게임 프로그래밍 기법입니다. 보통
난수 생성기를 알려진 지점(시드라고 부름)에서 시작하게 해서, 개발 및 테스트 단계에서
게임이 재현 가능하게 동작하도록 해 줍니다. 여기서는 플레이어가 `Same deal`을 요청했을 때
클론다이크 카드를 정확히 같은 배치로 나눠 주는 데 사용합니다.


<a id="introducing-the-new-klondikeworld-class"></a>

### 새 KlondikeWorld 클래스 소개

`class KlondikeGame` 선언은 FlameGame 클래스를 확장한 이 클래스가 반드시
KlondikeWorld 타입의 월드를 가져야 한다고 지정합니다(즉, `FlameGame<KlondikeWorld>`). 게임에 이런 것을
할 수 있는지 몰랐죠? 그렇다면 KlondikeWorld의 첫 번째 인스턴스는 어떻게 만들어질까요? 모든 것은
KlondikeGame 생성자 코드에 있습니다.

```dart
  KlondikeGame() : super(world: KlondikeWorld());
```

생성자 자체는 기본 생성자이지만, 콜론 `:`이 생성자 초기화 시퀀스를 시작하며
이 시퀀스가 처음으로 우리 월드를 만듭니다.


<a id="buttons"></a>

### 버튼

클론다이크 게임을 재시작하는 여러 방법을 실행하기 위해 버튼 몇 개를 사용하겠습니다. 먼저
Flame의 `ButtonComponent`를 확장해 `FlatButton` 클래스를 만듭니다. 이는 예전에
Flame 예제 페이지에 있던 Flat Button을 바탕으로 만든 것입니다. `ButtonComponent`는 두 개의 `PositionComponent`를 사용합니다.
하나는 버튼이 평상시 상태(올라와 있음)일 때, 다른 하나는 눌렸을 때 사용됩니다. 사용자가 버튼을 누르고
뗄 때마다 두 컴포넌트가 번갈아 `mounted`되고 `rendered`됩니다. 버튼을 누르려면
탭한 상태로 누르고 있으세요.

우리 버튼에서 두 컴포넌트는 버튼의 외곽선입니다. `buttonDown:` 쪽은 버튼이 눌렸을 때
외곽선을 빨간색으로 바꿔 경고를 표시합니다. 네 가지 버튼 액션이 모두
현재 게임을 끝내고 새 게임을 시작하기 때문입니다. 같은 이유로 버튼들은 캔버스 맨 위,
모든 카드보다 위쪽에 배치되어 실수로 누를 가능성이 적습니다. 버튼을 눌렀다가
마음이 바뀌면, 계속 누른 채로 손가락을 밀어 벗어나면 버튼은 아무 효과도 내지 않습니다.

네 개의 버튼은 위에서 설명한 재시작 액션을 트리거하며, 라벨은 `New deal`,
`Same deal`, `Draw 1 ⇌ 3`, `Have fun`입니다. Flame에는 번갈아 나타나는 두 개의 `Sprite`를
기반으로 하는 `SpriteButtonComponent`, 그리고 `HudButtonComponent`와 `AdvancedButtonComponent`도 있습니다.
이 밖의 버튼과 컨트롤러가 필요하다면 Flutter 오버레이, 메뉴 또는 설정 위젯을 사용해
라디오 버튼, 드롭다운 목록, 슬라이더 등 Flutter의 위젯을 활용하는 것이 가장 좋습니다.
이 튜토리얼의 목적에는 우리의 FlatButton으로 충분합니다.

월드의 `onLoad()` 중에 `addButton()` 메서드를 사용해 네 개의 버튼을 설정하고
`world`에 추가합니다.

```dart
    playAreaSize =
        Vector2(7 * cardSpaceWidth + cardGap, 4 * cardSpaceHeight + topGap);
    final gameMidX = playAreaSize.x / 2;

    addButton('New deal', gameMidX, Action.newDeal);
    addButton('Same deal', gameMidX + cardSpaceWidth, Action.sameDeal);
    addButton('Draw 1 or 3', gameMidX + 2 * cardSpaceWidth, Action.changeDraw);
    addButton('Have fun', gameMidX + 3 * cardSpaceWidth, Action.haveFun);
```

이렇게 하면 버튼들이 네 개의 파운데이션 파일 위에, 각 파일과 가운데 정렬되어 배치됩니다. 첫 번째
파운데이션 파일은 마침 화면의 위쪽 가운데를 기준으로 정렬되어 있으므로, 첫 번째 버튼은
그 위 가운데에 놓입니다.


<a id="anchors-and-co-ordinates"></a>

### 앵커와 좌표

여기와 `addButton()` 메서드의 식이 이상해 보일 수 있습니다. 카드와 파일은 모두
`Anchor.topLeft`인데 버튼은 `Anchor.center`이기 때문입니다. `Card`의 `position` 좌표는
카드의 왼쪽 위 모서리가 놓이는 곳이지만, `FlatButton`의 `position` 좌표는 버튼의
*중심*이 놓이는 곳이며, `FlatButton`의 여러 부분은 (내부적으로) 그 중심을 기준으로 배치됩니다.
이 예시들을 통해 Flame에서 좌표계가 어떻게 동작하는지 어느 정도 이해할 수 있습니다.


<a id="the-deal-method"></a>

### `deal()` 메서드

KlondikeWorld의 `onLoad()` 메서드가 마지막으로 하는 일은 `deal()` 메서드를 호출해 카드를 섞고
나눠 주는 것입니다. 이 메서드는 이제 KlondikeWorld 클래스에 있으며, `checkWin()`과
`letsCelebrate()` 메서드도 마찬가지인데, 이에 대해서는 나중에 더 설명합니다. 나눠 주는 과정은 이전과 같지만
이제 애니메이션이 포함됩니다.

```dart
  void deal() {
    assert(cards.length == 52, 'There are ${cards.length} cards: should be 52');

    if (gameRef.action != Action.sameDeal) {
      // 새로 나눠 주기: 난수 생성기의 시드를 바꿉니다.
      gameRef.seed = Random().nextInt(KlondikeGame.maxInt);
      if (gameRef.action == Action.changeDraw) {
        gameRef.klondikeDraw = (gameRef.klondikeDraw == 3) ? 1 : 3;
      }
    }
    // "Same deal" 옵션이면 이전 시드를 재사용하고, 그렇지 않으면 새 시드를 사용합니다.
    cards.shuffle(Random(gameRef.seed));

    var cardToDeal = cards.length - 1;
    var nMovingCards = 0;
    for (var i = 0; i < 7; i++) {
      for (var j = i; j < 7; j++) {
        final card = cards[cardToDeal--];
        card.doMove(
          tableauPiles[j].position,
          start: nMovingCards * 0.15,
          onComplete: () {
            tableauPiles[j].acquireCard(card);
            nMovingCards--;
            if (nMovingCards == 0) {
              var delayFactor = 0;
              for (final tableauPile in tableauPiles) {
                delayFactor++;
                tableauPile.flipTopCard(start: delayFactor * 0.15);
              }
            }
          },
        );
        nMovingCards++;
      }
    }
    for (var n = 0; n <= cardToDeal; n++) {
      stock.acquireCard(cards[n]);
    }
  }
```

먼저 이 게임의 `Action` 값을 처리합니다. 맨 처음 게임에서는 KlondikeGame 클래스가
`Action.newDeal`과 `klondikeDraw = 1`을 기본값으로 설정합니다. 하지만 그 뒤로는 플레이어가 버튼을 눌렀다 떼어
액션을 선택하면 KlondikeWorld가 그 값을 KlondikeGame에 저장하고, 플레이어가 게임에서
이기면 `Action.newDeal`이 자동으로 선택되어 저장됩니다. 액션은
보통 새 시드를 생성해 저장하지만, `Action.sameDeal`이면 이 과정을 건너뜁니다. 그런 다음
적용되는 `seed`로 카드를 섞습니다.

나눠 주는 로직은 클론다이크 튜토리얼 4단계에서 사용한 것과 같고, 애니메이션도 꽤 쉽습니다.
각 카드에 `card.doMove(`를 사용하되, 목적지를 바꾸고 `start:` 값을 늘려 가며,
출발하는 카드를 하나씩 셉니다. 루프가 끝난 뒤 몇 밀리초 동안
`nMovingCards`는 최댓값인 28(즉, 1 + 2 + 3 + 4 + 5 + 6 + 7)이 되고, 남은 24장의
카드는 제대로 구성된 스톡 파일로 들어갑니다.

그다음 1초 남짓한 동안 카드들이 도착하는데, 여기서 문제가 생깁니다. 카드는
스톡 파일 영역에서 보낸 순서대로 도착한다는 보장이 없습니다. 각 열의 마지막 카드를
너무 일찍 뒤집기 시작하면 엉뚱한 카드를 뒤집어 배치를 망칠 수 있습니다.
다음은 카드를 나눠 줄 때의 출력으로, 도착 순서가 어떻게 뒤섞일 수 있는지 보여 줍니다. `j` 변수는
태블로 파일 번호이고, `i`는 파일 안에서 카드의 위치입니다. 6번 파일로 갈 하트 킹이
5번 파일의 마지막 카드인 클럽 퀸보다 먼저 도착하고 있습니다. 그리고 6번 파일에는
아직 두 장이 더 가야 합니다.

```console
flutter: Move done, i 3, j 6, 6♠ 5 moving cards.
flutter: Move done, i 4, j 5, 9♥ 4 moving cards.
flutter: Move done, i 4, j 6, K♥ 3 moving cards.
flutter: Move done, i 5, j 5, Q♣ 2 moving cards.
flutter: Move done, i 5, j 6, 2♠ 1 moving cards.
flutter: Move done, i 6, j 6, 10♠ 0 moving cards.
flutter: Pile 0 [Q♦]
flutter: Pile 1 [J♣, Q♥]
flutter: Pile 2 [5♥, 5♦, J♦]
flutter: Pile 3 [A♠, Q♠, A♥, 5♠]
flutter: Pile 4 [8♦, 10♣, 7♥, 3♥, 4♥]
flutter: Pile 5 [4♠, 8♣, 5♣, 2♥, 9♥, Q♣]
flutter: Pile 6 [4♣, 3♦, K♦, 6♠, K♥, 2♠, 10♠]
```

그래서 카드가 도착할 때마다 `onComplete()` 콜백 코드에서 카드를 셉니다. 28장이 모두
도착한 뒤에야 각 태블로 파일의 마지막 카드를 뒤집기 시작합니다. 카드 나눠 주기가
끝나면 KlondikeWorld도 완성되어 플레이할 준비가 됩니다.


<a id="more-animations-of-moves"></a>

## 이동 애니메이션 더 알아보기

`Card` 클래스의 `doMove()`와 `turnFaceUp()` 메서드는 doMoveAndFlip()
메서드로 합쳐졌으며, 이 메서드는 스톡 파일에서 카드를 뽑을 때 사용합니다. 드래그 앤 드롭 후
카드 한 장 또는 여러 장을 파일에 놓을 때도 `doMove()`를 사용해 더 부드럽게 안착시킵니다. 마지막으로,
카드가 올라갈 준비가 되었다면 파운데이션 파일로 자동으로 옮기는 단축 기능이 있습니다. 이를 위해
`Card` 클래스에 `TapCallbacks`와 다음과 같은 `onTapUp()` 콜백을 추가합니다.

```dart
  onTapUp(TapUpEvent event) {
    if (isFaceUp) {
      final suitIndex = suit.value;
      if (game.foundations[suitIndex].canAcceptCard(this)) {
        pile!.removeCard(this);
        doMove(
          game.foundations[suitIndex].position,
          onComplete: () {
            game.foundations[suitIndex].acquireCard(this);
          },
        );
      }
    } else if (pile is StockPile) {
      game.stock.onTapUp(event);
    }
  }
```

카드가 올라갈 준비가 되었다면 그냥 탭하기만 하면 그 무늬에 맞는 파운데이션 파일로
자동으로 이동합니다. 게임에서 이기기 직전이라면 드래그 앤 드롭을 한참 덜 해도 됩니다!
위 코드에 새로운 것은 없지만, 스톡 파일의 맨 위 카드를 탭하면
`Card` 객체가 먼저 탭을 받아 `stock` 객체로 전달한다는 점은 다릅니다.


<a id="a-graphics-glitch"></a>

## 그래픽 글리치

여러 장의 카드를 한 태블로 파일에서 다른 태블로 파일로 옮기면, 예전(튜토리얼 4단계)에는
`TableauPile` 클래스의 내부 코드가 드래그 앤 드롭이 끝나자마자 카드를 제자리로 갑자기
옮겼습니다. 새 코드(5단계)에서 드래그 앤 드롭은 본질적으로 이전과 같은 코드를 사용하므로,
그 코드가 여러 장의 이동을 각각 `acquireCard` 호출로 끝나는 일련의 애니메이션 이동으로
처리하게 하고 싶은 유혹이 생깁니다. 하지만 이렇게 하니 보기 흉한 그래픽 글리치가 생겼습니다.
원인은 `acquireCard`가 `TableauPile`의 `layoutCards()` 메서드도 호출해서, 카드를 받을 때마다
파일 안의 모든 카드를 즉시 재배치했기 때문인 것으로 보입니다. 이 문제는
(결과적으로 꽤 어렵게) `TableauPile`에 `dropCards` 메서드를 추가해 해결했습니다.
이 메서드는 기존 동작 일부를 흉내 내면서 카드 애니메이션도
맞물리게 넣습니다.

여기서 얻을 수 있는 교훈은 게임 설계 단계에서 애니메이션과 시간에 따른
문제에 어느 정도 신경 쓸 가치가 있다는 것입니다. 그게 언제였냐고요? 바로 클론다이크 튜토리얼 1단계 준비와
2단계 뼈대 잡기 때입니다.


<a id="winning-the-game"></a>

## 게임에서 이기기

모든 무늬의 카드가 에이스부터 킹까지 모두 파운데이션 파일로 옮겨져 각 파일에 13장씩 쌓이면
게임에서 이깁니다. 이제 게임에는 이를 인식하는 코드가 있습니다. `FoundationPile`의
`acquireCard()` 메서드에 추가한 `isFull` 검사, `KlondikeWorld`로의 콜백, 그리고
네 개의 파운데이션이 모두 가득 찼는지 확인하는 검사입니다. 코드는 다음과 같습니다.

```dart
class FoundationPile extends PositionComponent implements Pile {
  FoundationPile(int intSuit, this.checkWin, {super.position})
      : suit = Suit.fromInt(intSuit),
        super(size: KlondikeGame.cardSize);

  final VoidCallback checkWin;

  final Suit suit;
  final List<Card> _cards = [];

  //#region Pile API

  bool get isFull => _cards.length == 13;
```

```dart
  void acquireCard(Card card) {
    assert(card.isFaceUp);
    card.position = position;
    card.priority = _cards.length;
    card.pile = this;
    _cards.add(card);
    if (isFull) {
      checkWin(); // KlondikeWorld가 모든 FoundationPile을 확인하게 합니다.
    }
  }
```

```dart
  void checkWin()
  {
    var nComplete = 0;
    for (final f in foundations) {
      if (f.isFull) {
        nComplete++;
      }
    }
    if (nComplete == foundations.length) {
      letsCelebrate();
    }
  }
```

클론다이크 게임에서는 주어진 카드 배치에서 이길 수 있는지, 혹은 이길 수 있었는데 결정적인 수를
놓쳤는지 계산할 수 있는 경우가 많습니다. 처음 나눠 준 배치가 이길 수 있는 배치인지 계산할 수 있는 경우도
많습니다. 클론다이크 배치 중 일정 비율은 이길 수 없습니다. 하지만 이 모든 것은 이 튜토리얼의 범위를
훨씬 벗어나므로, 지금은 계속 플레이해서 이기려고 할지, 아니면 포기하고 버튼 중 하나를 누를지
플레이어가 판단해야 합니다.


<a id="ending-a-game-and-re-starting-it"></a>

## 게임을 끝내고 다시 시작하기

게임은 플레이어가 이기거나 버튼 중 하나를 눌렀다 떼면 끝납니다. 그
시점에 KlondikeGame 클래스는 새 게임을 시작하는 데 필요한 모든 데이터, 즉 `Action`
값, `klondikeDraw` 값(1 또는 3), 이전 게임의 `seed`를 가지고 있어야 합니다. 각 버튼에는
KlondikeWorld의 `addButton()` 메서드가 제공하는 `onReleased:` 콜백이 있으며, 코드는 다음과 같습니다.

```dart
      onReleased: () {
        if (action == Action.haveFun) {
          // "승리" 시퀀스로 가는 지름길로, 튜토리얼 목적으로만 사용합니다.
          letsCelebrate();
        } else {
          // 새로 나눠 주거나 이전과 같은 배치로 재시작합니다.
          gameRef.action = action;
          gameRef.world = KlondikeWorld();
        }
      },
```

`letsCelebrate()` 메서드는 보통 플레이어가 이겼을 때만 호출됩니다. 나머지
세 버튼의 기능은 KlondikeGame의 `Action` 값을 설정하고, `FlameGame`의 `world`가
새 KlondikeWorld를 가리키도록 설정하는 것입니다. 그러면 현재 월드가 교체되고, 이전
KlondikeWorld의 저장 공간은 가비지 컬렉션이 정리하게 됩니다. 이어서 `FlameGame`이
KlondikeWorld의 `onLoad()` 메서드를 트리거합니다.

`letsCelebrate()` 메서드도 비슷한 코드로 끝나지만, 새로 나눠 주기를 강제합니다.

```dart
              gameRef.action = Action.newDeal;
              gameRef.world = KlondikeWorld();
```


<a id="the-have-fun-button"></a>

## `Have fun` 버튼

클론다이크 게임에서 이기면 `letsCelebrate()` 메서드가 작은 쇼를 보여 줍니다. 이를 보기 위해
게임 한 판을 끝까지 플레이해서 이길 필요가 없도록(**그리고** 이 메서드를 테스트하기 위해)
`Have fun` 버튼을 마련했습니다. 물론 실제 게임에는 이런 버튼이 있을 수 없겠죠...

자, 이것으로 끝입니다! 이제 게임을 더 즐겁게 플레이할 수 있습니다.

더 많은 것을 할 수도 있지만, 이 게임은 무엇보다도 튜토리얼**입니다**. 아래 버튼을 눌러
최종 코드를 보거나 직접 플레이해 보세요.

이제 Ember 튜토리얼도 살펴볼 차례입니다!

```{flutter-app}
:sources: ../tutorials/klondike/app
:page: step5
:show: popup code
```
