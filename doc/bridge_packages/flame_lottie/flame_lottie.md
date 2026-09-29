# flame_lottie

이 패키지를 사용하면 Lottie 애니메이션을 불러와 Flame 게임에 추가할 수 있습니다.


네이티브 Lottie 라이브러리(예: [lottie-android](https://github.com/airbnb/lottie-android))는
**Airbnb**가 관리합니다.

이 래퍼의 기반이 되는 Flutter 패키지 ``lottie``는 **xaha.dev**가 개발했으며
[pub.dev](https://pub.dev/packages/lottie)에서 찾을 수 있습니다.


<a id="usage"></a>

## 사용법

게임에서 사용하려면 pubspec.yaml에 `flame_lottie`를 추가하기만 하면 됩니다.

**loadLottie** 메서드와
[LottieBuilder](https://pub.dev/documentation/lottie/latest/lottie/LottieBuilder-class.html)를 사용해 Lottie 애니메이션을 불러오기만 하면 됩니다.
Lottie 파일을 불러오는 다양한 방법을 모두 지원합니다.

- [Lottie.asset](https://pub.dev/documentation/lottie/latest/lottie/Lottie/asset.html): 키를 사용해
AssetBundle에서 Lottie 파일을 가져옵니다.
- [Lottie.network](https://pub.dev/documentation/lottie/latest/lottie/Lottie/network.html): URL에서
lottie 파일을 가져옵니다.
- [Lottie.file](https://pub.dev/documentation/lottie/latest/lottie/Lottie/file.html): File에서
 lottie 파일을 가져옵니다.
- [Lottie.memory](https://pub.dev/documentation/lottie/latest/lottie/Lottie/memory.html): Uint8List에서
lottie 파일을 가져옵니다.

... 그리고 이를 `LottieComponent`로 Flame 🔥 게임에 추가합니다.

예시:

```dart
class MyGame extends FlameGame {
  ...
  @override
  Future<void> onLoad() async {
    final asset = Lottie.asset('assets/LottieLogo1.json');
    final animation = await loadLottie(asset);
    add(
      LottieComponent(
        animation,
        repeating: true, // 애니메이션을 계속 반복합니다.
        size: Vector2.all(400),
      ),
    );
  }
  ...
}
```
