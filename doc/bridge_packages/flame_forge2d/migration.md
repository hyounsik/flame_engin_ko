<a id="migrating-from-flame_forge2d-019"></a>

# flame_forge2d 0.19에서 마이그레이션하기

flame_forge2d 0.20은 Forge2D 0.15를 기반으로 합니다. Forge2D 0.15는 Box2D 2.x의 순수 Dart 포팅을
[Box2D v3](https://box2d.org/) 바인딩으로 대체했습니다. 내부 API 전체가 바뀌었으므로 이는 큰
호환성 깨짐 변경(breaking change)입니다.

이 페이지에서는 마이그레이션 중 flame_forge2d 쪽, 즉 `BodyComponent`, `Forge2DWorld`,
`Forge2DGame`, 접촉 콜백을 다룹니다. 물리 엔진을 직접 다루는 모든 작업
(도형, 조인트, 쿼리, 월드 스텝 진행)은
[Forge2D 마이그레이션 가이드](../../other_modules/forge2d/migration.md)에 설명되어 있으며, 먼저 읽어 보는 것이 좋습니다.

```{note}
파티클 시스템(LiquidFun)은 Box2D v3에 더 이상 존재하지 않으므로
`Forge2DWorld.raycastParticle`과 함께 제거되었습니다. 게임이 이 기능에
의존한다면 flame_forge2d 0.19를 계속 사용하세요.
```


<a id="platform-requirements"></a>

## 플랫폼 요구 사항

이제 최소 SDK는 Dart 3.12(Flutter 3.44)이며, Box2D가 Dart build hook을 통해 컴파일되므로
네이티브 플랫폼용으로 빌드하려면 C 툴체인(iOS와 macOS에서는 Xcode, Android에서는 NDK,
Windows에서는 Visual Studio Build Tools, Linux에서는 clang 또는 gcc)이 필요합니다. 웹에서는
WebAssembly 모듈이 앱에 자동으로 번들되므로 별도의 빌드 설정이 필요
없습니다.

이제 Forge2D는 물리 월드를 생성하기 전에 `await initializeForge2D()`가 필요하며, 웹에서는 이 과정에서
해당 모듈을 불러옵니다. `Forge2DGame`은 자신의 `onLoad`에서 이를 await하고 물리
월드를 지연 생성하므로 게임에서는 변경할 것이 없습니다. 테스트를 포함해 `Forge2DWorld`나 순수 Forge2D
`World`를 직접 생성하는 코드는 먼저 이를 await해야 합니다.


## BodyComponent

Fixture는 사라졌습니다. 이제 바디는 `ShapeGeometry`와 `ShapeDef`로 생성한 도형을 가집니다.
생성자 인자 `fixtureDefs`는 `shapeSpecs`로 대체되었으며, 이는 geometry와 선택적인 def를 짝지은
`ShapeSpec`의 목록입니다.

```dart
// 이전
BodyComponent(
  bodyDef: BodyDef(type: BodyType.dynamic),
  fixtureDefs: [
    FixtureDef(CircleShape()..radius = 5, restitution: 0.8, friction: 0.4),
  ],
);

// 이후
BodyComponent(
  bodyDef: BodyDef(type: BodyType.dynamic),
  shapeSpecs: [
    ShapeSpec(
      Circle(radius: 5),
      ShapeDef(material: SurfaceMaterial(restitution: 0.8, friction: 0.4)),
    ),
  ],
);
```

대신 `createBody`를 오버라이드한다면 `createFixture`/`createFixtureFromShape`를
`createShape`로 바꾸세요.

```dart
// 이전
@override
Body createBody() {
  final shape = EdgeShape()..set(start, end);
  final fixtureDef = FixtureDef(shape, friction: 0.3);
  return world.createBody(BodyDef())..createFixture(fixtureDef);
}

// 이후
@override
Body createBody() {
  final shapeDef = ShapeDef(material: SurfaceMaterial(friction: 0.3));
  return world.createBody(BodyDef())
    ..createShape(Segment(point1: start, point2: end), shapeDef);
}
```

렌더링 훅도 그에 맞게 바뀌었으며, 이제 도형에서 geometry를 다시 읽어 옵니다.

| 이전                               | 이후                                                  |
| ------------------------------------ | ------------------------------------------------------ |
| `renderFixture(Canvas, Fixture)`     | `renderShape(Canvas, Shape)`                           |
| `renderEdge(Canvas, Offset, Offset)` | `renderSegment(Canvas, Offset, Offset)`                |
| `renderChain(Canvas, List<Offset>)`  | 제거됨, chain 세그먼트는 `renderSegment`를 통해 렌더링됨 |
|                                      | `renderCapsule(Canvas, Offset, Offset, double)`이 새로 추가됨 |

`renderCircle`과 `renderPolygon`은 바뀌지 않았습니다. `BodyComponent.center`는 이제
`body.worldCenterOfMass`를 반환하며, `BodyDef(angle: a)`는 `BodyDef(rotation: Rot.fromAngle(a))`가 됩니다.

```{warning}
기본 마찰 값이 바뀌었습니다. `FixtureDef`의 기본값은 0이었지만
`SurfaceMaterial`의 기본값은 0.6입니다. 이전 기본값에 의존하던 도형은
더 이상 마찰이 없는 상태가 아니므로, 이전 동작이 필요한 곳에서는
`SurfaceMaterial(friction: 0)`을 명시적으로 전달하세요.
```

chain이 양면에서 단면으로 바뀌었습니다. 컴파일은 문제없이 되고 바디가 레벨 지형을
뚫고 떨어지는 현상으로만 드러나기 때문에 놓치기 쉽습니다.
단단한 면은 감긴 방향의 오른쪽이며, Flame의 y축은 아래를 향하므로
Box2D 자체 문서에서 설명하는 것과 반대 순서입니다. 지면 chain은 **왼쪽에서 오른쪽으로**
나열하고, 루프는 화면 기준 시계 방향으로 감으세요. 바디가 chain을 뚫고 떨어진다면 점의 순서를 뒤집으세요.

단면 chain은 한쪽에서만 접근하는 지면과 벽에 적합한
도형입니다. 경사로나 바디가 아래에서 닿을 수 있는 플랫폼처럼
모든 방향에서 막아야 하는 단단한 레벨 지형에는 대신 `Polygon`을 사용하세요. chain 루프는
속이 비어 있어서 한 모서리를 통과한 바디가 그 안에 갇히게 됩니다.

알아 두면 좋은 동작 개선 사항이 하나 있습니다. 트리에서 제거된 `BodyComponent`는
기본적으로 바디가 파괴되는데, 이제 이를 안전하게 다시 추가할 수 있습니다.
컴포넌트가 다시 마운트될 때 바디를 다시 생성하기 때문입니다.


<a id="contact-callbacks"></a>

## 접촉 콜백

`ContactCallbacks`는 형태가 그대로이므로, `beginContact`와 `endContact`만 구현하는 컴포넌트는
대부분 계속 동작합니다.

```dart
class Ball extends BodyComponent with ContactCallbacks {
  @override
  void beginContact(Object other, Contact contact) {
    if (other is Wall) { ... }
  }
}
```

바뀐 점:

- `Contact`는 이제 Forge2D의 클래스가 아니라 작은 flame_forge2d 클래스입니다. `shapeA`,
  `shapeB`, `bodyA`, `bodyB`, `isSensorEvent`를 가지며, begin 이벤트의 경우 `normal`과 `points`도 가집니다.
  end 이벤트는 도형이 파괴된 후에 도착할 수 있으므로, 바디를 사용하기 전에 `contact.isValid`를
  확인하세요. `contact.fixtureA`/`fixtureB`는 `contact.shapeA`/`shapeB`가 됩니다. 기존의 `isTouching()`과
  `getWorldManifold()` 메서드는 사라졌습니다. begin 이벤트 자체가 이미 도형들이 닿기 시작했다는 의미이며,
  manifold 데이터는 이벤트 자체에 있습니다.
- **접촉 이벤트는 도형별로 옵트인 방식입니다.** Box2D v3는 이벤트를 요청한 도형에 대해서만 이벤트를
  생성하므로, 관련된 도형에는 `ShapeDef(enableContactEvents: true)`가 필요하고, 센서와
  센서에 들어오는 도형에는 `enableSensorEvents: true`가 필요합니다. 기본 `BodyComponent.createBody()`는
  `bodyDef`나 `ShapeDef`의 `userData`가 `ContactCallbacks`이면 `shapeSpecs`를 통해 생성된 도형에
  두 플래그를 자동으로 설정하지만, `createBody`를 오버라이드한다면 직접
  설정해야 합니다.
- `preSolve`와 `postSolve`는 `ContactCallbacks`에서 제거되었습니다. 접촉이 처리되기 전에 거부하려면
  `world.preSolveCallback`을 설정하고 도형에 `ShapeDef.enablePreSolveEvents`를 활성화하세요.
  충격 강도가 필요하다면 `ShapeDef.enableHitEvents`를 활성화하고
  `world.physicsWorld.contactEvents.hit`을 읽으세요. 이 이벤트에는 `approachSpeed`가 담겨 있습니다. `Manifold`와
  `ContactImpulse`는 더 이상 존재하지 않습니다.
- `WorldContactListener`는 `ContactEventsDispatcher`로 대체되었으며, 월드는 업데이트마다 한 번씩
  이를 폴링합니다. 전달 알고리즘을 커스터마이징했다면 이를 상속하고,
  `contactListener` 인자를 대체한 `Forge2DGame` 또는 `Forge2DWorld`의 `contactEventsDispatcher` 인자로
  전달하세요.

또한 무언가와 닿아 있는 동안 파괴된 바디는 해당 접촉에 대한 마지막 `endContact`를
더 이상 발생시키지 않는다는 점에 유의하세요. 이벤트를 전달하는 데 필요한 userData가 바디와 함께
지워지기 때문입니다.


## Forge2DWorld

- 조인트 헬퍼가 제거되었습니다. 조인트는 물리 월드에서 타입별 메서드로 생성하고
  조인트에서 파괴하세요. `world.createJoint(joint)`와 `world.destroyJoint(joint)`는
  `world.physicsWorld.createRevoluteJoint(def)`와 `joint.destroy()`로 대체됩니다.
- 쿼리는 새로운 Forge2D API를 따릅니다. `raycast(callback, p1, p2)`는 `castRayClosest`,
  `castRay`, `castRayAll`(원점과 이동량을 받음)이 되고, `queryAABB(callback, aabb)`는
  `overlapAabb(aabb)`가 되며, 바운딩 박스 타입의 이름은 `AABB`에서 `Aabb`로 바뀌었습니다.
  `clearForces()`와 `raycastParticle`은 사라졌습니다.
- `world.preSolveCallback`과 `world.customFilterCallback`은 새로 추가된 전달용 setter입니다.
- `subStepCount`(기본값 4)는 각 업데이트에서 수행할 서브 스텝 수를 제어하며, 기존의
  velocity 및 position 반복 횟수를 대체합니다.
- Forge2D는 더 이상 모든 바디의 목록을 노출하지 않으므로 `world.physicsWorld.bodies`는
  `world.bodies`가 되며, 이는 `world.createBody`를 통해 생성된 바디를 추적합니다.
  `world.physicsWorld`에서 직접 생성한 바디는 포함되지 않으며, 중력 setter에 의해 깨어나지도 않습니다.
- 월드를 제거했다가 나중에 다시 추가할 수 있도록 물리 월드는 자동으로 파괴되지 않습니다.
  월드 사용을 완전히 마쳤다면 직접 `world.physicsWorld.destroy()`를 호출하세요.


## Forge2DGame

미터-픽셀 스케일링은 더 이상 카메라의 zoom을 거치지 않으므로, zoom은 카메라 줌 인/아웃에
자유롭게 사용할 수 있습니다.

- `Forge2DGame(zoom: 24)`는 `Forge2DGame(metersToPixels: 24)`가 되고,
  `game.camera.viewfinder.zoom = 24`는 `game.metersToPixels = 24`가 됩니다.
- 기본값이 10에서 100으로 바뀌었으므로, zoom을 설정한 적이 없는 게임은 이제 10배
  크게 렌더링됩니다. 이전과 똑같이 유지하려면 `metersToPixels: 10`을 전달하세요. 다만 먼저
  [](forge2d.md#units-and-scale)을 읽어 보세요. 이전 기본값에는 월드를 1미터보다 훨씬 작게 배치하라는
  권장 사항이 따라왔는데, 이제 그 권장 사항은 오히려 해롭습니다.
- `Forge2DGame`의 카메라는 `Forge2DViewfinder`를 사용하며, 이 뷰파인더는 물리 월드의 1미터를
  `metersToPixels` 픽셀로 렌더링합니다. 뷰파인더의 `zoom`은 그 위에 추가로 적용되며 이제 1에서 시작합니다.
  직접 `camera`를 전달하면 그 뷰파인더가 `Forge2DViewfinder`로 대체되므로, 커스텀 뷰파인더가 있다면
  직접 `Forge2DViewfinder`를 전달하세요.
- 렌더링 외에는 단위가 바뀐 것이 없습니다. 바디 위치,
  `camera.viewfinder.position`, `camera.viewfinder.visibleGameSize`, `camera.visibleWorldRect`, 그리고
  이벤트가 보고하는 로컬 위치는 모두 여전히 미터 단위입니다.
- 예를 들어 바디 위에 Flutter 위젯을 배치할 때처럼 zoom을 사용해 미터와 픽셀을 변환하던 코드는
  대신 `game.metersToPixels`를 사용해야 합니다.


<a id="world-scale"></a>

## 월드 스케일

이 변경은 컴파일과 실행은 문제없이 되는 게임을 망가뜨릴 가능성이 가장 높은 변경입니다.

예전 flame_forge2d는 월드를 픽셀보다 훨씬 작은 미터 단위로 배치하라고 안내했습니다.
Box2D v2가 모든 바디를 스텝당 2미터(약 120 m/s)인 `maxTranslation`으로 제한했기 때문입니다. Box2D v3는
이를 기본값이 400 m/s이고 월드별로 설정 가능한 `WorldDef.maximumLinearSpeed`로 대체했으며,
두 도형이 서로 `Tolerances.speculativeDistance`(0.02미터) 이내에 들어오는 즉시 접촉을 보고하는
speculative contact를 추가했습니다.

결과적으로 일부러 1미터 미만의 스케일로 배치한 월드는 이제 눈에 보이는 간격이 있는데도 접촉을
보고하고, 절대 튕기지 않으며, 바디가 아직 움직이는 중에도 sleep 상태로 만듭니다.
전체 내용은 [](forge2d.md#units-and-scale)을 참고하세요. 요약하면 다음과 같습니다.

- 움직이는 바디가 대략 0.1~10미터가 되도록 월드를 확대하는 것이 좋습니다. 길이
  **와 중력**에 같은 배율을 곱하면 시뮬레이션의 타이밍은 바뀌지 않으며, 그다음
  `metersToPixels`를 같은 배율로 나누면 화면에서 모든 것이 같은 크기로 유지됩니다. 다른 물리량이
  어떻게 스케일되는지는 같은 섹션의 표에 있습니다.
- 그것이 현실적이지 않다면 `Forge2DGame` 생성자에 `lengthUnitsPerMeter`를 전달해 대신
  Box2D의 허용 오차를 여러분의 스케일에 맞추세요. 예를 들어 사람의 키가 0.04 단위인 월드라면
  `super(lengthUnitsPerMeter: 0.04)`를 사용합니다.

디버그 모드에서 flame_forge2d는 이 문제가 생길 만큼 작은 움직이는 바디를 생성하면
경고를 한 번 출력합니다.


<a id="name-collisions"></a>

## 이름 충돌

Forge2D는 `World`를 export하는데, 이는 Flame의 `World` 컴포넌트와 이름이 충돌하므로 둘 다 사용하는 파일에서는
`import 'package:flame_forge2d/flame_forge2d.dart' hide World;`가 필요합니다. 이는 이전에도 마찬가지였고,
Forge2D의 `Transform`과 `flutter/material.dart`의 `Transform` 사이의 충돌도
마찬가지였습니다. 하지만 이제 Forge2D는 `Circle`, `Polygon`, `Shape`도 export하므로,
`flame/experimental.dart`에 있는 것들과 충돌할 수 있습니다. 파일마다 `hide`나 접두사를 붙인 import로
해결하세요. 예를 들면 다음과 같습니다.

```dart
import 'package:flame_forge2d/flame_forge2d.dart' hide Transform, World;
```
