import 'package:jenny/src/character.dart';
import 'package:meta/meta.dart';

/// **CharacterStorage**는 yarn 스크립트에 정의된 모든 [Character]의 캐시입니다.
/// 이 컨테이너는 YarnProject가 입력 스크립트를 파싱할 때
/// `<<character>>` 명령으로부터 채워집니다.
class CharacterStorage {
  final Map<String, Character> _cache = {};

  bool get isEmpty => _cache.isEmpty;
  bool get isNotEmpty => _cache.isNotEmpty;

  /// 주어진 이름 또는 별칭을 가진 캐릭터가 정의되어 있으면 `true`를 반환합니다.
  bool contains(String name) => _cache.containsKey(name);

  /// 주어진 이름/별칭을 가진 캐릭터를 가져오고, 해당 캐릭터가 없으면
  /// `null`을 반환합니다.
  Character? operator [](String name) => _cache[name];

  /// 새 [character]를 컨테이너에 추가합니다.
  ///
  /// 이 메서드는 내부용입니다. yarn 스크립트에서는
  /// `<<character>>` 명령으로 캐릭터를 선언하세요.
  @internal
  void add(Character character) {
    _cache[character.name] = character;
    for (final alias in character.aliases) {
      _cache[alias] = character;
    }
  }

  /// 저장소의 모든 캐릭터를 지웁니다.
  ///
  /// 새로운 캐릭터 집합을 로드하기 위해 장면 사이에 사용할 수
  /// 있습니다. 일반적으로 대화가 진행 중일 때는
  /// 사용하지 않습니다.
  void clear() {
    _cache.clear();
  }

  /// 이름으로 캐릭터를 제거합니다. 해당 캐릭터의 별칭도 함께 제거됩니다.
  ///
  /// 캐릭터가 더 이상 필요 없다고 확신할 때 사용할 수 있습니다.
  /// 일반적으로 대화가 진행 중일 때는 사용하지 않습니다.
  void remove(String name) {
    final character = _cache[name];
    if (character != null) {
      for (final alias in character.aliases) {
        _cache.remove(alias);
      }
      _cache.remove(character.name);
    }
  }
}
