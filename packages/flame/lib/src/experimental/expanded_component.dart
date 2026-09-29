import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

/// 경고: 실험적 기능입니다. API와 동작이 변경될 수 있습니다.
///
/// Flutter의 Expanded 위젯과 비슷하게 동작합니다.
/// 이 컴포넌트는 반드시 [LinearLayoutComponent]의 직접적인 자식이어야 합니다.
/// 이 컴포넌트 자체는 하는 일이 많지 않지만, 부모
/// [LinearLayoutComponent]가 계산 방식을 바꿔 이 컴포넌트가
/// 주축의 남는 공간을 차지할 수 있게 해 줍니다.
///
/// 부모([parent])인 [LinearLayoutComponent]가 주축 방향으로 shrink-wrap하면
/// 이 컴포넌트는 확장되지 않습니다.
///
/// ExpandedComponent는 절대 shrink-wrap하려 하지 않습니다. 부모에게는 오직
/// [intrinsicSize]만 보고하고, 부모로부터 크기 정보를
/// 받습니다.
///
/// 하지만 자식의 크기가 바뀌면 이를 부모에게 알려야 합니다.
/// 이는 주축 방향에서는 덜 중요하고,
/// 교차축 방향에서 더 중요합니다.
///
/// 사용 예시:
/// ```dart
/// ColumnComponent(
///   children: [
///     ExpandedComponent(
///       child: TextComponent(text: 'foo'),
///     );
///     TextComponent(text: 'bar')
///   ],
/// );
/// ```
class ExpandedComponent extends SingleLayoutComponent
    with ParentIsA<LinearLayoutComponent> {
  ExpandedComponent({
    super.key,
    super.position,
    super.anchor,
    super.priority,
    super.inflateChild = true,
    super.child,
  }) : super(size: null);

  @override
  void setLayoutAxisLength(LayoutAxis axis, double? value) {
    super.setLayoutAxisLength(axis, value);
    final child = this.child;
    if (inflateChild && child != null && value != null) {
      // We want to set the child's size.
      if (child is LayoutComponent) {
        child.setLayoutAxisLength(axis, value);
      } else {
        child.size[axis.axisIndex] = value;
      }
    }
  }

  @override
  void layoutChildren() {
    resetSize();
    parent.layoutChildren();
  }
}
