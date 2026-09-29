# MarkupAttribute

**MarkupAttribute**는 [줄][line] 안에서 마크업 태그로 구분된 텍스트 하위 범위에 대한 디스크립터입니다.
예를 들어 아래의 `.yarn` 줄에는 마크업 태그로 감싼 텍스트 범위가 두 개 있으므로, 이 줄에는
`MarkupAttribute` 두 개가 연결됩니다.
```yarn
[b]Jenny[/b] is a library based on \
    [link url="docs.yarnspinner.dev"]YarnSpinner[/link] for Unity.
```

이 `MarkupAttribute`들은 [DialogueLine][line]의 `.attributes` 속성에서 찾을 수 있습니다.


<a id="properties"></a>

## 속성

**name** `String`
: 마크업 태그의 이름입니다. 위 예제에서 첫 번째 속성의 이름은 `"b"`이고, 두 번째는 `"link"`입니다.

**start**, **end** `int`
: 줄의 최종 텍스트 안에서 마크업된 구간의 위치입니다. 첫 번째 인덱스는 포함이고 두 번째 인덱스는
  제외입니다. 너비가 0인 마크업 속성의 경우 `start`와 `end`가 같을 수 있습니다.

**length** `int`
: 마크업된 텍스트의 길이입니다. 항상 `end - start`와 같습니다.

**parameters** `Map<String, dynamic>`
: 이 마크업 속성에 연결된 파라미터 집합입니다. 위 예제에서 첫 번째 마크업 속성에는 파라미터가 없으므로
  이 맵은 비어 있습니다. 두 번째 마크업 속성에는 파라미터가 하나 있으므로, 이 맵은
  `{"url": "docs.yarnspinner.dev"}`와 같습니다.

  각 파라미터의 타입은 `.yarn` 스크립트에서 주어진 표현식의 타입에 따라 `String`, `num`, `bool` 중
  하나입니다. 파라미터 값의 표현식은 동적일 수 있습니다. 즉, 런타임에 평가될 수 있습니다. 아래 예제에서
  파라미터 `color`는 변수 `$color`의 값과 같으며, 이 값은 줄이 실행될 때마다 바뀔 수 있습니다.
  ```yarn
  My [i]favorite[/i] color is [bb color=$color]{$color}[/bb].
  ```

[line]: dialogue_line.md
