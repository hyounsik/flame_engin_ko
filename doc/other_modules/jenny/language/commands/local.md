# `<<local>>`

**\<\<local\>\>** 명령은 현재 노드 안에서 새 변수를 만들고 시작 값으로 초기화합니다. 따라서
[\<\<declare\>\>][declare]와 비슷하지만, 만들어지는 변수가 하나의 노드 안에서만 보인다는 점이 다릅니다.

`<<local>>` 명령의 문법은 다음 중 하나입니다.
```yarn
<<local $VARIABLE = EXPRESSION>>
<<local $VARIABLE = EXPRESSION as TYPE>>
```

이렇게 하면 `$VARIABLE`이라는 이름의 변수가 만들어지고(YarnSpinner의 모든 변수는 `$` 기호로
시작합니다), `EXPRESSION`의 값이 할당됩니다. 두 번째 형태에서는 표현식의 타입이 `TYPE`과 같은지
확인하며, 그렇지 않으면 컴파일 타임 오류가 발생합니다. 따라서 두 번째 형태는 만들어지는 변수의
타입을 명시적으로 표기하는 역할을 합니다.

다음과 같은 제한이 적용됩니다.

- 각 지역 변수는 한 노드 안에서 한 번만 선언할 수 있습니다.
- 지역 변수의 이름은 어떤 전역 변수의 이름과도 같을 수 없습니다.


<a id="examples"></a>

## 예제

이 예제에서 `$roll` 변수는 이 노드 하나 안에서만 일시적으로 필요하므로, 전역으로 선언하는 것은
의미가 없습니다.
```yarn
title: a_dice_roll
---
<<local $roll = dice(6)>>
<<if $roll == 1>>
  You've rolled 1, rotten luck...
<<elseif $roll == 2>>
  You've rolled 2, which is still below the average. Try harder!
<<elseif $roll == 3>>
  You've rolled 3.14159265 (well, almost).
<<elseif $roll == 4>>
  Your roll is an unlucky number. Please roll again
<<else>>
  You've rolled 10 (when rounded to the nearest ten). Good job!
<<endif>>
===
```

[declare]: declare.md
