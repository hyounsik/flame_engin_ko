<a id="coding-conventions"></a>

# 코딩 규칙

> [!Note]
> 다음 코딩 규칙은 단지 권장 사항일 뿐이며 전적으로
> 선택 사항입니다. 원하는 코딩 규칙을 자유롭게 사용하세요.


<a id="entities"></a>

## 엔티티

엔티티는 어떤 동작 로직도 포함해서는 안 되며, 대신 비헤이비어로 구성되어야 합니다. 이렇게 하면
더 유연하고 재사용 가능한 코드를 만들 수 있습니다. 엔티티는 직접 렌더링을 해서는 안 되며, 대신
엔티티의 시각적 표현을 처리할 자식 컴포넌트를 추가해야 합니다.


<a id="example-of-entities"></a>

### 엔티티 예시

✅ **좋은 예**

```dart
class Player extends Entity {
  Player() {
    // 비헤이비어
    add(JumpingBehavior());
    add(AttackingBehavior());

    // 컴포넌트
    add(SpriteComponent(...));
  }
}
```

❌ **나쁜 예**

```dart
class Player extends Entity {
  void update(double dt) {
    if (isJumping) {
      // 점프 로직
    }
    
    if (isAttacking) {
      // 공격 로직
    }
  }

  void render(Canvas canvas) {
    // 플레이어 렌더링
    canvas.drawImage(...);
  }
}
```


<a id="behaviors"></a>

## 비헤이비어

비헤이비어는 자신이 기술하는 동작 로직과 관련된 코드만 포함해야 합니다. 비헤이비어는
절대 직접 렌더링을 해서는 안 됩니다.

비헤이비어는 해당 비헤이비어와 관련된 추가 기능을 위해 자체 컴포넌트를 가질 수 있습니다. 예를 들어
엔티티를 점프하게 만드는 비헤이비어는 `TimerComponent`를 가져서 엔티티가 0.5초에 한 번만 점프할 수 있도록
보장할 수 있습니다. 또한 그 비헤이비어는 `KeyboardHandler` 믹스인을 사용해 점프 키 입력을 수신하고
점프를 트리거할 수도 있습니다. 해당 비헤이비어와 관련 없는 로직은 그 비헤이비어에 있어서는 안 됩니다.


<a id="example-of-behaviors"></a>

### 비헤이비어 예시

✅ **좋은 예**

```dart
class JumpingBehavior extends Behavior<Entity> with KeyboardHandler {
  bool isJumping = false;

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    isJumping = keysPressed.contains(LogicalKeyboardKey.space);
    return true;
  }

  @override
  void update(double dt) {
    if (isJumping) {
      // 점프 로직
    }
  }
}
```

❌ **나쁜 예**

```dart
class JumpBehavior extends Behavior<Entity> with KeyboardHandler {
  bool isJumping = false;
  bool isAttacking = false;

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    isJumping = keysPressed.contains(LogicalKeyboardKey.space);
    isAttacking = keysPressed.contains(LogicalKeyboardKey.keyA);
    return true;
  }

    
  void update(double dt) {
    if (isJumping) {
      // 점프 로직
    }
    if (isAttacking) {
      // 공격 로직
    }
  }
    
  void render(Canvas canvas) {
    // 무언가를 렌더링합니다
    canvas.drawImage(...);
  }
}
```
