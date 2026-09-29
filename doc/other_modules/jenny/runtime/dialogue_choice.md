# DialogueChoice

**DialogueChoice** 클래스는 `.yarn` 스크립트의 여러 [옵션][Option] 줄을 나타내며, 이 줄들은 사용자에게
표시되어 대화를 어떻게 진행할지 선택하게 합니다. `DialogueChoice` 객체는 `onChoiceStart()` 메서드를 통해
`DialogueView`에 전달됩니다.


<a id="properties"></a>

## 속성

**options** `List<DialogueOption>`
: 이 선택 세트를 구성하는 [DialogueOption]의 목록입니다.


[Option]: ../language/options.md
[DialogueOption]: dialogue_option.md
