# CharacterStorage
```{dartdoc}
:package: jenny
:symbol: CharacterStorage
:file: src/character_storage.dart
```


<a id="accessing-character-storage"></a>

## 캐릭터 저장소에 접근하기

캐릭터 저장소는 [YarnProject]를 통해 접근합니다.

```dart
final characters = yarnProject.characters;
```


<a id="removing-characters"></a>

## 캐릭터 제거하기

저장소에서 캐릭터를 제거해야 하는 상황이 있을 수 있습니다. 예를 들어 여러 장면이 있는 게임에서는
한 장면이 끝난 뒤 캐릭터를 제거하고 다음 장면을 위한 새 캐릭터를 로드할 수 있습니다.

`clear`로 모든 캐릭터를 제거합니다.

```dart
yarnProject.characters.clear();
```

캐릭터 하나를 제거하려면 `remove`를 사용합니다. 캐릭터의 이름이나 그 별칭 중 하나를 전달하면 됩니다.
캐릭터와 그 모든 별칭이 제거됩니다.

```dart
yarnProject.characters.remove('Jenny');
```

[YarnProject]: yarn_project.md
