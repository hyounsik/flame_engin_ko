<a id="writing-tests"></a>

# 테스트 작성하기

- 가능한 한 모든 새 기능은 테스트되어야 합니다. 버그를 수정할 때는 그 버그가 앞으로 다시
  나타나지 않도록 테스트를 추가해야 합니다.

- `melos run coverage`를 실행하면 모든 테스트를 "coverage" 모드로 실행합니다. 결과는
  `coverage/index.html` 파일에 저장되며, 브라우저에서 열어 볼 수 있습니다. 새로 추가하는 기능은
  100% 커버리지를 달성하도록 노력하세요.

- 모든 소스 파일에는 `_test` 접미사가 붙은 대응하는 테스트 파일이 있어야 합니다. 예를 들어
  `SpookyEffect`를 만들고 있고 소스 파일이 `src/effects/spooky_effect.dart`라면, 테스트 파일은
  소스 디렉터리 구조를 그대로 따라 `test/effects/spooky_effect_test.dart`가 되어야 합니다.

- 테스트 파일에는 `main()` 함수가 있어야 하며, 그 안에 테스트 대상 클래스의 이름과 같은 이름을 가진
  `group()`이 하나 있어야 합니다. 소스 파일에 public 클래스가 여러 개 있다면 각 클래스마다
  고유한 그룹이 있어야 합니다. 예를 들면 다음과 같습니다.

  ```dart
  void main() {
    group('SpookyEffect', () {
      // 여기에 테스트 작성
    });
  }
  ```

- 규모가 큰 클래스라면 최상위 그룹 안에 여러 그룹을 만들어 테스트 모음을 더 쉽게 탐색할 수 있게
  할 수 있습니다. 중첩된 그룹의 이름은 대문자로 시작해야 합니다.

- 개별 테스트의 이름은 보통 소문자로 시작해야 합니다.

- 테스트를 실행하기 위해 여러 헬퍼 클래스를 정의해야 하는 경우가 많습니다. 이런 클래스는
  private(밑줄로 시작)이어야 하며, 파일의 끝에 두어야 합니다. 그 이유는 어떤 테스트가 깨졌을 때
  가장 먼저 해야 할 일이 테스트 파일로 가서 모든 테스트를 실행하는 것이기 때문입니다.
  `main()` 함수가 파일의 맨 위에 있으면 이 과정이 훨씬 쉬워집니다.


<a id="types-of-tests"></a>

## 테스트의 종류


<a id="simple-tests"></a>

### 단순 테스트

```dart
test('the name of the test', () {
  expect(...);
});
```

사용할 수 있는 가장 단순한 종류의 테스트이며, 가장 빠르기도 합니다. Flame 프레임워크의 나머지 부분과
독립적으로 동작할 수 있는 클래스/메서드를 검사할 때 이 테스트를 사용하세요.


<a id="flamegame-tests"></a>

### FlameGame 테스트

테스트 안에 `FlameGame` 인스턴스를 두고 컴포넌트를 추가하여 다양한 동작을 검증하고 싶은 경우가
매우 흔합니다. 다음 방식을 권장합니다.

```dart
testWithFlameGame('the name of the test', (game) async {
  game.add(...);
  await game.ready();

  expect(...);
});
```

여기서 테스트 본문에 전달되는 `game` 인스턴스는 완전히 초기화된 게임으로, `GameWidget`에 마운트된
것처럼 동작합니다. `game.ready()` 메서드는 예약된 모든 컴포넌트가 로드되고 컴포넌트 트리에
마운트될 때까지 기다립니다.

`game` 안의 시간은 `game.update(dt)`로 진행시킬 수 있습니다.

이 테스트 안에서 커스텀 게임(예를 들어 어떤 믹스인이 적용된 게임)이 필요하다면 다음을 사용합니다.

```dart
testWithGame<_MyGame>(
  'the name of the test',
  _MyGame.new,
  (game) async {
    // 테스트 본문...
  },
);
```


<a id="widget-tests"></a>

### 위젯 테스트

때로는 "맨" `FlameGame`만으로는 부족하고 Flutter 인프라에도 접근하고 싶을 수 있습니다.
즉, 실제 Flutter 프레임워크에 포함된 진짜 `GameWidget`에 게임을 마운트하고 싶은 경우입니다.
이런 경우에는 다음을 사용합니다.

