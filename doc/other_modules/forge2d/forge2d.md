# Forge2D

**forge2d** 라이브러리는 [Box2D](https://box2d.org/) 물리 엔진의 Dart 바인딩을 제공하며,
모바일과 데스크톱 플랫폼에서는 엔진을 네이티브 코드로, 웹에서는 WebAssembly로 실행합니다.
Flame 사용 여부와 관계없이 어떤 Dart 프로젝트에서든 사용할 수 있습니다.

Flame 게임에서 Forge2D를 사용하려면 대신
[flame_forge2d](../../bridge_packages/flame_forge2d/flame_forge2d.md) 브릿지 패키지를 사용해야 합니다.
이 패키지는 여기서 설명하는 개념들을 Flame 컴포넌트로 감싸 줍니다.

forge2d 0.14에서 업그레이드하는 경우 [마이그레이션 가이드](migration.md)를 참고하세요.


<a id="getting-started"></a>

## 시작하기

`pubspec.yaml`에 `forge2d`를 추가하고, Forge2D를 초기화한 다음, 월드를 만듭니다.

```dart
import 'package:forge2d/forge2d.dart';

Future<void> main() async {
  // 월드를 만들기 전에 반드시 필요합니다. 아래의 "초기화"를 참고하세요.
  await initializeForge2D();

  final world = World(gravity: Vector2(0, -10));

  final ground = world.createBody(BodyDef(position: Vector2(0, -1)));
  ground.createShape(Polygon.box(50, 1));

  final ball = world.createBody(
    BodyDef(type: BodyType.dynamic, position: Vector2(0, 10)),
  );
  ball.createShape(
    Circle(radius: 0.5),
    ShapeDef(material: SurfaceMaterial(restitution: 0.8)),
  );

  for (var i = 0; i < 120; i++) {
    world.step(1 / 60);
    print(ball.position.y);
  }

  world.destroy();
}
```

forge2d를 단독으로 사용할 때는 월드가 Box2D의 y-up 규칙을 따르므로, 아래쪽 방향의 중력은
음수 y 값을 가진다는 점에 유의하세요. `flame_forge2d` 브릿지는 Flame의 y-down 좌표계에 맞도록
이를 뒤집어 줍니다.


<a id="initialization"></a>

## 초기화

첫 번째 `World`를 만들기 전에 `await initializeForge2D()`가 완료되어야 합니다. 네이티브
플랫폼에서는 즉시 반환되지만, 웹에서는 Box2D WebAssembly 모듈을 가져와 인스턴스화하며,
이 작업이 끝나기 전에 월드를 만들면 `StateError`가 발생합니다. 같은 코드가 모든 플랫폼에서
실행되어야 하므로, 시작할 때 항상 한 번 await 하세요.

```dart
await initializeForge2D();
```

웹 모듈은 Dart 웹 도구가 제공하는 패키지 에셋 경로, Flutter 웹이 자동으로 번들링하는 에셋,
마지막으로 페이지 옆의 `box2d.wasm` 순서로 찾으므로, 일반적인 경우에는 추가 설정이 필요 없습니다.
모듈을 다른 곳에 호스팅한다면 `initializeForge2D(wasmUri: ...)`로 Forge2D가 그 위치를 가리키게
하세요.

`flame_forge2d`는 `Forge2DGame.onLoad`에서 이를 대신 await 하므로, 이를 기반으로 만든 게임은
게임 바깥에서 `World`를 만드는 경우가 아니라면 호출할 필요가 없습니다.

`World`, `Body`, `Shape`, `Chain`, 그리고 조인트들은 네이티브 엔진 내부 id를 가리키는 가벼운
값 형태의 핸들입니다. 해제는 명시적으로 이루어집니다. 핸들을 다 사용했으면 `destroy()`를 호출하고,
`world.destroy()`는 시뮬레이션 전체를 해제합니다.


<a id="shapes"></a>

## 셰이프

바디는 셰이프를 가지며, 셰이프는 불변 `ShapeGeometry`(`Circle`, `Capsule`, `Segment`, `Polygon`)와
밀도, 충돌 필터, 이벤트 플래그, `SurfaceMaterial`(마찰, 반발 계수 등)을 담는 선택적인 `ShapeDef`로
만듭니다. 정적 레벨 지오메트리를 위한 선분 체인은 `body.createChain(ChainDef(points: ...))`로
만듭니다.


<a id="events-and-queries"></a>

## 이벤트와 쿼리

접촉(contact), 센서, 바디 이동 이벤트는 각 스텝 이후 `world.contactEvents`, `world.sensorEvents`,
`world.bodyMoveEvents`를 통해 월드에서 폴링합니다. 이벤트는 `enableContactEvents`,
`enableSensorEvents` 같은 `ShapeDef` 이벤트 플래그로 옵트인한 셰이프에 대해서만 생성됩니다.

레이 캐스트(`castRayClosest`, `castRay`, `castRayAll`)와 AABB 겹침 쿼리(`overlapAabb`)는
`World`에서 직접 사용할 수 있으며, 콜백 클래스를 사용하는 대신 결과를 반환합니다.
폭발은 `World.explode`로 적용합니다.


<a id="joints"></a>

## 조인트

distance, filter, motor, mouse, prismatic, revolute, weld, wheel의 8가지 조인트 타입을 지원합니다.
조인트는 해당 def를 월드의 타입별 메서드에 전달하여 만들고(예:
`world.createRevoluteJoint(RevoluteJointDef(bodyA: ..., bodyB: ...))`), `joint.destroy()`로
제거합니다. 각 조인트에 대한 설명은 [flame_forge2d 조인트
문서](../../bridge_packages/flame_forge2d/joints.md)를 참고하세요.


<a id="platform-support"></a>

## 플랫폼 지원

Forge2D는 Android, iOS, macOS, Windows, Linux, 웹을 지원합니다. 네이티브 플랫폼에서는 번들된
Box2D 소스가 Dart 빌드 훅으로 컴파일되며, 이를 위해 C 툴체인(iOS/macOS에서는 Xcode, Android에서는
NDK, Windows에서는 Visual Studio Build Tools, Linux에서는 clang 또는 gcc)이 필요합니다.
웹에서는 번들된 Box2D의 WebAssembly 빌드가 사용되며, 이는 Dart 웹 도구가 자동으로 제공하고
Flutter 웹 빌드에도 자동으로 번들링됩니다.

자세한 내용은 [forge2d 저장소](https://github.com/flame-engine/forge2d)를 참고하세요.
