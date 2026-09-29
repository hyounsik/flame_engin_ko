<a id="components"></a>

# 컴포넌트

게임 개발에서 컴포넌트는 특정한 게임 동작이나 시각 요소를 캡슐화한 독립적인 단위입니다. Flame은
[Flame Component System](../game.md)(FCS)을 사용하며, 여기서는 게임의 모든 객체(플레이어, 적, 배경, UI
요소)가 컴포넌트입니다. 각 로직이 자신만의 클래스에 담기고 컴포넌트를
[Flutter의 위젯 트리](https://docs.flutter.dev/get-started/fundamentals/widgets)처럼
트리로 자유롭게 조합할 수 있으므로, 게임을 만들고 유지보수하기가 쉬워집니다.

- [Position 컴포넌트](position_component.md)
- [스프라이트 컴포넌트](sprite_components.md)
- [Parallax 컴포넌트](parallax_component.md)
- [도형 컴포넌트](shape_components.md)
- [유틸리티 컴포넌트](utility_components.md)

```{include} ../diagrams/component.md
```

이 다이어그램이 겁나 보일 수 있지만 걱정하지 마세요. 보이는 것만큼 복잡하지 않습니다.


## Component

모든 컴포넌트는 `Component` 클래스를 상속하며, 다른 `Component`를 자식으로 가질 수 있습니다.
이것이 Flame Component System, 줄여서 FCS라고 부르는 것의 기반입니다.

자식은 `add(Component c)` 메서드로 추가하거나 생성자에서 직접 추가할 수 있습니다.

예:

```dart
void main() {
  final component1 = Component(children: [Component(), Component()]);
  final component2 = Component();
  component2.add(Component());
  component2.addAll([Component(), Component()]);
}
```

물론 여기서 `Component()`는 `Component`의 어떤 하위 클래스여도 됩니다.

모든 `Component`에는 선택적으로 구현할 수 있는 몇 가지 메서드가 있으며, 이 메서드들은 `FlameGame`
클래스에서 사용됩니다.


<a id="component-lifecycle"></a>

### 컴포넌트 생명주기

```{include} ../diagrams/component_life_cycle.md
```

`onGameResize` 메서드는 화면 크기가 바뀔 때마다 호출되며, 이 컴포넌트가 컴포넌트 트리에 추가될 때도
`onMount` 전에 호출됩니다.

`onParentResize` 메서드도 비슷합니다. 컴포넌트가 컴포넌트 트리에 마운트될 때 호출되며, 현재 컴포넌트의
부모 크기가 바뀔 때마다 호출됩니다.

`onRemove` 메서드를 오버라이드하면 컴포넌트가 게임에서 제거되기 전에 코드를 실행할 수 있습니다.
부모의 remove 메서드와 `Component`의 remove 메서드를 모두 사용해 컴포넌트를 제거하더라도 한 번만
실행됩니다.

`onLoad` 메서드를 오버라이드하면 이미지 로드 같은 컴포넌트의 비동기 초기화 코드를 실행할 수 있습니다.
이 메서드는 `onGameResize`와 `onMount`보다 먼저 실행됩니다. 컴포넌트의 수명 동안 단 한 번만 실행되는
것이 보장되므로 "비동기 생성자"라고 생각해도 됩니다.

`onMount` 메서드는 컴포넌트가 게임 트리에 마운트될 때마다 실행됩니다. 즉 이 메서드는 컴포넌트의 수명
동안 여러 번 실행될 수 있으므로, 여기서 `late final` 변수를 초기화해서는 안 됩니다. 이 메서드는 부모가
이미 마운트된 경우에만 실행됩니다. 부모가 아직 마운트되지 않았다면 이 메서드는 큐에서 대기합니다(게임
엔진의 나머지 부분에는 아무 영향이 없습니다).

부모의 자식 변경을 감지해야 한다면 `onChildrenChanged` 메서드를 오버라이드할 수 있습니다. 이 메서드는
자식이 부모에 추가되거나 부모에서 제거될 때마다 호출됩니다(자식이 부모를 바꾸는 경우도 포함). 파라미터에는
대상 자식과 변경 유형(`added` 또는 `removed`)이 담깁니다.

`onHotReload` 메서드는 Flutter의 핫 리로드가 실행될 때(디버그 모드 전용) 트리의 모든 컴포넌트에서
호출됩니다. 개발 중 코드 변경에 대응해 에셋을 다시 로드하거나, 캐시된 값을 다시 계산하거나, 다른 작업을
수행하려면 이 메서드를 오버라이드하세요. 이 알림은 로딩 중이거나 로드된 모든 자식에게 자동으로
전파되므로, 오버라이드할 때 반드시 `super.onHotReload()`를 호출해야 합니다:

```dart
class MyComponent extends Component {
  @override
  void onHotReload() {
    super.onHotReload();
    // 소스 코드에서 바뀌었을 수 있는 값을 다시 읽습니다.
    _cachedValue = _computeExpensiveValue();
  }
}
```

컴포넌트의 생명주기 상태는 다음 getter들로 확인할 수 있습니다:

- `isLoaded`: 현재 로드 상태를 bool로 반환합니다.
- `loaded`: 컴포넌트의 로드가 끝나면 완료되는 future를 반환합니다. `onLoad` 중에 추가된 자식들의 로드도
  포함됩니다.
- `isMounted`: 현재 마운트 상태를 bool로 반환합니다.
- `mounted`: 컴포넌트의 마운트가 끝나면 완료되는 future를 반환합니다.
- `isRemoved`: 현재 제거 상태를 bool로 반환합니다.
- `removed`: 컴포넌트가 제거되면 완료되는 future를 반환합니다.


<a id="priority"></a>

### 우선순위

Flame에서 모든 `Component`는 `int priority` 속성을 가지며, 이 속성은 부모의 자식들 사이에서 해당
컴포넌트의 정렬 순서를 결정합니다. 다른 언어와 프레임워크에서는 이를 `z-index`라고 부르기도 합니다.
`priority`를 높게 설정할수록 먼저 렌더링된 더 낮은 우선순위의 컴포넌트들 위에 렌더링되므로, 화면에서
더 앞에 있는 것처럼 보입니다.

예를 들어 두 컴포넌트를 추가하고 그중 하나의 우선순위를 1로 설정하면, 기본 우선순위가 0이므로 그
컴포넌트가 (겹치는 경우) 다른 컴포넌트 위에 렌더링됩니다.

모든 컴포넌트는 `priority`를 이름 있는 인자로 받으므로, 컴파일 타임에 컴포넌트의 우선순위를 알고 있다면
생성자에 전달할 수 있습니다.

예:

```dart
class MyGame extends FlameGame {
  @override
  void onLoad() {
    final myComponent = PositionComponent(priority: 5);
    add(myComponent);
  }
}
```

컴포넌트의 우선순위를 갱신하려면 `component.priority = 2`처럼 새 값을 설정하면 되고, 현재 틱의 렌더링
단계 전에 갱신됩니다.

다음 예제에서는 먼저 우선순위 1로 컴포넌트를 초기화한 다음, 사용자가 컴포넌트를 탭하면 우선순위를 2로
바꿉니다:

```dart
class MyComponent extends PositionComponent with TapCallbacks {

  MyComponent() : super(priority: 1);

  @override
  void onTapDown(TapDownEvent event) {
    priority = 2;
  }
}
```


<a id="custom-update-traversal-and-pausing"></a>

### 커스텀 update 순회와 일시 정지

엔진은 게임이 소유한 평탄화된 순회 목록을 통해 update 단계를 진행하며, `updateTree` 자체는 오버라이드할
수 없습니다. 자신의 하위 트리가 update되는 방식을 제어해야 하는 컴포넌트(유효 `dt` 변경, 자식 건너뛰기,
자식을 수동으로 update하기 등)는 `CustomTraversal`을 믹스인하고 `updateSubtree` 메서드를
오버라이드합니다:

```dart
class SlowMotionArea extends Component with CustomTraversal {
  @override
  void updateSubtree(double dt) => super.updateSubtree(dt / 2);
}
```

엔진은 모든 `CustomTraversal` 컴포넌트를 순회 경계로 취급합니다. 즉 해당 컴포넌트 자체는 평탄화된
목록에 나타나고, 그 `updateSubtree`가 하위 트리를 진행시킵니다. 이를 기반으로 하는 믹스인(예:
`HasTimeScale`)은 `on CustomTraversal`로 선언되어 `super.updateSubtree`로 연결되므로, 사용하는 쪽에서는
`with CustomTraversal, HasTimeScale`처럼 `CustomTraversal`을 먼저 믹스인해야 합니다. `FlameGame`은 이미
이를 믹스인하고 있으므로 `extends FlameGame with HasTimeScale`에는 추가 작업이 필요 없습니다.

하위 트리를 일시 정지하려면 `HasTimeScale`의 time scale을 `0`으로 설정하세요(또는 `pause()` 호출).
그러면 time scale이 다시 올라갈 때까지 update 단계에서 해당 컴포넌트와 모든 자손을 건너뜁니다.


<a id="composability-of-components"></a>

### 컴포넌트의 조합성

때로는 다른 컴포넌트를 내 컴포넌트 안에 감싸는 것이 유용합니다. 예를 들어 계층 구조를 통해 시각
컴포넌트들을 그룹화할 수 있습니다. `PositionComponent` 등 어떤 컴포넌트에든 자식 컴포넌트를 추가하면
됩니다.

컴포넌트에 자식 컴포넌트가 있으면, 부모가 update되고 렌더링될 때마다 모든 자식도 같은 조건으로
렌더링되고 update됩니다.

다음은 두 컴포넌트의 표시 여부를 래퍼가 처리하는 예제입니다:

```dart
class GameOverPanel extends PositionComponent {
  bool visible = false;
  final Image spriteImage;

  GameOverPanel(this.spriteImage);

  @override
  void onLoad() {
    // GameOverText는 Component입니다
    final gameOverText = GameOverText(spriteImage);
    // GameOverRestart는 SpriteComponent입니다
    final gameOverButton = GameOverButton(spriteImage);

    add(gameOverText);
    add(gameOverButton);
  }

  @override
  void render(Canvas canvas) {
    if (visible) {
    } // 보이지 않으면 자식들도 렌더링되지 않습니다
  }
}
```

컴포넌트에 자식 컴포넌트를 추가하는 방법은 두 가지입니다. 첫째, 게임 중 언제든 사용할 수 있는 `add()`,
`addAll()`, `addToParent()` 메서드가 있습니다. 전통적으로 자식은 컴포넌트의 `onLoad()` 메서드에서
생성되고 추가되지만, 게임 진행 중에 새 자식을 추가하는 것도 흔합니다.

둘째, 컴포넌트 생성자의 `children:` 파라미터를 사용하는 방법입니다. 이 방식은 표준 Flutter API와 더
비슷합니다:

```dart
class MyGame extends FlameGame {
  @override
  void onLoad() {
    add(
      PositionComponent(
        position: Vector2(30, 0),
        children: [
          HighScoreDisplay(),
          HitPointsDisplay(),
          FpsComponent(),
        ],
      ),
    );
  }
}
```

두 방식은 자유롭게 함께 쓸 수 있습니다. 생성자에 지정한 자식이 먼저 추가되고, 그 뒤에 추가 자식
컴포넌트가 추가됩니다.

`add()`, `addAll()`, `addToParent()` 메서드는 동기 메서드입니다. 자식이 로드되거나 마운트될 때까지
기다리지 않고 즉시 반환합니다. 따라서 `update()` 안이나 많은 컴포넌트를 생성하는 루프 안을 포함해 어디서든
`await`하거나 `unawaited`로 감쌀 필요 없이 안전하게 호출할 수 있습니다. 자식이 특정 생명주기 단계에
도달할 때까지 기다려야 한다면, 대신 그 자식의 `loaded`, `mounted`, `removed` future를 await하세요
([컴포넌트 생명주기](#컴포넌트-생명주기)의 생명주기 getter 참고):

```dart
world.add(coin);
await coin.mounted;
// 이제 coin이 마운트되었음이 보장됩니다.
```

여러 자식을 한꺼번에 추가하고 그 모두가 트리에 들어갔는지만 중요하다면, 개별 future를 모으는 대신
`game.lifecycleEventsProcessed`를 한 번 await하세요:

```dart
world.addAll(coins);
await game.lifecycleEventsProcessed;
// 이제 모든 coin이 world.children에 있습니다.
```

트리 전체가 아니라 특정 자식 그룹에 대해 특정 단계가 필요할 때를 위해, 같은 세 getter를 모든
`Iterable<Component>`에서도 사용할 수 있습니다:

```dart
world.addAll(coins);
await coins.loaded;
// 모든 coin의 로드가 끝났습니다.
```

자식은 추가되자마자 로드를 시작하므로, 부모 자신의 `onLoad` 안에서 `loaded`를 await하는 것은
안전합니다:

```dart
class Inventory extends Component {
  @override
  Future<void> onLoad() async {
    final coin = Coin();
    add(coin);
    await coin.loaded;
    // coin의 onLoad에서 준비한 모든 것을 이제 여기서 사용할 수 있습니다.
  }
}
```

하지만 거기서 `mounted`나 `removed`를 await하는 것은 안전하지 않습니다. 자식은 부모가 마운트된 뒤에만
마운트될 수 있고, 부모는 `onLoad`가 완료된 뒤에야 마운트되므로 이 future들은 교착 상태에 빠집니다.
`game.lifecycleEventsProcessed`도 마찬가지인데, 부모 자신의 대기 중인 마운트가 이 future가 기다리는 큐의
일부이기 때문입니다.

컴포넌트는 `onLoad` 중에 추가된 모든 자식의 로드가 끝날 때까지 로드된 것으로 간주되지 않습니다. 자식들의
`loaded` future를 명시적으로 await하지 않아도 마찬가지입니다. 즉 컴포넌트가 마운트될 즈음에는 `onLoad`
중에 만든 하위 트리가 완전히 로드된 상태이며, 그 자식들은 같은 생명주기 처리 단계에서 컴포넌트와 함께
마운트됩니다. 단, 로드에 실패한 자식은 예외로, 부모를 막지 않고 트리에서 제외됩니다. 부모가 자식을
기다리므로, 자식의 `onLoad`에서 부모의 `loaded`나 `mounted` future를 await해서는 안 됩니다. 교착 상태에
빠지기 때문입니다.

어느 방법으로 추가하든, 자식은 로드되고 마운트된 뒤에야 비로소 사용 가능해진다는 것만 보장됩니다.
보장할 수 있는 것은 자식들이 추가 예약된 순서와 같은 순서로 children 목록에 나타난다는 것뿐입니다.


<a id="access-to-the-world-from-a-component"></a>

### 컴포넌트에서 World에 접근하기

`World`를 조상으로 가진 컴포넌트가 그 `World` 객체에 접근해야 한다면 `HasWorldRef` 믹스인을 사용할 수
있습니다.

예:

```dart
class MyComponent extends Component with HasWorldRef<MyWorld>,
    TapCallbacks {
  @override
  void onTapDown(TapDownEvent info) {
    // worldRef의 타입은 MyWorld입니다
    worldRef.add(AnotherComponent());
  }
}
```

올바른 타입의 `World` 조상이 없는 컴포넌트에서 `worldRef`에 접근하려고 하면 assertion 오류가 발생합니다.


<a id="ensuring-a-component-has-a-given-parent"></a>

### 컴포넌트가 특정 부모를 갖도록 보장하기

컴포넌트가 특정 타입의 부모에 추가되어야 한다면, `ParentIsA` 믹스인을 사용해 강하게 타입이 지정된 부모를
강제할 수 있습니다.

예:

```dart
class MyComponent extends Component with ParentIsA<MyParentComponent> {
  @override
  void onLoad() {
    // parent의 타입은 MyParentComponent입니다
    print(parent.myValue);
  }
}
```

`MyComponent`를 `MyParentComponent`가 아닌 부모에 추가하려고 하면 assertion 오류가 발생합니다.


<a id="ensuring-a-component-has-a-given-ancestor"></a>

### 컴포넌트가 특정 조상을 갖도록 보장하기

컴포넌트 트리의 어딘가에 특정 타입의 조상이 있어야 한다면, `HasAncestor` 믹스인을 사용해 그 관계를
강제할 수 있습니다.

이 믹스인은 지정한 타입의 `ancestor` 필드를 제공합니다.

예:

```dart
class MyComponent extends Component with HasAncestor<MyAncestorComponent> {
  @override
  void onLoad() {
    // ancestor의 타입은 MyAncestorComponent입니다.
    print(ancestor.myValue);
  }
}
```

`MyAncestorComponent`가 없는 트리에 `MyComponent`를 추가하려고 하면 assertion 오류가 발생합니다.


<a id="component-keys"></a>

### 컴포넌트 키

컴포넌트는 식별 키를 가질 수 있으며, 이를 통해 트리의 어느 지점에서든 컴포넌트 트리에서 해당 컴포넌트를
찾을 수 있습니다.

키로 컴포넌트를 등록하려면 컴포넌트 생성자의 `key` 인자에 키를 전달하기만 하면 됩니다:

```dart
final myComponent = Component(
  key: ComponentKey.named('player'),
);
```

그런 다음 컴포넌트 트리의 다른 지점에서 이를 찾으려면:

```dart
flameGame.findByKey(ComponentKey.named('player'));
```

키에는 `unique`와 `named` 두 가지 유형이 있습니다. unique 키는 키 인스턴스의 동등성을 기준으로 합니다.
즉:

```dart
final key = ComponentKey.unique();
final key2 = key;
print(key == key2); // true
print(key == ComponentKey.unique()); // false
```

named 키는 받은 이름을 기준으로 합니다. 따라서:

```dart
final key1 = ComponentKey.named('player');
final key2 = ComponentKey.named('player');
print(key1 == key2); // true
```

named 키를 사용할 때는 `findByKeyName` 헬퍼로도 컴포넌트를 찾을 수 있습니다.


```dart
flameGame.findByKeyName('player');
```


<a id="querying-child-components"></a>

### 자식 컴포넌트 쿼리하기

컴포넌트에 추가된 자식들은 `children`이라는 `ComponentList`에 담깁니다. 이 집합에서 특정 타입의
컴포넌트를 쿼리하려면 `query<T>()` 함수를 사용할 수 있습니다. children 목록에서 `strictMode`는 기본적으로
`false`이지만, 이를 활성화하면(`createComponentList`를 오버라이드해 `ComponentList(strictMode: true)`를
반환하도록 하면) 쿼리를 사용하기 전에 `children.register`로 쿼리를 등록해야 합니다.

나중에 특정 타입의 쿼리를 실행하리라는 것을 컴파일 타임에 알고 있다면, `strictMode`가 `true`든 `false`든
쿼리를 등록하는 것이 좋습니다. 그렇게 하면 성능상 이점이 있기 때문입니다. `register` 호출은 보통
`onLoad`에서 합니다.

예:

```dart
@override
void onLoad() {
  children.register<PositionComponent>();
}
```

위 예제에서는 `PositionComponent`에 대한 쿼리를 등록했으며, 등록된 컴포넌트 타입을 쿼리하는 방법은
아래 예제에서 볼 수 있습니다.

```dart
@override
void update(double dt) {
  final allPositionComponents = children.query<PositionComponent>();
}
```


<a id="querying-components-at-a-specific-point-on-the-screen"></a>

### 화면의 특정 지점에 있는 컴포넌트 쿼리하기

`componentsAtPoint()` 메서드를 사용하면 화면의 어떤 지점에 어떤 컴포넌트가 렌더링되었는지 확인할 수
있습니다. 반환값은 컴포넌트의 iterable이지만, 두 번째 파라미터로 쓰기 가능한 `List<Vector2>`를 전달하면
각 컴포넌트의 로컬 좌표 공간에서의 최초 지점 좌표도 얻을 수 있습니다.

iterable은 앞에서 뒤 순서로 컴포넌트를 가져옵니다. 즉 앞쪽 컴포넌트가 먼저 나오고 그 뒤에 뒤쪽
컴포넌트가 나옵니다.

이 메서드는 `containsLocalPoint()` 메서드를 구현한 컴포넌트만 반환할 수 있습니다.
`PositionComponent`(Flame의 많은 컴포넌트의 기반 클래스)는 이 구현을 제공합니다. 하지만 `Component`를
상속하는 커스텀 클래스를 정의한다면 `containsLocalPoint()` 메서드를 직접 구현해야 합니다.

다음은 `componentsAtPoint()`를 사용하는 예입니다:

```dart
void onDragUpdate(DragUpdateEvent event) {
  game.componentsAtPoint(event.canvasEndPosition).forEach((component) {
    if (component is DropTarget) {
      component.highlight();
    }
  });
}
```


<a id="visibility-of-components"></a>

### 컴포넌트의 표시 여부

컴포넌트를 숨기거나 표시하는 권장 방법은 보통 `add`와 `remove` 메서드로 트리에 추가하거나 트리에서
제거하는 것입니다.

하지만 트리에 컴포넌트를 추가하거나 제거하면 해당 컴포넌트의 생명주기 단계(`onRemove`와 `onMount` 호출
등)가 실행됩니다. 또한 이는 비동기 과정이므로, 컴포넌트를 빠르게 연달아 제거하고 추가한다면 다시
추가하기 전에 제거가 끝났는지 주의해서 확인해야 합니다.

```dart
/// 자식 컴포넌트를 빠르게 연달아 제거하고 추가하는 것을
/// 처리하는 예
void show() async {
  // 컴포넌트가 아직 제거되는 중일 수 있으므로
  // 먼저 [removed] future를 await해야 합니다.
  await myChildComponent.removed;
  add(myChildComponent);
}

void hide() {
  remove(myChildComponent);
}
```

이런 동작이 항상 바람직한 것은 아닙니다.

컴포넌트를 표시하고 숨기는 또 다른 방법은 `HasVisibility` 믹스인을 사용하는 것으로, `Component`를
상속하는 어떤 클래스에서든 사용할 수 있습니다. 이 믹스인은 `isVisible` 속성을 추가합니다. 트리에서
제거하지 않고, `isVisible`을 `false`로 설정하면 컴포넌트가 숨겨지고 `true`로 설정하면 다시 표시됩니다.
이는 컴포넌트와 그 모든 자손(자식)의 표시 여부에 영향을 줍니다.

```dart
/// HasVisibility를 구현하는 예
class MyComponent extends PositionComponent with HasVisibility {}

/// isVisible 속성 사용법
final myComponent = MyComponent();
add(myComponent);

myComponent.isVisible = false;
```

이 믹스인은 컴포넌트가 렌더링되는지 여부에만 영향을 주며, 다른 동작에는 영향을 주지 않습니다.

```{note}
중요! 컴포넌트가 보이지 않더라도 여전히 트리에 있으며
'update'와 다른 모든 생명주기 이벤트 호출을 계속 받습니다.
입력 이벤트에도 계속 반응하고, 충돌 감지 등 다른
컴포넌트와의 상호작용도 계속됩니다.
```

이 믹스인은 `renderTree` 메서드를 막는 방식으로 동작하므로, `renderTree`를 오버라이드한다면 이 기능을
유지하기 위해 `isVisible`을 수동으로 확인하는 코드를 포함해야 합니다.

```dart
class MyComponent extends PositionComponent with HasVisibility {

  @override
  void renderTree(Canvas canvas) {
    // 표시 여부를 확인합니다
    if (isVisible) {
      // 여기에 커스텀 코드

      // 트리 렌더링을 계속합니다
      super.renderTree(canvas);
    }
  }
}
```


<a id="render-contexts"></a>

### 렌더 컨텍스트

부모 컴포넌트가 렌더링 관련 속성을 자식 트리로 전달하게 하고 싶다면, 부모 컴포넌트의 `renderContext`
속성을 오버라이드할 수 있습니다. `RenderContext`를 상속하는 커스텀 클래스를 반환한 뒤, 렌더링 중에
자식에서 `findRenderContext`를 사용하면 됩니다. 렌더 컨텍스트는 스택으로 저장되며, 렌더링을 위해 렌더
트리를 탐색할 때마다 전파됩니다.

예:

```dart
class IntContext extends ComponentRenderContext {
  int value;

  IntContext(this.value);
}

class ParentWithContext extends Component {
  @override
  IntContext renderContext = IntContext(42);
}

class ChildReadsContext extends Component {
  @override
  void render(Canvas canvas) {
    final context = findRenderContext<IntContext>();
    // context.value를 사용할 수 있습니다
  }
}
```

각 컴포넌트는 컴포넌트 트리에서 자신보다 위에 있는 모든 부모의 컨텍스트에 접근할 수 있습니다. 여러
컴포넌트가 선택한 타입 `T`와 일치하는 컨텍스트를 추가했다면 "가장 가까운" 컨텍스트가 반환됩니다(다만
일반적으로는 컴포넌트마다 고유한 컨텍스트 타입을 만듭니다).


<a id="effects"></a>

## 이펙트

Flame은 특정 유형의 컴포넌트에 적용할 수 있는 이펙트 모음을 제공합니다. 이 이펙트들을 사용하면 위치나
크기 같은 컴포넌트의 일부 속성에 애니메이션을 적용할 수 있습니다.
[사용 가능한 이펙트 목록](../effects/effects.md)을 확인해 보세요.

실행 중인 이펙트의 예제는
[이펙트 예제 디렉터리](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/effects)에서
찾을 수 있습니다.

```{toctree}
:hidden:

Position 컴포넌트        <position_component.md>
스프라이트 컴포넌트      <sprite_components.md>
Parallax 컴포넌트        <parallax_component.md>
도형 컴포넌트            <shape_components.md>
유틸리티 컴포넌트        <utility_components.md>
```
