# FlameNetworkAssets

`FlameNetworkAssets`는 네트워크에서 에셋을 가져오고 캐싱하는 솔루션을 제공하는 데 중점을 둔
브릿지 패키지입니다.

`FlameNetworkAssets` 클래스는 에셋별 핸들러를 만들기 위해 상속해서 사용하는 추상화를
제공합니다.

기본적으로 이 패키지는 http 요청을 위해 `http` 패키지를, 로컬 캐시를 저장할 위치를 얻기 위해
`path_provider`를 사용합니다. 이들 대신 다른 방식을 사용하려면 생성자의
선택적 인자를 사용하세요.

이 패키지에는 이미지 전용 에셋 핸들러 클래스가 포함되어 있습니다.

```dart
final networkAssets = FlameNetworkImages();
final playerSprite = await networkAssets.load('https://url.com/image.png');
```

특정 에셋 핸들러 클래스를 만들려면 `FlameNetworkAssets` 클래스를 상속하고
`decodeAsset`과 `encodeAsset` 인자를 정의하기만 하면 됩니다.

```dart
class FlameNetworkCustomAsset extends FlameNetworkAssets<CustomAsset> {
  FlameNetworkImages({
    super.get,
    super.getAppDirectory,
    super.cacheInMemory,
    super.cacheInStorage,
  }) : super(
          decodeAsset: (bytes) => CustomAsset.decode(bytes),
          encodeAsset: (CustomAsset asset) => asset.encode(),
        );
}
```
