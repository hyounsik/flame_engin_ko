<a id="migrating-from-forge2d-014"></a>

# forge2d 0.14에서 마이그레이션하기

Forge2D 0.15는 처음부터 새로 작성되었습니다. Box2D 2.x를 순수 Dart로 포팅한 것이 아니라, 이제는
[Box2D v3](https://box2d.org/)에 대한 바인딩 모음이며, 모바일과 데스크톱에서는 네이티브 코드로,
웹에서는 WebAssembly로 실행됩니다. 이 때문에 public API 전체가 바뀌었습니다.

Flame을 통해 Forge2D를 사용한다면
[flame_forge2d 마이그레이션 가이드](../../bridge_packages/flame_forge2d/migration.md)도 함께
참고하세요. 이 가이드는 여기서 설명하는 변경 사항에 더해 `BodyComponent`, `Forge2DWorld`,
접촉 콜백의 변경 사항을 다룹니다.

```{note}
파티클 시스템(LiquidFun)은 Box2D v3에 포함되지 않아 제거되었습니다.
게임이 이 기능에 의존한다면 forge2d 0.14를 계속 사용하세요.
```


<a id="initialization-is-required"></a>

## 초기화가 필요합니다

첫 번째 `World`를 만들기 전에 `await initializeForge2D()`가 완료되어야 합니다. 네이티브
플랫폼에서는 즉시 반환되고, 웹에서는 Box2D WebAssembly 모듈을 로드하며, 이 호출 없이 월드를 만들면
`StateError`가 발생합니다. 0.14에는 이런 호출이 없었으므로 시작 시점에 추가하세요.

```dart
await initializeForge2D();
final world = World(gravity: Vector2(0, -10));
```


<a id="platform-requirements"></a>

## 플랫폼 요구 사항

Dart SDK 최소 버전은 이제 3.12(Flutter 3.44)입니다. 네이티브 플랫폼에서는 번들된 Box2D 소스가
Dart 빌드 훅을 통해 컴파일되므로 C 툴체인이 필요합니다. iOS와 macOS에서는 Xcode, Android에서는 NDK,
Windows에서는 Visual Studio Build Tools, Linux에서는 clang 또는 gcc가 필요합니다. 웹에서는 번들된
WebAssembly 모듈을 일반적인 호스팅 환경에서 자동으로 찾으므로, `initializeForge2D()`를 await 하는
것 외에는 추가 설정이 필요 없습니다.


<a id="fixtures-are-gone-bodies-carry-shapes"></a>

## Fixture가 사라지고 바디가 셰이프를 가집니다

`Body`는 더 이상 `Fixture`를 가지지 않습니다. 대신 `Shape`를 가지며, `Shape`는 불변
`ShapeGeometry`와 선택적인 `ShapeDef`로 만듭니다. 마찰과 반발 계수는 def의 `material`로
옮겨졌습니다.

```dart
// 이전
final shape = CircleShape()..radius = 5;
body.createFixture(FixtureDef(shape, restitution: 0.8, friction: 0.4, density: 2));

// 이후
body.createShape(
  Circle(radius: 5),
  ShapeDef(
    material: SurfaceMaterial(restitution: 0.8, friction: 0.4),
    density: 2,
  ),
);
```

```{warning}
기본 마찰 값이 바뀌었습니다. `FixtureDef`의 기본 마찰은 0이었지만,
`SurfaceMaterial`의 기본값은 0.6입니다. Box2D는 접촉의 마찰을
`sqrt(frictionA * frictionB)`로 혼합하므로, 한쪽이 예전 기본값에 의존하던 쌍은
마찰이 없었지만 이제는 그렇지 않습니다. 그 동작에 의존하던 곳에서는
`SurfaceMaterial(friction: 0)`을 명시적으로 전달하세요.
```

`body.fixtures`는 `body.shapes`가 되고, `fixture.testPoint`는 `shape.testPoint`가 됩니다(여전히
월드 좌표 기준). 셰이프의 지오메트리는 렌더링이나 확인을 위해 `shape.geometry`로 다시 읽을 수
있으며, 이는 sealed 타입인 `ShapeGeometry`를 반환합니다.

```dart
switch (shape.geometry) {
  case Circle(:final center, :final radius):
  case Capsule(:final center1, :final center2, :final radius):
  case Segment(:final point1, :final point2):
  case Polygon(:final points, :final radius):
}
```


<a id="shape-construction"></a>

## 셰이프 생성

| 이전                                | 이후                                                       |
| ----------------------------------- | ---------------------------------------------------------- |
| `CircleShape()..radius = r`         | `Circle(radius: r, center: c)`                             |
| `EdgeShape()..set(a, b)`            | `Segment(point1: a, point2: b)`                            |
| `PolygonShape()..set(vertices)`     | `Polygon(vertices)`                                        |
| `PolygonShape()..setAsBoxXY(w, h)`  | `Polygon.box(w, h)`                                        |
| `ChainShape()..createChain(points)` | `body.createChain(ChainDef(points: points))`               |
| `ChainShape()..createLoop(points)`  | `body.createChain(ChainDef(points: points, isLoop: true))` |

`Capsule`은 새로 추가되었으며, 0.14에는 대응하는 것이 없습니다.

체인은 이제 최소 4개의 점이 필요하며, 한쪽 면만 충돌합니다. 단단한 면은 감기 방향의 오른쪽에
있으므로, 루프는 반시계 방향으로 감고 열린 지면 체인은 오른쪽에서 왼쪽 순서로 나열합니다.
열린 체인에서 첫 번째와 마지막 점은 부드러운 충돌을 위한 고스트 앵커이며 충돌 가능한 선분에
포함되지 않으므로, 점 4개짜리 열린 체인은 선분 하나를 만듭니다. 체인의 선분들은
`chain.segments`로 가져올 수 있습니다.


<a id="contact-listeners-become-polled-events"></a>

## 접촉 리스너가 폴링 이벤트로 바뀌었습니다

`ContactListener`와 `world.setContactListener`는 더 이상 존재하지 않습니다. 각 스텝 이후 월드는
그 스텝 동안 발생한 이벤트를 노출하며, 각 셰이프는 자신이 생성할 이벤트에 옵트인해야 합니다.

```dart
// 이전
class MyListener extends ContactListener {
  @override
  void beginContact(Contact contact) { ... }
}
world.setContactListener(MyListener());

// 이후
body.createShape(Circle(radius: 1), ShapeDef(enableContactEvents: true));

world.step(1 / 60);
for (final event in world.contactEvents.begin) {
  // event.shapeA, event.shapeB, event.normal, event.points
}
```

- `world.contactEvents`는 `begin`, `end`, `hit` 목록을 가집니다. begin 이벤트는 접촉 법선과
  접촉점을 담고 있으며, 이것이 예전의 `Manifold`를 대체합니다.
- `world.sensorEvents`는 `begin`과 `end` 센서 겹침을 가지며, 각각 `sensor`와 `visitor` 셰이프를
  담고 있습니다. 센서와 그 방문자 모두 `ShapeDef.enableSensorEvents`가 필요합니다.
- `world.bodyMoveEvents`는 스텝 동안 움직인 바디를 알려 줍니다.
- end 이벤트는 그사이에 파괴된 셰이프를 참조할 수 있으므로, 사용하기 전에 `Shape.isValid`를
  확인하세요.

`preSolve`는 월드 수준의 `world.preSolveCallback`이 되며, 이 콜백은 이번 스텝에서 접촉을 풀지(solve)
여부를 반환하고, 셰이프에 `ShapeDef.enablePreSolveEvents`가 필요합니다. `postSolve`와
`ContactImpulse`는 없습니다. 충격 세기가 필요하다면 `ShapeDef.enableHitEvents`를 활성화하고
`world.contactEvents.hit`를 읽으세요. 이 이벤트는 `point`, `normal`, `approachSpeed`를 담고 있습니다.
예전에는 contact filter를 상속해서 하던 커스텀 쌍 필터링은 이제 `world.customFilterCallback`입니다.

예전 `Contact` 클래스는 완전히 사라졌으므로, 그 메서드들에는 직접적인 대체가 없습니다. 특히
콜백을 보호하는 데 흔히 쓰이던 `contact.isTouching()`은 begin 이벤트 자체가 셰이프들이 닿기
시작했음을 의미하므로 더 이상 필요하지 않고, `contact.getWorldManifold(...)`는 begin 이벤트의
`normal`과 `points`로 대체됩니다.


<a id="queries-return-their-results"></a>

## 쿼리가 결과를 반환합니다

레이 캐스트와 쿼리 콜백 클래스는 결과를 반환하는 `World`의 메서드로 대체되었습니다. 레이는 이제
두 점이 아니라 원점과 이동량(translation)으로 표현된다는 점에 유의하세요.

```dart
// 이전
class MyCallback extends RayCastCallback {
  @override
  double reportFixture(
    Fixture fixture,
    Vector2 point,
    Vector2 normal,
    double fraction,
  ) { ... }
}
world.raycast(MyCallback(), start, end);

// 이후
final hit = world.castRayClosest(start, end - start);
final allHits = world.castRayAll(start, end - start);
world.castRay(start, end - start, (hit) => 1);
```

각 `RayHit`는 `shape`, `point`, `normal`, `fraction`을 담고 있습니다. `world.queryAABB(callback,
aabb)`는 겹치는 셰이프를 반환하는 `world.overlapAabb(aabb)`가 되며, 축 정렬 경계 상자 클래스의
이름은 `AABB`에서 `Aabb`로 바뀌었습니다. Box2D v3에서는 힘이 스텝마다 적용되므로
`world.clearForces()`는 사라졌습니다. 폭발은 `world.explode(ExplosionDef(...))`로 사용할 수 있습니다.


<a id="joints"></a>

## 조인트

조인트는 월드의 타입별 메서드로 만들고, 조인트 자체에서 파괴합니다. def의 `initialize` 헬퍼는
사라졌습니다. 앵커는 로컬 점으로 지정하며, `body.localPoint(worldAnchor)`로 계산할 수 있습니다.

```dart
// 이전
final jointDef = RevoluteJointDef()..initialize(bodyA, bodyB, anchor);
final joint = RevoluteJoint(jointDef);
world.createJoint(joint);
world.destroyJoint(joint);

// 이후
final joint = world.createRevoluteJoint(
  RevoluteJointDef(
    bodyA: bodyA,
    bodyB: bodyB,
    localAnchorA: bodyA.localPoint(anchor),
    localAnchorB: bodyB.localPoint(anchor),
  ),
);
joint.destroy();
```

사용할 수 있는 조인트는 distance, filter, motor, mouse, prismatic, revolute, weld, wheel입니다.
gear, pulley, rope, friction, constant-volume 조인트는 Box2D v3에 존재하지 않습니다.
`FilterJoint`(두 바디 사이의 충돌만 비활성화)와 `WheelJoint`는 새로 추가되었습니다.

스프링 파라미터의 이름은 `frequencyHz` 대신 `hertz`이며, 스프링은 일반적으로 `enableSpring`으로
명시적으로 활성화해야 합니다. 조인트 접근자는 이제 `getX()`/`setX()` 메서드가 아니라 getter와
setter입니다(예: `joint.motorSpeed = 2`, `joint.angle`). 한계 설정 메서드는 이름 있는 인자를 받습니다:
`joint.setLimits(lower: 0, upper: pi)`.

월드 공간 앵커인 `joint.anchorA`와 `joint.anchorB`는 더 이상 존재하지 않으며, 로컬 앵커만 있습니다.
필요할 때 월드 위치를 계산하세요. 예를 들어 조인트를 렌더링할 때는 다음과 같이 합니다.

```dart
final anchorA = joint.bodyA.worldPoint(joint.localAnchorA);
final anchorB = joint.bodyB.worldPoint(joint.localAnchorB);
```


<a id="world-and-body-changes"></a>

## 월드와 바디의 변경 사항

- `world.stepDt(dt)`는 `world.step(dt, subStepCount: 4)`가 됩니다. 속도와 위치 반복 횟수는
  기본값이 4인 단일 `subStepCount`로 대체되었습니다.
- `world.bodies`는 없습니다. 만든 바디를 직접 추적하거나 `world.bodyMoveEvents`를 사용하세요.
- `World`, `Body`, `Shape`, `Chain`, 그리고 조인트들은 네이티브 엔진 내부 id를 가리키는 가벼운
  값 형태의 핸들입니다. `destroy()`로 명시적으로 파괴하고, 핸들이 이미 파괴된 대상을 가리킬 수
  있을 때는 `isValid`를 확인하세요.
- 회전은 `Rot`(코사인/사인 쌍)으로 표현되므로, `BodyDef(angle: a)`는
  `BodyDef(rotation: Rot.fromAngle(a))`가 되고 `body.setTransform(position, rotation)`은 `Rot`를
  받습니다. `body.angle`은 여전히 존재합니다.
- 바디 이름 변경: `worldCenter`는 이제 `worldCenterOfMass`, `getLocalCenter()`는
  `localCenterOfMass`, `setAwake(value)`는 `isAwake = value`, `getInertia()`는
  `rotationalInertia`, `bodyType`은 `type`, `resetMassData()`는 `applyMassFromShapes()`,
  `setMassData(data)`는 `massData = data`, `worldVector(v)`는 `rotation.rotate(v)`,
  `localVector(v)`는 `rotation.inverseRotate(v)`입니다.
- `BodyDef` 이름 변경: `allowSleep`은 이제 `enableSleep`, `bullet`은 `isBullet`, `active`는
  `isEnabled`입니다.
- 바디별 중력이 바뀌었습니다. `gravityScale`은 이제 `Vector2`가 아니라 `double`이며, 월드 중력에
  곱하는 배수이므로 중력이 0인 월드에서는 아무 효과가 없습니다. `gravityOverride`는 예전 Dart
  포팅의 확장 기능이었으며 Box2D v3에는 대체할 것이 없습니다. 바디에 고유한 중력 벡터를 주려면
  `gravityScale: 0`으로 설정하고(또는 월드 중력을 0으로 유지하고) 매 업데이트마다 직접 힘을
  적용하세요. 예를 들어 `BodyComponent`에서는 다음과 같이 합니다.

  ```dart
  @override
  void update(double dt) {
    super.update(dt);
    body.applyForce(customGravity * body.mass);
  }
  ```

  힘은 매 스텝 후에 초기화되므로, 한 번이 아니라 매 업데이트마다 적용해야 합니다.
  정지한 바디가 계속 잠든 상태로 있어도 된다면 `wake: false`를 전달하세요. 일반 중력도
  이렇게 동작합니다.
- `userData`는 네이티브 포인터 대신 월드 안의 Dart 쪽에 저장되며, 소유한 핸들이 파괴되면
  함께 지워집니다.
