<a id="getting-started"></a>

# 시작하기


<a id="about-flame"></a>

## Flame 소개

Flame은 게임에 필요한 완전한 솔루션 세트를 방해되지 않는 방식으로 제공하는 모듈식 Flutter 게임 엔진입니다.
Flutter가 제공하는 강력한 인프라를 활용하면서도, 프로젝트를 만드는 데 필요한 코드는
단순하게 만들어 줍니다.

간단하면서도 효과적인 게임 루프 구현과 게임에 필요할 수 있는 기능들을 제공합니다.
예를 들어 입력, 이미지, 스프라이트, 스프라이트 시트, 애니메이션, 충돌 감지, 그리고 Flame Component System
(줄여서 FCS)이라고 부르는 컴포넌트 시스템이 있습니다.

또한 Flame의 기능을 확장하는 독립 패키지들도 제공하며, 이는
[브릿지 패키지](bridge_packages/bridge_packages.md) 섹션에서 찾아볼 수 있습니다.

모든 부분이 독립적이고 모듈식이므로 원하는 부분만 골라서 사용할 수 있습니다.

엔진과 그 생태계는 커뮤니티에 의해 꾸준히 개선되고 있으니, 언제든 편하게 연락하시고
이슈와 PR을 열거나 제안해 주세요.

엔진을 널리 알리고 커뮤니티를 키우는 데 도움을 주고 싶다면 스타를 눌러 주세요. :)


<a id="installation"></a>

## 설치

다음 명령을 실행하여 `pubspec.yaml`에 `flame` 패키지를 의존성으로 추가합니다.

```console
flutter pub add flame
```

