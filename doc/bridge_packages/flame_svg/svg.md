# Flame SVG

flame_svg는 게임에서 SVG 이미지를 렌더링하기 위한 간단한 API를 제공합니다.


<a id="installation"></a>

## 설치

SVG 지원은 `flame_svg` 브릿지 패키지가 제공하므로, 사용하려면 반드시 pubspec 파일에
추가하세요.

설치에 대해 더 알고 싶다면
[pub.dev의 flame_svg](https://pub.dev/packages/flame_svg/install)를 방문하세요.


<a id="how-to-use-flame_svg"></a>

## flame_svg 사용 방법

사용하려면 `'package:flame_svg/flame_svg.dart'`에서 `Svg` 클래스를 import하고, 다음 코드를 사용해
캔버스에 렌더링하면 됩니다.

```dart
final svgInstance = await Svg.load('assets/android.svg');

final position = Vector2(100, 100);
final size = Vector2(300, 300);

svgInstance.renderPosition(canvas, position, size);
```

또는 `SvgComponent`를 사용해 컴포넌트 트리에 추가할 수도 있습니다.

```dart
class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final svgInstance = await Svg.load('assets/android.svg');
    final size = Vector2.all(100);
    final position = Vector2.all(100);
    final svgComponent = SvgComponent(
      size: size,
      position: position,
      svg: svgInstance,
    );

    add(svgComponent);
  }
}
```
