<a id="event-behaviors-"></a>

# 이벤트 비헤이비어 ⌨

`flame_behaviors` 패키지는 이벤트 비헤이비어도 제공합니다. 이 비헤이비어들은 컴포넌트용으로 기존에 있는
Flame 이벤트 믹스인 위에 놓인 계층입니다. 이 비헤이비어들은 사용자가 부모 엔티티와 상호작용할 때
트리거됩니다. 따라서 이 이벤트들은 항상 부모 엔티티를 기준으로 합니다.


## TappableBehavior

`TappableBehavior`를 사용하면 개발자가 Flame의 [탭 이벤트][flame_tap_docs]를 자신의 엔티티에서
사용할 수 있습니다.

```dart
class MyTappableBehavior extends TappableBehavior<MyEntity> {
  @override
  void onTapDown(TapDownEvent event) {
    // tap down 업데이트 이벤트가 발생하면 무언가를 수행합니다.
  }
}
```


## DraggableBehavior

`DraggableBehavior`를 사용하면 개발자가 Flame의 [드래그 이벤트][flame_drag_docs]를 자신의 엔티티에서
사용할 수 있습니다.

```dart
class MyDraggableBehavior extends DraggableBehavior<MyEntity> {
  @override
  void onDragUpdate(DragUpdateEvent event) {
    // drag update 이벤트가 발생하면 무언가를 수행합니다.
  }
}
```

[flame_drag_docs]: https://docs.flame-engine.org/latest/flame/inputs/drag_events.html
[flame_tap_docs]: https://docs.flame-engine.org/latest/flame/inputs/tap_events.html
