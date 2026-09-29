<a id="looping-background-music"></a>

# 배경 음악 반복 재생

`Bgm` 클래스를 사용하면 애플리케이션(또는 게임)의 생명주기 상태 변화에 맞춰 배경 음악 트랙의 반복 재생을
관리할 수 있습니다.

애플리케이션이 종료되거나 백그라운드로 전환되면 `Bgm`이 현재 재생 중인 음악 트랙을 자동으로
일시 정지합니다. 마찬가지로 애플리케이션이 재개되면 `Bgm`이 배경 음악을 다시
재생합니다. 트랙을 수동으로 일시 정지하고 재개하는 것도 지원합니다.

이 클래스가 제대로 동작하려면 다음을 호출해 옵저버를 등록해야 합니다.

```dart
FlameAudio.bgm.initialize();
```

**중요 참고:** `initialize` 함수는 `WidgetsBinding` 클래스의 인스턴스가 이미 존재하는 시점에
호출해야 합니다. 이 호출은 게임의 `onLoad` 메서드 안에 두는 것이
가장 좋습니다.

배경 음악 사용은 끝났지만 애플리케이션/게임은 계속 실행하고 싶은 경우에는
`dispose` 함수를 사용해 옵저버를 제거합니다.

```dart
FlameAudio.bgm.dispose();
```

반복되는 배경 음악 트랙을 재생하려면 다음을 실행합니다.

```dart
import 'package:flame_audio/flame_audio.dart';

FlameAudio.bgm.play('assets/audio/adventure-track.mp3');
```

[Flame Audio 문서](audio.md)에서 설명한 것처럼 적절한 폴더 구조를 갖추고 `pubspec.yaml` 파일에
파일을 추가해야 합니다.


<a id="caching-music-files"></a>

## 음악 파일 캐싱

`Bgm` 클래스는 기본적으로 캐시된 음악 파일을 저장하는 데 `FlameAudio`의 정적 인스턴스를
사용합니다.

따라서 음악을 미리 로드하려면
[Flame Audio 문서](audio.md)의 권장 사항을 그대로 따르면 됩니다.

원한다면 서로 다른 `AudioCache`를 사용하는 `Bgm` 인스턴스를 직접
만들 수도 있습니다.


<a id="methods"></a>

## 메서드


<a id="play"></a>

### 재생

`play` 함수는 재생할 음악 파일의 위치를 가리키는 경로인 `String`을 받습니다
(Flame Audio 폴더 구조 요구 사항을 따릅니다).

선택적인 `double` 파라미터인 `volume`을 추가로 전달할 수 있습니다(기본값은 `1.0`).

예시:

```dart
FlameAudio.bgm.play('assets/audio/music/boss-fight/level-382.mp3');
```

```dart
FlameAudio.bgm.play('assets/audio/music/world-map.mp3', volume: .25);
```


<a id="stop"></a>

### 정지

현재 재생 중인 배경 음악 트랙을 정지하려면 `stop`을 호출하면 됩니다.

```dart
FlameAudio.bgm.stop();
```


<a id="pause-and-resume"></a>

### 일시 정지와 재개

배경 음악을 수동으로 일시 정지하고 재개하려면 `pause`와 `resume` 함수를 사용할 수 있습니다.

`FlameAudio.bgm`은 현재 재생 중인 배경 음악 트랙의 일시 정지와 재개를 자동으로 처리합니다.
수동으로 일시 정지(`pausing`)하면 앱/게임에 다시 포커스가 돌아왔을 때 자동으로 재개되지
않습니다.

```dart
FlameAudio.bgm.pause();
```

```dart
FlameAudio.bgm.resume();
```
