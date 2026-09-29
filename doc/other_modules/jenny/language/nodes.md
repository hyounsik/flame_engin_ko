<a id="nodes"></a>

# 노드

**노드**는 NPC와의 단일 대화나 상호작용을 나타내는 작은 텍스트 구역입니다. 각 노드에는
**제목(title)**이 있으며, 이 제목은 [DialogueRunner]에서 해당 노드를 *실행*하거나 다른 노드에서
해당 노드로 [점프][jump]하는 데 사용할 수 있습니다.

노드는 일반 프로그래밍 언어의 함수와 같다고 생각할 수 있습니다. 노드를 실행하는 것은 함수를
호출하는 것과 같으며, 노드/함수의 중간에서 실행을 시작할 수는 없습니다. 함수가 너무 커지면
보통 여러 개의 작은 함수로 나누고 싶어지는데, 노드도 마찬가지입니다. 노드가 너무 길어지면
여러 개의 작은 노드로 나누는 것이 좋습니다.

각 노드는 **헤더**와 **본문**으로 이루어집니다. 헤더와 본문은 대시 3개(이상)로 구분하며,
본문은 "=" 기호 3개로 끝납니다.
```yarn
// NODE HEADER
---
// NODE BODY
===
```

또한 대시 3개(이상)를 사용해 헤더를 앞의 내용과 구분할 수도 있으므로, 다음도 유효한 노드입니다.
```yarn
---------------
// NODE HEADER
---------------
// NODE BODY
===
```

**노드**는 Jenny 런타임에서 [Node] 클래스로 표현됩니다.

[Node]: ../runtime/node.md


<a id="header"></a>

## 헤더

노드의 헤더는 `TAG: CONTENT` 형식의 줄 하나 이상으로 이루어집니다. 이 줄 중 하나에는 노드의 이름인
**title**이 반드시 들어 있어야 합니다.
```yarn
title: NodeName
```

노드의 title은 유효한 ID여야 합니다(즉, 문자로 시작하고 그 뒤에 문자, 숫자, 밑줄이 몇 개든 올 수
있습니다). 한 프로젝트 안의 모든 노드는 고유한 title을 가져야 합니다.

title 외에도 노드 헤더에 추가 태그를 몇 개든 넣을 수 있습니다. Jenny는 이 태그들을 노드의
메타데이터와 함께 저장하지만, 그 외의 방식으로는 해석하지 않습니다. 이후 프로그래밍 방식으로
이 태그들에 접근할 수 있습니다.
```yarn
title: Alert
colorID: 0
modal: true
---
WARNING\: Entering Radioactive Zone!
===
```


<a id="body"></a>

## 본문

노드의 본문은 대화 자체가 들어 있는 곳입니다. 본문은 문장(statement)의 나열일 뿐이며, 각 문장은
[줄][Line], [옵션][Option], [명령][Command] 중 하나입니다. 예를 들면 다음과 같습니다.
```yarn
title: Gloomy_Morning
camera_zoom: 2
---
You  : Good morning!
Guard: You call this good? 'Tis as crappy as could be
You  : Why, what happened?
Guard: Don't you see the fog? Chills me through to the bones
You  : Sorry to hear that... 
You  : So, can I pass?
Guard: Can I get some exercise cutting you into pieces? Maybe that'll warm me up!
You  : Ok, I think I'll be going. Hope you feel better soon!
===
```

[DialogueRunner]: ../runtime/dialogue_runner.md
[jump]: commands/jump.md
[Line]: lines.md
[Option]: options.md
[Command]: commands/commands.md
