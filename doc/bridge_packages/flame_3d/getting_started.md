<a id="getting-started"></a>

# 시작하기

이 패키지를 사용해 보기 전에 알아 두어야 할 몇 가지 중요한 사항이 있습니다.

GPU 기반 3D 지원은 아직 실험 단계인
[Flutter GPU](https://github.com/flutter/flutter/wiki/Flutter-GPU)에 의존하며, Flutter GPU는 다시
Impeller에 의존합니다. 이는 다음을 의미합니다.

- **Flutter GPU**와 **Impeller**가 아직 실험 단계이므로 이 패키지도 실험적인 것으로 간주되며
  언제든 호환성이 깨지는 변경이 있을 수 있습니다.
- 지금까지 지원 여부를 명시적으로 테스트한 플랫폼은 Android, iOS, macOS뿐입니다.
- 기본적으로 활성화되어 있지 않다면 Impeller를 활성화해야 합니다(아래 참고).


<a id="enabling-impeller"></a>

## Impeller 활성화하기

그다음, 기본적으로 활성화되어 있지 않다면 Impeller를 활성화해야 합니다. 예를 들어 macOS의 경우
생성된 `macos/runner/Info.plist` 디렉터리에 다음을 추가합니다.

```xml
<dict>
  ...
  <key>FLTEnableImpeller</key>
  <true/>
  <key>FLTEnableFlutterGPU</key>
  <true/>
</dict>
```

또는 대신 다음 플래그와 함께 Flutter를 실행할 수 있습니다.

```bash
flutter run --enable-flutter-gpu
```


<a id="playground--examples"></a>

## 플레이그라운드와 예제

`flame_3d` 사용법을 보여 주는 "플레이그라운드" 형식의 예제는 `packages/flame_3d/example`
디렉터리에서 찾을 수 있습니다. 여기에는 기본 제공 콘솔 명령으로 전환할 수 있는 여러 "setup"이 들어 있습니다.

아래에서 더 복잡한 예제 세 가지도 찾을 수 있습니다.

- [Defend the Donut](https://github.com/flame-engine/defend_the_donut/) - 거대한 우주 도넛이 등장하는
  간단한 1인칭 우주선 게임입니다.
- [Collect the Donut](https://github.com/luanpotter/collect_the_donut) - 로우 폴리 도적을 조종해
  스켈레톤을 공격하고 도넛을 모으는 간단한 3인칭 게임입니다.
- [Flutter & Friends 2025 Workshop](https://github.com/luanpotter/flutter_and_friends_slides) - Flutter & Friends
  2025에서 진행한 발표로, 여러 카메라 스타일을 설정하는 방법을 보여 주는 데모가
  포함되어 있습니다.