최신 버전은 [pub.dev](https://pub.dev/packages/flame/install)에서 확인할 수 있습니다.

그런 다음 `flutter pub get`을 실행하면 바로 사용할 준비가 끝납니다!


<a id="getting-started-1"></a>

## 시작하기

시작하는 데 따라 해 볼 수 있는 튜토리얼 모음이
[tutorials 폴더](https://github.com/flame-engine/flame/tree/main/doc/tutorials)에 있습니다.

모든 기능에 대한 간단한 예제는
[examples 폴더](https://github.com/flame-engine/flame/tree/main/examples)에서 찾을 수 있습니다.

Flame을 실행하려면 `GameWidget`을 사용해야 합니다. `GameWidget`은 위젯 트리 어디에나 둘 수 있는
평범한 위젯일 뿐입니다. 앱의 루트 위젯으로 사용할 수도 있고, 다른 위젯의 자식으로 사용할 수도 있습니다.

다음은 `GameWidget`을 사용하는 간단한 예제입니다.

```dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget(
      game: FlameGame(),
    ),
  );
}
```

Flame에는 Flame Component System(FCS)이라는 개념이 있는데, 게임 오브젝트를 관리하기 쉽도록
구성하는 방법입니다. 자세한 내용은 [컴포넌트](flame/components/components.md) 섹션에서 읽을 수 있습니다.

새 게임을 시작하려면 `FlameGame` 클래스나 `World` 클래스를 상속해야 합니다.
`FlameGame`은 게임의 루트로, 게임 루프와 컴포넌트를 관리하는 역할을 합니다.
`World` 클래스는 게임 안에 월드를 만드는 데 사용할 수 있는 컴포넌트입니다.

따라서 간단한 게임을 만들려면 다음과 같이 할 수 있습니다.

```dart
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(
    GameWidget(
      game: FlameGame(world: MyWorld()),
    ),
  );
}

class MyWorld extends World {
  @override
  Future<void> onLoad() async {
    add(Player(position: Vector2(0, 0)));
  }
}
```

보시다시피 `World` 클래스를 상속하는 `MyWorld` 클래스를 만들었습니다. `onLoad` 메서드를
오버라이드하여 (아직 존재하지 않는) `Player` 컴포넌트를 월드에 추가했습니다.
`FlameGame` 클래스에는 기본적으로 월드를 지켜보는 `camera`가 있으며, 기본적으로 화면 중앙에서
월드의 (0, 0) 위치를 바라봅니다. 카메라와 월드에 대해 더 알아보려면
[카메라 컴포넌트](flame/camera.md) 섹션을 읽어 보세요.

`Player` 컴포넌트는 원하는 어떤 종류의 컴포넌트든 될 수 있습니다. 처음 시작할 때는 화면에
스프라이트(이미지)를 렌더링할 수 있는 컴포넌트인 `SpriteComponent` 클래스를 사용하는 것을 권장합니다.

예를 들면 다음과 같습니다.

```dart
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/extensions.dart';

class Player extends SpriteComponent {
  Player({super.position}) :
    super(size: Vector2.all(200), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('assets/images/player.png');
  }
}
```

이 예제에서는 `SpriteComponent` 클래스를 상속하는 `Player` 클래스를 만들었습니다. `onLoad` 메서드를
오버라이드하여 `player.png`라는 이미지 파일에서 불러온 스프라이트를 컴포넌트의 스프라이트로 설정했습니다.
이미지는 프로젝트의 `assets/images` 디렉터리에 있어야 하며
([에셋 디렉터리 구조](flame/structure.md) 참고), `pubspec.yaml` 파일의
[assets 섹션](https://docs.flutter.dev/ui/assets/assets-and-images)에 추가해야 합니다.
이 클래스에서는 또한 `super` 생성자에 값을 전달하여 컴포넌트의 크기를 200x200으로, [앵커](flame/components/position_component.md#anchor)를
컴포넌트의 중앙으로 설정했습니다. 그리고 `Player` 클래스를 사용하는 쪽에서 생성할 때 컴포넌트의 위치를
설정할 수 있게 했습니다(`Player(position: Vector2(0, 0))`).

컴포넌트에서 입력을 처리하려면 [입력 믹스인](flame/inputs/inputs.md) 중 아무것이나 컴포넌트에
추가하면 됩니다. 예를 들어 탭 입력을 처리하고 싶다면 player 컴포넌트에 `TapCallbacks` 믹스인을
추가하여 player 컴포넌트의 경계 안에서 발생하는 탭 이벤트를 받을 수 있습니다. 또는 월드 전체에서
탭 입력을 처리하고 싶다면 상속한 `World` 클래스에 `TapCallbacks` 믹스인을 추가하면 됩니다.

다음 예제는 player 컴포넌트에 대한 탭을 처리하며, player 컴포넌트가 탭되면
player의 크기가 너비와 높이 모두 50픽셀씩 커집니다.

```dart
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/extensions.dart';

class Player extends SpriteComponent with TapCallbacks {
  Player({super.position}) :
    super(size: Vector2.all(200), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('assets/images/player.png');
  }
  
  @override
  void onTapUp(TapUpEvent info) {
    size += Vector2.all(50);
  }
}
```

이것은 Flame을 시작하는 방법에 대한 간단한 예제일 뿐입니다. 게임을 만드는 데 사용할 수 있는
(그리고 아마도 필요할) 기능은 훨씬 더 많지만, 좋은 출발점이 될 것입니다.

[awesome flame 저장소](https://github.com/flame-engine/awesome-flame#user-content-articles--tutorials)도
확인해 보세요. Flame을 시작하는 데 도움이 되는, 커뮤니티가 작성한 좋은 튜토리얼과 글이
꽤 많이 모여 있습니다.


<a id="outside-of-the-scope-of-the-engine"></a>

## 엔진의 범위를 벗어나는 것들

게임은 그 내용에 따라 복잡한 기능들을 필요로 하기도 합니다. 이러한 기능 중 일부는
Flame Engine 생태계의 범위를 벗어나는데, 이 섹션에서는 그러한 기능들과 함께
사용할 수 있는 패키지/서비스 추천을 소개합니다.


<a id="multiplayer-netcode"></a>

### 멀티플레이어 (넷코드)

Flame은 온라인 멀티플레이어 게임을 만드는 데 필요할 수 있는 네트워크 기능을 포함하지 않습니다.

멀티플레이어 게임을 만든다면 다음 패키지/서비스를 추천합니다.

- [Nakama](https://github.com/obrunsmann/flutter_nakama/): 현대적인 게임과 앱을 구동하도록
 설계된 오픈 소스 서버입니다.
- [Firebase](https://firebase.google.com/): 간단한 멀티플레이어 경험을 만드는 데 사용할 수 있는
수십 가지 서비스를 제공합니다.
- [Supabase](https://supabase.com/): Postgres 기반의 Firebase보다 저렴한 대안입니다.
- [PubNub](https://github.com/pubnub/dart): 게임 로비와 플레이어 업데이트를 동기화하기 위한
실시간 메시징 네트워크입니다.
