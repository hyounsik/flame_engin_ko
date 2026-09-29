# flame_spine

이 패키지를 사용하면 Spine 스켈레탈 애니메이션을 불러와 Flame 게임에 추가할 수 있습니다.


<a id="usage"></a>

## 사용법

게임에서 사용하려면 pubspec.yaml에 `flame_spine`을 추가하고 Spine 에셋을 `assets/` 디렉터리에
추가하기만 하면 됩니다. 그러면 `FlameGame`에 `SpineComponent`를 추가할 수 있습니다.

```{note}
`main` 메서드나 `onLoad`에서 `await initSpineFlutter();`를 호출하는 것을 잊지 마세요.
```

예시:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSpineFlutter();
  runApp(const GameWidget.managed(gameFactory: SpineExample.new));
}

class FlameSpineExample extends FlameGame {
 late final SpineComponent spineboy;

 @override
 Future<void> onLoad() async {
  await initSpineFlutter();
  // 에셋 파일에서 Spineboy 아틀라스와 스켈레톤 데이터를 불러오고
  // 이를 사용해 SpineComponent를 만듭니다. 크기를 줄이고
  // 화면 중앙에 배치합니다
  spineboy = await SpineComponent.fromAssets(
   atlasFile: 'assets/spine/spineboy.atlas',
   skeletonFile: 'assets/spine/spineboy-pro.skel',
   scale: Vector2(0.4, 0.4),
   anchor: Anchor.center,
   position: size / 2,
  );

  // 트랙 0에 "walk" 애니메이션을 반복 모드로 설정합니다
  spineboy.animationState.setAnimationByName(0, 'walk', true);
  add(spineboy);
 }

 @override
 void onDetach() {
  // spineboy를 위해 로드된 네이티브 리소스를 해제합니다.
  spineboy.dispose();
 }
}
```
