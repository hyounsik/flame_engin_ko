import 'package:jenny/src/errors.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/variables.dart';

class VariableStorage {
  final Map<String, dynamic> variables = <String, dynamic>{};

  int get length => variables.length;
  bool get isEmpty => variables.isEmpty;
  bool get isNotEmpty => variables.isNotEmpty;

  bool getBooleanValue(String name) => variables[name]! as bool;
  num getNumericValue(String name) => variables[name]! as num;
  String getStringValue(String name) => variables[name]! as String;

  bool hasVariable(String name) => variables.containsKey(name);
  dynamic getVariable(String name) => variables[name]!;

  Expression getVariableAsExpression(String name) {
    final dynamic value = variables[name];
    return switch (value) {
      String() => StringVariable(name, this),
      num() => NumericVariable(name, this),
      bool() => BooleanVariable(name, this),
      _ => throw DialogueError(
        'Cannot convert variable $name with type ${value.runtimeType} to '
        'an expression',
      ),
    };
  }

  ExpressionType getVariableType(String name) {
    final dynamic value = variables[name];
    return switch (value) {
      String() => ExpressionType.string,
      num() => ExpressionType.numeric,
      bool() => ExpressionType.boolean,
      _ => ExpressionType.unknown,
    };
  }

  void setVariable(String name, dynamic value) {
    final dynamic oldValue = variables[name];
    if (!(value is String || value is num || value is bool)) {
      throw DialogueError(
        'Cannot set variable $name to a value with type ${value.runtimeType}',
      );
    }
    if (oldValue != null &&
        !(value is String && oldValue is String) &&
        !(value is num && oldValue is num) &&
        !(value is bool && oldValue is bool)) {
      throw DialogueError(
        'Redefinition of variable $name from type ${oldValue.runtimeType} to '
        '${value.runtimeType} is not allowed',
      );
    }
    variables[name] = value;
  }

  /// 모든 변수를 지웁니다. 기본적으로 노드 방문 횟수는 지워지지 않습니다.
  /// 노드 방문 횟수까지 제거하려면 [clearNodeVisits]를 `true`로 설정하세요.
  ///
  /// 노드 방문 변수 이름에는 @ 기호가 접두사로 붙는다는 점에 유의하세요.
  /// @ 기호로 시작하는 사용자 정의 변수가 있다면, [clearNodeVisits]가
  /// `false`일 때 이 변수들도 유지됩니다. 이런 변수는
  /// [remove]를 사용해 개별적으로 제거해야 합니다.
  void clear({bool clearNodeVisits = false}) {
    if (!clearNodeVisits) {
      variables.removeWhere((key, _) => !key.startsWith('@'));
    } else {
      variables.clear();
    }
  }

  /// [name]으로 변수를 제거합니다.
  void remove(String name) {
    variables.remove(name);
  }
}
