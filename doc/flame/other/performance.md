<a id="performance"></a>

# 성능

다른 게임 엔진과 마찬가지로 Flame도 API를 지나치게 복잡하게 만들지 않으면서 최대한 효율적이도록
노력합니다. 하지만 범용 엔진이라는 특성상 Flame은 만들어지는 게임의 종류에 대해 어떤 가정도 할 수 없습니다.
따라서 게임 개발자에게는 게임이 동작하는 방식에 따라 성능을 최적화할 여지가 항상 남아 있습니다.

한편, 하드웨어에 따라 Flame으로 달성할 수 있는 것에는 항상 명확한 한계가 있습니다. 하지만 하드웨어의
한계와는 별개로, Flame 사용자가 흔히 빠지는 함정이 몇 가지 있으며 이는 간단한 단계를 따르면 쉽게 피할 수 있습니다.
이 섹션에서는 몇 가지 최적화 요령과 흔한 성능 함정을 피하는 방법을 다룹니다.

```{note}
면책 조항: Flame 프로젝트는 저마다 매우 다릅니다. 따라서 여기에서
설명하는 해결책이 항상 눈에 띄는 성능 향상을 가져온다고 보장할 수는 없습니다.
```


<a id="object-creation-per-frame"></a>

## 프레임마다 객체 생성

클래스의 객체를 생성하는 일은 어떤 종류의 프로젝트/게임에서든 매우 흔합니다. 하지만 객체 생성은 꽤
복잡한 작업입니다. 생성되는 객체의 빈도와 양에 따라 애플리케이션이
느려질 수 있습니다.

게임에서는 특히 이 점을 매우 조심해야 합니다. 게임에는 보통 최대한 빠르게 업데이트되는 게임 루프가 있고,
각 업데이트를 프레임이라고 부르기 때문입니다. 하드웨어에 따라 게임은 초당 30, 60, 120 또는 그 이상의
프레임으로 업데이트될 수 있습니다. 즉, 한 프레임에서 새 객체를 생성하면 게임은 결국 초당 프레임 수만큼의
객체를 생성하게 됩니다.

Flame 사용자는 보통 `Component`의 `update`와 `render` 메서드를 오버라이드할 때 이 문제에 부딪힙니다.
예를 들어, 아래의 무해해 보이는 코드에서는 매 프레임마다 새 `Vector2`와
새 `Paint` 객체가 생성됩니다. 하지만 객체 안의 데이터는 모든 프레임에서 본질적으로
같습니다. 이제 60 FPS로 실행되는 게임에 `MyComponent` 인스턴스가 100개 있다고 상상해 보세요.
이는 사실상 매초 `Vector2`와 `Paint`의 새 인스턴스가 각각 6000개(100 * 60)씩
생성된다는 뜻입니다.

```{note}
이메일을 보낼 때마다 새 컴퓨터를 사거나, 무언가를 쓸 때마다
새 펜을 사는 것과 같습니다. 물론 일은 해내지만,
경제적으로 현명한 방법은 아닙니다.
```

```dart
class MyComponent extends PositionComponent {
  @override
  void update(double dt) {
    position += Vector2(10, 20) * dt;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint());
  }
}
```

더 나은 방법은 아래와 같습니다. 이 코드는 필요한 `Vector2`와 `Paint` 객체를
클래스 멤버로 저장해 두고 모든 update와 render 호출에서 재사용합니다.

```dart
class MyComponent extends PositionComponent {
  final _direction = Vector2(10, 20);
  final _paint = Paint();

  @override
  void update(double dt) {
    position.setValues(
      position.x + _direction.x * dt, 
      position.y + _direction.y * dt,
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }
}
```

```{note}
요약하면, 매 프레임마다 불필요한 객체를 생성하지 마세요. 작아 보이는
객체라도 대량으로 생성되면 성능에 영향을 줄 수 있습니다.
```


<a id="unwanted-collision-checks"></a>

## 불필요한 충돌 검사

Flame에는 두 `Hitbox`가 서로 교차하는 순간을 감지할 수 있는 내장 충돌 감지 시스템이 있습니다.
이상적인 경우 이 시스템은 매 프레임 실행되어 충돌을 검사합니다. 또한 실제 교차 검사를 수행하기 전에
충돌 가능성이 있는 것만 걸러낼 만큼 똑똑합니다.

그럼에도 히트박스 수가 늘어날수록 충돌 감지 비용이 증가한다고 보는 것이 안전합니다.
하지만 많은 게임에서 개발자가 항상 가능한 모든 쌍의 충돌을 감지하고 싶어 하는 것은 아닙니다.
예를 들어, 플레이어가 히트박스를 가진 `Bullet` 컴포넌트를 발사할 수 있는 간단한 게임을 생각해 보세요.
이런 게임에서 개발자는 아마 두 총알 사이의 충돌 감지에는 관심이 없겠지만, Flame은 여전히
그 충돌 검사를 수행합니다.

이를 피하려면 총알 컴포넌트의 `collisionType`을 `CollisionType.passive`로 설정하면 됩니다.
그러면 Flame은 모든 passive 히트박스 사이의 충돌 검사를 완전히 건너뜁니다.

```{note}
그렇다고 모든 게임에서 총알 컴포넌트가 항상 passive 히트박스를 가져야 한다는 뜻은 아닙니다.
게임 규칙에 따라 어떤 히트박스를 passive로 만들지는 개발자가 결정할 일입니다.
예를 들어, Flame 예제의 Rogue Shooter 게임은 총알 대신 적에게
passive 히트박스를 사용합니다.
```


