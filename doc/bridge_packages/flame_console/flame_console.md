# flame_console

Flame Console은 개발자가 게임을 디버깅하고 게임과 상호작용할 수 있게 해 주는 Flame 게임용 터미널
오버레이입니다.

`GameWidget`에 연결할 수 있는 오버레이를 제공하며, 활성화하면 Flutter 위젯으로 작성된 터미널 형태의
인터페이스가 표시됩니다. 이 인터페이스에서 명령을 실행해 실행 중인 게임과 컴포넌트에 대한 정보를 보거나
작업을 수행할 수 있습니다.

기본 제공 명령 세트가 포함되어 있으며, 커스텀 명령을 추가할 수도 있습니다.


<a id="usage"></a>

## 사용법

Flame Console은 오버레이이므로 사용하려면 게임 위젯에 등록해야 합니다.

그다음 오버레이를 언제 보여줄지는 여러분이 결정합니다. 아래는 누르면 콘솔을 보여주는 floating action
button 예제입니다.

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: GameWidget(
      game: _game,
      overlayBuilderMap: {
        'console': (BuildContext context, MyGame game) => FlameConsoleView(
              game: game,
              onClose: () {
                _game.overlays.remove('console');
              },
            ),
      },
    ),
    floatingActionButton: FloatingActionButton(
      heroTag: 'console_button',
      onPressed: () {
        _game.overlays.add('console');
      },
      child: const Icon(Icons.developer_mode),
    ),
  );
}
```


<a id="built-in-commands"></a>

## 기본 제공 명령

- `help` - 사용 가능한 명령과 사용법을 나열합니다.
- `ls` - 컴포넌트를 나열합니다.
- `rm` - 컴포넌트를 제거합니다.
- `debug` - 컴포넌트의 디버그 모드를 전환합니다.
- `pause` - 게임 루프를 일시 정지합니다.
- `resume` - 게임 루프를 재개합니다.


<a id="custom-commands"></a>

## 커스텀 명령

 커스텀 명령은 `FlameConsoleCommand` 클래스를 상속해 만들고, `ConsoleView` 위젯의
 `customCommands` 목록에 추가하면 됩니다.

 ```dart
class MyCustomCommand extends FlameConsoleCommand<MyGame> {
  @override
  String get name => 'my_command';

  @override
  String get description => 'Description of my command';

  // execute 메서드는 튜플을 반환해야 합니다. 첫 번째
  // 요소는 에러 메시지(실패한 경우)이고, 두 번째
  // 요소는 명령의 출력입니다.
  @override
  (String?, String) execute(MyGame game, ArgResults args) {
    // 게임에서 무언가를 수행합니다
    return (null, 'Hello World');
  }
}
```

그런 다음 `ConsoleView` 위젯을 만들 때 커스텀 명령을 `customCommands` 목록에 추가합니다.

```dart
ConsoleView(
  game: game,
  customCommands: [MyCustomCommand()],
  onClose: () {
    _game.overlays.remove('console');
  },
),
```


<a id="customizing-the-console-ui"></a>

## 콘솔 UI 커스터마이징

콘솔의 모양과 느낌도 커스터마이징할 수 있습니다. `ConsoleView` 위젯을 만들 때 커스터마이징에 사용할 수 있는
몇 가지 속성이 있습니다.

- `containerBuilder`: 기록과 명령 입력이 표시되는 꾸며진 컨테이너를 만드는 데
사용됩니다.
- `cursorBuilder`: 커서 위젯을 만드는 데 사용됩니다.
- `historyBuilder`: 기록의 스크롤 요소를 만드는 데 사용됩니다. 기본적으로는 단순한
`SingleChildScrollView`가 사용됩니다.
- `cursorColor`: 커서의 색상입니다. 커서의 색상만 바꾸고 싶을 때
사용할 수 있습니다.
- `textStyle`: 콘솔의 텍스트 스타일입니다.

