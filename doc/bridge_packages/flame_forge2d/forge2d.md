# Forge2D

Blue Fire는 [Box2D](https://box2d.org/) 물리 엔진의 Dart 바인딩인 Forge2D를 관리합니다
(모바일과 데스크톱에서는 네이티브, 웹에서는 WebAssembly).

Forge2D를 Flame에서 사용하려면 브릿지 라이브러리인
[flame_forge2d](https://github.com/flame-engine/flame/tree/main/packages/flame_forge2d)를 사용하고,
Dart 프로젝트에서만 사용하려면
[forge2d](https://github.com/flame-engine/forge2d) 라이브러리를 직접 사용하면 됩니다.

게임에서 사용하려면 `pubspec.yaml`에 `flame_forge2d`를 추가하기만 하면 됩니다. 자세한 내용은
[Forge2D 예제](https://github.com/flame-engine/flame/tree/main/packages/flame_forge2d/example)와
pub.dev의 [설치 안내](https://pub.dev/packages/flame_forge2d)에서
확인할 수 있습니다.

Forge2D는 Box2D를 네이티브 코드로 실행하므로, 네이티브 플랫폼용으로 빌드할 때는 C 툴체인이
필요합니다(iOS/macOS에서는 Xcode, Android에서는 NDK, Windows에서는 Visual Studio Build Tools,
Linux에서는 clang 또는 gcc). 웹에서는 대신 번들된 Box2D WebAssembly 빌드가 사용됩니다.

물리 월드를 생성하기 전에 반드시 `await initializeForge2D()`로 Forge2D를 초기화해야 하며,
웹에서는 이 과정에서 WebAssembly 모듈을 불러옵니다. `Forge2DGame`은 자신의 `onLoad`에서 이를 await하므로
게임에서는 따로 할 일이 없습니다. 하지만 이는 `onLoad`를 오버라이드하는 `Forge2DGame` 하위 클래스가
바디를 생성하기 전에 반드시 `super.onLoad()`를 await해야 한다는 뜻이기도 합니다.

```dart
class MyGame extends Forge2DGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();  // 이것을 await하지 않으면 웹에서 게임이 동작하지 않습니다.
    world.add(MyBody());
  }
}
```

`Forge2DGame` 밖에서 `Forge2DWorld`나 순수 Forge2D `World`를 생성한다면 먼저 직접
`initializeForge2D()`를 await해야 합니다. 그렇지 않으면 웹에서 월드 생성 시 예외가 발생합니다.

기존 게임을 flame_forge2d 0.19에서 업그레이드하는 경우
[마이그레이션 가이드](migration.md)를 참고하세요.


## Forge2DGame

프로젝트에서 Forge2D를 사용할 예정이라면 Forge2D 전용 `FlameGame` 클래스인 `Forge2DGame`을
사용하는 것이 좋습니다.

이 클래스의 이름은 `Forge2DGame`이며, `BodyComponents`라는 Forge2D 전용 특수 컴포넌트와
일반 Flame 컴포넌트를 모두 지원합니다.

`Forge2DGame`에는 `Forge2DViewfinder`를 사용하는 `CameraComponent`가 내장되어 있습니다. 물리 월드는
미터 단위로 측정되며, 뷰파인더는 1미터를 `metersToPixels` 픽셀로 렌더링합니다. 이 값의 기본값은
100입니다. 월드는 현실적인 스케일의 미터 단위로 배치하고, 화면에서 얼마나 크게 보일지는 `metersToPixels`가
결정하도록 하세요. 두 가지를 분리해 두는 이유는 [](#단위와-스케일)를 참고하세요.

스케일은 생성자에서 `super(metersToPixels: yourScale)`을 호출하거나,
나중에 `game.metersToPixels = yourScale;`로 변경할 수 있습니다.

뷰파인더의 `zoom`은 `metersToPixels` 위에 추가로 적용되며 기본값은 1이므로, 원래 용도인
카메라 줌 인/아웃에 자유롭게 사용할 수 있습니다. 렌더링을 제외한 모든 것은 미터 단위로
유지되므로 바디 위치, `camera.viewfinder.position`, `camera.visibleWorldRect`, 그리고 이벤트가 보고하는
로컬 위치는 모두 여전히 미터 단위로 표현됩니다.

Box2D에 이미 익숙하다면, Box2D 월드의 개념 전체가 `Forge2DGame` 컴포넌트의 `world`에 매핑되며,
컴포넌트로 사용하려는 모든 `Body`는 `BodyComponent`로 감싸서 `Forge2DGame`의 `world`에
추가해야 한다는 점을 알아 두면
좋습니다.

`Forge2DGame` 월드의 컴포넌트 목록에는 물리 엔티티와 함께 물리와 관련 없는 컴포넌트도
둘 수 있습니다. update가 호출되면 Forge2D 물리 엔진을 사용해 모든 `BodyComponent`를
적절히 업데이트하며, 게임의 다른 컴포넌트들은 일반적인 `FlameGame` 방식에 따라
업데이트됩니다.

`Forge2DGame`에서는 Flame과 같은 좌표계를 유지하기 위해 `Forge2D`와 비교해 중력이 뒤집혀 있습니다.
따라서 `Vector2(0, 10)`처럼 중력의 y축이 양수이면 바디를 아래로 끌어당기고,
y축이 음수이면 위로 끌어당깁니다. 중력은 `Forge2DGame`의 생성자에서
직접 설정할 수 있습니다.

간단한 `Forge2DGame` 구현 예제는
[examples 폴더](https://github.com/flame-engine/flame/tree/main/packages/flame_forge2d/example)에서 볼 수 있습니다.


<a id="units-and-scale"></a>

## 단위와 스케일

Forge2D는 Box2D이며, Box2D는 미터, 킬로그램, 초 단위에 맞춰 조정되어 있습니다. 월드는 현실적인
스케일의 미터 단위로 배치하고, 움직이는 바디의 크기는 대략 0.1~10미터 사이로 유지하는 것을 목표로 하세요.
가장 이상적인 크기는 1미터입니다. 화면에서 얼마나 크게 보일지는 별개의 결정이며, 바로 그것을 위해
`metersToPixels`가 있습니다.

```{note}
Box2D v3 마이그레이션 이전에 flame_forge2d를 사용했다면, 이는
권장 사항이 바뀐 것입니다. 이전 버전에는 스텝당 2미터라는 고정된
`maxTranslation`(약 120 m/s)이 있었고, 문서에서는 그 한도 아래에
머물기 위해 월드를 1미터보다 훨씬 작게 배치하라고 안내했습니다. 이 한도는
이제 `WorldDef.maximumLinearSpeed`이며, 기본값은 400 m/s이고
`Forge2DWorld(definition: WorldDef(...))`를 통해 월드별로 설정할 수 있습니다.
definition을 전달할 때는 `gravity` 인자도 함께 전달하세요(또는
`WorldDef.gravity`를 명시적으로 설정하세요). definition의 기본값은
Flame의 y-down `(0, 10)`이 아니라 Box2D의 y-up `(0, -10)`이기 때문입니다.
이제 월드를 축소할 이유가 없으며, 오히려 축소하지 말아야 할
충분한 이유가 있습니다.
```


<a id="why-a-shrunken-world-misbehaves"></a>

### 축소된 월드가 오동작하는 이유

Box2D의 몇몇 허용 오차는 적용 대상 도형에 대한 비율이 아니라 절대 길이입니다. 따라서
1미터보다 훨씬 작은 스케일로 배치된 월드에서는 이 값들을 더 이상 무시할 수 없게 되고
오히려 동작을 좌우하게 됩니다.

| 허용 오차                        | 기본값  | 폭이 1미터뿐인 월드에서 일어나는 일   |
| -------------------------------- | -------- | --------------------------------------------- |
| `Tolerances.speculativeDistance` | 0.02 m   | 월드 폭의 2%에 걸쳐 접촉이 보고됨  |
| `WorldDef.restitutionThreshold`  | 1 m/s    | 아무것도 튕기지 않음                          |
| `WorldDef.hitEventThreshold`     | 1 m/s    | hit 이벤트가 전혀 생성되지 않음              |
| `BodyDef.sleepThreshold`         | 0.05 m/s | 바디가 아직 움직이는 중에 sleep 상태가 됨         |
| `WorldDef.maxContactPushSpeed`   | 3 m/s    | 겹친 바디들이 격렬하게 밀려남 |
| `Tolerances.aabbMargin`          | 0.05 m   | broadphase 경계가 도형보다 훨씬 커짐            |

이 중 첫 번째가 버그로 보고되는 항목입니다. Box2D는 서로 가까워지고 있지만 아직 닿지 않은 도형에 대해
접촉점을 생성합니다. 이 덕분에 빠른 바디가 물체를 통과하는 것을 막고 대부분의 충돌 떨림을
없앨 수 있습니다. 하지만 이는 최대 `Tolerances.speculativeDistance`만큼의 눈에 보이는 간격이 남아 있는
상태에서도 `beginContact`가 발생한다는 뜻이기도 합니다. 이 값보다 충분히 크지 않은 바디는
이웃한 바디와 항상 접촉 상태가 됩니다. flame_forge2d는 그렇게 작은 움직이는 바디를 발견하면
디버그 모드에서 경고를 한 번 출력합니다.


<a id="scaling-a-world-up"></a>

### 월드 확대하기

현재 월드가 너무 작다면 월드를 확대하고 중력도 함께 확대하세요. 이 마지막 부분은
놓치기 쉽습니다. 길이만 확대하면 모든 것이 당밀 속에서 움직이는 것처럼 보이지만,
길이와 중력을 같은 배율로 확대하면 시뮬레이션의 타이밍은
전혀 바뀌지 않습니다. 길이 배율이 `S`일 때는 다음과 같습니다.

| 물리량                                                      | 배율           |
| ------------------------------------------------------------- | ------------------ |
| 길이, 위치, 반지름, 속도, 중력, 가속도 | `S`                |
| 밀도, 마찰, 반발, 감쇠, 각속도 | `1`, 변경 없음     |
| 질량                                                        | `S²`               |
| 힘, 선형 충격량                                       | `S³`               |
| 토크, 회전 관성, 각 충격량                 | `S⁴`               |
| **시간**                                                      | **`1`, 변경 없음** |

따라서 높이 1미터, 공 0.02 m, 중력 9.81인 월드는 높이 10미터, 공 0.2 m,
중력 98.1인 월드가 되며, 동작은 완전히 같으면서도 Box2D가 조정된 범위 안에 여유 있게
들어갑니다. 화면에서 같은 크기로 보이게 하려면 `metersToPixels`를 같은 배율로 나누세요.


<a id="when-the-layout-cannot-change"></a>

### 레이아웃을 바꿀 수 없는 경우

월드를 확대하는 것이 현실적이지 않다면, 길이 단위 몇 개가 1미터인지를 Box2D에 알려 주세요.
그러면 위 첫 번째 표의 모든 허용 오차가 그에 맞춰 조정됩니다.

```dart
class MyGame extends Forge2DGame {
  MyGame() : super(lengthUnitsPerMeter: 0.04);
}
```

플레이어 캐릭터의 키를 기준으로 삼는 것이 좋은 경험 법칙입니다. 캐릭터의 키가 0.04 단위이고
이를 사람으로 생각한다면 0.04를 전달하세요. 그러면 같은 표를 사용해 해당 스케일에서
중력, 밀도, 힘이 적절한 값이 되도록 하는 것은 여러분의 몫입니다.

이 값은 Box2D 내부의 프로세스 전역 설정이며 물리 월드가 존재한 뒤에는 바꿀 수 없으므로,
생성자에만 전달할 수 있고 동시에 실행되는 여러 게임이 같은 값을 사용해야 합니다.
이미 적용된 값과 다른 값을 요청하는 게임은 시뮬레이션을 조용히 망가뜨리는 대신
`StateError`를 던집니다.


## Forge2DWorld

`Forge2DWorld`는 모든 [`BodyComponent`]가 존재하는 월드입니다. `Forge2DGame`에는 기본적으로
`world`라는 `Forge2DWorld` 인스턴스가 있으며, 여기에
`BodyComponent`를 추가하면 됩니다.

월드를 교체하고 싶다면 직접 `Forge2DWorld` 인스턴스를 만들어 `Forge2DGame` 인스턴스의
`world` 속성에 할당하면 됩니다(`game.world = Forge2DWorld()`).

나중에 월드를 재사용하면서 물리 상태를 유지하고 싶다면, 월드가 게임에서 제거될 때
바디가 파괴되지 않도록 해야 합니다. `game.world.destroyBodiesOnRemove = false;`처럼
`world.destroyBodiesOnRemove`를 false로 설정하면 됩니다.

내부의 Forge2D 물리 월드는 `world.physicsWorld`로 접근할 수 있습니다. 이를 사용해 joint 생성이나
원시 이벤트 스트림 폴링처럼 `Forge2DWorld`가 감싸지 않은 Forge2D API의 부분에
접근할 수 있습니다.


## BodyComponent

`BodyComponent`는 물리 엔진과 상호작용하는 바디인 `Forge2D` 바디의 래퍼입니다.
바디는 하나 이상의 `Shape`를 가지며, 이 `Shape`는 `ShapeGeometry`(`Circle`, `Capsule`, `Segment`,
`Polygon`, 그리고 `body.createChain`을 통한 chain)와, 표면 재질(마찰, 반발), 밀도, 필터,
이벤트 플래그를 담는 선택적인 `ShapeDef`로
생성됩니다.

`BodyComponent`를 만드는 방법은 다음과 같습니다.

- `createBody()`를 오버라이드해 바디를 생성하고 반환합니다.
- BodyComponent의 생성자에 `BodyDef` 인스턴스(그리고 선택적으로 `ShapeGeometry`와 선택적인 `ShapeDef`를
짝지은 `ShapeSpec` 인스턴스 목록)를 전달해 기본 `createBody()` 구현을
사용합니다.
- 기본 `createBody()` 구현을 사용하면서 `this.bodyDef`에 `BodyDef` 인스턴스를 할당하고,
선택적으로 `this.shapeSpecs`에 `ShapeSpec` 인스턴스 목록을 할당합니다.

```dart
final ball = BodyComponent(
  bodyDef: BodyDef(type: BodyType.dynamic),
  shapeSpecs: [
    ShapeSpec(
      Circle(radius: 0.5),
      ShapeDef(material: SurfaceMaterial(restitution: 0.8)),
    ),
  ],
);
```

`BodyComponent`는 기본적으로 `renderBody = true`입니다. 그렇지 않으면 `Body`를 만들고 `BodyComponent`를
게임에 추가한 후에도 아무것도 보이지 않기 때문입니다. 이를 끄고 싶다면 `renderBody`를 false로
설정(또는 오버라이드)하면 됩니다.

다른 Flame 컴포넌트와 마찬가지로 `BodyComponent`에도 자식을 추가할 수 있습니다. 예를 들어 바디 위에
애니메이션이나 다른 컴포넌트를 추가하고 싶을 때 매우 유용합니다.

생성하는 바디는 Forge2D의 좌표계(Y축이 뒤집혀 있음)가 아니라
Flame의 좌표계를 기준으로 정의해야 합니다.

:exclamation: Forge2D에서는 바디를 다른 컴포넌트의 자식으로 추가하면 안 됩니다.
Forge2D에는 중첩된 바디라는 개념이 없기 때문입니다.
따라서 바디는 물리 월드의 최상위, 즉 `Forge2DGame.world`에 있어야 합니다.
그러므로 `add(Weapon()))` 대신 (아래처럼) `world.add(Weapon())`을 사용해야 하며, 물론 `Player`도
처음부터 월드에 추가해야 합니다.

```dart
class Weapon extends BodyComponent {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // ...
  }
}

class Player extends BodyComponent {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    world.add(Weapon());
  }
}
```

나중에 무기에서 발사되는 총알을 추가하고 싶을 수도 있습니다. 총알도 같은 방식으로 월드에 추가하지만,
매우 빠르게 움직일 예정이라면 터널링 문제를 피하기 위해 반드시 `isBullet = true`로
설정하세요.


<a id="contact-callbacks"></a>

## 접촉 콜백

`Forge2DGame`은 접촉 이벤트를 전파하는 간단한 기본 제공 솔루션을 제공합니다.

접촉 이벤트는 두 `Shape`가 서로 만날 때마다 발생합니다. 이 이벤트를 통해 `Shape`들이
접촉하기 시작할 때(`beginContact`)와 접촉이 끝날 때(`endContact`)를
수신할 수 있습니다. 센서 겹침도 같은 콜백으로 전달됩니다.

이 이벤트를 수신하는 방법은 여러 가지입니다. 일반적인 방법 중 하나는 이 이벤트에 관심 있는
`BodyComponent`에서 `ContactCallbacks` 클래스를 믹스인으로 사용하는 것입니다.

```dart
class Ball extends BodyComponent with ContactCallbacks {
  ...
  void beginContact(Object other, Contact contact) {
    if (other is Wall) {
      // 여기서 무언가를 수행합니다.
    }
  }
  ...
}
```

위 코드가 동작하려면 `Ball`의 `body.userData` 또는 접촉하는 `shape.userData`가
`ContactCallbacks`로 설정되어 있어야 합니다. 그리고 `Wall`이 `BodyComponent`라면 그 `body.userData` 또는 접촉하는
`shape.userData`가 `Wall`로 설정되어 있어야 합니다.

`userData`가 `null`이면 접촉 이벤트는 무시되며, 기본값은 `null`입니다.

Forge2D는 이벤트를 받겠다고 설정한 도형에 대해서만 이벤트를 생성하므로, 관련된 도형에는
`ShapeDef.enableContactEvents`도 true로 설정되어 있어야 합니다(센서와 센서에 들어오는 도형에는
`ShapeDef.enableSensorEvents`). `BodyComponent`의 기본 `createBody()` 구현은 바디나 도형의 userData에
`ContactCallbacks`가 있으면 `shapeSpecs`를 통해 생성된 도형에 이 플래그들을 자동으로 활성화합니다.
하지만 `createBody()`를 오버라이드한다면 직접 설정해야
합니다.

```dart
class Ball extends BodyComponent with ContactCallbacks {
  ...

  @override
  Body createBody() {
    ...
    final bodyDef = BodyDef(
      userData: this,
    );
    final shapeDef = ShapeDef(
      enableContactEvents: true,
    );
    ...
  }

}
```

`Ball`과 `Wall`이 접촉하기 시작할 때마다 `beginContact`가 호출되고,
도형 간의 접촉이 끝나면 `endContact`가 호출됩니다.

기존의 `preSolve`와 `postSolve` 콜백은 더 이상 존재하지 않습니다. 접촉이 처리되기 전에 비활성화하려면
(예: 한쪽 방향으로만 통과할 수 있는 플랫폼) `ShapeDef.enablePreSolveEvents`와 함께 `world.preSolveCallback`을
사용하세요. 충격 강도를 측정하려면 `ShapeDef.enableHitEvents`를 활성화하고
`world.physicsWorld.contactEvents.hit`을 폴링하세요.

구현 예제는 [Flame Forge2D
예제](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/bridge_libraries/flame_forge2d/utils/balls.dart)에서 볼 수 있습니다.
