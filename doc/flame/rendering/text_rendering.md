<a id="text-rendering"></a>

# 텍스트 렌더링

Flame에는 텍스트 렌더링을 돕는 전용 클래스가 몇 가지 있습니다.


<a id="text-components"></a>

## 텍스트 컴포넌트

Flame으로 텍스트를 렌더링하는 가장 간단한 방법은 제공되는 텍스트 렌더링
컴포넌트 중 하나를 활용하는 것입니다.

- `TextComponent`: 한 줄의 텍스트를 렌더링합니다.
- `TextBoxComponent`: 여러 줄의 텍스트를 크기가 정해진 박스 안에 담으며, 타이핑 효과도
지원합니다. `newLineNotifier`를 사용하면 새 줄이 추가될 때 알림을 받을 수 있습니다. 텍스트가 모두
출력되었을 때 함수를 실행하려면 `onComplete` 콜백을 사용하세요.
- `ScrollTextBoxComponent`: 텍스트가 감싸는 박스의 경계를 넘을 때 세로 스크롤 기능을 추가해
`TextBoxComponent`의 기능을 확장합니다.


모든 컴포넌트는 [이 예제](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/rendering/text_example.dart)에서 확인할 수 있습니다.


### TextComponent

`TextComponent`는 한 줄의 텍스트를 렌더링하는 간단한 컴포넌트입니다.

간단한 사용법:

```dart
class MyGame extends FlameGame {
  @override
  void onLoad() {
    add(
      TextComponent(
        text: 'Hello, Flame',
        position: Vector2.all(16.0),
      ),
    );
  }
}
```

폰트 패밀리, 크기, 색상 등 렌더링 관련 요소를 설정하려면 해당 정보를 담은
`TextRenderer`를 제공(또는 수정)해야 합니다. 이 인터페이스에 대한 자세한 내용은 아래에서 볼 수 있으며,
사용할 수 있는 가장 간단한 구현은 Flutter의 `TextStyle`을 받는 `TextPaint`입니다.

```dart
final regular = TextPaint(
  style: TextStyle(
    fontSize: 48.0,
    color: BasicPalette.white.color,
  ),
);

class MyGame extends FlameGame {
  @override
  void onLoad() {
    add(
      TextComponent(
        text: 'Hello, Flame',
        textRenderer: regular,
        anchor: Anchor.topCenter,
        position: Vector2(size.width / 2, 32.0),
      ),
    );
  }
}
```

