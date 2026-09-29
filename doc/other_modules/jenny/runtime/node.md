# Node

**Node** 클래스는 `.yarn` 스크립트 안의 [노드][node] 하나를 나타냅니다. 이 클래스의 객체는
`onNodeStart()`, `onNodeFinish()` 메서드를 통해 [DialogueView]에 전달됩니다.


<a id="properties"></a>

## 속성

**title** `String`
: 노드의 title(이름)입니다.

**tags** `Map<String, String>`
: 노드 헤더에 지정된 추가 태그입니다. 필수 `title` 태그 외에 다른 태그가 없으면 맵은 비어 있습니다.

**iterator** `Iterator<DialogueEntry>`
: 노드의 내용으로, `DialogueLine`, `DialogueChoice`, `Command`의 시퀀스입니다.

[node]: ../language/nodes.md
[DialogueView]: dialogue_view.md
