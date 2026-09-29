<a id="flame-style-guide"></a>

# Flame 스타일 가이드

이 문서는 Flame 및 관련 프로젝트에서 코드를 작성할 때 따르는 일반적인 스타일 가이드입니다. 우리는
코드를 깔끔하고 읽기 쉽게 유지하려고 노력합니다. 이는 특정 기능이 어떻게 동작하는지 이해하거나 문제가
생긴 부분을 디버깅하기 위해 이 코드를 살펴봐야 하는 사용자들을 위한 것이기도 하고,
현재와 미래의 메인테이너들을 위한 것이기도 합니다.

이 가이드는 공식 [Dart 스타일 가이드][effective dart]를 확장합니다. 먼저 그 문서를 꼭 읽어 주세요.
Dart 프로그래밍 실력을 분명히 높여 줄 것입니다.


<a id="code-formatting"></a>

## 코드 포매팅

대부분의 코드 포매팅 규칙은 린터를 통해 자동으로 강제됩니다. 다음 명령을 실행하여
코드가 규칙을 준수하는지 확인하고 간단한 포매팅 문제를 수정하세요.

```shell
flutter analyze
dart format .
```


<a id="code-structure"></a>

## 코드 구조


<a id="imports"></a>

### 임포트

- 여러 라이브러리에 정의된 외부 심볼을 사용하는 경우, 그중 가장 작은 라이브러리를 임포트하는 것을
  선호합니다. 예를 들어 `@protected` 같은 어노테이션은 `package:meta/meta.dart`를,
  `Canvas`는 `dart:ui`를 임포트하여 사용합니다.

- `package:flutter/cupertino.dart`나 `package:flutter/material.dart`는 절대 임포트하지 마세요.
  위젯을 다루는 경우라면 훨씬 작은 라이브러리인 `package:flutter/widgets.dart`를 사용하세요.


<a id="exports"></a>

### 익스포트

- 파일 하나에는 public 클래스를 하나만 두고, 파일 이름을 그 클래스 이름을 따서 짓는 것을 강력히
  권장합니다. 파일 안에 private 클래스를 여러 개 두는 것은 전혀 문제없습니다.

- 이 규칙의 예외가 될 수 있는 경우는 "메인" 클래스가 public이어야 하는 작은 "헬퍼" 클래스를
  필요로 할 때입니다. 또는 파일에 서로 관련된 아주 작은 클래스 여러 개가 들어 있는 경우입니다.

- 파일의 "메인" 클래스는 파일을 열자마자 바로 보이도록 파일의 시작 부분(임포트 섹션 바로 다음)에
  위치해야 합니다. typedef, 헬퍼 클래스, 함수를 포함한 다른 모든 정의는 메인 클래스 아래로
  옮겨야 합니다.

- 파일에 public 심볼이 여러 개 정의되어 있다면 `export ... show ...` 문을 사용하여 명시적으로
  익스포트해야 합니다. 예를 들면 다음과 같습니다.

  ```dart
  export 'src/effects/provider_interfaces.dart'
    show
      AnchorProvider,
      AngleProvider,
      PositionProvider,
      ScaleProvider,
      SizeProvider;
  ```


<a id="assertions"></a>

### 어서션

계약 위반이나 사전 조건/사후 조건 실패를 감지하려면 `assert`를 사용합니다. 하지만 때로는
예외를 사용하는 것이 더 적절할 수 있습니다. 다음과 같은 경험 법칙을 적용합니다.

- 개발자가 통제할 수 있는 조건을 확인할 때는 명확한 오류 메시지와 함께 assert를 사용합니다.
  예를 들어 `opacity` 수준을 입력으로 받는 컴포넌트를 만들 때는 값이 0에서 1 사이인지
  확인해야 합니다. 개발자가 오류를 더 쉽게 디버깅할 수 있도록 오류 메시지에 값 자체를
  포함하는 것도 고려하세요.

  ```dart
  assert(0 <= opacity && opacity <= 1, 'The opacity value must be from 0 to 1: $opacity');
  ```

  발생 가능한 위반을 감지하기 위해 assert는 항상 가능한 한 이른 시점에 사용합니다. 예를 들어
  `opacity`의 유효성은 render 함수가 아니라 생성자/setter에서 확인합니다.

  이러한 assert를 추가할 때는 assert가 실제로 발생하는지 확인하는 테스트도 함께 추가합니다.
  이 테스트는 컴포넌트가 잘못된 입력을 받아들이지 않는다는 것과, 오류 메시지가 예상한 내용과
  같다는 것을 검증합니다.

