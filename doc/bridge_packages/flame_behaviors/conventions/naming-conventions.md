<a id="naming-conventions"></a>

# 네이밍 규칙

> [!Note]
> 다음 네이밍 규칙은 단지 권장 사항일 뿐이며 전적으로
> 선택 사항입니다. 원하는 네이밍 규칙을 자유롭게 사용하세요.


<a id="entities"></a>

## 엔티티


<a id="anatomy-of-entities"></a>

### 엔티티 이름의 구조

`Type (name)`


<a id="examples-of-entities"></a>

### 엔티티 예시

✅ **좋은 예**

```dart
class Player extends Entity {}

class Enemy extends Entity {}

class Bullet extends Entity {}
```

❌ **나쁜 예**

```dart
class PlayerEntity extends Entity {}

class EnemyEntity extends Entity {}

class BulletEntity extends Entity {}
```


<a id="behaviors"></a>

## 비헤이비어


<a id="anatomy-of-behaviors"></a>

### 비헤이비어 이름의 구조

`Verb (action)` + `Behavior`


<a id="examples-of-behaviors"></a>

### 비헤이비어 예시

✅ **좋은 예**

```dart
class JumpingBehavior extends Behavior<Entity> {}

class AttackingBehavior extends Behavior<Entity> {}
```

❌ **나쁜 예**

```dart
class JumpBehavior extends Behavior<Entity> {}

class AttackBehavior extends Behavior<Entity> {}
```
