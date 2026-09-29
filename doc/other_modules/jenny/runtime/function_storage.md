# FunctionStorage

**FunctionStorage**는 모든 [사용자 정의 함수][user-defined functions]를 저장하는 역할을 하는
[YarnProject]의 일부입니다. `YarnProject.functions` 속성으로 접근할 수 있습니다.

함수 저장소를 사용하면 커스텀 함수를 몇 개든 등록하여 yarn 스크립트에서 사용할 수 있게 만들 수 있습니다.
이런 함수는 yarn 스크립트를 파싱하기 전에 등록해야 하며, 그렇지 않으면 컴파일러가 함수 이름을 인식할 수
없다는 오류를 발생시킵니다.

Dart 함수가 다음 요구 사항을 충족하면 Jenny의 사용자 정의 함수로 등록할 수 있습니다.

- 반환 타입이 `int`, `double`, `num`, `bool`, `String` 중 하나여야 합니다.
- 모든 인자가 위치 인자여야 합니다. 즉, 이름 있는 인자가 없어야 합니다.
- 모든 인자의 타입이 `int`, `int?`, `double`, `double?`, `num`, `num?`, `bool`, `bool?`,
  `String`, `String?` 중 하나여야 합니다.
- null을 허용하는 인자가 있다면 null을 허용하지 않는 인자들 뒤에 와야 합니다. 이런 인자는 Yarn
  스크립트에서 선택 사항이 되며, 제공되지 않으면 `null` 값으로 전달됩니다.
- 함수의 첫 번째 인자는 `YarnProject`일 수도 있습니다. 이런 인자가 있으면 자동으로 전달됩니다. 예를 들어
  `fn(YarnProject, int)` 함수가 있다면 yarn 스크립트에서 간단히 `fn(1)`로 호출할 수 있습니다.

그런 다음 함수의 인자 개수에 따라 `addFunction0`, ..., `addFunction4` 메서드 중 하나를 사용해 Dart 함수를
추가할 수 있습니다(이는 Dart 템플릿 언어의 제약입니다). 함수를 등록할 때는 Yarn 스크립트에서 이 함수를
부를 `name`을 지정합니다. 이 이름은 실제 함수 이름과 같을 수도 있고 다를 수도 있습니다. 예를 들어
게임에 `hasVisitedTheWizard()` 함수가 있지만, YarnProject에는 `has_visited_the_wizard()`라는 이름으로
등록할 수 있습니다.

사용자 정의 함수의 이름은 다음 조건을 만족해야 한다는 점을 기억하세요.

- 고유해야 합니다.
- 유효한 ID여야 합니다.
- 어떤 내장 함수와도 같을 수 없습니다.


<a id="methods"></a>

## 메서드

**hasFunction**(`String name`) → `bool`
: 함수 `name`이 이미 등록되었는지 여부를 반환합니다.

**addFunction0**(`String name`, `T0 Function() fn`)
: 인자가 없는 함수 `fn`을 사용자 정의 함수 `name`으로 등록합니다.

**addFunction1**(`String name`, `T0 Function(T1) fn1`)
: 인자가 하나인 함수 `fn1`을 `name`이라는 이름으로 등록합니다.

**addFunction2**(`String name`, `T0 Function(T1, T2) fn2`)
: 인자가 두 개인 함수 `fn2`를 주어진 `name`으로 등록합니다.

**addFunction3**(`String name`, `T0 Function(T1, T2, T3) fn3`)
: 인자가 세 개인 함수 `fn3`을 `name`이라는 이름으로 등록합니다.

**addFunction4**(`String name`, `T0 Function(T1, T2, T3, T4) fn4`)
: 인자가 네 개인 함수 `fn4`를 `name`으로 등록합니다.

**clear**
: 모든 사용자 정의 함수를 제거합니다.

**remove**(`String name`)
: 지정한 `name`의 사용자 정의 함수를 제거합니다.


<a id="properties"></a>

## 속성

**length** → `int`
: 지금까지 등록된 사용자 정의 함수의 개수입니다.

**isEmpty** → `bool`
: 등록된 사용자 정의 함수가 없으면 `true`를 반환합니다.

**isNotEmpty** → `bool`
: 등록된 함수가 하나라도 있는지 여부입니다.


[user-defined functions]: ../language/expressions/functions/functions.md#user-defined-functions
