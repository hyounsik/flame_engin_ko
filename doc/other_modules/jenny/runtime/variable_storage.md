# VariableStorage
```{dartdoc}
:package: jenny
:symbol: VariableStorage
:file: src/variable_storage.dart
```


<a id="accessing-variable-storage"></a>

## 변수 저장소에 접근하기

변수 저장소는 [YarnProject]를 통해 접근합니다.

```dart
final variables = yarnProject.variables;
```


<a id="removing-variables"></a>

## 변수 제거하기

대부분의 경우 변수는 [YarnProject]의 수명 동안 유지되어야 합니다. 하지만 저장소에서 변수를 제거해야 하는
상황이 있을 수 있습니다. 예를 들어 여러 장면이 있는 게임에서는 특정 장면에만 쓰이는 변수가 더 이상
필요하지 않으면 제거할 수 있습니다.

`clear`로 모든 변수를 제거합니다. 기본적으로 이 메서드는 노드 방문 횟수를 유지하는데, 방문 횟수도 변수로
저장되기 때문입니다. 노드 방문 횟수는 Yarn이 '노드를 이미 방문했다면 이것을 하라' 같은 로직에 사용하므로
그대로 두는 것이 가장 좋습니다. 하지만 이것들까지 제거하려면 `clearNodeVisits`를 `true`로 설정하세요.

```dart
/// 노드 방문 횟수를 제외한 모든 변수를 지웁니다.
yarnProject.variables.clear();

/// 노드 방문 횟수를 포함한 모든 변수를 지웁니다.
yarnProject.variables.clear(clearNodeVisits: true);
```

변수 하나를 제거하려면 `remove`를 사용합니다.

```dart
yarnProject.variables.remove('money');
```

[YarnProject]: yarn_project.md
