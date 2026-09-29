import 'package:flame/src/experimental/linear_layout_component.dart';
import 'package:flutter/rendering.dart';

/// 경고: 실험적 기능입니다. API와 동작이 변경될 수 있습니다.
///
/// ColumnComponent는 자식들을 세로 방향으로 배치하는
/// 레이아웃 컴포넌트입니다.
///
/// [children]은 세로축을 따라 배치되며, 자식들 사이의 간격은
/// [gap] 파라미터로 정합니다.
/// 세로축 방향의 자식 정렬은
/// [mainAxisAlignment]로, 가로축 방향의 정렬은
/// [crossAxisAlignment]로 제어합니다.
///
/// [size]가 null이 아니면 일반적인 명시적 크기 지정처럼 동작합니다.
/// [size]가 null이면 모든 자식을 담을 수 있는 최소 크기로
/// 크기를 설정합니다. 이는 [size]를 [intrinsicSize]로 설정하는 것과 비슷하지만,
/// 자식들이나 다른 속성 등이 변경되면
/// 크기도 그에 따라 반응한다는 점이 다릅니다.
///
/// 사용 예시:
/// ```dart
/// ColumnComponent(
///   gap: 10.0,
///   mainAxisAlignment: MainAxisAlignment.center,
///   crossAxisAlignment: CrossAxisAlignment.start,
///   children: [
///     TextComponent('Child 1'),
///     TextComponent('Child 2'),
///     TextComponent('Child 3'),
///   ],
/// );
/// ```
class ColumnComponent extends LinearLayoutComponent {
  ColumnComponent({
    super.key,
    super.mainAxisAlignment = MainAxisAlignment.start,
    super.crossAxisAlignment = CrossAxisAlignment.start,
    super.gap = 0.0,
    super.size,
    super.position,
    super.anchor,
    super.priority,
    super.children,
  }) : super(direction: Direction.vertical);
}
