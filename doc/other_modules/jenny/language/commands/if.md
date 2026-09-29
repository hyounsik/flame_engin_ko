# `<<if>>`

**\<\<if\>\>** 명령은 조건을 평가하고, 그 결과에 따라 다음에 실행할 문장을 결정합니다. 대부분의
프로그래밍 언어의 `if` 키워드에 해당합니다. 이 명령은 여러 부분으로 이루어질 수 있으며, 다음과 같은
모양입니다.
```yarn
<<if condition1>>
  statements1...
<<elseif condition2>>
  statements2...
<<else>>
  statementsN...
<<endif>>
```

- 각 명령 안의 조건은 불리언 타입이어야 합니다.
- `<<elseif>>` 블록은 몇 개든 올 수 있습니다.
- `<<elseif>>` 블록과 `<<else>>`는 선택 사항입니다.
- 마지막의 `<<endif>>`는 필수입니다.
- 각 블록 안의 문장은 들여쓰기해야 합니다.

런타임에는 `if` 블록 안의 조건이 가장 먼저 평가됩니다. 그 결과가 `true`이면 대화는 `statements1`을
실행하며, 다른 조건은 평가되지 않고 다른 문장 블록도 실행되지 않습니다. 하지만 `condition1`이
`false`로 평가되면 `condition2`가 계산됩니다. 이 조건이 참이면 대화 러너는 `statements2`를 실행하고,
거짓이면 `else` 블록으로 넘어가 `statementsN`을 실행합니다. 마지막으로 대화는 마지막 `<<endif>>`
다음에 오는 문장으로 진행합니다.


<a id="example"></a>

## 예제

이 대화에서 *Guard*는 그 지역 주민들 사이에서의 평판에 따라 다르게 인사합니다. 평판이 −100 아래로
떨어지면 보자마자 공격당합니다.
```yarn
title: GuardGreeting
---
<<if $reputation >= 100>>
  Guard: Hail to the savior of the people!
<<elseif $reputation >= 30>>
  Guard: Nice to meet you, sir!
<<elseif $reputation >= 0>>
  Guard: Hello
<<elseif $reputation > -30>>
  Guard: I'm keeping an eye on you...
<<elseif $reputation > -100>>
  Guard: You filthy scum!
<<else>>
  Guard: You'll pay for your crimes! #auto
  <<attack>>
<<endif>>
===
```
