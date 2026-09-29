# AudioPool

AudioPool은 오디오 재생 지연을 최소화하기 위해 로컬 에셋이 미리 로드된 AudioPlayer를 제공하는 공급자입니다.
효과음이 빠르게 재생되어야 하고 서로 겹칠 수도 있는 빠른 템포의 게임에서
특히 유용합니다.

하나의 AudioPool은 항상 같은 사운드를 재생합니다. 보통 반복적으로 또는 동시에 재생해야 할 수 있는
짧은 효과음이며, 예를 들면 다음과 같습니다.

- 우주 슈팅 게임의 발사 소리
- 플랫포머 게임의 점프 소리
- 폭발 효과
- 코인이나 아이템 획득
- 적 피격 소리


<a id="how-it-works"></a>

## 동작 방식

AudioPool은 모두 같은 사운드를 재생하도록 설정된 AudioPlayer 인스턴스의 풀을 생성하고 미리 로드하는 방식으로
동작합니다. 사운드를 재생해야 할 때는 다음과 같이 진행됩니다.

1. 풀이 보유한 플레이어 중 사용 가능한 플레이어를 제공합니다
2. 사용 가능한 플레이어가 없으면 필요할 때 새 플레이어를 생성합니다
3. 사운드 재생이 끝나거나 수동으로 정지되면 플레이어는 재사용을 위해 풀로 반환됩니다.
   단, 풀이 이미 최대 크기 제한에 도달한 경우에는 플레이어가 해제됩니다

이 방식은 필요할 때마다 새 AudioPlayer 인스턴스를 생성하는 것에 비해 지연 시간을 크게 줄이면서,
풀의 최대 크기를 제한해 메모리도 관리합니다.


<a id="creating-an-audiopool"></a>

## AudioPool 생성하기

AudioPool을 생성하는 방법은 여러 가지입니다.


<a id="using-flameaudio-helper"></a>

### FlameAudio 헬퍼 사용하기

가장 간단한 방법은 `FlameAudio`의 헬퍼 메서드를 사용하는 것으로, Flame의 전역 오디오 캐시를
편리하게 사용합니다.

```dart
import 'package:flame_audio/flame_audio.dart';

Future<void> loadSounds() async {
  // 최소 1개, 최대 2개의 플레이어를 가진 풀을 생성합니다
  // Flame의 전역 오디오 캐시를 자동으로 사용합니다
  AudioPool explosionSoundPool = await FlameAudio.createPool(
    'assets/audio/explosion.mp3',
    minPlayers: 1,
    maxPlayers: 2,
  );
}
```


<a id="creating-directly-with-source"></a>

### Source로 직접 생성하기

정적 팩토리 메서드를 직접 사용해 AudioPool을 생성할 수도 있습니다.

```dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flame_audio/flame_audio.dart';

Future<void> loadSounds() async {
  // 특정 Source로 풀을 생성합니다
  AudioPool explosionSoundPool = await AudioPool.create(
    source: AssetSource('assets/audio/explosion.mp3'),
    minPlayers: 1,
    maxPlayers: 2,
    audioCache: FlameAudio.audioCache, // 선택 사항
  );
}
```


<a id="creating-from-asset-path"></a>

### 에셋 경로로 생성하기

편의를 위해 에셋 경로만으로 AudioPool을 생성할 수도 있습니다.

```dart
import 'package:flame_audio/flame_audio.dart';

Future<void> loadSounds() async {
  AudioPool explosionSoundPool = await AudioPool.createFromAsset(
    path: 'assets/audio/explosion.mp3',
    minPlayers: 1,
    maxPlayers: 2,
    audioCache: FlameAudio.audioCache, // 선택 사항
  );
}
```

파라미터는 다음과 같습니다.

- `source` 또는 `path`: 재생할 오디오 소스(Source 객체 또는 에셋 경로)
- `minPlayers`: 처음에 생성하고 미리 로드할 AudioPlayer의 수(기본값: 1)
- `maxPlayers`: 풀에 유지할 수 있는 AudioPlayer의 최대 수
- `audioCache`: 사용할 AudioCache 인스턴스(선택 사항)
- `audioContext`: 풀의 모든 플레이어가 사용할 오디오 컨텍스트(선택 사항)


<a id="using-an-audiopool"></a>

## AudioPool 사용하기

AudioPool을 생성했으면 사운드를 재생할 수 있습니다.

```dart
// 기본 볼륨(1.0)으로 사운드를 재생합니다
final stopFunction = await audioPool.start();

// 지정한 볼륨으로 사운드를 재생합니다
final stopFunction = await audioPool.start(volume: 0.5);

// 나중에 필요하면 사운드를 정지할 수 있습니다
await stopFunction();
```

`start()` 메서드는 `StopFunction`을 반환하며, 이를 호출하면 사운드가 자연스럽게 끝나기 전에
정지할 수 있습니다.


<a id="managing-the-pool"></a>

## 풀 관리하기

AudioPool은 더 이상 풀이 필요하지 않을 때 리소스를 해제하는 `dispose()` 메서드를 제공합니다.

```dart
// 풀 사용이 끝났을 때
await audioPool.dispose();
```


<a id="example-usage"></a>

## 사용 예제

다음은 Flame 게임에서 AudioPool을 사용하는 방법을 보여 주는 전체 예제입니다.

```dart
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';

class MyGame extends FlameGame {
  late AudioPool laserSound;
  late AudioPool explosionSound;

  @override
  Future<void> onLoad() async {
    // 효과음을 오디오 풀에 로드합니다
    laserSound = await FlameAudio.createPool(
      'assets/audio/laser.mp3',
      minPlayers: 3,
      maxPlayers: 6,
    );

    explosionSound = await FlameAudio.createPool(
      'assets/audio/explosion.mp3',
      minPlayers: 2,
      maxPlayers: 4,
    );
  }

  void fireLaser() async {
    // 레이저 효과음을 재생합니다 - 빠르게 연속 호출할 수 있습니다
    final stop = await laserSound.start();

    // 사운드를 일찍 정지해야 한다면:
    // await stop();
  }

  void enemyDestroyed() async {
    // 폭발 효과음을 재생합니다
    await explosionSound.start(volume: 0.7);
  }

  @override
  Future<void> onRemove() async {
    await super.onRemove();

    // 게임 컴포넌트가 제거될 때 리소스를 정리합니다
    await laserSound.dispose();
    await explosionSound.dispose();
  }
}
```

인터랙티브 예제는 [Flame Basic](https://examples.flame-engine.org/)에서도 확인할 수 있습니다.
