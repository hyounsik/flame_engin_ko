<a id="getting-started-"></a>

# 시작하기 🚀


<a id="prerequisites-"></a>

## 사전 요구 사항 📝

Flame Behaviors를 사용하려면 프로젝트에 [Flame 패키지][flame_package_link]가 추가되어
있어야 합니다.

> **참고**: Flame Behaviors는 Flame `">=1.10.0 <2.0.0"`이 필요합니다.


<a id="installing-"></a>

## 설치 🧑‍💻

먼저 [`flame_behaviors`][flame_behaviors_package_link] 패키지를 추가합니다.

```shell
# 📦 pub.dev의 flame_behaviors 패키지를 프로젝트에 추가합니다
flutter pub add flame_behaviors
```


## Entity

엔티티는 게임을 구성하는 기본 단위입니다. 엔티티는 여러 `Behavior`를 가질 수 있는 시각적인 게임 오브젝트를
나타내며, 이 `Behavior`들이 엔티티가 어떻게 동작할지를 정의합니다.

```dart
// `Entity`를 상속해 커스텀 엔티티를 정의합니다.
class MyEntity extends Entity {
  MyEntity() : super(behaviors: [MyBehavior()]);
}
```


<a id="types-of-entities"></a>

### 엔티티의 종류

Flame Behaviors에는 두 가지 종류의 엔티티가 있습니다.

- `Entity`: 어떤 게임 오브젝트든 나타낼 수 있는 범용 엔티티입니다.
- `PositionedEntity`: 위치와 크기를 가진 엔티티로, `PositionComponent`를 기반으로 합니다.

이 엔티티들은 엔티티의 기본 기능을 제공하는 믹스인인 `EntityMixin`을
사용합니다.

어떤 컴포넌트든 엔티티로 만들고 싶다면 이 믹스인을 사용할 수 있습니다. 예를 들어 `SpriteComponent`를
엔티티로 만들고 싶다면 다음과 같이 하면 됩니다.

```dart
class MySpriteEntity extends SpriteComponent with EntityMixin {
  Future<void> onLoad() async {
    // 엔티티에 비헤이비어를 추가합니다.
    add(MyBehavior());
  }
}
```

`FlameGame`을 엔티티로 만들 수도 있습니다.

```dart
class MyGame extends FlameGame with EntityMixin {
  Future<void> onLoad() async {
    // 엔티티에 비헤이비어를 추가합니다.
    add(MyGameBehavior());
  }
}
```


## Behavior

비헤이비어는 엔티티가 어떻게 동작하는지를 정의하는 컴포넌트입니다. `EntityMixin`을 사용하는 모든 컴포넌트에
붙일 수 있으며, 해당 엔티티의 특정 동작을 처리합니다. 비헤이비어는 모든 엔티티에 사용할 수 있는
범용 비헤이비어로 만들 수도 있고, 비헤이비어가 요구하는 특정 엔티티 타입을 지정할 수도 있습니다.

```dart
// 어떤 타입의 Entity에도 추가할 수 있습니다.
class MyGenericBehavior extends Behavior {
  ...
}

// MyEntity와 그 하위 클래스에만 추가할 수 있습니다.
class MySpecificBehavior extends Behavior<MyEntity> {
  ...
}
```


<a id="behavior-composition"></a>

### 비헤이비어 합성

각 비헤이비어는 해당 비헤이비어와 관련된 추가 기능을 위해 자체 `Component`를 가질 수 있습니다.
예를 들어 `TimerComponent`로 시간 기반 동작을 구현할 수 있습니다.

```dart
class MyBehavior extends Behavior {
  @override
  Future<void> onLoad() async {
    add(TimerComponent(period: 5, repeat: true, onTick: _onTick));
  }

  void _onTick() {
    // 5초마다 무언가를 수행합니다.
  }
}
```

> [!NOTE]
> `Behavior`는 시각적 컴포넌트(Entity)가 어떻게 동작하는지를 기술하는 비시각적 컴포넌트입니다.
> 따라서 비헤이비어는 자체 `Behavior`를 가질 수 없습니다.


<a id="whats-next"></a>

## 다음 단계

다음 섹션에서는 일반적인 게임 개발 작업에 Flame Behaviors를 사용하는 방법을 보여 줍니다.

- [게임 입력 처리하기](event-behaviors.md)
- [충돌 처리하기](collision-detection.md)

Flame Behaviors는 코드의 이름을 짓고 구성하는 방법에 대한 몇 가지 규칙도 제공합니다.

- [네이밍 규칙](conventions/naming-conventions.md)
- [코드 규칙](conventions/coding-conventions.md)

Flame Behaviors 사용법에 대해 더 알아보려면 [아티클][article_link]을 확인하세요.

[flame_package_link]: https://pub.dev/packages/flame
[flame_behaviors_package_link]: https://pub.dev/packages/flame_behaviors
[article_link]: https://verygood.ventures/blog/build-games-with-flame-behaviors
