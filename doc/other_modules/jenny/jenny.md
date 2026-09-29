<!-- cSpell:ignore Slughorn horcrux horcruxes Moste Potente -->

# Jenny

**jenny** 라이브러리는 게임에 *대화*를 추가하기 위한 도구 모음입니다. 대화는 사용자가 제어하는
상호작용, 분기, 동적으로 생성되는 콘텐츠, 명령, 마크업, Jenny 또는 게임에서 제어하는 상태,
커스텀 함수와 명령 등을 포함하여 상당히 복잡해질 수 있습니다.
`jenny` 라이브러리는 Unity용 [Yarn Spinner] 라이브러리의 비공식 포팅입니다. 라이브러리 이름은
실을 잣는 기계의 일종인 [spinning jenny]에서 따왔습니다.

게임에 대화를 추가하는 작업은 일반적으로 두 단계로 이루어집니다.

1. 대화 텍스트 작성하기
2. 게임 안에서 대화를 인터랙티브하게 표시하기

`jenny`에서는 이 두 작업이 완전히 분리되어 있어, 게임 콘텐츠 제작과 게임 엔진 개발을
서로 독립적으로 진행할 수 있습니다.

[Yarn Spinner]: https://docs.yarnspinner.dev/
[spinning jenny]: https://en.wikipedia.org/wiki/Spinning_jenny


<a id="writing-dialogue"></a>

## 대화 작성하기

`jenny`에서 대화는 일반 텍스트로 작성되며, 게임에 에셋으로 추가되는 `.yarn` 파일에 저장됩니다.
`.yarn` 파일 형식은 [Yarn Spinner]의 제작자들이 개발했으며, 대화를 작성하기 위해 특별히 설계되었습니다.

가장 단순한 형태의 yarn 대화는 희곡처럼 보입니다.
```yarn
title: Scene1_Gregory_and_Sampson
---
Sampson: Gregory, on my word, we'll not carry coals.
Gregory: No, for then we should be colliers.
Sampson: I mean, an we be in choler, we'll draw.
Gregory: Ay, while you live, draw your neck out of collar.
Sampson: I strike quickly being moved.
Gregory: But thou art not quickly moved to strike.
===
```

이 간단한 대화를 게임 안에서 렌더링하면, 두 캐릭터가 번갈아 말하는 대사의 연속으로 표시됩니다.
`DialogRunner`를 사용하면 대화가 자동으로 진행될지, 사용자가 "클릭하며 넘겨야" 할지를
제어할 수 있습니다.

`.yarn` 형식은 이 외에도 훨씬 고급 기능을 많이 지원합니다. 대화를 비선형적으로 진행하거나,
변수와 조건부 실행을 지원하거나, 플레이어가 응답을 선택할 수 있게 하는 등의 기능입니다.
무엇보다도 이 형식은 매우 직관적이어서 따로 배우지 않아도 대체로 이해할 수 있습니다.
```yarn
title: Slughorn_encounter
---
<<if visited("Horcrux_question")>>
  Slughorn: Sorry, Tom, I don't have time right now.
  <<stop>>
<<endif>>

Slughorn: Oh hello, Tom, is there anything I can help you with?
Tom: Good {time_of_day()}, Professor.
-> I was curious about the 12 uses of the dragon blood.
    Slughorn: Such an inquisitive mind! You can read about that in the "Moste \
              Potente Potions" in the Restricted Section of the library.
    <<give restricted_library_pass>>
    Tom: Thank you, Professor, this is very munificent of you.
-> I wanted to ask... about Horcruxes <<if $knows_about_horcruxes>>
    <<jump Horcrux_question>>
-> I just wanted to say how much I always admire your lectures.
    Slughorn: Thank you, Tom. I do enjoy flattery, even if it is well-deserved.
===

title: Horcrux_question
---
Slughorn: Where... did you hear that?
-> Tom: It was mentioned in an old book in the library...
    Slughorn: I see that you have read more books from the Restricted Section \
              than is wise.
    Slughorn: I'm sorry, Tom, I should have seen you'd be tempted...
    <<take restricted_library_pass>>
    -> But Professor!..
        Slughorn: This is for your good, Tom. Many of those books are dangerous!
        Slughorn: Now off you go. And do your best to forget about what you \
                  asked...
        <<stop>>
-> Tom: I overheard it... And the word felt sharp and frigid, like it was the \
   embodiment of Dark Art <<if luck() >= 80>>
    Slughorn: It is a very Dark Art indeed, it is not good for you to know \
              about it...
    Tom: But if I don't know about this Dark Art, how can I defend myself \
         against it?
    Slughorn: It is a Ritual, one of the darkest known to wizard-kind ...
    ...
    <<achievement "The Darkest Secret">>
===
```

이 코드 조각은 `.yarn` 언어의 다음과 같은 여러 기능을 보여 줍니다.

- 텍스트를 *노드*라고 부르는 더 작은 덩어리로 나누는 기능
- `<<if>>`나 `<<jump>>` 같은 명령으로 대화의 흐름을 제어하는 기능
- 플레이어의 선택에 따라 달라지는 대화 경로
- 특정 메뉴 선택지를 동적으로 비활성화하는 기능
- 상태 정보를 변수에 보관하는 기능
- 사용자 정의 함수(`time_of_day`, `luck`)와 명령(`<<give>>`, `<<take>>`)

자세한 내용은 [Yarn 언어](language/language.md) 섹션을 참고하세요.


<a id="using-the-dialogue-in-a-game"></a>

## 게임에서 대화 사용하기

`jenny` 라이브러리 자체는 어떤 게임 엔진과도 통합되지 않습니다. 하지만 그런 통합을 만드는 데
사용할 수 있는 런타임을 제공합니다. 이 런타임은 다음 구성 요소로 이루어집니다.

- [`YarnProject`](runtime/yarn_project.md) -- 모든 yarn 스크립트, 변수, 커스텀 함수와 명령,
  설정 등을 알고 있는 중앙 정보 저장소입니다.
- [`DialogueRunner`](runtime/dialogue_runner.md) -- 특정 대화 노드를 실행할 수 있는 실행기입니다.
  이 실행기는 대화 줄을 하나 이상의 `DialogueView`로 보냅니다.
- [`DialogueView`](runtime/dialogue_view.md) -- 대화가 최종 사용자에게 어떻게 표시될지를 설명하는
  추상 인터페이스입니다. 이 인터페이스를 구현하는 것이 `jenny`를 특정 환경에 통합하는 주된
  방법입니다.


```{toctree}
:hidden:

YarnSpinner 언어      <language/language.md>
Jenny API             <runtime/jenny_runtime.md>
```
