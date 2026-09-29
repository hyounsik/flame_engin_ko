# `<<declare>>`

**\<\<declare\>\>** 명령은 새 전역 변수를 만들고 초기값을 할당합니다. 이 명령을 만난 이후에는,
선언된 변수를 인라인 표현식, 다른 명령, 심지어 다른 declare 문을 포함해 변수가 필요한 곳 어디서든
사용할 수 있습니다.

대부분의 다른 명령과 달리 `<<declare>>` 명령은 컴파일 타임, 즉 yarn 스크립트를 파싱할 때 실행됩니다.
대화가 실행될 때는 변수가 이미 초기화되어 사용할 준비가 되어 있으므로 아무 효과가 없습니다.
이런 이유로 `<<declare>>` 명령은 노드 바깥, 스크립트의 루트 수준에 두어야 하며, 이를 통해 이 명령이
노드가 실행될 때 실행되지 않는다는 점을 분명히 합니다.

예를 들면 다음과 같습니다.
```yarn
<<declare $monicker = "boy">>

---------------
title: Greeting
---------------
Teacher: Welcome to the class, {$monicker}!
===
```

여기서 `<<declare>>` 명령은 `String` 타입의 `$monicker`라는 새 변수를 도입하고 초기값으로 `"boy"`를
할당합니다. 이후 이 변수는 "Greeting" 노드 안에서 사용됩니다. 그 시점에 변수의 값은 무엇이든 될 수
있습니다. 다른 노드에서 바뀌었을 수도 있고, 게임 자체가 바꾸었을 수도 있습니다. 하지만
`<<declare>>` 문은 이것이 유효한 변수 이름이며 어떤 타입인지를 Jenny에게 알려 주기 위해 필요합니다.

프로젝트 구성 관점에서 권장하는 방법은 모든 `<<declare>>` 문을 별도의 파일에 넣고, 이 yarn 파일이
가장 먼저 파싱되도록 하는 것입니다. 그러면 모든 전역 변수가 이후 노드에서 사용되기 전에 선언된다는
것이 보장됩니다.

게임이 세이브 기능을 지원한다면 yarn 전역 변수의 값도 저장하고 싶을 것입니다. 이 경우 저장된 값의
복원은 모든 yarn 스크립트가 파싱된 *후에* 해야 합니다(그렇지 않으면 엔진은 변수가 두 번 선언되었다고
판단합니다).


<a id="syntax"></a>

## 문법

`<<declare>>` 문에는 여러 형태가 있습니다. 가장 흔한 형태는 다음과 같습니다.
```yarn
<<declare $VARIABLE = EXPRESSION>>
```

여기서 `$VARIABLE`은 선언하는 변수의 이름이고(Yarn의 모든 변수는 `$` 기호로 시작합니다),
`EXPRESSION`은 리터럴이거나, 변수의 초기값을 제공하기 위해 컴파일 타임에 평가되는 더 복잡한
[표현식][expression]입니다. 변수의 타입은 `EXPRESSION`의 타입으로부터 추론됩니다.

`<<declare>>` 명령에 사용할 수 있는 또 다른 문법은 다음과 같습니다.
```yarn
<<declare $VARIABLE as TYPE>>
```

여기서 `TYPE`은 `Bool`, `Number`, `String` 중 하나입니다. 이렇게 하면 주어진 타입의 변수가 만들어지고,
각각 `false`, `0`, `""` 값으로 초기화됩니다.

마지막으로 이 두 문법을 결합할 수도 있습니다.
```yarn
<<declare $VARIABLE = EXPRESSION as TYPE>>
```

이 방법은 `EXPRESSION`의 타입이 바로 드러나지 않아 선언을 더 명시적으로 만들고 싶을 때 유용합니다.
컴파일러는 `EXPRESSION`의 타입이 `TYPE`과 같은지 확인하며, 그렇지 않으면 컴파일 타임 오류를
발생시킵니다.


<a id="examples"></a>

## 예제
```yarn
<<declare $prefix = "Mr.">>
<<declare $gold = 100>>
<<declare $been_to_hell = false>>

<<declare $name as String>>
<<declare $distanceTraveled as Number>>

<<declare $birthDay = randomRange(1, 365) as Number>>
<<declare $vulgarity = GetObscenitySetting() as Bool>>
```

:::{note}
클래스의 public 멤버를 문서화하는 것처럼, 각 `<<declare>>`에 변수의 목적을 설명하는 문서 주석을
함께 다는 것이 좋습니다.
:::


[expression]: ../expressions/expressions.md
