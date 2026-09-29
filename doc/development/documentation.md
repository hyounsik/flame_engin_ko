<a id="documentation-site"></a>

# 문서 사이트

Flame의 문서는 **Markdown**으로 작성됩니다. 작성된 문서는 [Sphinx] 엔진과 그 [MyST] 플러그인의
도움을 받아 HTML로 렌더링됩니다. 렌더링된 파일은 (스크립트의 도움을 받지만) 수동으로
[flame-docs-site]에 게시되며, 사이트는 [GitHub Pages]를 통해 제공됩니다.

[Sphinx]: https://www.sphinx-doc.org/en/master/
[MyST]: https://myst-parser.readthedocs.io/en/latest/
[flame-docs-site]: https://github.com/flame-engine/flame-docs-site
[GitHub Pages]: https://pages.github.com/


## Markdown

메인 문서 사이트는 Markdown으로 작성됩니다. 여러분이 Markdown 문법의 기초에 이미 익숙하다고
가정합니다(그렇지 않다면 인터넷에 가이드가 많이 있습니다). 대신 이 섹션에서는 우리 빌드 시스템에서
활성화된 Markdown 확장 기능에 초점을 맞춥니다.


<a id="table-of-contents"></a>

## 목차

사이트의 목차는 직접 만들어야 합니다. 이는 하위 디렉터리마다 하나씩 있는 특별한 `{toctree}`
블록을 사용하여 이루어집니다.

`````markdown
```{toctree}
:hidden:

First Topic    <relative_path/to_topic1.md>
Second Topic   <topic2.md>
```
`````

문서 사이트에 새 문서를 추가할 때는 반드시 toctree 중 하나에 포함되도록 하세요. 그렇지 않으면
빌드 중에 문서가 고아(orphaned) 상태라는 경고가 표시됩니다.


<a id="admonitions"></a>

## 애드모니션

애드모니션(admonition)은 독특한 모양으로 강조된 텍스트 블록입니다. 백틱 세 개 문법을 사용하여
만듭니다.

`````markdown
```{note}
Please note this very important caveat.
```
```{warning}
Don't look down, or you will encounter an error.
```
```{error}
I told you so.
```
```{seealso}
Also check out this cool thingy.
```
`````

```{note}
이 매우 중요한 주의 사항에 유의하세요.
```

```{warning}
아래를 보지 마세요. 그러면 오류를 만나게 됩니다.
```

```{error}
그러게 내가 뭐랬어요.
```

```{seealso}
이 멋진 것도 확인해 보세요.
```


<a id="deprecations"></a>

## 지원 중단

특별한 `{deprecated}` 블록을 사용하면 문서나 문법의 일부를 지원 중단(deprecated)된 것으로
표시할 수 있습니다. 이 블록에는 지원 중단이 발생한 버전을 지정해야 합니다.

`````markdown
```{deprecated} v1.3.0

Please use this **other** thing instead.
```
`````

이는 다음과 같이 렌더링됩니다.

```{deprecated} v1.3.0

대신 이 **다른** 것을 사용하세요.
```


<a id="live-examples"></a>

## 라이브 예제

우리 문서 사이트에는 직접 만든 **flutter-app** 지시문이 있어, Flutter 위젯을 만들어 문서 내용과
함께 삽입할 수 있습니다.

Markdown에서 임베드를 삽입하는 코드는 다음과 같습니다.

