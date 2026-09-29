<a id="lines"></a>

# 줄

**줄(line)**은 Yarn 대화에서 가장 흔한 요소입니다. 게임 속 캐릭터가 말하는 하나의 대사일 뿐입니다.
`.yarn` 파일에서 **줄**은 [노드 본문][node body]의 텍스트 한 줄로 표현됩니다. 줄에는 다음 요소가
들어갈 수 있습니다.

- 캐릭터 ID
- 일반 텍스트
- 이스케이프된 텍스트
- 보간 표현식
- 마크업
- 해시태그
- 줄 끝의 주석
- (단, 줄에는 명령을 넣을 수 없습니다.)

**줄**은 Jenny 런타임에서 [DialogueLine] 클래스로 표현됩니다.


<a id="character-id"></a>

## 캐릭터 ID

줄이 한 단어와 그 뒤의 `:`로 시작하면, 그 단어는 해당 줄을 말하는 캐릭터의 이름으로 간주됩니다.
다음 예제에서는 Prosser와 Ford라는 두 캐릭터가 서로 대화하고 있으며, 마지막 줄에는 캐릭터 ID가
없습니다.
```yarn
title: Bulldozer_Conversation
---
Prosser: You want me to come and lie there...
Ford: Yes
Prosser: In front of the bulldozer?
Ford: Yes
Prosser: In the mud.
Ford: In, as you say, the mud.
(low rumbling noise...)
===
```

캐릭터 ID는 반드시 유효한 ID여야 한다는 점을 강조할 필요가 있습니다. 즉, 공백이나 다른 특수 문자를
포함할 수 없습니다. 아래 예제에서 "Harry Potter"는 유효한 캐릭터 ID가 아니지만, 나머지는 모두
괜찮습니다.
```yarn
title: Hello
---
Harry Potter: Hello, Hermione!
Harry_Potter: Hello, Hermione!
HarryPotter: Hello, Hermione!
Harry: Hello, Hermione!
===
```

