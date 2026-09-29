# DialogueOption

**DialogueOption** 클래스는 `.yarn` 스크립트의 [옵션][Option] 줄 하나를 나타냅니다. 여러 옵션은
[DialogueChoice] 객체로 묶입니다.


<a id="properties"></a>

## 속성

**text** `String`
: 인라인 표현식을 평가하고, 마크업을 제거하고, 이스케이프 시퀀스를 처리한 뒤 계산된 옵션의 텍스트입니다.

**tags** `List<String>`
: 이 옵션의 해시태그 목록입니다. 해시태그가 없으면 목록은 비어 있습니다. 목록의 각 항목은 `#`으로
  시작하는 단순한 문자열입니다.

**attributes** `List<MarkupAttribute>`
: 옵션에 연결된 마크업 구간의 목록입니다. 각 [MarkupAttribute]는 **text** 안에서 마크업 태그로 구분된
  하나의 구간에 해당합니다.

**isAvailable** `bool`
: 이 옵션의 *조건문*을 평가한 결과입니다. 옵션에 조건문이 없으면 `true`를 반환합니다.

**isDisabled** `bool`
: `!isAvailable`과 같습니다.


[Option]: ../language/options.md
[DialogueChoice]: dialogue_choice.md
