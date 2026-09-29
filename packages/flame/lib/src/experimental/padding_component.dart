import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/rendering.dart';

/// Flutter의 Padding 위젯과 비슷한 패딩 컴포넌트입니다.
/// [padding]은 Flutter의 대응 위젯에서와 같은 방식으로 사용합니다.
/// 이 컴포넌트는 자식의 크기에 맞춰 줄어들거나 늘어나도록 설계되었지만,
/// 크기를 명시적으로 설정해도 괜찮습니다. 이 경우 자식은 단순히
/// 패딩 크기만큼 오프셋됩니다.
///
/// 이 컴포넌트의 자식은 [child]로 설정합니다. [PaddingComponent] 인스턴스에
/// [add]를 직접 사용하는 것은 피하세요. 자식이 여러 개일 때의
/// 동작은 정의되어 있지 않으며, 자식 하나만을 위해 설계되었습니다.
///
/// [padding]과 [child]는 나중에 설정할 수도 있으며, 그러면
/// 레이아웃이 갱신됩니다.
///
/// [inflateChild]가 true이면 [resetSize]는 [syncChildSize]를 통해 자식의 크기를
/// 사용 가능한 공간을 채우도록 설정합니다. 자식이 [LayoutComponent]의
/// 하위 클래스이면 [resetSize]는 [LayoutComponent.setLayoutSize]를 사용합니다.
///
/// 사용 예시:
/// ```dart
/// PaddingComponent(
///   padding: EdgeInsets.all(10),
///   child: TextComponent(text: 'bar')
/// );
/// ```
class PaddingComponent extends SingleLayoutComponent {
  PaddingComponent({
    super.key,
    EdgeInsets? padding,
    super.anchor,
    super.position,
    super.priority,
    super.size,
    super.inflateChild = false,
    PositionComponent? child,
  }) : _padding = padding ?? EdgeInsets.zero,
       super(child: null) {
    this.child = child;
  }

  EdgeInsets _padding;

  EdgeInsets get padding => _padding;

  set padding(EdgeInsets value) {
    _padding = value;
    layoutChildren();
  }

  @override
  void layoutChildren() {
    resetSize();
    final child = this.child;
    if (child == null) {
      return;
    }
    // Regardless of shrinkwrap or size, top left padding is set.
    child.topLeftPosition.setFrom(padding.topLeft.toVector2());
  }

  @override
  Vector2 get availableSize {
    return padding.deflateSize(size.toSize()).toVector2();
  }

  @override
  Vector2 get intrinsicSize {
    final childWidth = child?.size.x ?? 0;
    final childHeight = child?.size.y ?? 0;
    return Vector2(
      childWidth + padding.horizontal,
      childHeight + padding.vertical,
    );
  }
}
