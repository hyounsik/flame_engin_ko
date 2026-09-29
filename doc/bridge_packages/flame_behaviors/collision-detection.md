<a id="collision-detection-"></a>

# 충돌 감지 💥

Flame에는 강력한 [충돌 감지 시스템](https://docs.flame-engine.org/latest/flame/collision_detection.html)이 기본으로 포함되어 있지만,
이 API는 강하게 타입이 지정되어 있지 않습니다. 컴포넌트는 충돌한 컴포넌트를 항상
`PositionComponent`로 받으며, 개발자가 그것이 어떤 타입의 클래스인지 직접 확인해야 합니다.

`flame_behaviors`는 강하게 타입이 지정된 API를 강제하는 데 중점을 둡니다. 충돌 대상이 되는 엔티티의 타입을
기술하는 `CollisionBehavior`라는 특별한 비헤이비어를 제공합니다. 하지만 이 비헤이비어가 실제 충돌 감지를
수행하지는 않습니다. 실제 충돌 감지는
`PropagatingCollisionBehavior`가 수행합니다.

`PropagatingCollisionBehavior`는 부모 엔티티에 히트박스를 등록해 충돌 감지를 처리합니다. 해당 히트박스에
충돌이 발생하면 `PropagatingCollisionBehavior`는 부모 엔티티와 충돌한 컴포넌트가
`CollisionBehavior`에 지정된 대상 엔티티 타입을 포함하는지 확인합니다.

`PropagatingCollisionBehavior`가 충돌 감지를 처리하게 하면 두 가지 주요 이점이 있습니다.
첫 번째이자 가장 중요한 이점은 성능입니다. 엔티티 자체에만 충돌 콜백을 등록하므로
충돌 감지 시스템이 엔티티마다 여러 개 있을 수 있는 "collidable" 비헤이비어들을 일일이 거칠
필요가 없습니다. 이제는 충돌이 발생했음이 확인된 경우에만 그렇게 합니다.

두 번째 이점은 [관심사 분리][separation_of_concerns]가 가능하다는 점입니다.
각 `CollisionBehavior`는 특정 충돌 사용 사례를 처리하므로, 개발자가 무엇과 충돌하고 있는지 알아내기 위해
하나의 큰 메서드 안에 여러 if 문을 작성할 필요가
없습니다.

이 충돌 비헤이비어 패턴의 좋은 사용 사례는 `flame_behaviors`
[예제](https://github.com/flame-engine/flame/tree/main/packages/flame_behaviors/example)에서 볼 수 있습니다.

```dart
class MyEntityCollisionBehavior
    extends CollisionBehavior<MyCollidingEntity, MyParentEntity> {
  @override
  void onCollisionStart(
    List<Vector2> intersectionPoints,
    MyCollidingEntity other,
  ) {
    // MyCollidingEntity와 충돌하기 시작했습니다
  }

  @override
  void onCollisionEnd(MyCollidingEntity other) {
    // MyCollidingEntity와의 충돌이 끝났습니다
  }
}

class MyParentEntity extends Entity {
  MyParentEntity()
    : super(
        behaviors: [
          PropagatingCollisionBehavior(RectangleHitbox()),
          MyEntityCollisionBehavior(),
        ],
      );
   ...   
}
```

[separation_of_concerns]: https://en.wikipedia.org/wiki/Separation_of_concerns
