<a id="miscellaneous-functions"></a>

# 기타 함수


## if(condition, then, else)

이 함수는 삼항 if 조건을 구현하며, Dart의 `?:` 연산자에 해당합니다.

이 함수는 `condition`(불리언이어야 함)을 평가한 다음, 조건이 `true`이면 `then`의 값을, `false`이면
`else`의 값을 반환합니다. 인자 `then`과 `else`의 타입은 같아야 합니다.

참고: `condition`에 따라 `then`/`else` 값 중 하나만 평가됩니다. 이는 해당 표현식을 평가할 때 부수 효과가
생길 수 있는 경우에 중요할 수 있습니다.
```yarn
title: Birth
---
Doctor: Congratulations, you have a { if($gender == "m", "boy", "girl") }!
===
```


## plural(x, words...)

변수 `x`의 값에 따라 올바른 복수형을 반환합니다.

이 함수는 로케일에 따라 달라지며, `YarnProject`의 `locale` 속성에 따라 구현과 시그니처가 바뀝니다.
모든 경우에 첫 번째 인자 `x`는 숫자여야 하고, 나머지 인자는 모두 문자열이어야 합니다.

이 함수의 목적은 현재 언어의 규칙에 맞는 올바른 복수형 문구를 만드는 것입니다. 예를 들어 `$n`이 변수일 때
`{$n} items`라고 말해야 한다고 해 보겠습니다. 변수 값을 그대로 끼워 넣으면 "23 items"나 "1 items" 같은
문구가 만들어지는데, 이는 원하는 결과가 아닙니다. 대신 `plural()` 함수를 사용하면 "item"이라는 단어의
올바른 복수형을 선택해 줍니다.
```yarn
I have {plural($n, "% item")}.
```

영어 로케일(`en`)에서 `plural()` 함수는 숫자 `$x` 뒤에 1개 또는 2개의 `word`를 받습니다. 첫 번째 단어는
단수형이고, 두 번째 단어는 복수형입니다. 단수형이 충분히 단순해서 `-s`나 `-es`를 붙여 복수형을 만들 수
있다면 두 번째 단어는 생략할 수 있습니다. 예를 들면 다음과 같습니다.
```yarn
// Here "foot" is an irregular noun, so its plural form must be specified
// explicitly. At the same time, "inch" is regular, and the function
// plural() will know to add "es" to make its plural form.
The distance is {plural($ft, "% foot", "% feet")} and {plural($in, "% inch")}.
```

영어 외의 로케일에서는 복수형 단어의 개수가 1개에서 3개까지 될 수 있습니다. 보통 첫 번째 단어는
단수형이고, 나머지는 서로 다른 복수형이며, 그 의미는 언어마다 다릅니다. 예를 들어 우크라이나어
로케일(`uk`)에서 `plural()` 함수는 단수형, "few" 복수형, "many" 복수형의 3개 단어를 요구합니다.

<!--- cSpell:ignore мене монета монети монет -->
```yarn
// Assuming locale == 'uk'
У мене є {plural($coins, "% монета", "% монети", "% монет")}.

// Produces phrases like this:
//   У мене є 21 монета
//   У мене є 23 монети
//   У мене є 25 монет
```

위의 모든 예제에서 단어에 `%` 기호가 들어 있다는 점에 주목하세요. 이는 숫자 자체가 들어갈 자리를
나타내는 플레이스홀더로 사용됩니다. `words` 중 일부(또는 전부)에 `%` 기호가 없어도 괜찮습니다.


## visit_count(node)

`node`를 방문한 횟수를 반환합니다.

대화가 노드에 들어갔다가 나오면 그 노드는 "방문한" 것으로 간주됩니다. 노드에서는 일반적인 대화 흐름을
통해 나오거나 [\<\<stop\>\>] 명령으로 나올 수 있습니다. 하지만 노드를 실행하는 도중 런타임 예외가
발생하면 방문으로 집계되지 않습니다.

`node` 인자는 문자열이어야 하며, 유효한 노드 이름을 담고 있어야 합니다. 주어진 이름의 노드가 프로젝트에
없으면 예외가 발생합니다.
```yarn
title: LuckyWheel
---
<<if visit_count("LuckyWheel") < 5>>
  Clown: Would you like to spin a wheel and get fabulous prizes?
  -> I sure do!
     <<jump SpinLuckyWheel>>
  -> I don't talk to strangers...
     <<stop>>
<<else>>
  Clown: Sorry kid, we're all out of prizes for now.
<<endif>>
===
```

```{seealso}
- [`visited(node)`](#visitednode)
```


## visited(node)

주어진 title을 가진 노드를 방문했으면 `true`를, 그렇지 않으면 `false`를 반환합니다.

노드가 "방문한" 것으로 간주되려면 대화가 그 노드에 적어도 한 번 들어갔다가 나와야 합니다. 예를 들어
노드 "X" 안에서 표현식 `visited("X")`는 이 노드를 처음 실행하는 동안에는 `false`를 반환하고, 이후의
모든 실행에서는 `true`를 반환합니다.

`node` 인자는 문자열이어야 하며, 유효한 노드 이름을 담고 있어야 합니다. 주어진 이름의 노드가 프로젝트에
없으면 예외가 발생합니다.
```yarn
title: MerchantDialogue
---
<<if not visited("MerchantDialogue")>>
  // This part of the dialogue will run only during the first interaction
  // with the merchant.
  Merchant: Greetings! My name is Linn.
  Merchant: I offer exquisite wares for the most fastidious customers!
  Player: Hi. I'm Bob. I like stuff.
<<endif>>
...
===
```

```{seealso}
- [`visit_count(node)`](#visit_countnode)
```


[\<\<stop\>\>]: ../../commands/stop.md
