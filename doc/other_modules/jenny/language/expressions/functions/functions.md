<a id="functions"></a>

# 함수

YarnSpinner의 **함수**는 다른 프로그래밍 언어나 수학에서의 개념과 같습니다. 일정한 개수의 인자를 받아
결과를 계산하고 반환합니다. 함수 호출은 함수 이름과 그 뒤의 괄호 안 인자로 나타냅니다. 인자가 없더라도
괄호는 반드시 필요합니다.
```yarn
<<set $roll_2d6 = dice(6) + dice(6)>>
<<set $random = random()>>
```

Jenny에는 아래에 나열된 약 20개의 내장 함수가 있으며, 사용자 정의 함수를 추가할 수도 있습니다.


<a id="built-in-functions"></a>

## 내장 함수

- **난수 함수**
  - [`dice(n)`](random.md#dicen)
  - [`random()`](random.md#random)
  - [`random_range(a, b)`](random.md#random_rangea-b)

- **숫자 함수**
  - [`ceil(x)`](numeric.md#ceilx)
  - [`dec(x)`](numeric.md#decx)
  - [`decimal(x)`](numeric.md#decimalx)
  - [`floor(x)`](numeric.md#floorx)
  - [`inc(x)`](numeric.md#incx)
  - [`int(x)`](numeric.md#intx)
  - [`round(x)`](numeric.md#roundx)
  - [`round_places(x, n)`](numeric.md#round_placesx-n)

- **타입 변환 함수**
  - [`bool(x)`](type.md#boolx)
  - [`number(x)`](type.md#numberx)
  - [`string(x)`](type.md#stringx)

- **기타 함수**
  - [`if(condition, then, else)`](misc.md#ifcondition-then-else)
  - [`plural(x, ...)`](misc.md#pluralx-words)
  - [`visit_count(node)`](misc.md#visit_countnode)
  - [`visited(node)`](misc.md#visitednode)


<a id="user-defined-functions"></a>

## 사용자 정의 함수

내장 함수 외에도, 이후 yarn 스크립트에서 사용할 수 있는 **사용자 정의 함수**를 몇 개든 정의할 수
있습니다. 이 함수들의 문법은 내장 함수와 완전히 같습니다. 함수 이름과 그 뒤의 괄호 안 인자로
이루어집니다.

각 사용자 정의 함수에는 함수를 `YarnProject`에 추가할 때 선언되는 고정된 시그니처가 있습니다. 함수는
특정 타입의 고정된 개수의 인자와 고정된 반환 타입을 가져야 합니다.

모든 사용자 정의 함수는 사용하기 전에 `YarnProject`에 추가되어야 합니다. 파서가 알 수 없는 함수를
만나거나 인자의 개수나 타입이 맞지 않으면 컴파일 오류가 발생합니다.

사용자 정의 함수는 다음과 같은 다양한 목적으로 사용할 수 있습니다.

- 현재 Jenny에 없는 기능을 구현하기
- 게임 엔진과 연동하기
- Jenny 바깥에 저장된 "변수"에 접근할 수 있게 하기
- 기타 등등
```yarn
title: Blacksmith
---
// This example showcases several hypothetical user-defined functions:
// - broken(slot): checks whether the item in the given slot is broken;
// - name(slot): gives the name for an item in a slot, e.g. "sword" or "bow";
// - money(): returns the current amount of money that the player has.
// At the same time, functions `round()` and `plural()` are built-in.

<<if broken("main_hand")>>
  <<local $repair_cost = round(value("main_hand") / 5)>>

  Blacksmith: Your {name("main_hand")} seems to be completely broken!
  Blacksmith: I can fix it for just {plural($repair_cost, "% coin")}
  -> Ok, do it  <<if money() >= $repair_cost>>
  -> I'll be fine...
<<endif>>
===
```

```{seealso}
- [`FunctionStorage`](../../../runtime/function_storage.md) -- `YarnProject`에
  사용자 정의 함수를 추가하는 방법을 설명하는 문서입니다.
```


```{toctree}
:hidden:

난수 함수                 <random.md>
숫자 함수                 <numeric.md>
타입 변환 함수            <type.md>
기타 함수                 <misc.md>
```
