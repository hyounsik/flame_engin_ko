<a id="audio"></a>

# 오디오

오디오 재생은 대부분의 게임에 필수적이므로 간단하게 만들었습니다!

먼저 `pubspec.yaml` 파일의 의존성 목록에 [flame_audio](https://github.com/flame-engine/flame_audio)를
추가해야 합니다.

```yaml
dependencies:
  flame_audio: VERSION
```

최신 버전은 [pub.dev](https://pub.dev/packages/flame_audio/install)에서 확인할 수 있습니다.

`flame_audio` 패키지를 설치한 후 `pubspec.yaml` 파일의 assets 섹션에 오디오 파일을 추가할 수 있습니다.
지정한 경로에 오디오 파일이 실제로 있는지 확인하세요.

모든 경로는 `pubspec.yaml`에 선언된 그대로 전체 경로로 지정하며, 앞에 아무것도 붙지 않습니다.
아래 예제에서는 오디오 파일을 `assets/audio`에 두지만, 어떤 디렉터리든 사용할 수 있습니다.

아래 예제를 위해서는 `pubspec.yaml` 파일에 다음과 같은 내용이 있어야 합니다.

```yaml
flutter:
  assets:
    - assets/audio/explosion.mp3
    - assets/audio/music.mp3
```

그러면 다음 메서드를 사용할 수 있습니다.

```dart
import 'package:flame_audio/flame_audio.dart';

// 효과음처럼 짧고 반복해서 사용하는 오디오 클립용
FlameAudio.play('assets/audio/explosion.mp3');

// 오디오 파일을 반복 재생할 때
FlameAudio.loop('assets/audio/music.mp3');

// 긴 오디오 파일을 재생할 때
FlameAudio.playLongAudio('assets/audio/music.mp3');

// 긴 오디오 파일을 반복 재생할 때
FlameAudio.loopLongAudio('assets/audio/music.mp3');

// 게임을 일시 정지/재개할 때 함께 일시 정지/재생되어야 하는
// 배경 음악용
FlameAudio.bgm.play('assets/audio/music.mp3');
```

`play/loop`와 `playLongAudio/loopLongAudio`의 차이점은, `play/loop`는 최적화된 기능을 사용해 반복 사이에
끊김 없이 소리를 반복 재생할 수 있고 게임 프레임 레이트가 거의 떨어지지 않는다는 점입니다. 가능하면
항상 전자의 메서드를 사용하는 것이 좋습니다.

`playLongAudio/loopLongAudio`는 길이에 상관없이 오디오를 재생할 수 있지만, 프레임 레이트 저하를 일으키며
반복 재생되는 오디오의 반복 사이에 약간의 간격이 생깁니다.

[`Bgm` 클래스](bgm.md)(`FlameAudio.bgm`을 통해)를 사용하면 반복되는 배경 음악 트랙을 재생할 수 있습니다.
`Bgm` 클래스를 사용하면 게임이 백그라운드로 전환되거나 포그라운드로 돌아올 때 Flame이 배경 음악 트랙의
일시 정지와 재개를 자동으로 관리합니다.

짧은 효과음을 매우 효율적으로 재생하고 싶다면 [`AudioPool` 클래스](audio_pool.md)를 사용할 수 있습니다.
`AudioPool`은 특정 사운드가 미리 로드된 `AudioPlayer`들의 풀을 유지하며, 이를 매우 빠르게 연속으로
재생할 수 있게 해 줍니다.

여러 기기에서 동작하며 권장하는 파일 형식은 MP3, OGG, WAV입니다.

이 브릿지 라이브러리(flame_audio)는 여러 사운드를 동시에 재생할 수 있도록(게임에서 매우 중요합니다)
[audioplayers](https://github.com/bluefireteam/audioplayers)를 사용합니다. 더 자세한 설명은
링크를 확인하세요.

`play`와 `loop` 모두에 선택적인 double 파라미터인 `volume`을 추가로 전달할 수 있습니다
(기본값은 `1.0`).

`play`와 `loop` 메서드는 모두 [audioplayers](https://github.com/bluefireteam/audioplayers) 라이브러리의
`AudioPlayer` 인스턴스를 반환하며, 이를 통해 정지, 일시 정지 및 기타 파라미터 설정을
할 수 있습니다.

사실 오디오 재생 방식을 완전히 제어하고 싶다면 언제든 `AudioPlayer`를 직접 사용할 수 있습니다.
-- `FlameAudio` 클래스는 공통 기능을 위한 래퍼일 뿐입니다.


<a id="caching"></a>

## 캐싱

에셋을 미리 로드할 수 있습니다. 오디오는 처음 요청될 때 메모리에 저장되어야 하므로
각 mp3를 처음 재생할 때 지연이 생길 수 있습니다. 오디오를 미리 로드하려면
다음을 사용하면 됩니다.

```dart
await FlameAudio.audioCache.load('assets/audio/explosion.mp3');
```

게임의 `onLoad` 메서드에서 처음에 모든 오디오를 로드해 두면 항상 부드럽게 재생됩니다.
여러 오디오 파일을 로드하려면 `loadAll` 메서드를 사용합니다.

```dart
await FlameAudio.audioCache.loadAll([
  'assets/audio/explosion.mp3',
  'assets/audio/music.mp3',
]);
```

마지막으로, `clear` 메서드를 사용해 캐시에 로드된 파일을 제거할 수 있습니다.

```dart
FlameAudio.audioCache.clear('assets/audio/explosion.mp3');
```

캐시 전체를 비우는 `clearCache` 메서드도 있습니다.

예를 들어 게임에 여러 레벨이 있고 레벨마다 서로 다른 사운드와 음악을 사용하는 경우
유용할 수 있습니다.
