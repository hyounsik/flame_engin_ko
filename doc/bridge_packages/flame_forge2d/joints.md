<a id="joints"></a>

# 조인트

조인트는 서로 다른 두 바디를 다양한 방식으로 연결하는 데 사용합니다.
조인트는 객체 간의 상호작용을 시뮬레이션해 경첩, 바퀴, 로프, 체인 등을 만드는 데 도움이 됩니다.

조인트의 `Body` 중 하나는 `BodyType.static` 타입일 수 있습니다. `BodyType.static` 및/또는
`BodyType.kinematic` 사이의 조인트도 허용되지만, 아무 효과가 없으면서 처리 시간을 소모합니다.

`Joint`를 생성하려면 해당하는 `JointDef` 하위 클래스를 파라미터와 함께 만들고,
물리 월드의 타입별 생성 메서드에 전달합니다. 예를 들면
`world.physicsWorld.createRevoluteJoint(revoluteJointDef)`와 같습니다. 생성 메서드는 해당 타입의 조인트를 반환하며,
조인트를 제거하려면 `joint.destroy()`를 호출합니다.


<a id="built-in-joints"></a>

## 기본 제공 조인트

현재 Forge2D는 다음 조인트를 지원합니다.

- [`DistanceJoint`](#distancejoint)
- [`FilterJoint`](#filterjoint)
- [`MotorJoint`](#motorjoint)
- [`MouseJoint`](#mousejoint)
- [`PrismaticJoint`](#prismaticjoint)
- [`RevoluteJoint`](#revolutejoint)
- [`WeldJoint`](#weldjoint)
- [`WheelJoint`](#wheeljoint)

이전 Forge2D 버전에 있던 gear, pulley, rope, friction, constant-volume 조인트는 Box2D v3에
존재하지 않으므로 Forge2D에서도 더 이상 존재하지 않습니다.


### `DistanceJoint`

`DistanceJoint`는 두 바디 위의 두 점이 서로 고정된 거리를 유지하도록
제약합니다.

질량이 없는 단단한 막대라고 생각할 수 있으며, 스프링을 활성화하면
스프링/댐퍼 역할도 할 수 있습니다.

```dart
world.physicsWorld.createDistanceJoint(
  DistanceJointDef(
    bodyA: firstBody,
    bodyB: secondBody,
    length: 10,
    enableSpring: true,
    hertz: 3,
    dampingRatio: 0.2,
  ),
);
```

```{flutter-app}
:sources: ../../examples
:page: distance_joint
:subfolder: stories/bridge_libraries/flame_forge2d/joints
:show: code popup
```

가장 많이 사용되는 `DistanceJointDef` 파라미터는 다음과 같습니다.

- `localAnchorA`, `localAnchorB`: 각 바디의 원점을 기준으로 한 앵커 점입니다.

- `length`: 두 앵커 점 사이의 거리를 결정하며 0보다
커야 합니다. 기본값은 1입니다.

- `enableSpring`, `hertz`, `dampingRatio`: 스프링을 활성화하면 막대가 부드러워집니다.
`hertz` 값이 높을수록 스프링이 단단해지며, `dampingRatio`는 진동이 얼마나 빨리 멈추는지를 정의합니다.
0은 감쇠 없음, 1은 임계 감쇠를 의미합니다.

- `enableLimit`, `minLength`, `maxLength`: 스프링이 활성화되어 있을 때 바디 사이의 거리를 일정 범위로
제한합니다.

- `enableMotor`, `motorSpeed`, `maxMotorForce`: 바디 사이의 거리를 구동합니다.

```{warning}
길이를 0이나 짧은 값으로 사용하지 마세요.
```


### `FilterJoint`

`FilterJoint`는 바디를 전혀 제약하지 않습니다. 유일한 목적은 연결된 두 바디 사이의
모든 충돌을 비활성화하는 것입니다.

```dart
world.physicsWorld.createFilterJoint(
  FilterJointDef(bodyA: firstBody, bodyB: secondBody),
);
```


### `MotorJoint`

`MotorJoint`는 두 바디 사이의 상대적인 움직임을 제어하는 데 사용합니다. 일반적인 용도는
고정된 점을 기준으로 동적 바디의 움직임을 제어하는 것으로, 예를 들어 애니메이션을 만들 때
사용합니다.

`MotorJoint`를 사용하면 목표 위치와 회전 오프셋을 지정해 바디의 움직임을 제어할 수 있습니다.
목표 위치와 회전에 도달하기 위해 적용할 최대 모터 힘과 토크를 설정할 수 있습니다. 바디가 막히면
멈추며, 접촉 힘은 최대 모터 힘과 토크에
비례합니다.

```dart
final motorJoint = world.physicsWorld.createMotorJoint(
  MotorJointDef(
    bodyA: first,
    bodyB: second,
    maxForce: 1000,
    maxTorque: 1000,
    correctionFactor: 0.1,
  ),
);
```

```{flutter-app}
:sources: ../../examples
:page: motor_joint
:subfolder: stories/bridge_libraries/flame_forge2d/joints
:show: code popup
```

`MotorJointDef`에는 다음과 같은 선택적 조정 파라미터가 있습니다.

- `maxForce`: 목표 위치에 도달하기 위해 연결된 바디에 적용할 최대 병진
힘입니다.

- `maxTorque`: 목표 회전에 도달하기 위해 연결된 바디에 적용할 최대 회전
힘입니다.

- `correctionFactor`: [0, 1] 범위의 위치 보정 계수입니다. 목표 위치에서 벗어났을 때 조인트가 반응하는
정도를 조정합니다. 값이 높을수록 조인트가 더 빠르게 반응하고, 값이 낮을수록
더 느리게 반응합니다. 값을 너무 높게 설정하면 조인트가 과도하게 보정하며 진동해
불안정해질 수 있습니다. 너무 낮게 설정하면 반응이 너무 느릴 수 있습니다.

선형 오프셋과 각 오프셋은 바디들이 서로의 위치와 회전을 기준으로 도달해야 하는 목표 거리와
각도입니다. `MotorJointDef`에 `linearOffset`과 `angularOffset`으로 전달하거나,
나중에 `MotorJoint`의 같은 이름의 setter로
변경할 수 있습니다.

예를 들어 다음 코드는 매 업데이트 주기마다 조인트의 각 오프셋을 증가시켜
바디를 회전시킵니다.

```dart
@override
void update(double dt) {
  super.update(dt);

  joint.angularOffset = joint.angularOffset + motorSpeed * dt;
}
```


### `MouseJoint`

`MouseJoint`는 마우스로 바디를 조작하는 데 사용합니다. 바디 위의 한 점을 커서의 현재 위치로
끌어가려고 합니다. 회전에는 제한이 없습니다.

`MouseJoint` 정의에는 목표 점, 최대 힘, hertz, 감쇠 비율이 있습니다.
목표 점은 처음에 바디의 앵커 점과 일치합니다. 최대 힘은 여러 동적 바디가 상호작용할 때
격렬한 반응을 막기 위해 사용합니다. 원하는 만큼 크게 설정해도 됩니다.
hertz와 감쇠 비율은 distance 조인트와 비슷한 스프링/댐퍼 효과를 만드는 데
사용합니다.

```{warning}
많은 사용자가 mouse 조인트를 게임 플레이에 맞게 활용하려고 시도했습니다. 사용자들은
보통 정밀한 위치 지정과 즉각적인 반응을 원합니다. mouse 조인트는
그런 상황에서 잘 동작하지 않습니다. 대신 kinematic 바디를
사용하는 것을 고려해 보세요.
```

```dart
final mouseJoint = world.physicsWorld.createMouseJoint(
  MouseJointDef(
    bodyA: groundBody,
    bodyB: ballBody,
    target: ballBody.position,
    maxForce: 3000 * ballBody.mass * 10,
    dampingRatio: 1,
    hertz: 5,
  ),
);
```

```{flutter-app}
:sources: ../../examples
:page: mouse_joint
:subfolder: stories/bridge_libraries/flame_forge2d/joints
:show: code popup
```

- `maxForce`: 대상 바디를 움직이기 위해 가할 수 있는 최대 제약 힘을
  정의합니다. 보통 무게의 배수로 표현합니다
  (배수 *질량* 중력).

- `dampingRatio`: 진동이 얼마나 빨리 멈추는지를 정의합니다. 범위는
  0에서 1까지이며, 0은 감쇠 없음, 1은 임계 감쇠를 의미합니다.

- `hertz`: 바디의 반응 속도, 즉 목표 위치에 얼마나 빨리 도달하려고 하는지를
  정의합니다.

- `target`: 초기 월드 목표 점입니다. 처음에는 바디 앵커와 일치한다고
  가정합니다. 드래그하는 동안에는 `target` setter를 통해 업데이트합니다.
  `mouseJoint.target = newPosition;`.


### `PrismaticJoint`

`PrismaticJoint`는 하나의 자유도를 제공하며, bodyA에 고정된 축을 따라 두 바디가 상대적으로
평행 이동할 수 있게 합니다. 상대적인 회전은 막힙니다.

`PrismaticJointDef`는 로컬 축과 앵커 점을 사용해 운동 직선을 정의해야 합니다.
정의에서 로컬 앵커 점과 로컬 축을 사용하므로 초기 구성이 제약 조건을
약간 벗어나도 됩니다.

로컬 앵커 점들이 월드 공간에서 일치할 때 조인트의 평행 이동 값은 0입니다.

```{warning}
적어도 하나의 바디는 회전이 고정되지 않은 동적 바디여야 합니다.
```

`PrismaticJoint` 정의는 [`RevoluteJoint`](#revolutejoint) 정의와 비슷하지만,
회전 대신 평행 이동을 사용합니다.

```dart
final prismaticJoint = world.physicsWorld.createPrismaticJoint(
  PrismaticJointDef(
    bodyA: dynamicBody,
    bodyB: groundBody,
    localAxisA: Vector2(1, 0),
  ),
);
```

```{flutter-app}
:sources: ../../examples
:page: prismatic_joint
:subfolder: stories/bridge_libraries/flame_forge2d/joints
:show: code popup
```

- `bodyA`, `bodyB`: 조인트로 연결되는 바디입니다.
- `localAnchorA`, `localAnchorB`: 각 바디의 원점을 기준으로 한 앵커 점입니다.
- `localAxisA`: bodyA 프레임에서의 평행 이동 축으로, 이 축을 따라 평행 이동이 고정됩니다.


<a id="prismatic-joint-limit"></a>

#### Prismatic Joint 제한

하한과 상한 평행 이동 값을 지정하는 조인트 제한으로 상대적인 평행 이동을
제한할 수 있습니다.

```dart
PrismaticJointDef(
  ...
  enableLimit: true,
  lowerTranslation: -20,
  upperTranslation: 20,
);
```

- `enableLimit`: 평행 이동 제한을 활성화하려면 true로 설정합니다
- `lowerTranslation`: 미터 단위의 평행 이동 하한입니다
- `upperTranslation`: 미터 단위의 평행 이동 상한입니다

조인트를 생성한 후에는 다음 메서드로 제한을 변경할 수 있습니다.

```dart
prismaticJoint.setLimits(lower: -10, upper: 10);
```


<a id="prismatic-joint-motor"></a>

#### Prismatic Joint 모터

모터를 사용해 움직임을 구동하거나 조인트 마찰을 모델링할 수 있습니다. 무한한 힘이 생성되지 않도록
최대 모터 힘이 제공됩니다.

```dart
PrismaticJointDef(
  ...
  enableMotor: true,
  motorSpeed: 1,
  maxMotorForce: 100,
);
```

- `enableMotor`: 모터를 활성화하려면 true로 설정합니다
- `motorSpeed`: 초당 미터 단위의 목표 모터 속도입니다
- `maxMotorForce`: 목표 모터 속도에 도달하는 데 사용하는 N 단위의 최대 모터 힘입니다.

조인트를 생성한 후에는 다음 setter로 모터의 속도와 힘을 변경할 수 있습니다.

```dart
prismaticJoint.motorSpeed = 2;
prismaticJoint.maxMotorForce = 200;
```

또한 다음 getter로 조인트의 평행 이동 값과 속도를 가져올 수 있습니다.

```dart
prismaticJoint.translation;
prismaticJoint.speed;
```


### `RevoluteJoint`

`RevoluteJoint`는 두 바디가 흔히 경첩 점이라고 부르는 공통 앵커 점을 공유하도록 강제합니다.
revolute 조인트는 두 바디의 상대적인 회전이라는 하나의 자유도를 가집니다.

`RevoluteJoint`를 만들려면 두 바디와 경첩 점에서 일치하는 로컬 앵커 점을 제공합니다.
정의에서 로컬 앵커 점을 사용하므로 초기 구성이 제약 조건을
약간 벗어나도 됩니다.

```dart
final revoluteJoint = world.physicsWorld.createRevoluteJoint(
  RevoluteJointDef(
    bodyA: firstBody,
    bodyB: secondBody,
    localAnchorA: firstBody.localPoint(anchor),
    localAnchorB: secondBody.localPoint(anchor),
  ),
);
```

```{flutter-app}
:sources: ../../examples
:page: revolute_joint
:subfolder: stories/bridge_libraries/flame_forge2d/joints
:show: code popup
```

경우에 따라 조인트 각도를 제어하고 싶을 수 있습니다. 이를 위해 `RevoluteJointDef`에는
조인트 제한 및/또는 모터를 시뮬레이션할 수 있는 선택적 파라미터가 있습니다.


<a id="revolute-joint-limit"></a>

#### Revolute Joint 제한

하한과 상한 각도를 지정하는 조인트 제한으로 상대적인 회전을 제한할 수 있습니다.

```dart
RevoluteJointDef(
  ...
  enableLimit: true,
  lowerAngle: 0,
  upperAngle: pi / 2,
);
```

- `enableLimit`: 각도 제한을 활성화하려면 true로 설정합니다
- `lowerAngle`: 라디안 단위의 하한 각도입니다
- `upperAngle`: 라디안 단위의 상한 각도입니다

조인트를 생성한 후에는 다음 메서드로 제한을 변경할 수 있습니다.

```dart
revoluteJoint.setLimits(lower: 0, upper: pi);
```


<a id="revolute-joint-motor"></a>

#### Revolute Joint 모터

모터를 사용해 공유 점을 중심으로 한 상대적인 회전을 구동할 수 있습니다. 무한한 힘이 생성되지 않도록
최대 모터 토크가 제공됩니다.

```dart
RevoluteJointDef(
  ...
  enableMotor: true,
  motorSpeed: 5,
  maxMotorTorque: 100,
);
```

- `enableMotor`: 모터를 활성화하려면 true로 설정합니다
- `motorSpeed`: 초당 라디안 단위의 목표 모터 속도입니다
- `maxMotorTorque`: 목표 모터 속도에 도달하는 데 사용하는 N-m 단위의 최대 모터 토크입니다.

조인트를 생성한 후에는 다음 setter로 모터의 속도와 토크를 변경할 수 있습니다.

```dart
revoluteJoint.motorSpeed = 2;
revoluteJoint.maxMotorTorque = 200;
```

또한 현재 조인트 각도를 가져올 수 있습니다.

```dart
revoluteJoint.angle;
```


### `WeldJoint`

`WeldJoint`는 두 바디 사이의 모든 상대적인 움직임을 제한해 사실상 두 바디를 하나로
붙이는 데 사용합니다.

`WeldJointDef`에는 연결할 두 바디와 용접 점에서 일치하는 로컬 앵커 점이
필요합니다.

```dart
world.physicsWorld.createWeldJoint(
  WeldJointDef(
    bodyA: firstBody,
    bodyB: secondBody,
    localAnchorA: firstBody.localPoint(anchor),
    localAnchorB: secondBody.localPoint(anchor),
  ),
);
```

```{flutter-app}
:sources: ../../examples
:page: weld_joint
:subfolder: stories/bridge_libraries/flame_forge2d/joints
:show: code popup
```

- `bodyA`, `bodyB`: 연결할 두 바디입니다

- `localAnchorA`, `localAnchorB`: 각 바디의 원점을 기준으로 한 앵커 점으로, 이 점에서 두
  바디가 용접됩니다

`linearHertz`, `angularHertz`, `linearDampingRatio`, `angularDampingRatio` 파라미터로
용접 부위에 탄성을 줄 수도 있습니다.


<a id="breakable-bodies-and-weldjoint"></a>

#### 부서지는 바디와 WeldJoint

Forge2D의 제약 솔버는 반복적으로 동작하므로 조인트에는 어느 정도 유연성이 있습니다. 즉,
WeldJoint로 연결된 바디가 약간 휘어질 수 있습니다. 부서지는 바디를 시뮬레이션하려면
여러 도형을 가진 하나의 바디를 만드는 것이 더 좋습니다. 바디가 부서질 때 `WeldJoint`에 의존하는 대신
도형을 파괴하고 새 바디에 다시 생성하면 됩니다.


### `WheelJoint`

`WheelJoint`는 두 개의 자유도를 제공합니다. 하나는 bodyA에 고정된 스프링 축을 따른 평행 이동이고,
다른 하나는 bodyB의 회전입니다. 차량 서스펜션용으로 설계되었습니다.

```dart
world.physicsWorld.createWheelJoint(
  WheelJointDef(
    bodyA: chassis,
    bodyB: wheel,
    localAnchorA: chassis.localPoint(wheel.position),
    localAxisA: Vector2(0, 1),
    hertz: 4,
    dampingRatio: 0.7,
    enableMotor: true,
    maxMotorTorque: 30,
    motorSpeed: -25,
  ),
);
```

- `localAxisA`: bodyA 프레임에서의 서스펜션 축입니다.
- `enableSpring`, `hertz`, `dampingRatio`: 서스펜션 스프링 설정입니다.
- `enableLimit`, `lowerTranslation`, `upperTranslation`: 서스펜션 이동 범위를 제한합니다.
- `enableMotor`, `motorSpeed`, `maxMotorTorque`: 바퀴의 회전을 구동합니다.