`````markdown
```{flutter-app}
:sources: ../flame/examples
:page: tap_events
:show: widget code popup
:width: 180
:height: 160
```
``````

각 옵션의 의미는 다음과 같습니다.

- **sources**: 실행하려는 Flutter 코드가 있는 루트 디렉터리의 이름을 지정합니다. 이 디렉터리는
  Flutter 저장소여야 하며, 그 안에 `pubspec.yaml` 파일이 있어야 합니다. 경로는 `doc/_sphinx`
  디렉터리를 기준으로 한 상대 경로로 간주됩니다.

- **page**: `sources`로 지정한 루트 디렉터리 안의 하위 경로입니다. 이 옵션에는 두 가지 효과가 있습니다.
  첫째, `main.dart.html?$page`처럼 위젯 html 페이지의 경로 뒤에 덧붙여집니다.
  둘째, 임베드의 소스 코드를 보여 주는 버튼이 `page`로 지정한 이름의 파일이나 디렉터리의 코드를
  표시합니다.

  이 옵션의 목적은 여러 예제를 하나의 실행 파일로 묶을 수 있게 하는 것입니다.
  이 옵션을 사용할 때는 앱의 `main.dart` 파일이 전달된 `page`에 따라 알맞은 위젯으로 실행을
  라우팅해야 합니다.

- **show**: `widget`, `code`, `infobox`, `popup` 모드 중 일부를 포함합니다. `widget` 모드는
  페이지 안에 직접 예제를 임베드한 iframe을 만듭니다. `code` 모드는 이 예제를 만든 코드를
  사용자가 볼 수 있게 하는 버튼을 표시합니다. `popup` 모드도 버튼을 표시하며, 이 버튼은 예제를
  오버레이 창에 표시합니다. 이 방식은 더 큰 앱을 시연할 때 더 적합합니다. "widget"과 "popup"
  모드를 동시에 사용하는 것은 권장하지 않습니다. 마지막으로 `infobox` 모드는 결과를 떠 있는 창에
  표시합니다. 이 모드는 `widget`, `code`와 함께 사용하는 것이 가장 좋습니다.

- **width**: 임베드된 애플리케이션의 너비를 정의하는 정수입니다. 정의하지 않으면
  너비는 100%가 됩니다.

- **height**: 임베드된 애플리케이션의 높이를 정의하는 정수입니다. 정의하지 않으면
  높이는 350px가 됩니다.

```{flutter-app}
:sources: ../flame/examples
:page: tap_events
:show: widget code popup
```


<a id="standardization-and-templates"></a>

## 표준화와 템플릿

문서에 추가되는 모든 섹션이나 패키지에는 명명 규칙, 디렉터리 구조, 표준화된 목차가 중요합니다.
모든 섹션과 패키지는 왼쪽 사이드바 메뉴에서 논리적 순서나 알파벳 순서로 탐색할 수 있도록
목차를 가지거나 부모 markdown 파일에 항목이 있어야 합니다. 또한 정리를 위해 다음과 같은
명명 규칙을 따라야 합니다.

- bridge_packages/package_name/package_name.md
- documentation_section/documentation_section.md

```{note}
문서 경로에 공백이 들어가지 않도록 하세요.
[이 버그](https://github.com/ipython/ipython/pull/13765) 때문에
프로젝트를 빌드할 수 없게 됩니다.
```


<a id="building-documentation-locally"></a>

## 로컬에서 문서 빌드하기

자신의 컴퓨터에서 문서 사이트를 빌드하는 것은 꽤 간단합니다. 필요한 것은 다음과 같습니다.

1. 명령줄에서 사용할 수 있는, 정상적으로 설치된 **Flutter**.

2. [기여하기][contributing] 가이드에 따른 **Melos** 명령줄 도구.

3. python 3.8 이상의 **Python** 환경. 전용 python 가상 환경을 두는 것을 권장하지만
   필수는 아닙니다.

4. 다음 명령을 사용하여 나머지 요구 사항을 설치합니다.

   ```shell
   melos run doc-setup
   ```

이 전제 조건들이 갖춰지면 내장 Melos 타깃을 사용해 문서를 빌드할 수 있습니다.

```shell
melos doc-build
```

여기서 **melos doc-build** 명령은 문서 사이트를 HTML로 렌더링합니다. 이 명령은 문서를 변경할
때마다 다시 실행해야 합니다. 다행히 이전 실행 이후 변경된 문서만 다시 빌드할 만큼 똑똑하기
때문에, 보통 다시 빌드하는 데는 1~2초밖에 걸리지 않습니다.

파일 중 하나가 변경될 때마다 문서를 자동으로 다시 컴파일하고 싶다면 아래의 내장 Melos 타깃을
사용하면 됩니다. 이 타깃은 문서를 서빙하고 기본 브라우저로 문서를 열어 주기도 합니다.

```shell
melos doc-serve
```

**melos doc-serve** 명령을 사용할 때는 sphinx 테마에 변경이 있을 때만 **melos doc-build**가
필요합니다. serve 명령이 변경 시 문서를 자동으로 컴파일하고 로컬에서 호스팅까지 하기 때문입니다.
문서는 기본적으로 `http://localhost:8000/`에서 제공됩니다.

가끔 유용하게 쓸 수 있는 다른 make 명령도 있습니다.

- **melos doc-clean**은 캐시된 생성 파일을 모두 제거합니다(시스템이 잘못된 상태에 빠진 경우를
대비).
- **melos doc-linkcheck**는 문서에 깨진 링크가 있는지 검사합니다.
- **melos doc-kill**은 8000번 포트에서 실행 중인 고아 TCP 스레드를 모두 제거합니다.

생성된 html 파일은 `doc/_build/html` 디렉터리에 있으며, 브라우저에서 `doc/_build/html/index.html`
파일을 열어 직접 볼 수 있습니다. 유일한 단점은 브라우저가 로컬 드라이브에서 연 파일에서는
동적 콘텐츠를 허용하지 않는다는 점입니다. 해결 방법은 **melos doc-serve**를 실행하는 것입니다.

**melos doc-clean** 명령을 실행했다면 서버를 다시 시작해야 합니다. clean 명령이 `html`
디렉터리 전체를 삭제하기 때문입니다.

```{note}
문서 경로에 공백이 들어가지 않도록 하세요.
[이 버그](https://github.com/ipython/ipython/pull/13765) 때문에
프로젝트를 빌드할 수 없게 됩니다.
```


[contributing]: contributing.md#environment-setup