- 알고 있는 어떤 방법으로도 개발자가 발생시킬 수 없는 조건을 확인할 때는 오류 메시지 없이
  assert를 사용합니다. 이런 assert가 발생한다면 Flame 프레임워크의 버그를 의미합니다.

  이런 assert는 코드 안에 직접 들어 있는 "미니 테스트" 역할을 하며, 잘못된 내부 상태를 만들 수 있는
  향후 리팩터링으로부터 코드를 보호합니다. 이런 assert를 의도적으로 발생시키는 테스트는
  작성할 수 없어야 합니다.

- 개발자가 통제할 수 없을 수도 있는 조건(즉, 환경이나 사용자 입력에 따라 달라질 수 있는 조건)을
  검사할 때는 명시적인 if 검사와 예외를 사용합니다. assert와 예외 중 무엇을 사용할지 결정할 때는
  다음 질문을 생각해 보세요. 개발자가 자신의 쪽에서 충분히 테스트를 한 뒤에도 프로덕션에서
  해당 오류 조건이 발생할 수 있는가?


<a id="class-structure"></a>

### 클래스 구조

- 모든 클래스 생성자를 클래스의 맨 위에 두는 것을 고려하세요. 그러면 클래스를 어떻게 사용해야
  하는지 훨씬 쉽게 알 수 있습니다.

- 클래스 API를 가능한 한 많이 private으로 만들고, "혹시 몰라서" 멤버를 노출하지 마세요.
  그래야 나중에 호환성을 깨뜨리는 변경(breaking change) 없이 클래스를 수정/리팩터링하기가 훨씬 쉽습니다.

  모든 public 멤버를 문서화하는 것을 잊지 마세요! 문서화는 보기보다 어렵고, 문서화의 부담을
  줄이는 한 가지 방법은 가능한 한 많은 변수를 private으로 만드는 것입니다.

- 클래스가 `List<X>`나 `Vector2` 속성을 노출한다고 해서 마음대로 수정해도 된다는 뜻은
  **아닙니다**! 문서에서 수정해도 된다고 명시하지 않는 한, 이런 속성은 읽기 전용으로 생각하세요.

- 클래스가 충분히 커지면 코드 탐색과 접기를 돕는 *region*을 클래스 안에 추가하는 것을
  고려하세요(`//` 뒤에 공백이 없다는 점에 주의하세요).

  ```dart
  //#region Region description
  ...
  //#endregion
  ```

- 클래스에 getter/setter로 노출해야 하는 private 멤버가 있다면 다음과 같은 코드 구조를
  선호합니다.

  ```dart
  class MyClass {
    MyClass();

    ...
    int _variable;
    ...

    /// getter와 setter 모두에 대한 문서.
    int get variable => _variable;
    set variable(int value) {
      assert(value >= 0, 'variable must be non-negative: $value');
      _variable = value;
    }
  }
  ```

  이렇게 하면 모든 private 변수가 클래스 위쪽의 한 블록에 모이므로, 클래스가 어떤 데이터를
  가지고 있는지 빠르게 파악할 수 있습니다.


<a id="documentation"></a>

## 문서화

- 클래스, 메서드, 변수의 의미/목적을 설명할 때는 dartdoc `///`을 사용합니다.

- 특정 코드 조각의 구현 세부 사항을 설명할 때는 일반 주석 `//`을 사용합니다. 즉, 이런 주석은
  무언가가 어떻게(HOW) 동작하는지를 설명합니다.

- 기능에 대한 상위 수준의 개요, 특히 그 기능이 전체 Flame 프레임워크에 어떻게 들어맞는지는
  `doc/` 폴더의 마크다운 문서를 사용해 설명합니다.