`WORD + ':'`로 시작하는 줄을 쓰고 싶지만 그 단어가 캐릭터 이름으로 해석되기를 원하지 않는다면,
콜론을 [이스케이프](#이스케이프된-텍스트)할 수 있습니다.
```yarn
title: Warning
---
Attention\: The cake is NOT a lie
===
```

```{note}
모든 캐릭터는 스크립트에서 사용하기 전에 [\<\<character\>\>] 명령으로
**선언**해야 합니다.
```


<a id="interpolated-expressions"></a>

## 보간 표현식

**보간 표현식(interpolated expression)**을 사용하면 줄에 동적인 텍스트를 삽입할 수 있습니다.
이 표현식은 중괄호 `{}`로 감싸며, 중괄호 안의 모든 내용이 평가된 뒤 평가 결과가 텍스트에
삽입됩니다.
```yarn
title: Greeting
---
Trader: Hello, {$player_name}! Would you like to see my wares?
Player: I have only {plural($money, "% coin")}, do you have anything I can afford?
===
```

표현식은 줄이 전달되는 런타임에 평가되므로, 같은 줄이라도 실행할 때마다 다른 텍스트를 만들 수
있습니다.
```yarn
title: Exam_Greeting
---
<<if $n_attempts == 0>>
  Professor: Welcome to the exam!
  <<jump Exam>>
<<elseif $n_attempts < 5>>
  Professor: You have tried {plural($n_attempts, "% time")} already, but I \
             can give you another try.
  <<jump Exam>>
<<else>>
  Professor: You've failed 5 times in a row! How is this even possible?
<<endif>> 
===
```

평가가 끝나면 표현식의 텍스트는 추가 처리 없이 그대로 줄에 삽입됩니다. 즉, 표현식의 텍스트에는
특수 문자(`[`, `]`, `{`, `}`, `\` 등)가 들어 있을 수 있으며, 이를 이스케이프할 필요가 없습니다.
또한 표현식은 마크업을 포함하거나 해시태그를 만들어 낼 수 없다는 뜻이기도 합니다.

표현식에 대한 자세한 내용은 [표현식][Expressions] 섹션을 참고하세요.


<a id="markup"></a>

## 마크업

**마크업**은 텍스트 주석(annotation)을 위한 메커니즘입니다. HTML 태그와 다소 비슷하지만,
꺾쇠괄호 대신 대괄호 `[]`를 사용합니다.
```yarn
title: Markup
---
Wizard: No, no, no! [em]This is insanity![/em]
===
```

마크업 태그는 줄의 텍스트를 바꾸지 않으며, 단지 텍스트에 주석을 삽입할 뿐입니다. 따라서 위의 줄은
게임에서 "No, no, no! This is insanity!"로 전달되지만, 마지막 17개 문자가 `em` 태그로 표시되었다는
추가 정보가 줄에 함께 붙어 있습니다.

마크업 태그는 중첩될 수도 있고 너비가 0일 수도 있으며, 값이 동적일 수 있는 파라미터를 포함할 수도
있습니다. 자세한 내용은 [마크업][Markup] 문서를 참고하세요.


<a id="hashtags"></a>

## 해시태그

해시태그는 줄의 끝에 올 수 있으며 `#text` 형식을 가집니다. 즉, 해시태그는 `#` 기호 뒤에 공백을
포함하지 않는 임의의 텍스트가 오는 것입니다.

해시태그는 줄 수준의 메타데이터를 추가하는 데 사용됩니다. 해시태그 뒤에는 줄 내용이 올 수
없습니다(주석은 허용됩니다). 한 줄에 여러 해시태그를 연결할 수 있습니다.

<!-- cSpell:ignore HPMOR (Harry Potter and the Methods of Rationality) -->
```yarn
title: Hashtags
---
Harry: There is no justice in the laws of Nature, Headmaster, no term for \
       fairness in the equations of motion. #sad // HPMOR.39
Harry: The universe is neither evil, nor good, it simply does not care.
Harry: The stars don't care, or the Sun, or the sky.
Harry: But they don't have to! We care! #elated #volume:+1
Harry: There is light in the world, and it is us! #volume:+2
===
```

대부분의 경우 Jenny 엔진은 태그를 해석하지 않고 줄 정보의 일부로 저장만 합니다. 런타임에 이 태그들을
살펴보는 것은 프로그래머의 몫입니다.


<a id="escaped-text"></a>

## 이스케이프된 텍스트

줄에 넣어야 하는 문자가 원래는 위에서 언급한 특수 문법 중 하나로 해석되는 문자라면, 그 문자를
백슬래시 `\`로 **이스케이프**할 수 있습니다.

인식되는 이스케이프 시퀀스는 다음과 같습니다: `\\`, `\/`, `\#`, `\<`, `\>`, `\[`, `\]`, `\{`, `\}`,
`\:`, `\-`, `\n`. 또한 `\⏎`(즉, 백슬래시 바로 뒤에 줄바꿈이 오는 것)도 있습니다.
```yarn
title: Escapes
---
\// This is not a comment  // but this is
This is not a \#hashtag
This is not a \<<command>>
\{This line\} does not contain an expression
Not a \[markup\]
===
```

`\⏎` 이스케이프를 사용하면 하나의 긴 줄을 여러 물리적 줄로 나누면서도, Jenny가 여전히 한 줄처럼
처리하게 할 수 있습니다. 이 이스케이프 시퀀스는 줄바꿈 기호와 다음 줄 시작 부분의 공백을
모두 소비합니다.
```yarn
title: One_long_line
---
This line is so long that it becomes uncomfortable to read in a text editor. \
    Therefore, we use the backslash-newline escape sequence to split it into \
    several physical lines. The indentation at the start of the continuation \
    lines is for convenience only, and will be removed from the resulting \
    text.
===
```


[node body]: nodes.md#body
[DialogueLine]: ../runtime/dialogue_line.md
[Expressions]: expressions/expressions.md
[Markup]: markup.md
