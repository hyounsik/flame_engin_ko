import 'package:jenny/jenny.dart';
import 'package:jenny/src/structure/dialogue_entry.dart';
import 'package:jenny/src/structure/line_content.dart';

/// **DialogueLine** 클래스는 대화 [[Line]] 안의 텍스트 한 줄을
/// 나타냅니다.
///
/// `DialogueLine` 객체는 `onLineStart()`, `onLineSignal()`, `onLineStop()`,
/// `onLineFinish()` 메서드를 통해 [DialogueView]에
/// 전달됩니다.
///
/// 대사에는 [character](말하는 주체의 이름)와 [tags](대사에 대한
/// 메타 정보를 지정하는 해시태그 토큰 목록)가 포함될 수
/// 있습니다.
///
/// yarn 스크립트에서 대사의 예시는 다음과 같습니다.
/// ```yarn
/// Hermione: Holy cricket! You're Harry Potter.  #surprised
/// ```
/// 여기서 [character]는 "Hermione"이고, 대사의 [text]는 "Holy
/// cricket! You're Harry Potter."이며, [tags] 목록에는 "#surprised"라는
/// 항목 하나가 들어갑니다.
///
/// 대사에는 인라인 표현식도 포함될 수 있으며, 이 표현식은 대화 러너가
/// 대사를 실행할 때마다 다시 평가됩니다:
/// ```yarn
/// Jenny: My favorite color is {$favoriteColor}, what about you?
/// ```
/// 평가 후 결과 문자열은 "My favorite color is
/// vantablack, what about you?"가 될 수 있습니다.
///
/// 마지막으로 대사에는 마크업 속성이 있을 수 있습니다. 이는 HTML 태그와
/// 비슷하지만 대괄호를 사용합니다:
/// ```yarn
/// Jenny: My [i]favorite[/i] color is [bb color=$color]{$color}[/bb].
/// ```
/// 이 마크업 속성은 출력에 보이지 않지만(즉 결과 텍스트는 여전히
/// "My favorite color is vantablack"입니다), [attributes] 목록에서
/// 조회할 수 있습니다. 이 목록은 "favorite"이라는 단어를 감싸는
/// `[i]` 속성과, "vantablack"이라는 단어를 감싸며 `color` 파라미터를 가진
/// 또 다른 `[bb]` 속성이 있음을 알려줍니다.
///
/// 인라인 표현식에는 마크업 속성을 포함할 수 없습니다.
class DialogueLine extends DialogueEntry {
  DialogueLine({
    required this._content,
    this._character,
    this._tags,
  }) : _value = _content.isConst ? _content.text : null;

  final Character? _character;
  final List<String>? _tags;
  final LineContent _content;
  String? _value;

  /// 이 대사(Line)의 내용입니다.
  LineContent? get content => _content;

  /// 이 대사를 말하는 캐릭터입니다. 대사에 화자가 없으면
  /// null일 수 있습니다.
  Character? get character => _character;

  /// 모든 인라인 표현식을 치환하고, 마크업을 제거하고, 이스케이프 시퀀스를
  /// 처리한 뒤 계산된 대사 텍스트입니다.
  ///
  /// 이 값은 대사가 [evaluate]된 후에만 접근할 수 있습니다. 이후 대사가
  /// 다시 평가되면 값이 바뀔 수 있습니다(재평가는 대사가 [DialogueRunner]를
  /// 거칠 때마다 일어납니다).
  String get text {
    assert(_value != null, 'Line was not evaluated');
    return _value!;
  }

  /// 대사에 연결된 해시태그 목록입니다. 해시태그가 없으면
  /// 목록은 비어 있습니다.
  ///
  /// 목록의 각 값은 `#` 기호로 시작합니다.
  List<String> get tags => _tags ?? const [];

  /// 대사에 연결된 마크업 스팬 목록입니다.
  List<MarkupAttribute> get attributes => _content.attributes ?? const [];

  /// 이후 다시 실행해도 대사가 절대 바뀌지 않으면 true입니다. 즉
  /// 대사가 어떤 동적 표현식에도 의존하지 않는 경우입니다.
  bool get isConst => _content.isConst;

  @override
  Future<void> processInDialogueRunner(DialogueRunner dialogueRunner) {
    evaluate();
    return dialogueRunner.deliverLine(this);
  }

  /// 현재 모든 인라인 표현식의 값을 치환하여 대사의 [text]를
  /// 계산합니다.
  ///
  /// 보통은 이 메서드를 직접 호출할 필요가 없습니다 --
  /// [DialogueRunner]가 대신 처리해 줍니다. 하지만 대화 러너 밖에서
  /// `DialogueLine`에 접근해야 한다면 이 메서드를 호출해야
  /// 할 수도 있습니다.
  void evaluate() {
    _value = _content.evaluate();
  }

  @override
  String toString() {
    final prefix = character == null ? '' : '${character!.name}: ';
    final text = _value ?? '<unevaluated>';
    return 'DialogueLine($prefix$text)';
  }

  @override
  bool operator ==(Object other) =>
      other is DialogueLine &&
      text == other.text &&
      character == other.character;
}
