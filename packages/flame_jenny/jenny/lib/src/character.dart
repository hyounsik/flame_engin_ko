import 'package:jenny/jenny.dart';

/// **Character**는 대화에서 특정 대사를 말하는 인물을 나타냅니다.
/// 이 객체는 [DialogueView]에 전달되는 [DialogueLine]의
/// `.character` 속성으로 사용할 수 있습니다.
///
/// [YarnProject]의 `strictCharacterNames` 설정이 false가 아니라면,
/// 모든 캐릭터는 `<<character>>` 명령으로
/// 선언해야 합니다.
class Character {
  Character(this.name, {List<String>? aliases}) : aliases = aliases ?? [];

  Map<String, dynamic>? _data;

  /// 캐릭터의 정식 이름으로, [<<character>>] 명령의 첫 번째 인자로
  /// 주어진 값입니다.
  final String name;

  /// yarn 스크립트에서 이 캐릭터를 가리킬 때 사용할 수 있는
  /// 추가 이름(ID)입니다.
  final List<String> aliases;

  /// 이 캐릭터와 연결된 추가 정보입니다. 짧은 소개, 초상화, 소속, 색상 등이
  /// 포함될 수 있습니다. 이 정보는 각 캐릭터마다 직접 저장해야 하며,
  /// 그러면 [DialogueView]에서
  /// 접근할 수 있습니다.
  ///
  /// 여기에는 원하는 어떤 키-값 쌍이든 저장할 수 있고, 아무것도 저장하지 않아도 됩니다.
  Map<String, dynamic> get data => _data ??= <String, dynamic>{};

  @override
  String toString() => 'Character($name)';
}