```dart
testWidgets('test name', (tester) async {
  final game = _MyGame();
  await tester.pumpWidget(GameWidget(game: game));
  await tester.pump();
  await tester.pump();

  // 이 시점에서 게임은 완전히 초기화되었으며, 게임에 대해 검사를
  // 실행할 수 있습니다.
  expect(...);

  // game.update(0)과 동일
  await tester.pump();

  // 게임 내 시간을 20밀리초만큼 진행
  await tester.pump(const Duration(milliseconds: 20));
});
```

`tester` 컨트롤러에는 탭, 드래그, 키 입력 등을 시뮬레이션하기 위한 추가 메서드도 있습니다.


<a id="golden-tests"></a>

### 골든 테스트

이 테스트는 무언가가 의도한 대로 렌더링되는지 검증합니다. 골든 테스트를 만드는 과정은
간단합니다.

1. 다음 템플릿을 사용하여 테스트를 작성합니다.

   ```dart
   testGolden(
     'the name of the test',
     (game) async {
        // 필요한 컴포넌트를 추가하여 게임을 설정합니다
        // 원한다면 여기에 `expect()` 검사도 추가할 수 있습니다
     },
     size: Vector2(300, 200),
     goldenFile: '.../_goldens/my_test_file.png',
   );
   ```

   여기서 `size` 파라미터는 게임 캔버스와 출력 이미지의 크기를 결정합니다. `goldenFile` 파라미터는
   "골든" 결과를 저장할 파일의 이름입니다. 이 값은 테스트 파일을 기준으로 한 `test/_goldens`
   디렉터리의 상대 경로여야 합니다.

2. 다음을 실행합니다.

   ```shell
   flutter test --update-goldens
   ```

   그러면 골든 파일이 처음으로 생성됩니다. 파일을 열어 의도한 대로 정확히 렌더링되는지 확인하세요.
   그렇지 않다면 파일을 삭제하고 1단계로 돌아갑니다.

3. 이후 `flutter test`를 실행하면 골든 테스트의 출력이 저장된 골든 파일과 일치하는지 검사합니다.
   일치하지 않으면 Flutter는 테스트가 있는 위치의 `failures/` 디렉터리에 이미지 차이(image-diff)
   파일을 저장합니다.

```{note}
골든 테스트에서는 텍스트 사용을 피하세요. 폰트 차이와 안티앨리어싱 알고리즘의 차이 때문에
플랫폼마다 안정적으로 렌더링되지 않습니다.
```


<a id="random-tests"></a>

### 랜덤 테스트

난수 생성기를 사용해 무작위 입력을 만든 다음 그 정확성을 검사하는 테스트입니다.
다음과 같이 사용합니다.

```dart
testRandom('test name', (Random random) {
  // [random]을 사용해 무작위 입력을 생성합니다
});
```

`repeatCount: 1000` 파라미터를 추가하면 지정한 횟수만큼 매번 다른 시드로 이 테스트를 실행합니다.
테스트를 개발하는 동안에는 테스트가 깨지지 않는지 확인하기 위해 `repeatCount`를 높게 설정해
실행하는 것이 유용합니다. 하지만 메인 저장소에 테스트를 제출할 때는 repeatCount를 10보다
높게 설정하지 마세요.

테스트가 특정 시드에서 깨지면 그 시드가 테스트 출력에 표시됩니다. 그 값을 테스트에
`seed: NNN` 파라미터로 추가하면, 테스트가 고쳐질 때까지 필요한 만큼 같은 시드로 실행할 수 있습니다.
코드를 제출할 때는 `seed:` 파라미터를 남겨 두지 마세요. 테스트를 무작위화하는 의미가 없어지기 때문입니다.

코드를 건드리지 않고도 컴파일 타임 define으로 시드를 전달하여 전체 테스트 실행의 시드를
고정할 수도 있습니다.

```bash
flutter test --dart-define=RANDOM_SEED=1234
```

그러면 모든 무작위 테스트가 그 시드에서 시작하며, 테스트의 각 반복은 반복 인덱스만큼 시드를
오프셋하여 반복마다 서로 다른 값을 유지합니다. flutter/tests 고객 테스트 실행은 이 방식을 사용해
결정론적으로 동작합니다.
