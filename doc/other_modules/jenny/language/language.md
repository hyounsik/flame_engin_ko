<a id="yarnspinner-language"></a>

# YarnSpinner 언어

**YarnSpinner**는 `.yarn` 파일을 작성하는 언어입니다. YarnSpinner 언어에 대해서는
[공식 문서][official documentation]를 확인할 수 있지만, 여기서는 **Jenny** 구현을 설명합니다.
Jenny 구현에는 원래 기능이 모두 포함되어 있지 않을 수도 있지만, 반대로 YarnSpinner에 아직
구현되지 않은 기능이 포함되어 있을 수도 있습니다.


<a id="yarn-files"></a>

## Yarn 파일

모든 Yarn 프로젝트에는 하나 이상의 `.yarn` 파일이 있습니다. 이 파일들은 UTF-8 인코딩의 일반 텍스트
파일입니다. 따라서 어떤 텍스트 편집기나 IDE에서든 편집할 수 있습니다.

`.yarn` 파일을 여러 개 두면 프로젝트를 더 잘 정리할 수 있지만, Jenny는 파일의 개수나 파일 간의
관계에 대해 어떤 요구 사항도 두지 않습니다.

각 `.yarn` 파일에는 **주석**, **태그**, **[명령][commands]**, **[노드][nodes]**가 들어갈 수 있습니다.
예를 들면 다음과 같습니다.
```yarn
// This is a comment
// The line below, however, is a tag:
# Chapter 1d

<<declare $visited_graveyard = false>>
<<declare $money = 25>>  // is this too much?

title: Start
---
// Node content
===
```


<a id="comments"></a>

### 주석

주석은 `//`로 시작하여 줄의 끝까지 이어집니다. 주석 안의 모든 텍스트는 마치 존재하지 않는 것처럼
Jenny가 완전히 무시합니다.

YarnSpinner에는 여러 줄 주석이 없습니다.


<a id="tags"></a>

### 태그

파일 수준 태그는 `#`으로 시작하여 줄의 끝까지 이어집니다. 태그는 파일별 커스텀 프로젝트 메타데이터를
포함하는 데 사용할 수 있습니다. 이 태그들은 Jenny가 어떤 방식으로도 해석하지 않습니다.


<a id="commands"></a>

### 명령

명령은 [뒤에서][commands] 더 자세히 설명하지만, 여기서 짚고 넘어갈 점은 파일의 루트 수준
(즉, 노드 바깥)에서는 제한된 수의 명령만 허용된다는 것입니다. 현재 허용되는 명령은 다음과 같습니다.

- `<<declare>>`
- `<<character>>`

노드 바깥의 명령은 컴파일 타임 명령어입니다. 즉, YarnProject를 컴파일하는 동안 실행됩니다.


<a id="nodes"></a>

### 노드

노드는 yarn 파일 콘텐츠의 대부분을 차지하며, 별도의 [섹션][nodes]에서 설명합니다. 하나의 파일에
여러 노드를 차례로 배치할 수 있습니다. 노드 사이에는 특별한 구분자가 필요 없습니다. 한 노드가
끝나면 곧바로 다음 노드가 시작될 수 있습니다.


```{toctree}
:hidden:

노드         <nodes.md>
줄           <lines.md>
옵션         <options.md>
명령         <commands/commands.md>
표현식       <expressions/expressions.md>
마크업       <markup.md>
```

[commands]: commands/commands.md
[nodes]: nodes.md
[official documentation]: https://docs.yarnspinner.dev/getting-started/writing-in-yarn
