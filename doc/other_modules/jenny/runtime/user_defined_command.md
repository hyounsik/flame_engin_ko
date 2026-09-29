# UserDefinedCommand

**UserDefinedCommand** 클래스는 yarn 스크립트 안에서 커스텀(내장이 아닌) 명령이 한 번 호출되는 것을
나타냅니다. 이 타입의 객체는 [DialogueView]의 `.onCommand()` 메서드를 통해 전달됩니다.


<a id="properties"></a>

## 속성

**name** `String`
: 꺾쇠괄호를 제외한 명령의 이름입니다. 예를 들어 yarn 스크립트의 명령이 `<<smile>>`이라면 이름은
  `"smile"`입니다.

**argumentString** `String`
: 하나의 문자열로 된 명령 인자입니다. 예를 들어 명령이 `<<move Hippo {$delta}>>`이고 변수 `$delta`의 값이
  `3.17`이라면, 인자 문자열은 `"Hippo 3.17"`이 됩니다.

  `argumentString`은 명령이 실행될 때마다 다시 평가되지만, 대화 러너가 명령을 실행하기 전에 이 속성에
  접근하는 것은 오류입니다.

**arguments** `List<dynamic>?`
: 파싱된 값의 목록으로 된 명령 인자입니다. 명령이 시그니처 없이(즉, "orphaned command"로) 선언되었다면 이
  속성은 null입니다. 하지만 명령이 외부 함수에 연결되었다면, 목록의 인자 개수와 타입은 그 함수의 인자와
  일치합니다.

  위와 같은 예에서 연결된 Dart 함수가 `move(String target, double distance)`라면 `arguments`는
  `['Hippo', 3.17]`이 됩니다.


<a id="see-also"></a>

## 함께 보기

- YarnSpinner 언어의 [사용자 정의 명령][User-defined Commands]에 대한 설명.
- [CommandStorage] 문서에 있는, 새 커스텀 명령을 등록하는 방법에 대한 가이드.


[CommandStorage]: command_storage.md
[DialogueView]: dialogue_view.md
[User-defined Commands]: ../language/commands/user_defined_commands.md