<a id="object-pooling"></a>

## 오브젝트 풀링

"프레임마다 객체 생성" 섹션에서 언급했듯이, 객체를 자주 생성하고 파괴하면
성능에 영향을 줄 수 있습니다. 반복적으로 생성되고 제거되는 컴포넌트(총알, 파티클, 적 등)에는
오브젝트 풀링이 효과적인 최적화 기법입니다.

오브젝트 풀링은 객체를 계속 생성하고 파괴하는 대신 재사용합니다. Flame은
오브젝트 풀링을 쉽고 효율적으로 할 수 있도록 `ComponentPool` 클래스를 제공합니다.


### ComponentPool

`ComponentPool` 클래스는 재사용 가능한 컴포넌트의 풀을 관리합니다. 컴포넌트의 생명주기를
자동으로 처리합니다. 풀에서 가져온 컴포넌트가 부모에서 제거되면
재사용을 위해 풀로 반환됩니다.

**풀 생성하기:**

```dart
class MyGame extends FlameGame {
  late final ComponentPool<Bullet> bulletPool;

  @override
  Future<void> onLoad() async {
    bulletPool = ComponentPool<Bullet>(
      factory: () => Bullet(),
      maxSize: 50,      // 풀에 보관할 최대 총알 수
      initialSize: 10,  // 즉시 사용할 수 있도록 총알 10개를 미리 생성
    );
  }
}
```

**풀에서 컴포넌트 가져오기:**

컴포넌트가 필요하면 `acquire()`를 사용해 풀에서 하나를 가져옵니다. 풀이 비어 있으면
팩토리 함수를 사용해 새 컴포넌트가 자동으로 생성됩니다.

```dart
void spawnBullet(Vector2 position, Vector2 velocity) {
  final bullet = bulletPool.acquire();
  bullet.position.setFrom(position);
  bullet.velocity.setFrom(velocity);
  world.add(bullet);
}
```

**컴포넌트를 풀에 반환하기:**

컴포넌트는 게임 트리에서 제거될 때 **자동으로** 풀에 반환됩니다.
컴포넌트에서 `removeFromParent()`를 호출하기만 하면 됩니다. 수동으로 해제하는 단계는 없습니다.

```dart
class Bullet extends SpriteComponent with CollisionCallbacks {
  Vector2 velocity = Vector2.zero();

  @override
  void update(double dt) {
    super.update(dt);
    position.add(velocity * dt);

    // 화면 밖으로 나가면 총알을 제거합니다. 풀에는 자동으로 반환됩니다.
    if (position.x < -100 || position.x > gameRef.size.x + 100) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(List<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    // 충돌하면 풀로 반환합니다. 수동 해제는 필요 없습니다.
    removeFromParent();
  }

  @override
  void onMount() {
    super.onMount();
    // 재사용될 때 컴포넌트가 깨끗한 상태가 되도록 여기서 시각적/내부 상태를 초기화합니다.
    // 호출자가 설정하는 상태(position, velocity)는 acquire()와 add() 사이에
    // 설정되므로 여기서 초기화하면 안 됩니다.
  }
}
```


<a id="pool-management"></a>

### 풀 관리

**사용 가능한 컴포넌트 확인하기:**

현재 풀에서 사용 가능한 컴포넌트가 몇 개인지 확인할 수 있습니다.

```dart
print('Available bullets: ${bulletPool.availableCount}');
```

**풀 비우기:**

메모리를 확보하거나 풀을 초기화해야 한다면 사용 가능한 모든 컴포넌트를 비울 수 있습니다.

```dart
bulletPool.clear();
```

```{note}
비우기는 현재 풀에 있는 컴포넌트에만 영향을 줍니다. 사용 중인 컴포넌트
(가져왔지만 아직 반환되지 않은 컴포넌트)는 영향을 받지 않습니다.
```


<a id="best-practices"></a>

### 모범 사례

1. **특별한 믹스인이 필요 없습니다**: 어떤 `Component` 하위 클래스든 풀링할 수 있습니다.
   `ComponentPool`에 팩토리 함수만 넘기면 바로 사용할 수 있습니다.

2. **내부 상태 초기화에는 `onMount`를 사용하세요**: 시각적 또는 내부 속성(예: 애니메이션 프레임,
   바운스 단계)은 `onMount()`에서 초기화합니다. 호출자가 설정하는 상태(위치나 속도 등)는
   `acquire()`와 `add()` 사이에 설정되므로 여기서 초기화하지 마세요.

3. **`removeFromParent()`만 호출하세요**: 컴포넌트는 제거될 때 자동으로 풀에 반환됩니다.
   따로 호출해야 하는 수동 해제 메서드는 없습니다.

4. **적절한 풀 크기를 설정하세요**: 게임의 필요에 따라 `maxSize`를 설정합니다. 너무 작으면
   새 객체를 자주 생성하게 되고, 너무 크면 메모리를 낭비하게 됩니다.

5. **워밍업에는 `initialSize`를 사용하세요**: 자주 사용하는 컴포넌트를 미리 생성하도록
   `initialSize`를 설정하면 게임플레이 중 프레임 드롭을 줄일 수 있습니다.

6. **풀은 LIFO 방식으로 동작합니다**: 풀은 내부적으로 스택(Last In, First Out)을 사용합니다. 즉,
   가장 최근에 반환된 컴포넌트가 다음에 가져오게 되는 컴포넌트입니다.
