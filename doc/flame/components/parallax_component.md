# ParallaxComponent

패럴랙스 스크롤링은 배경 레이어를 서로 다른 속도로 움직여 깊이감을 만드는 고전적인 게임 개발
기법입니다. 카메라에 가까운 물체는 멀리 있는 물체보다 더 빠르게 움직이는 것처럼 보입니다. 차창 밖을
볼 때 가까운 나무는 휙휙 지나가지만 먼 산은 거의 움직이지 않는 것과 같습니다. 이 효과는 2D 게임
월드를 더 몰입감 있게 만들어 주며, 횡스크롤 게임, 플랫포머, 메뉴 화면 등에서 흔히 사용됩니다.

이 `Component`는 여러 장의 투명한 이미지를 겹쳐 그려 깊이감 있는 배경을 렌더링하는 데 사용할 수
있으며, 각 이미지나 애니메이션(`ParallaxRenderer`)은 서로 다른 속도로 움직입니다.

가장 간단한 `ParallaxComponent`는 다음과 같이 만듭니다:

```dart
@override
Future<void> onLoad() async {
  final parallaxComponent = await loadParallaxComponent([
    ParallaxImageData('assets/images/bg.png'),
    ParallaxImageData('assets/images/trees.png'),
  ]);
  add(parallaxComponent);
}
```

ParallaxComponent는 `onLoad` 메서드를 구현하여 "스스로 로드"할 수도 있습니다:

```dart
class MyParallaxComponent extends ParallaxComponent<MyGame> {
  @override
  Future<void> onLoad() async {
    parallax = await gameRef.loadParallax([
      ParallaxImageData('assets/images/bg.png'),
      ParallaxImageData('assets/images/trees.png'),
    ]);
  }
}

class MyGame extends FlameGame {
  @override
  void onLoad() {
    add(MyParallaxComponent());
  }
}
```

이렇게 하면 정적인 배경이 만들어집니다. 움직이는 패럴랙스(패럴랙스의 핵심이 바로 이것입니다)를
원한다면, 각 레이어의 설정을 얼마나 세밀하게 지정할지에 따라 몇 가지 방법으로 구현할 수 있습니다.

가장 간단한 방법은 `load` 헬퍼 함수에 이름 있는 선택적 파라미터 `baseVelocity`와
`velocityMultiplierDelta`를 설정하는 것입니다. 예를 들어 배경 이미지를 X축을 따라 움직이되, 이미지가
"가까울수록" 더 빠르게 움직이게 하려면 다음과 같이 합니다:

```dart
@override
Future<void> onLoad() async {
  final parallaxComponent = await loadParallaxComponent(
    _dataList,
    baseVelocity: Vector2(20, 0),
    velocityMultiplierDelta: Vector2(1.8, 1.0),
  );
}
```

baseSpeed와 layerDelta는 캐릭터가 점프하거나 게임 속도가 빨라질 때처럼 언제든지 설정할 수 있습니다.

```dart
@override
void onLoad() {
  final parallax = parallaxComponent.parallax;
  parallax.baseSpeed = Vector2(100, 0);
  parallax.velocityMultiplierDelta = Vector2(2.0, 1.0);
}
```

기본적으로 이미지는 왼쪽 아래에 정렬되고, X축을 따라 반복되며, 화면 높이를 덮도록 비율에 맞춰
스케일링됩니다. 횡스크롤 게임을 만드는 것이 아닌 경우처럼 이 동작을 바꾸고 싶다면, 각
`ParallaxRenderer`에 `repeat`, `alignment`, `fill` 파라미터를 설정하고 이를 `ParallaxLayer`에 추가한
뒤 `ParallaxComponent`의 생성자에 전달하면 됩니다.

고급 예제:

```dart
final images = [
  loadParallaxImage(
    'assets/images/stars.jpg',
    repeat: ImageRepeat.repeat,
    alignment: Alignment.center,
    fill: LayerFill.width,
  ),
  loadParallaxImage(
    'assets/images/planets.jpg',
    repeat: ImageRepeat.repeatY,
    alignment: Alignment.bottomLeft,
    fill: LayerFill.none,
  ),
  loadParallaxImage(
    'assets/images/dust.jpg',
    repeat: ImageRepeat.repeatX,
    alignment: Alignment.topRight,
    fill: LayerFill.height,
  ),
];

final layers = images.map(
  (image) => ParallaxLayer(
    await image,
    velocityMultiplier: images.indexOf(image) * 2.0,
  )
);

final parallaxComponent = ParallaxComponent.fromParallax(
  Parallax(
    await Future.wait(layers),
    baseVelocity: Vector2(50, 0),
  ),
);
```

- 이 예제에서 별(stars) 이미지는 두 축 모두로 반복해서 그려지고, 중앙에 정렬되며, 화면 너비를
 채우도록 스케일링됩니다.
- 행성(planets) 이미지는 Y축으로 반복되고, 화면 왼쪽 아래에 정렬되며, 스케일링되지 않습니다.
- 먼지(dust) 이미지는 X축으로 반복되고, 오른쪽 위에 정렬되며, 화면 높이를 채우도록 스케일링됩니다.

`ParallaxComponent` 설정을 마쳤다면 다른 컴포넌트와 마찬가지로 게임에 추가합니다
(`game.add(parallaxComponent`).
또한 이미지를 `pubspec.yaml` 파일에 에셋으로 추가하는 것을 잊지 마세요. 그렇지 않으면 이미지를 찾을
수 없습니다.

`Parallax` 파일에는 게임의 확장(extension)이 들어 있어 `loadParallax`, `loadParallaxLayer`,
`loadParallaxImage`, `loadParallaxAnimation`을 추가하며, 이들은 전역 이미지 캐시 대신 게임의 이미지
캐시를 자동으로 사용합니다. `ParallaxComponent` 파일도 마찬가지이며, 이쪽은 `loadParallaxComponent`를
제공합니다.

전체 화면 `ParallaxComponent`를 원한다면 `size` 인자를 생략하기만 하면 됩니다. 그러면 게임의 크기를
따르며, 게임의 크기나 방향이 바뀔 때도 전체 화면에 맞게 크기가 조정됩니다.

Flame은 두 종류의 `ParallaxRenderer`를 제공합니다. `ParallaxImage`와 `ParallaxAnimation`입니다.
`ParallaxImage`는 정적 이미지 렌더러이고, `ParallaxAnimation`은 이름에서 알 수 있듯이 애니메이션 및
프레임 기반 렌더러입니다.
`ParallaxRenderer` 클래스를 상속하여 커스텀 렌더러를 만들 수도 있습니다.

세 가지 구현 예제는
[examples 디렉터리](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/parallax)에서
찾을 수 있습니다.