모든 옵션은 [TextComponent의
API](https://pub.dev/documentation/flame/latest/components/TextComponent-class.html)에서 확인할 수 있습니다.


### TextBoxComponent

`TextBoxComponent`는 `TextComponent`와 매우 비슷하지만, 이름에서 알 수 있듯이 경계 박스 안에
텍스트를 렌더링하는 데 사용되며, 제공된 박스 크기에 따라 줄바꿈을 만듭니다.

`TextBoxConfig`의 `growingBox` 변수로 텍스트가 작성됨에 따라 박스가 커질지, 아니면 고정될지를
결정할 수 있습니다. 고정된 박스는 크기를 고정하거나(`TextBoxComponent`의
`size` 속성 설정), 텍스트 내용에 맞게 자동으로 줄어들 수 있습니다.

또한 `align` 속성을 사용하면 텍스트 내용의 가로 및 세로 정렬을 제어할 수 있습니다.
예를 들어 `align`을 `Anchor.center`로 설정하면 텍스트가 경계 박스 안에서
세로와 가로 모두 가운데에 정렬됩니다.

박스의 여백을 변경하려면 `TextBoxConfig`의 `margins` 변수를 사용하세요.

마지막으로, 문자열의 각 문자를 실시간으로 타이핑하는 것처럼 하나씩 보여 주는
"타이핑" 효과를 흉내 내고 싶다면 `boxConfig.timePerChar` 파라미터를 제공하면 됩니다.

타이핑 효과를 제어하려면, 전체 텍스트를 한 번에 보여 주는 `skip`과, 컴포넌트를 다시 만들 필요 없이
타이핑 효과를 처음으로 되돌리는 `resetAnimation`을 호출하세요. `skip`은
`boxConfig.timePerChar`를 `0`으로 설정한다는 점에 유의하세요. 따라서 `skip`을 호출한 후
타이핑 효과를 다시 재생하려면 `resetAnimation`을 호출하기 직전이나 직후에
`boxConfig.timePerChar`를 다시 설정해야 합니다.

사용 예:

```dart
class MyTextBox extends TextBoxComponent {
  MyTextBox(String text) : super(
    text: text,
    textRenderer: tiny,
    boxConfig: TextBoxConfig(timePerChar: 0.05),
  );

  final bgPaint = Paint()..color = Color(0xFFFF00FF);
  final borderPaint = Paint()..color = Color(0xFF000000)..style = PaintingStyle.stroke;

  @override
  void render(Canvas canvas) {
    Rect rect = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRect(rect, bgPaint);
    canvas.drawRect(rect.deflate(boxConfig.margin), borderPaint);
    super.render(canvas);
  }
}
```


모든 옵션은 [TextBoxComponent의
API](https://pub.dev/documentation/flame/latest/components/TextBoxComponent-class.html)에서 확인할 수 있습니다.


### ScrollTextBoxComponent

`ScrollTextBoxComponent`는 `TextBoxComponent`의 고급 버전으로,
정해진 영역 안에 스크롤 가능한 텍스트를 표시하도록 설계되었습니다.
이 컴포넌트는 대화창이나 정보 패널처럼 많은 양의 텍스트를
제한된 공간에 보여 줘야 하는 인터페이스를 만들 때 특히 유용합니다.

`TextBoxComponent`의 `align` 속성은 사용할 수 없다는 점에 유의하세요.


사용 예:


```dart
class MyScrollableText extends ScrollTextBoxComponent {
  MyScrollableText(Vector2 frameSize, String text) : super(
    size: frameSize,
    text: text,
    textRenderer: regular, 
    boxConfig: TextBoxConfig(timePerChar: 0.05),
  );
}
```


### TextElementComponent

단일 InlineTextElement부터 서식이 적용된 DocumentRoot까지, 임의의 TextElement를 렌더링하고 싶다면
`TextElementComponent`를 사용할 수 있습니다.

간단한 예로, 리치 텍스트를 담은 블록 요소(HTML의 "div"를 떠올리면 됩니다)의 시퀀스를
렌더링하는 DocumentRoot를 만들 수 있습니다.

```dart
  final document = DocumentRoot([
    HeaderNode.simple('1984', level: 1),
    ParagraphNode.simple(
      'Anything could be true. The so-called laws of nature were nonsense.',
    ),
    // ...
  ]);
  final element = TextElementComponent.fromDocument(
    document: document,
    position: Vector2(100, 50),
    size: Vector2(400, 200),
  );
```

크기는 두 가지 방법으로 지정할 수 있다는 점에 유의하세요.

- 모든 `PositionComponents`에 공통인 size 속성, 또는
- 적용된 `DocumentStyle`에 포함된 width/height

문서에 스타일을 적용하는 예제입니다(스타일에는 크기뿐 아니라 다른 파라미터도
포함할 수 있습니다).

```dart
  final style = DocumentStyle(
    width: 400,
    height: 200,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
    background: BackgroundStyle(
      color: const Color(0xFF4E322E),
      borderColor: const Color(0xFF000000),
      borderWidth: 2.0,
    ),
  );
  final document = DocumentRoot([ ... ]);
  final element = TextElementComponent.fromDocument(
    document: document,
    style: style,
    position: Vector2(100, 50),
  );
```

좀 더 정교한 [리치 텍스트, 서식이 적용된
텍스트 블록 렌더링 예제](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/rendering/rich_text_example.dart)를 참고하세요.

텍스트 렌더링 파이프라인의 내부 동작에 대한 자세한 내용은 아래의 "Text Elements,
Text Nodes, and Text Styles"를 참고하세요.


### Flame Markdown

굵게/기울임꼴이 있는 간단한 문자열부터 완전히 구조화된 문서까지, 리치 텍스트 기반 DocumentRoot를
더 쉽게 만들 수 있도록 Flame은 `markdown` 라이브러리와 Flame의 텍스트 렌더링 인프라를 연결하는
`flame_markdown` 브릿지 패키지를 제공합니다.

`FlameMarkdown` 헬퍼 클래스의 `toDocument` 메서드를 사용해 마크다운 문자열을
DocumentRoot로 변환하기만 하면 됩니다(이를 사용해 `TextElementComponent`를 만들 수 있습니다).

```dart
import 'package:flame/text.dart';
import 'package:flame_markdown/flame_markdown.dart';

// ...
final component = await TextElementComponent.fromDocument(
  document: FlameMarkdown.toDocument(
    '# Header\n'
    '\n'
    'This is a **bold** text, and this is *italic*.\n'
    '\n'
    'This is a second paragraph.\n',
  ),
  style: ...,
  position: ...,
  size: ...,
);
```


<a id="infrastructure"></a>

## 인프라

Flame Component System을 사용하지 않거나, 텍스트 렌더링의 기반 인프라를 이해하고 싶거나,
사용하는 폰트와 스타일을 사용자 정의하고 싶거나, 직접 사용자 정의 렌더러를 만들고 싶다면
이 섹션을 참고하세요.

- `TextRenderer`: 렌더러는 텍스트를 "어떻게" 렌더링할지 알고 있습니다. 본질적으로 어떤 문자열이든
  렌더링하기 위한 스타일 정보를 담고 있습니다.
- `TextElement`: 요소는 서식이 적용되고 "레이아웃된" 텍스트 조각으로, 문자열("무엇을")과
  스타일("어떻게")을 포함합니다.

다음 다이어그램은 텍스트 렌더링 파이프라인의 클래스 및 상속 구조를 보여 줍니다.

```{mermaid}
%%{init: { 'theme': 'dark' } }%%
classDiagram
    %% renderers
    note for TextRenderer "This just the style (how).
    It knows how to take a text string and create a TextElement.
    `render` is just a helper to `format(text).render(...)`. Same for `getLineMetrics`."
    class TextRenderer {
        TextElement format(String text)
        LineMetrics getLineMetrics(String text)
        void render(Canvas canvas, String text, ...)
    }
    class TextPaint
    class SpriteFontRenderer
    class DebugTextRenderer
    
    %% elements
    class TextElement {
        LineMetrics metrics
        render(Canvas canvas, ...)
    }
    class TextPainterTextElement
        
    TextRenderer --> TextPaint
    TextRenderer --> SpriteFontRenderer
    TextRenderer --> DebugTextRenderer

    TextRenderer *-- TextElement
    TextPaint *-- TextPainterTextElement
    SpriteFontRenderer *-- SpriteFontTextElement

    note for TextElement "This is the text (what) and the style (how);
    laid out and ready to render."
    TextElement --> TextPainterTextElement
    TextElement --> SpriteFontTextElement
    TextElement --> Others
```

### TextRenderer

`TextRenderer`는 Flame이 텍스트를 렌더링하는 데 사용하는 추상 클래스입니다. `TextRenderer`의 구현은
텍스트를 "어떻게" 렌더링할지에 대한 정보, 즉 폰트 스타일, 크기, 색상 등을 포함해야 합니다.
또한 `format` 메서드를 통해 이 정보를 주어진 텍스트 문자열과 결합해
`TextElement`를 생성할 수 있어야 합니다.

Flame은 두 가지 구체적인 구현을 제공합니다.

- `TextPaint`: 가장 많이 사용되며, Flutter의 `TextPainter`를 사용해 일반 텍스트를 렌더링합니다.
- `SpriteFontRenderer`: `SpriteFont`(스프라이트 시트 기반 폰트)를 사용해 비트맵 텍스트를 렌더링합니다.
- `DebugTextRenderer`: 골든 테스트(Golden Test) 전용입니다.

하지만 다른 형태의 사용자 정의 텍스트 렌더링으로 확장하고 싶다면 직접 구현을 제공할 수도 있습니다.

`TextRenderer`의 주된 역할은 텍스트 문자열을 `TextElement`로 포맷하는 것이며, 이렇게 만든 요소는
화면에 렌더링할 수 있습니다.

```dart
final textElement = textRenderer.format("Flame is awesome")
textElement.render(...) 
```

하지만 렌더러는 요소를 바로 만들어 렌더링하는 헬퍼 메서드도 제공합니다.

```dart
textRenderer.render(
  canvas,
  'Flame is awesome',
  Vector2(10, 10),
  anchor: Anchor.topCenter,
);
```


#### TextPaint

`TextPaint`는 Flame에 내장된 텍스트 렌더링 구현입니다. Flutter의 `TextPainter` 클래스를
기반으로 하며(그래서 이런 이름이 붙었습니다), 스타일 클래스인 `TextStyle`로 설정할 수 있습니다.
`TextStyle`은 텍스트 렌더링에 필요한 모든 타이포그래피 정보, 즉 폰트 크기와
색상, 폰트 패밀리 등을 담고 있습니다.

스타일 외에도 선택적으로 추가 파라미터 하나를 제공할 수 있는데, 바로
`textDirection`입니다(다만 이 값은 보통 이미 `ltr`, 즉 왼쪽에서 오른쪽으로 설정되어 있습니다).

사용 예:

```dart
const TextPaint textPaint = TextPaint(
  style: TextStyle(
    fontSize: 48.0,
    fontFamily: 'Awesome Font',
  ),
);
```

참고: `TextStyle` 클래스를 포함한 패키지가 여러 개 있습니다. Flame은 `text` 모듈을 통해
올바른 것(Flutter의 것)을 export합니다.

```dart
import 'package:flame/text.dart';
```

하지만 명시적으로 import하고 싶다면
`package:flutter/painting.dart`(또는 material이나 widgets)에서 import해야 합니다. `dart:ui`도 import해야 한다면,
해당 모듈에는 같은 이름의 다른 클래스가 있으므로 그쪽의 `TextStyle`을
숨겨야(hide) 할 수도 있습니다.

```dart
import 'package:flutter/painting.dart';
import 'dart:ui' hide TextStyle;
```

다음은 `TextStyle`의 몇 가지 일반적인 속성입니다([`TextStyle` 속성의 전체
목록](https://api.flutter.dev/flutter/painting/TextStyle-class.html) 참고).

- `fontFamily`: Arial(기본값) 같은 일반적으로 사용 가능한 폰트, 또는 pubspec에 추가한
 사용자 정의 폰트([사용자 정의 폰트 추가 방법](https://docs.flutter.dev/cookbook/design/fonts) 참고).
- `fontSize`: 폰트 크기(pt 단위, 기본값 `24.0`).
- `height`: 텍스트 줄의 높이. 폰트 크기의 배수로 지정합니다(기본값 `null`).
- `color`: `ui.Color`로 지정하는 색상(기본값 흰색).

색상과 색상을 만드는 방법에 대한 자세한 내용은 [색상과
팔레트](palette.md) 가이드를 참고하세요.


#### SpriteFontRenderer

기본으로 제공되는 또 다른 렌더러 옵션은 `SpriteFontRenderer`로, 스프라이트 시트를 기반으로 한
`SpriteFont`를 제공할 수 있게 해 줍니다. TODO


#### DebugTextRenderer

이 렌더러는 골든 테스트에서 사용하기 위한 것입니다. 골든 테스트에서 일반적인 폰트 기반 텍스트를 렌더링하면
플랫폼마다 폰트 정의가 다르고 안티앨리어싱에 사용되는 알고리즘이 달라서
신뢰할 수 없습니다. 이 렌더러는 각 단어를 단색 사각형처럼 렌더링하므로,
폰트 기반 렌더링에 의존하지 않고도 요소의 레이아웃, 위치, 크기를 테스트할 수 있습니다.


<a id="inline-text-elements"></a>

## 인라인 텍스트 요소

`TextElement`는 특정 스타일이 적용되어 "미리 컴파일되고", 서식이 적용되고 레이아웃된 텍스트 조각으로,
어떤 위치에서든 바로 렌더링할 수 있습니다.

`InlineTextElement`는 `TextElement` 인터페이스를 구현하며, 두 가지 메서드를 구현해야 합니다.
하나는 요소를 이동시키는 방법을, 다른 하나는 캔버스에 그리는 방법을 알려 줍니다.

```dart
  void translate(double dx, double dy);
  void draw(Canvas canvas);
```

이 메서드들은 `InlineTextElement`의 구현에서 오버라이드하기 위한 것이며, 사용자가 직접
호출하는 일은 거의 없을 것입니다. 편리한 `render` 메서드가 제공되기 때문입니다.

```dart
  void render(
    Canvas canvas,
    Vector2 position, {
    Anchor anchor = Anchor.topLeft,
  })
```

이 메서드를 사용하면 주어진 앵커를 사용해 특정 위치에 요소를 렌더링할 수 있습니다.

이 인터페이스는 또한 해당 `InlineTextElement`에 연결된 `LineMetrics` 객체의 getter를 요구(및 제공)합니다.
이를 통해 사용자(및 `render` 구현)는 요소와 관련된 크기
정보(너비, 높이, ascent 등)에 접근할 수 있습니다.

```dart
  LineMetrics get metrics;
```


<a id="text-elements-text-nodes-and-text-styles"></a>

## Text Elements, Text Nodes, Text Styles

일반적인 렌더러는 항상 `InlineTextElement`를 직접 다루지만, 그 밑에는 더 풍부하거나 서식이 적용된
텍스트를 렌더링하는 데 사용할 수 있는 더 큰 인프라가 있습니다.

Text Element는 Inline Text Element의 상위 집합으로, 리치 텍스트 문서 안의 임의의 렌더링 블록을
나타냅니다. 본질적으로 이들은 구체적이고 "물리적인" 것으로, 캔버스에 렌더링될
준비가 된 객체입니다.

이 특성이 Text Element를 Text Node 및 Text Style과 구분합니다. Text Node는 구조화된 텍스트 조각이고,
Text Style(Flutter의 `TextStyle`과 함께 사용하기 쉽도록 코드에서는 `FlameTextStyle`이라고 부릅니다)은
임의의 텍스트 조각을 어떻게 렌더링해야 하는지를 기술하는 디스크립터입니다.

따라서 가장 일반적인 경우, 사용자는 `TextNode`로 원하는 리치
텍스트 조각을 기술하고, 여기에 적용할 `FlameTextStyle`을 정의한 다음, 이를 사용해 `TextElement`를 생성합니다.
렌더링 유형에 따라 생성된 `TextElement`는 `InlineTextElement`가 되며, 이렇게 되면
다시 렌더링 파이프라인의 일반적인 흐름으로 돌아오게 됩니다. Inline Text 유형 요소의 고유한 특성은
고급 렌더링에 사용할 수 있는 LineMetrics를 노출한다는 점입니다. 반면 다른
요소들은 크기와 위치를 알지 못하는 더 단순한 `draw` 메서드만 노출합니다.

하지만 서식이 적용된 텍스트로 풍부하게 꾸민 문서 전체(여러 블록이나 문단)를 만들려는 경우에는
다른 유형의 Text Element, Text Node, Text Style을 사용해야 합니다.
임의의 TextElement를 렌더링하려면 대신 `TextElementComponent`를 사용할 수도 있습니다(위 참고).

[이러한 사용 예제](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/rendering/rich_text_example.dart)를 참고하세요.


<a id="text-nodes-and-the-document-root"></a>

### Text Node와 Document Root

`DocumentRoot`는 (상속 관계상) 그 자체로 `TextNode`는 아니지만, 여러 블록이나
문단으로 배치된 리치 텍스트의 "페이지" 또는 "문서"를 구성하는 `BlockNodes`의 그룹을 나타냅니다.
문서 전체를 나타내며 전역 스타일을 받을 수 있습니다.

리치 텍스트 문서를 정의하는 첫 번째 단계는 노드를 만드는 것이며, 대개
`DocumentRoot`가 될 것입니다.

이 노드는 먼저 헤더, 문단, 열(column)을 정의할 수 있는 최상위 Block Node 리스트를
포함합니다.

그런 다음 각 블록은 다른 블록이나 Inline Text Node를 포함할 수 있으며, Inline Text Node는 Plain Text Node일 수도,
특정 서식이 적용된 리치 텍스트일 수도 있습니다.

노드 구조로 정의된 계층은 `FlameTextStyle` 클래스에 정의된 대로
스타일링 목적으로도 사용된다는 점에 유의하세요.

실제 노드들은 모두 `TextNode`를 상속하며, 다음 다이어그램과 같이 구분됩니다.

```{mermaid}
%%{init: { 'theme': 'dark' } }%%
graph TD
    %% Config %%
    classDef default fill:#282828,stroke:#F6BE00;

    %% Nodes %%
    TextNode("
        <big><strong>TextNode</strong></big>
        Can be thought of as an HTML DOM node;
        each subclass can be thought of as a specific tag.
    ")
    BlockNode("
        <big><strong>BlockNode</strong></big>
        #quot;div#quot;
    ")
    InlineTextNode("
        <big><strong>InlineTextNode</strong></big>
        #quot;span#quot;
    ")
    ColumnNode("
        <big><strong>ColumnNode</strong></big>
        column-arranged group of other Block Nodes
    ")
    TextBlockNode("
        <big><strong>TextBlockNode</strong></big>
        a #quot;div#quot; with an InlineTextNode as a direct child
    ")
    HeaderNode("
        <big><strong>HeaderNode</strong></big>
        #quot;h1#quot; / #quot;h2#quot; / etc
    ")
    ParagraphNode("
        <big><strong>ParagraphNode</strong></big>
        #quot;p#quot;
    ")
    GroupTextNode("
        <big><strong>GroupTextNode</strong></big>
        groups other TextNodes in a single line
    ")
    PlainTextNode("
        <big><strong>PlainTextNode</strong></big>
        just plain text, unformatted
    ")
    ItalicTextNode("
        <big><strong>ItalicTextNode</strong></big>
        #quot;i#quot; / #quot;em#quot;
    ")
    BoldTextNode("
        <big><strong>BoldTextNode</strong></big>
        #quot;b#quot; / #quot;strong#quot;
    ")
    TextNode ----> BlockNode
    TextNode --------> InlineTextNode
    BlockNode --> ColumnNode
    BlockNode --> TextBlockNode
    TextBlockNode --> HeaderNode
    TextBlockNode --> ParagraphNode
    InlineTextNode --> GroupTextNode
    InlineTextNode --> PlainTextNode
    InlineTextNode --> BoldTextNode
    InlineTextNode --> ItalicTextNode
```

<a id="flame-text-styles"></a>

### (Flame) Text Style

Text Style을 노드에 적용해 요소를 생성할 수 있습니다. 이들은 모두 `FlameTextStyle`
추상 클래스를 상속합니다(Flutter의 `TextStyle`과 혼동하지 않도록 이런 이름이 붙었습니다).

이들은 트리와 같은 구조를 따르며, 항상 `DocumentStyle`을 루트로 가집니다. 이 구조는
대응하는 노드 구조에 계단식(cascading) 스타일을 적용하는 데 활용됩니다. 사실 이들은 CSS 정의와
꽤 비슷하며, CSS 정의로 생각해도 됩니다.

전체 상속 체인은 다음 다이어그램에서 볼 수 있습니다.

```{mermaid}
%%{init: { 'theme': 'dark' } }%%
classDiagram
    %% Nodes %%
    class FlameTextStyle {
        copyWith()
        merge()
    }

    note for FlameTextStyle "Root for all styles.
    Not to be confused with Flutter's TextStyle."

    class DocumentStyle {
        <<for the entire Document Root>>
        size
        padding
        background [BackgroundStyle]
        specific styles [for blocks & inline]
    }

    class BlockStyle {
        <<for Block Nodes>>
        margin, padding
        background [BackgroundStyle]
        text [InlineTextStyle]
    }

    class BackgroundStyle {
        <<for Block or Document>>
        color
        border
    }

    class InlineTextStyle {
        <<for any nodes>>
        font, color
    }

    FlameTextStyle <|-- DocumentStyle
    FlameTextStyle <|-- BlockStyle
    FlameTextStyle <|-- BackgroundStyle
    FlameTextStyle <|-- InlineTextStyle
```

<a id="text-elements"></a>

### Text Element

마지막으로 요소(element)가 있습니다. 요소는 노드("무엇을")와 스타일("어떻게")의 조합을 나타내며,
따라서 캔버스에 렌더링될, 미리 컴파일되고 레이아웃된 리치 텍스트 조각을 나타냅니다.

특히 Inline Text Element는
`TextRenderer`(단순화된 "어떻게")와 문자열(한 줄의 "무엇을")의 조합으로 생각할 수도 있습니다.

`InlineTextStyle`은 `asTextRenderer` 메서드를 통해 특정 `TextRenderer`로 변환될 수 있고,
이 렌더러를 사용해 텍스트의 각 줄을 고유한 `InlineTextElement`로 레이아웃하기 때문입니다.

렌더러를 직접 사용하면 레이아웃 과정 전체가 생략되고, 단일
`TextPainterTextElement` 또는 `SpriteFontTextElement`가 반환됩니다.

보시다시피 요소에 대한 두 정의는 모든 것을 고려하면 본질적으로 동일합니다.
하지만 여전히 텍스트를 렌더링하는 두 가지 경로가 남습니다. 어느 쪽을 골라야 할까요? 이 난제를
어떻게 해결할까요?

확신이 서지 않는다면 다음 지침이 자신에게 가장 적합한 경로를 고르는 데 도움이 될 것입니다.

- 텍스트를 렌더링하는 가장 간단한 방법이 필요하다면 `TextPaint`(기본 렌더러 구현)를 사용하세요.
  - 이를 위해 FCS가 제공하는 `TextComponent` 컴포넌트를 사용할 수 있습니다.
- 스프라이트 폰트를 렌더링하려면 `SpriteFontRenderer`(`SpriteFont`를 받는 렌더러 구현)를
  사용해야 합니다.
- 자동 줄바꿈이 적용된 여러 줄의 텍스트를 렌더링하려면 두 가지 선택지가 있습니다.
  - FCS의 `TextBoxComponent`를 사용합니다. 이 컴포넌트는 어떤 텍스트 렌더러든 사용해 텍스트의 각 줄을
    요소로 그리며, 자체적으로 레이아웃과 줄바꿈을 처리합니다.
  - Text Node & Style 시스템을 사용해 미리 레이아웃된 요소를 만듭니다. 참고: 현재 이를 위한
    FCS 컴포넌트는 없습니다.
- 마지막으로, 서식이 적용된(또는 리치) 텍스트가 필요하다면 Text Node & Style을 사용해야 합니다.
