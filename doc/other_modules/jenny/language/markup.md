<!-- cSpell:ignore lorem ipsum dolor sit amet, consectetur adipiscing elit -->
<!-- cSpell:ignore Malfoy -->

<a id="markup"></a>

# 마크업

**마크업**은 대화 줄의 일부분에 주석(annotation)을 다는 메커니즘입니다. HTML 태그와 다소 비슷하며,
구글 문서의 댓글 같은 것이라고 상상해도 됩니다. 중요한 점은 마크업 태그가 텍스트에 주석을 달 뿐,
게임에서 텍스트의 내용이나 표시 방식을 바꾸지는 않는다는 것입니다. 마크업 정보를 게임에서 실제로
활용하는 것은 개발자의 몫입니다.


<a id="syntax"></a>

## 문법

마크업 태그는 대괄호 안에 태그 이름을 넣어 나타냅니다: `[tag_name]`. 이에 대응하는 닫는 태그는
`[/tag_name]`입니다. 모든 마크업 태그에는 대응하는 닫는 태그가 있어야 합니다.
```yarn
Hello, [wavy]world[/wavy]!
```

마크업 태그는 서로 중첩될 수 있지만 올바르게 중첩되어야 합니다. 즉, 한 마크업 범위는 다른 범위의
완전히 안쪽이나 완전히 바깥쪽에 있어야 합니다.
```yarn
Lorem [S]ipsum dolor [A]sit[/A] amet[/S], consectetur [B]adipiscing[/B] elit
```

특별한 **close-all** 마크업 태그 `[/]`는 현재 열려 있는 모든 마크업 범위를 닫습니다. 마크업 태그의
이름이 길어서 반복하고 싶지 않을 때도 편리합니다.
```yarn
Lorem ipsum dolor sit amet, [bold]consectetur adipiscing elit[/]
```

**자체 닫힘(self-closing)** 마크업 태그는 `[tag_name/]` 형식을 가집니다. 이 태그는 텍스트 안의
한 위치를 표시합니다. 또한 이런 태그의 양쪽에 공백이 있으면, 결과 텍스트에서 태그 뒤의 공백 하나가
제거됩니다. 이를 원하지 않는다면 마크업 태그 뒤에 공백을 하나 더 추가하면 됩니다.
```yarn
Lorem ipsum dolor sit amet, [wave/] consectetur adipiscing elit.
```

마크업 태그는 HTML 태그 속성과 비슷한 파라미터도 받습니다. 파라미터의 이름은 임의의 ID일 수 있고,
값은 줄이 실행될 때마다 평가되는 표현식입니다. 따라서 속성 값은 동적일 수 있습니다.
```yarn
Lorem ipsum [color name=$color]dolor sit amet[/color]
```

마크업 태그는 동적 텍스트(보간 표현식)를 감쌀 수 있으며, 이 경우 줄이 실행될 때마다 마크업된
구간의 길이가 달라집니다. 반면 마크업을 동적으로 생성할 수는 없습니다. 즉, 보간 표현식은 대괄호로
감싼 텍스트를 포함하더라도 항상 그대로 삽입됩니다.
```yarn
Hello, [b]{$player}[/b]!
```

마지막으로, 줄 안에 실제로 대괄호로 감싼 텍스트를 넣고 싶다면, 마크업으로 파싱되지 않도록
대괄호를 백슬래시 `\`로 이스케이프할 수 있습니다.
```yarn
Hello, \[world\]!
```

```{seealso}
- [MarkupAttribute](../runtime/markup_attribute.md): 줄 안의 마크업 속성에 대한
  런타임 표현입니다.
```


<a id="examples"></a>

## 예제


<a id="mark-a-piece-of-text-with-a-different-style"></a>

### 텍스트 일부를 다른 스타일로 표시하기

이 예제에서 "Voldemort"라는 단어는 특별한 "cursed" 마크업으로 렌더링되어, 그 단어 자체가 저주받았음을
나타냅니다(게임에서 실제로 어떻게 렌더링할지는 여러분에게 달려 있습니다). 마찬가지로 두 번째 줄의
"stupid"라는 단어에는 강조가 적용되어 있으며, 이탤릭체로 렌더링할 수 있습니다.
```yarn
title: Scene117_Harry_MrMalfoy
---
Harry: I'm not afraid of [cursed]Voldemort[/cursed]!
MrMalfoy: You must be really brave... or really [i]stupid[/i]?
===
```


<a id="provide-additional-information-about-a-text-fragment"></a>

### 텍스트 조각에 대한 추가 정보 제공하기

이 예제에서 "Llewellyn"이라는 단어에는 툴팁 정보가 연결되어 있습니다. 게임에서는 이 단어를 특별한
스타일로 렌더링하여, 사용자가 단어 위에 마우스를 올리면 이 NPC를 어디서 찾을 수 있는지 보여 주는
미니맵이 담긴 툴팁을 볼 수 있음을 암시할 수 있습니다.
```yarn
title: MonkDialogue
---
Monk: Visit [tooltip place="TS" x=23 y=-74]Llewellyn[/] in Thunderstorm, \
      he will be able to help you.
===
```


<a id="indicate-where-special-non-text-tokens-may-be-inserted"></a>

### 특별한 비텍스트 토큰이 삽입될 위치 표시하기

`[item/]` 마크업 태그는 아이템의 이름으로 대체되며, 이 이름은 인터랙티브하게 동작합니다.
이름을 탭하면 아이템의 설명 카드가 표시됩니다.
```yarn
title: BlacksmithQuest
---
<<local $reward = if($chapter==1, "A0325", "A1018")>>
Smith: Find me my lost ring, and I'll give you this [item id=$reward/].
===
```