### Dartdocs

- [Flutter 문서화 가이드][flutter documentation guide]를 확인하세요. 좋은 문서를 작성하는 데
  도움이 되는 훌륭한 조언이 많이 담겨 있습니다.
  - 다만 수동태로 작성하라는 조언은 무시하세요.

- 클래스 문서는 가급적 클래스 이름 자체로 시작하고, 다음과 같은 패턴을 따르는 것이 좋습니다.

  ```dart
  /// [MyClass] is ...
  /// [MyClass] serves as ...
  /// [MyClass] does the following ...
  ```

  이런 관례를 따르는 이유는 클래스 문서가 충분히 길어지는 경우가 많아서, 문서의 맨 위를 봤을 때
  정확히 무엇을 문서화하고 있는지 바로 알기 어려울 수 있기 때문입니다.

- 메서드 문서는 메서드 이름을 암묵적인 주어로 하여, 현재 단순 시제의 동사로 시작해야 합니다.
  첫 문장 뒤에는 문단을 나눕니다. 메서드 사용자에게 무엇이 불분명할 수 있을지 생각해 보고,
  사전 조건과 사후 조건이 있다면 언급하세요.
  예를 들면 다음과 같습니다.

  ```dart
  /// Adds a new [child] into the container, and becomes the owner of that
  /// child.
  ///
  /// The child will be disposed of when this container is destroyed.
  /// It is an error to try to add a child that already belongs to another
  /// container.
  void addChild(T child) { ... }
  ```

  뻔한 내용을 적는 것은 피하세요(적어도 뻔한 내용만 적지는 마세요).

- 생성자 문서는 메서드 스타일(예: "Creates ...", "Constructs ...")을 따르거나, 클래스 이름을 생략한
  클래스 스타일(예: "Rectangular-shaped component")을 따를 수 있습니다. (1) 클래스의 주 생성자이고,
  (2) 모든 파라미터가 명확하며 클래스의 public 멤버와 일치하는 경우에는 생성자 문서를 생략해도 됩니다.

  클래스 문서를 생성자의 dartdoc으로 복사하기 위해 매크로를 사용하지 **마세요**. 일반적으로
  클래스 문서는 "이 클래스가 무엇인지"라는 질문에 답하고, 생성자 문서는 "어떻게 생성되는지"에
  답합니다.


<a id="main-docs"></a>

### 메인 문서

지금 읽고 있는 Flame 메인 문서 웹사이트의 문서를 말합니다. 메인 문서 사이트는 사람들이
Flame에서 사용할 수 있는 다양한 기능에 대해 배우러 오는 곳입니다. 새 클래스를 추가한다면
dartdoc 수준과 메인 문서 사이트 모두에 문서화해야 합니다. 후자는 클래스를 발견할 수 있게 해 주는
역할을 합니다. 문서 사이트가 없다면 개발자들이 그 클래스의 존재를 모르기 때문에 클래스가
전혀 사용되지 않을 수도 있습니다(적어도 가능했던 것보다 덜 사용될 것입니다).

메인 문서 사이트에 문서를 추가할 때는 예제를 문서에 직접 포함하는 것도 고려하세요. 그러면
독자들이 새 기능을 사용해 보는 데 더 흥미를 느낄 것입니다.

문서 사이트를 다루는 방법은 [문서화][documentation] 매뉴얼을 확인하세요.

문서를 작성할 때는 일반적으로 다음 스타일 규칙이 적용됩니다.

- 한 줄의 최대 길이는 100자입니다.
- 문서의 일반 텍스트를 읽기 쉽도록 외부 링크는 문서 하단에 정의하는 것을 선호합니다.
- 제목과 앞의 내용 사이는 빈 줄 2개로 구분합니다. 그러면 일반 텍스트에서 섹션을 알아보기 쉽습니다.
- 목록은 줄의 시작 부분에서 시작하고, 하위 목록은 공백 2칸으로 들여씁니다.


[effective dart]: https://dart.dev/guides/language/effective-dart
[flutter documentation guide]: https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo#user-content-documentation-dartdocs-javadocs-etc
[documentation]: documentation.md
