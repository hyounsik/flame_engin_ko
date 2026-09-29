<a id="collision-detection"></a>

# 충돌 감지

거의 모든 게임은 객체가 서로 닿거나 겹치는 순간을 알아야 합니다. 충돌 감지가 없다면 플레이어는 벽을
통과해 걸어갈 수 있고, 총알은 적을 그대로 통과하며, 코인은 절대 수집할 수 없을 것입니다.
Flame은 내장 충돌 감지 시스템을 제공하므로, 교차 계산을 직접 작성하는 대신 객체가 충돌했을 때
*무슨 일이 일어나는지*에 집중할 수 있습니다.

충돌 감지는 대부분의 게임에서 두 컴포넌트가 서로 교차하는 것을 감지하고 그에 대응하기 위해
필요합니다. 예를 들어 화살이 적을 맞히거나 플레이어가 코인을 줍는 경우입니다.

대부분의 충돌 감지 시스템에서는 히트박스라는 것을 사용해 컴포넌트의 경계 상자를 더 정밀하게 만듭니다.
Flame에서 히트박스는 컴포넌트에서 충돌에 반응할 수 있는 영역이며,
[제스처 입력](inputs/inputs.md#gesturehitboxes)을 더 정확하게 만들어 줍니다.

충돌 감지 시스템은 히트박스를 만들 수 있는 세 가지 도형, 즉 Polygon, Rectangle, Circle을
지원합니다. 하나의 컴포넌트에 여러 히트박스를 추가하여 충돌을 감지하거나 점을 포함하는지 판단하는 데
쓸 영역을 구성할 수 있습니다. 후자는 정확한 제스처 감지에 매우 유용합니다. 충돌 감지는 두 히트박스가
충돌했을 때 무엇을 해야 하는지는 처리하지 않습니다. 따라서 예를 들어 두 `PositionComponent`의
히트박스가 교차했을 때 무슨 일이 일어날지는 사용자가 직접 구현해야 합니다.

내장 충돌 감지 시스템은 서로를 지나쳐 버리는 두 히트박스 사이의 충돌은 고려하지 않는다는 점에
유의하세요. 이는 히트박스가 매우 빠르게 움직이거나, `update`가 큰 델타 타임으로 호출될 때(예를 들어
앱이 포그라운드에 있지 않을 때) 발생할 수 있습니다.
이 현상을 터널링(tunneling)이라고 합니다.


<a id="mixins"></a>

## 믹스인


### HasCollisionDetection

게임에서 충돌 감지를 사용하려면 게임에 `HasCollisionDetection` 믹스인을 추가해야 합니다. 그래야
게임이 충돌할 수 있는 컴포넌트를 추적할 수 있습니다.

예시:

```dart
class MyGame extends FlameGame with HasCollisionDetection {
  // ...
}
```

이제 컴포넌트에 `ShapeHitbox`를 추가하고 그 컴포넌트를 게임에 추가하면, 자동으로 충돌 검사가
이루어집니다.

`HasCollisionDetection`을 `FlameGame` 대신 다른 `Component`에 직접 추가할 수도
있습니다.
예를 들어 `CameraComponent`에 사용되는 `World`에 추가할 수 있습니다.
이렇게 하면 해당 컴포넌트의 트리에 추가된 히트박스는 그 하위 트리에 있는 다른 히트박스와만
비교되므로, 하나의 `FlameGame` 안에 충돌 감지가 있는 여러 월드를 둘 수 있습니다.

예시:

```dart
class CollisionDetectionWorld extends World with HasCollisionDetection {}
```

```{note}
히트박스는 하나의 충돌 감지 시스템에만 연결되며, 그 시스템은
`HasCollisionDetection` 믹스인을 가진 가장 가까운 부모입니다.
```


### CollisionCallbacks

충돌에 반응하려면 컴포넌트에 `CollisionCallbacks` 믹스인을 추가해야 합니다.
예시:


```{flutter-app}
:sources: ../flame/examples
:page: collision_detection
:show: widget code infobox
:width: 180
:height: 160
```

```dart
class MyCollidable extends PositionComponent with CollisionCallbacks {
  @override
  void onCollision(List<Vector2> points, PositionComponent other) {
    if (other is ScreenHitbox) {
      //...
    } else if (other is YourOtherComponent) {
      //...
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is ScreenHitbox) {
      //...
    } else if (other is YourOtherComponent) {
      //...
    }
  }
}
```

이 예시에서는 Dart의 `is` 키워드를 사용해 어떤 종류의 컴포넌트와 충돌했는지 확인합니다.
points 리스트는 히트박스의 가장자리가 교차하는 지점입니다.

두 `PositionComponent`가 모두 `onCollision` 메서드를 구현했다면 `onCollision` 메서드는 두 컴포넌트
모두에서 호출되며, 두 히트박스에서도 호출된다는 점에 유의하세요. 두 컴포넌트와 히트박스가 서로
충돌하기 시작하거나 충돌을 멈출 때 호출되는 `onCollisionStart`와 `onCollisionEnd` 메서드도
마찬가지입니다.

`PositionComponent`(와 히트박스)가 다른 `PositionComponent`와 충돌하기 시작하면
`onCollisionStart`와 `onCollision`이 모두 호출됩니다. 따라서 충돌이 시작될 때 특별히 해야 할 일이
없다면 `onCollision`만 오버라이드하면 되며, 그 반대도 마찬가지입니다.

위 예시처럼 화면 가장자리와의 충돌을 확인하고 싶다면 미리 정의된
[ScreenHitbox](#screenhitbox) 클래스를 사용할 수 있습니다.

기본적으로 모든 히트박스는 속이 비어 있습니다(hollow). 즉, 한 히트박스가 다른 히트박스 안에 완전히
들어가 있어도 충돌이 발생하지 않습니다. 히트박스를 속이 찬(solid) 상태로 만들고 싶다면
`isSolid = true`로 설정하면 됩니다. solid 히트박스 안에 있는 hollow 히트박스는 충돌을 발생시키지만,
그 반대는 아닙니다. solid 히트박스의 가장자리와 교차하는 지점이 없으면 대신 중심 위치가
반환됩니다.


<a id="collision-order"></a>

### 충돌 순서

한 타임 스텝 안에서 `Hitbox`가 둘 이상의 다른 `Hitbox`와 충돌하면, `onCollision` 콜백은 사실상
무작위 순서로 호출됩니다. 경우에 따라서는 이것이 문제가 될 수 있습니다. 예를 들어 공이 튀는 게임에서는
어떤 객체와 먼저 부딪혔는지에 따라 공의 궤적이 달라질 수 있습니다. 이를 해결하는 데 도움이 되도록
`collisionsCompletedNotifier` 리스너를 사용할 수 있습니다. 이 리스너는 충돌 감지 과정이 끝날 때
트리거됩니다.

사용 예로, `PositionComponent`에 충돌 중인 다른 컴포넌트를 저장할 지역 변수를 추가할 수 있습니다:
`List<PositionComponent> collisionComponents = [];`. 그런 다음 `onCollision` 콜백을 사용해
다른 모든 `PositionComponent`를 이 리스트에 저장합니다.

```dart
@override
void onCollision(List<Vector2> intersectionPoints, PositionComponent other) {
  collisionComponents.add(other);
  super.onCollision(intersectionPoints, other);
}

```

마지막으로, `PositionComponent`의 `onLoad` 메서드에 리스너를 추가하여 충돌을 어떻게 처리할지
결정하는 함수를 호출합니다.

```dart
(gameRef as HasCollisionDetection)
    .collisionDetection
    .collisionsCompletedNotifier
    .addListener(() {
  resolveCollisions();
});
```

`collisionComponents` 리스트는 `update`가 호출될 때마다 비워 주어야 합니다.


## ShapeHitbox

`ShapeHitbox`는 일반 컴포넌트이므로, 다른 컴포넌트와 마찬가지로 히트박스를 추가하려는 컴포넌트에
추가하면 됩니다.

```dart
class MyComponent extends PositionComponent {
  @override
  void onLoad() {
    add(RectangleHitbox());
  }
}
```

위와 같이 히트박스에 아무 인자도 주지 않으면, 히트박스는 부모를 최대한 채우려고 합니다. 히트박스가
부모를 채우게 하는 것 외에도 히트박스를 초기화하는 방법은 두 가지가 있습니다. 하나는 일반 생성자를
사용해 크기와 위치 등으로 히트박스 자체를 정의하는 방법입니다. 다른 하나는 `relative` 생성자를
사용해 대상 부모의 크기에 대한 상대값으로 히트박스를 정의하는 방법입니다.


특정한 경우에는 히트박스의 부모 컴포넌트로 `onCollision*` 이벤트를 전파하지 않고 히트박스끼리의
충돌만 처리하고 싶을 수 있습니다. 예를 들어 차량에는 충돌을 제어하는 몸체 히트박스와, 왼쪽이나
오른쪽으로 회전할 수 있는지 확인하는 측면 히트박스가 있을 수 있습니다.
즉, 몸체 히트박스와 충돌하는 것은 컴포넌트 자체와 충돌하는 것이지만, 측면 히트박스와 충돌하는 것은
실제 충돌이 아니므로 히트박스의 부모로 전파되어서는 안 됩니다.
이런 경우 `triggersParentCollision` 변수를 `false`로 설정하면 됩니다.

```dart
class MyComponent extends PositionComponent {

  late final MySpecialHitbox utilityHitbox;

  @override
  void onLoad() {
    utilityHitbox = MySpecialHitbox();
    add(utilityHitbox);
  }

  void update(double dt) {
    if (utilityHitbox.isColliding) {
      // 히트박스가 충돌 중일 때 특정 작업을 수행합니다
    }
  }
// 컴포넌트의 onCollision* 함수들. MySpecialHitbox의 충돌은 무시됩니다.
}

class MySpecialHitbox extends RectangleHitbox {
  MySpecialHitbox() {
    triggersParentCollision = false;
  }

// 히트박스 전용 onCollision* 함수들

}
```

각 도형이 어떻게 정의되는지는 [ShapeComponents](components/shape_components.md) 섹션에서 더 자세히
읽을 수 있습니다.

더 복잡한 영역을 구성하기 위해 `PositionComponent`에 `ShapeHitbox`를 원하는 만큼 추가할 수 있다는
점을 기억하세요. 예를 들어 모자를 쓴 눈사람은 세 개의 `CircleHitbox`와 모자에 해당하는 두 개의
`RectangleHitbox`로 표현할 수 있습니다.

히트박스는 충돌 감지에 사용할 수도 있고, 컴포넌트 위에서의 제스처 감지를 더 정확하게 만드는 데
사용할 수도 있습니다. 후자에 대해서는 [GestureHitboxes](inputs/inputs.md#gesturehitboxes) 믹스인에
관한 섹션을 참고하세요.


### CollisionType

히트박스에는 `collisionType`이라는 필드가 있으며, 이 필드는 히트박스가 언제 다른 히트박스와
충돌해야 하는지 정의합니다. 충돌 감지 성능을 높이려면 보통 가능한 한 많은 히트박스를
`CollisionType.passive`로 설정하는 것이 좋습니다. 기본 `CollisionType`은 `active`입니다.

`CollisionType` enum에는 다음 값이 있습니다.

- `active`는 active 또는 passive 타입의 다른 `Hitbox`와 충돌합니다
- `passive`는 active 타입의 다른 `Hitbox`와 충돌합니다
- `inactive`는 다른 어떤 `Hitbox`와도 충돌하지 않습니다

따라서 서로 간의 충돌을 검사할 필요가 없는 히트박스가 있다면 생성자에서
`collisionType: CollisionType.passive`를 설정하여 passive로 지정할 수 있습니다.
예를 들어 지면 컴포넌트가 여기에 해당할 수 있고, 적들끼리 서로 충돌을 검사할 필요가 없다면 적도
`passive`로 지정할 수 있습니다.

서로 충돌할 수 없는 수많은 총알이 플레이어를 향해 날아오는 게임을 상상해 보세요. 이 경우 플레이어는
`CollisionType.active`로, 총알은 `CollisionType.passive`로 설정하면 됩니다.

그리고 `inactive` 타입은 충돌 감지에서 아예 검사되지
않습니다.
예를 들어 지금은 신경 쓰지 않아도 되지만 나중에 다시 화면 안으로 들어올 수 있어서 게임에서 완전히
제거하지는 않은, 화면 밖의 컴포넌트에 사용할 수 있습니다.

이것들은 이 타입들을 사용하는 방법의 예시일 뿐이며, 훨씬 더 많은 사용 사례가 있을 것입니다. 여러분의
사용 사례가 여기에 나와 있지 않더라도 주저하지 말고 사용하세요.


### PolygonHitbox

`PolygonHitbox`는 볼록할 수도 있고 오목할 수도 있습니다. 충돌, `containsPoint`, 레이 캐스팅은 둘 다에서
동작합니다. 어떤 점이 다각형 안에 있는지는 그 점에서 바깥으로 나가는 동안 다각형의 변을 몇 개
지나는지로 판단하기 때문입니다. 다만 비용은 꼭짓점 수에 따라 늘어나므로, 꼭짓점이 많은 다각형은 적은
다각형보다 충돌 검사와 레이 캐스팅 비용이 더 큽니다.

다른 히트박스 도형에는 필수 생성자가 없습니다. 붙어 있는 충돌체의 크기로부터 기본값을 계산할 수 있기
때문입니다. 하지만 다각형은 경계 상자 안에서 무한히 많은 방식으로 만들 수 있으므로, 이 도형은
생성자에서 정의를 직접 넣어 주어야 합니다.

`PolygonHitbox`는 [](components/shape_components.md#polygoncomponent)와 같은 생성자를 가지고
있습니다. 생성자에 대한 문서는 해당 섹션을 참고하세요.

여기에는 `PolygonHitbox.fromPath`도 포함되며, 이 생성자는
[Path의 윤곽으로부터](components/shape_components.md#from-a-path) 히트박스를 만듭니다. 대개 오목한
형태인 스프라이트나 벡터 그래픽의 외곽선을 따르는 히트박스를 빠르게 얻을 수 있는 방법입니다.

```dart
class Spaceship extends SpriteComponent with CollisionCallbacks {
  Spaceship(this.outline);

  final Path outline;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(PolygonHitbox.fromPath(outline, sampling: 2));
  }
}
```

꼭짓점 수가 히트박스의 비용을 결정하므로, 게임에 충분할 만큼 외곽선을 가깝게 따르는 범위 안에서 가장
높은 `sampling` 값을 사용하세요. 윤곽은 히트박스가 생성될 때 순회되므로, 매 틱마다가 아니라 한 번만
생성하세요.


### RectangleHitbox

`RectangleHitbox`는 [](components/shape_components.md#rectanglecomponent)와 같은 생성자를 가지고
있습니다. 생성자에 대한 문서는 해당 섹션을 참고하세요.


### CircleHitbox

`CircleHitbox`는 [](components/shape_components.md#circlecomponent)와 같은 생성자를 가지고
있습니다. 생성자에 대한 문서는 해당 섹션을 참고하세요.


## ScreenHitbox

`ScreenHitbox`는 뷰포트/화면의 가장자리를 나타내는 컴포넌트입니다. 게임에 `ScreenHitbox`를 추가하면
히트박스를 가진 다른 컴포넌트들이 가장자리와 충돌할 때 알림을 받습니다. 인자는 받지 않으며, 추가된
게임의 `size`에만 의존합니다. `ScreenHitbox` 자체는 무언가와 충돌했을 때 알림을 받을 필요가 없다면
게임에서 `add(ScreenHitbox())`만 하면 됩니다. `ScreenHitbox`에는 `CollisionCallbacks` 믹스인이
있으므로, 필요하다면 해당 객체에 직접 `onCollisionCallback`, `onStartCollisionCallback`,
`onEndCollisionCallback` 함수를 추가할 수 있습니다.


## CompositeHitbox

`CompositeHitbox`에는 여러 히트박스를 추가하여 하나로 합쳐진 히트박스처럼
동작하게 할 수 있습니다.

예를 들어 모자를 만들고 싶다면, 모자의 가장자리를 제대로 따르기 위해 두 개의
[](#rectanglehitbox)를 사용하고 싶을 수 있습니다. 그런 다음 그 히트박스들을 이 클래스의 인스턴스에
추가하면, 각 히트박스별로 따로가 아니라 모자 전체에 대한 충돌에 반응할 수 있습니다.


<a id="broad-phase"></a>

## 브로드 페이즈

게임 필드가 아주 크지 않고 충돌 가능한 컴포넌트가 많지 않다면, 사용되는 브로드 페이즈 시스템에
대해 걱정할 필요가 없습니다. 따라서 표준 구현의 성능으로 충분하다면 이 섹션은 읽지 않아도 됩니다.

브로드 페이즈는 충돌 감지의 첫 단계로, 잠재적인 충돌을 계산합니다.
이러한 잠재적 충돌을 계산하는 것은 교차를 정확히 검사하는 것보다 빠르며,
모든 히트박스를 서로 검사할 필요를 없애 주므로
O(n²)를 피할 수 있습니다.

브로드 페이즈는 잠재적 충돌의 집합(`CollisionProspect`의 집합)을
만들어 냅니다. 이 집합은 이후 히트박스 사이의 정확한 교차를 검사하는 데
사용됩니다(이를 "내로 페이즈(narrow phase)"라고 부르기도 합니다).

기본적으로 Flame의 충돌 감지는 sweep and prune 브로드 페이즈 단계를 사용합니다. 게임에 다른 종류의
브로드 페이즈가 필요하다면 `Broadphase`를 확장하여 직접 브로드 페이즈를 작성하고, 사용할 충돌 감지
시스템을 수동으로 설정하면 됩니다.

예를 들어 표준 sweep and prune 대신 마법 같은 알고리즘으로 만든 브로드 페이즈를 구현했다면,
다음과 같이 합니다.

```dart
class MyGame extends FlameGame with HasCollisionDetection {
  MyGame() : super() {
    collisionDetection =
        StandardCollisionDetection(broadphase: MagicAlgorithmBroadphase());
  }
}
```


<a id="quad-tree-broad-phase"></a>

## 쿼드 트리 브로드 페이즈

게임 필드가 크고 충돌 가능한 컴포넌트가 많다면(백 개 이상), 표준 sweep and prune은
비효율적일 수 있습니다. 그런 경우 쿼드 트리 브로드 페이즈를 사용해 볼 수 있습니다.

그렇게 하려면 게임에 `HasCollisionDetection` 대신 `HasQuadTreeCollisionDetection` 믹스인을 추가하고,
게임 로드 시 `initializeCollisionDetection` 함수를 호출합니다.

```dart
class MyGame extends FlameGame with HasQuadTreeCollisionDetection {
  @override
  void onLoad() {
    initializeCollisionDetection(
      mapDimensions: const Rect.fromLTWH(0, 0, mapWidth, mapHeight),
      minimumDistance: 10,
    );
  }
}
```

`initializeCollisionDetection`을 호출할 때는 쿼드 트리 알고리즘이 제대로 동작하도록 올바른 맵 크기를
전달해야 합니다. 시스템을 더 효율적으로 만들기 위한 추가 파라미터도 있습니다.

- `minimumDistance`: 객체들이 충돌할 가능성이 있다고 판단하기 위한 객체 간 최소 거리입니다.
  `null`이면 검사가 비활성화되며, 이것이 기본 동작입니다
- `maxObjects`: 한 사분면에 들어갈 수 있는 최대 객체 수입니다. 기본값은 25입니다.
- `maxDepth`: 사분면 내부의 최대 중첩 수준입니다. 기본값은 10입니다

쿼드 트리 시스템을 사용한다면, 컴포넌트에서 `CollisionCallbacks` 믹스인의 `onComponentTypeCheck`
함수를 구현하여 더욱 효율적으로 만들 수 있습니다.
서로 다른 타입의 항목 간 충돌을 막아야 할 때 유용합니다.
계산 결과는 캐시되므로
여기서 동적인 파라미터를 검사해서는 안 됩니다. 이 함수는 순수한 타입 검사기로 사용하도록
의도되었습니다.

```dart
class Bullet extends PositionComponent with CollisionCallbacks {

  @override
  bool onComponentTypeCheck(PositionComponent other) {
    if (other is Player || other is Water) {
      // Player나 Water와는 충돌하지 않습니다
      return false;
    }
    // 부모의 타입 검사 결과에 관심이 없다면 그냥 true를
    // 반환하세요. 또는 super를 호출해
    // 부모의 결과로 결과를 덮어쓸 수 있습니다.
    return super.onComponentTypeCheck(other);
  }

  @override
  void onCollisionStart(
    List<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    // Brick과 접촉하면 컴포넌트를 제거합니다.
    // Player와 Water는 이전 단계에서 [onComponentTypeCheck]에 의해
    // 걸러지므로 이 함수에 전달되지
    // 않습니다.
    if (other is Brick) {
      removeFromParent();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
```

격렬한 게임플레이가 이어지고 나면 맵에 빈 사분면이 많이 생겨 과도하게 클러스터화될 수 있습니다.
`QuadTree.optimize()`를 실행하면 빈 사분면을 정리할 수 있습니다.

```dart
class QuadTreeExample extends FlameGame
        with HasQuadTreeCollisionDetection {

  /// 격렬한 게임플레이 세션이 끝났을 때 호출되는 함수
  /// 예약해서 실행할 수도 있지만, 매 update마다 실행할 필요는 없습니다.
  /// 게임 상황에 맞는 적절한 간격을 사용하세요
  onGameIdle() {
    (collisionDetection as QuadTreeCollisionDetection)
            .quadBroadphase
            .tree
            .optimize();
  }
}

```

```{note}
항상 다양한 충돌 감지 방식을 실험해 보고
여러분의 게임에서 어떤 성능을 내는지 확인하세요.
`QuadTreeBroadphase`가 기본값보다 훨씬 _느린_ 경우도
드물지 않습니다.
더 정교한 방식이 항상 더 빠르다고 가정하지 마세요.
```


<a id="ray-casting-and-ray-tracing"></a>

## 레이 캐스팅과 레이 트레이싱

레이 캐스팅과 레이 트레이싱은 게임 안의 한 점에서 광선(ray)을 쏘아 보내고, 그 광선이 무엇과
충돌하는지, 그리고 무언가에 부딪힌 뒤 어떻게 반사되는지 알아내는 방법입니다.

아래의 모든 메서드에서 무시하고 싶은 히트박스가 있다면,
호출 시 제외할 히트박스 리스트인 `ignoreHitboxes` 인자를
추가할 수 있습니다.
예를 들어 플레이어나 NPC에 있는 히트박스 안쪽에서 광선을 쏘는 경우,
또는 광선이 `ScreenHitbox`에서 튕겨 나오지 않게 하고 싶은 경우에
꽤 유용합니다.


<a id="ray-casting"></a>

### 레이 캐스팅

레이 캐스팅은 한 점에서 하나 이상의 광선을 쏘아 무언가, Flame의 경우 히트박스에 부딪히는지 확인하는
작업입니다.

이를 위해 `raycast`와 `raycastAll` 두 가지 메서드를 제공합니다. 첫 번째 메서드는 광선 하나만 쏘고,
광선이 무엇에 어디서 부딪혔는지에 대한 정보와 거리, 법선, 반사 광선 같은 추가 정보가 담긴 결과를
돌려받습니다.
두 번째 메서드인 `raycastAll`은
비슷하게 동작하지만 원점 주위로, 또는 원점을 중심으로 한 각도 안에서 여러 광선을 균일하게
쏘아 보냅니다.

기본적으로 `raycast`와 `raycastAll`은 광선의 원점에서 얼마나 떨어져 있는지와 관계없이
가장 가까운 충돌을 찾습니다.
하지만 사용 사례에 따라서는 특정 범위 안의 충돌만 찾고 싶을 수도 있습니다.
이런 경우에는 선택 사항인 `maxDistance`를 지정할 수 있습니다.

레이 캐스팅 기능을 사용하려면 게임에 `HasCollisionDetection` 믹스인이 있어야 합니다. 믹스인을 추가한
뒤에는 게임 클래스에서 `collisionDetection.raycast(...)`를 호출할 수 있으며, `HasGameRef` 믹스인을
사용하면 다른 컴포넌트에서도 호출할 수 있습니다.

예시:

```{flutter-app}
:sources: ../flame/examples
:page: ray_cast
:show: widget code infobox
:width: 180
:height: 160
```

```dart
class MyGame extends FlameGame with HasCollisionDetection {
  @override
  void update(double dt) {
    super.update(dt);
    final ray = Ray2(
        origin: Vector2(0, 100),
        direction: Vector2(1, 0),
    );
    final result = collisionDetection.raycast(ray);
  }
}
```

이 예시에서는 `Ray2` 클래스를 사용하고 있습니다. 이 클래스는 원점 위치와 방향(둘 다 `Vector2`로
정의됨)으로 광선을 정의합니다. 이 광선은 `0, 100`에서 시작하여 오른쪽으로 곧게 뻗어 나갑니다.

이 작업의 결과는 광선이 아무것에도 부딪히지 않았다면 `null`이고, 그렇지 않으면 다음을 담은
`RaycastResult`입니다.

- 광선이 부딪힌 히트박스
- 충돌의 교차점
- 반사 광선, 즉 광선이 부딪힌 히트박스에서 어떻게 반사되는지
- 충돌의 법선, 즉 광선이 부딪힌 히트박스 면에 수직인 벡터

성능이 걱정된다면 `RaycastResult` 객체를 미리 만들어 `out` 인자로 메서드에 전달할 수 있습니다.
그러면 메서드가 매 반복마다 새 객체를 만드는 대신 이 객체를 재사용할 수 있습니다. `update` 메서드에서
레이 캐스팅을 많이 하는 경우에 좋습니다.


#### raycastAll

때로는 원점에서 모든 방향, 또는 제한된 범위의 방향으로 광선을 쏘고 싶을 때가 있습니다. 이는 다양하게
응용할 수 있습니다. 예를 들어 플레이어나 적의 시야를 계산할 수도 있고, 광원을 만드는 데 사용할 수도
있습니다.

예시:

```dart
class MyGame extends FlameGame with HasCollisionDetection {
  @override
  void update(double dt) {
    super.update(dt);
    final origin = Vector2(200, 200);
    final result = collisionDetection.raycastAll(
      origin,
      numberOfRays: 100,
    );
  }
}
```

이 예시에서는 (200, 200)에서 모든 방향으로 균일하게 퍼지는 100개의 광선을 쏘아 보냅니다.

방향을 제한하고 싶다면 `startAngle`과 `sweepAngle` 인자를 사용할 수 있습니다.
`startAngle`(바로 위쪽부터 계산)은 광선이 시작되는 각도이며, 광선은 `startAngle + sweepAngle`에서
끝납니다.

성능이 걱정된다면 함수가 생성하는 `RaycastResult` 객체들을 리스트로 만들어 `out` 인자로 전달하여
재사용할 수 있습니다.


<a id="ray-tracing"></a>

### 레이 트레이싱

레이 트레이싱은 레이 캐스팅과 비슷하지만, 광선이 무엇에 부딪히는지만 확인하는 것이 아니라 광선을
계속 추적할 수 있습니다. 즉, 반사 광선(히트박스에서 튕겨 나온 광선)이 무엇에 부딪히는지, 그리고 그
반사 광선의 반사 광선이 무엇에 부딪히는지 등을 충분히 추적했다고 판단할 때까지 확인할 수 있습니다.
예를 들어 당구공이 당구대에서 어떻게 튕길지 상상해 보면, 그런 정보를 레이 트레이싱의 도움으로 얻을 수
있습니다.

예시:

```{flutter-app}
:sources: ../flame/examples
:page: ray_trace
:show: widget code infobox
:width: 180
:height: 160
```

```dart
class MyGame extends FlameGame with HasCollisionDetection {
  @override
  void update(double dt) {
    super.update(dt);
    final ray = Ray2(
        origin: Vector2(0, 100),
        direction: Vector2(1, 1)..normalize()
    );
    final results = collisionDetection.raytrace(
      ray,
      maxDepth: 100,
    );
    for (final result in results) {
      if (result.intersectionPoint.distanceTo(ray.origin) > 300) {
        break;
      }
    }
  }
}
```

위 예시에서는 (0, 100)에서 오른쪽 아래 대각선 방향으로 광선을 쏘고,
최대 100개의 히트박스에서 튕기도록 지정합니다.
반드시 100개의 결과가 나와야 하는 것은 아닙니다.
어느 시점에 반사 광선 중 하나가 히트박스에 부딪히지 않으면 메서드가 종료되기 때문입니다.

이 메서드는 지연(lazy) 방식으로 동작합니다. 즉, 요청한 계산만 수행하므로 결과를 얻으려면 반환된
iterable을 순회하거나, `toList()`를 호출하여 모든 결과를 바로 계산해야 합니다.

for 루프에서 이를 어떻게 활용하는지 볼 수 있습니다. 이 루프에서는 현재 반사 광선의 교차점(이전
광선이 히트박스에 부딪힌 지점)이 시작 광선의 원점에서 300픽셀보다 멀리 떨어져 있는지 확인하고,
그렇다면 나머지 결과에는 관심을 두지 않습니다(그러면 나머지 결과는 계산할 필요도 없습니다).

성능이 걱정된다면 함수가 생성하는 `RaycastResult` 객체들을 리스트로 만들어 `out` 인자로 전달하여
재사용할 수 있습니다.


<a id="comparison-to-forge2d"></a>

## Forge2D와의 비교

게임에 본격적인 물리 엔진을 사용하고 싶다면
[flame_forge2d](https://github.com/flame-engine/flame/tree/main/packages/flame_forge2d)를
의존성으로 추가하여 Forge2D를 사용하기를
권장합니다.
하지만 사용 사례가 더 단순하고 컴포넌트의 충돌을 확인하고 제스처의 정확도를 높이는 정도만 원한다면,
Flame의 내장 충돌 감지로도 충분히 잘 해낼 수 있습니다.

다음과 같은 요구 사항이 있다면 최소한 [Forge2D](https://github.com/flame-engine/forge2d) 사용을
고려해 보세요.

- 사실적으로 상호작용하는 힘
- 다른 물체와 상호작용할 수 있는 파티클 시스템
- 물체 사이의 조인트

반면, 다음 중 일부만 필요하다면 Flame 충돌 감지 시스템만 사용하는 것이 좋습니다(Forge2D를 끌어들이지
않는 편이 더 단순하기 때문입니다).

- 일부 컴포넌트가 충돌할 때 대응하는 기능
- 컴포넌트가 화면 경계와 충돌할 때 대응하는 기능
- 제스처가 더 정확하도록 컴포넌트의 히트박스로 사용할 복잡한 도형
- 컴포넌트의 어느 부분이 무언가와 충돌했는지 알려 주는 히트박스


<a id="examples"></a>

## 예제

- [Collidable AnimationComponent](https://examples.flame-engine.org/#/Collision_Detection_Collidable_AnimationComponent)
- [Circles](https://examples.flame-engine.org/#/Collision_Detection_Circles)
- [Multiple shapes](https://examples.flame-engine.org/#/Collision_Detection_Multiple_shapes)
- [더 많은 예제](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/collision_detection)
