import 'package:flame/components.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:flutter/widgets.dart';

/// **AlignComponent**는 상대 배치를 사용해 자식을 자신 안에 배치하는
/// 레이아웃 컴포넌트입니다. Flutter의 [Align] 위젯과 비슷합니다.
///
/// 이 컴포넌트에는 정렬 대상이 될 단일 [child]가 필요합니다.
/// 물론 이 컴포넌트에 다른 자식들을 추가할 수도 있지만,
/// 처음 지정한 [child]만 정렬됩니다.
///
/// [alignment] 파라미터는 현재 컴포넌트 안에서 자식이 놓일 위치를 나타냅니다.
/// 예를 들어 [alignment]가 `Anchor.center`이면
/// 자식이 가운데에 배치됩니다.
///
/// 일반적으로 이 컴포넌트의 크기는 부모의 크기와 같습니다. 하지만
/// [widthFactor]나 [heightFactor] 속성을 지정하면, 해당 방향의
/// 이 컴포넌트 크기는 자식의 크기에
/// 해당 계수를 곱한 값이 됩니다. 예를 들어 [heightFactor]를
/// 1로 설정하면 이 컴포넌트의 너비는 부모의 너비와 같아지지만,
/// 높이는 자식의 높이와 같아집니다.
///
/// ```dart
/// AlignComponent(
///   child: TextComponent('hello'),
///   alignment: Anchor.centerLeft,
/// );
/// ```
///
/// 기본적으로 자식의 앵커는 [alignment] 값과 같게 설정됩니다. 이렇게 하면
/// 전통적인 정렬 동작이 됩니다. 예를 들어 자식의 중심이
/// 현재 컴포넌트의 중심에 놓이거나, 자식의 오른쪽 아래
/// 모서리가 컴포넌트의 오른쪽 아래 모서리에 놓일 수 있습니다.
/// 하지만 자식에게 다른 앵커를 지정하고
/// [keepChildAnchor]를 true로 설정하면 더 독특한 배치도 할 수 있습니다.
/// 예를 들어 `alignment`를
/// `topCenter`로, 자식의 앵커를 `bottomCenter`로 설정하면 자식이
/// 사실상 현재 컴포넌트의 위쪽에 배치됩니다.
/// ```dart
/// PlayerSprite().add(
///   AlignComponent(
///     child: HealthBar()..anchor = Anchor.bottomCenter,
///     alignment: Anchor.topCenter,
///     keepChildAnchor: true,
///   ),
/// );
/// ```
class AlignComponent extends PositionComponent {
  /// [alignment]에 따라 이 컴포넌트의 바운딩 박스 안에 [child]를 배치해 두는
  /// 컴포넌트를 생성합니다.
  ///
  /// 정확히 말하면 자식은 현재 컴포넌트의 바운딩 박스 안에서 [alignment]
  /// 상대 위치에 놓입니다. [keepChildAnchor] 파라미터가 true가 아니면
  /// 자식의 앵커도 [alignment]로 설정됩니다.
  AlignComponent({
    PositionComponent? child,
    Anchor alignment = Anchor.topLeft,
    this.widthFactor,
    this.heightFactor,
    this.keepChildAnchor = false,
    super.priority,
  }) {
    this.alignment = alignment;
    this.child = child;
  }

  PositionComponent? _child;

  /// 이 컴포넌트가 배치할 컴포넌트입니다. [child]는
  /// 현재 컴포넌트에 자동으로 마운트됩니다.
  PositionComponent? get child => _child;

  set child(PositionComponent? value) {
    if (_child?.parent == this) {
      _child?.removeFromParent();
    }
    _child = value;
    _child?.parent = this;
    _updateChildAnchor();
    _updateChildPosition();
  }

  late Anchor _alignment;

  /// 현재 컴포넌트 안에서 [child]를 배치하는 방식입니다.
  ///
  /// 참고: Flutter의 [Alignment]와 달리 컴포넌트의 왼쪽 위 모서리는
  /// 상대 좌표 `(0, 0)`이고, 오른쪽 아래 모서리는
  /// 좌표 `(1, 1)`입니다.
  Anchor get alignment => _alignment;

  set alignment(Anchor value) {
    _alignment = value;
    _updateChildAnchor();
    _updateChildPosition();
  }

  /// `null`이면 컴포넌트의 너비가 부모의 너비와 같습니다.
  /// 그렇지 않으면 너비는 자식의 너비에
  /// 이 계수를 곱한 값이 됩니다.
  final double? widthFactor;

  /// `null`이면 컴포넌트의 높이가 부모의 높이와 같습니다.
  /// 그렇지 않으면 높이는 자식의 높이에
  /// 이 계수를 곱한 값이 됩니다.
  final double? heightFactor;

  /// `false`(기본값)이면 자식의 `anchor`가
  /// [alignment] 값과 같게 유지됩니다. `true`이면 [child]가
  /// 부모와 독립적인 자신만의 `anchor` 값을 가질 수 있습니다.
  final bool keepChildAnchor;

  @override
  set size(Vector2 value) {
    throw UnsupportedError('The size of AlignComponent cannot be set directly');
  }

  @override
  void onMount() {
    assert(
      parent is ReadOnlySizeProvider,
      "An AlignComponent's parent must have a size",
    );
  }

  @override
  void onParentResize(Vector2 maxSize) {
    if (_child != null) {
      super.size = Vector2(
        widthFactor == null ? maxSize.x : _child!.size.x * widthFactor!,
        heightFactor == null ? maxSize.y : _child!.size.y * heightFactor!,
      );
    }
    _updateChildPosition();
  }

  @mustCallSuper
  @override
  void onChildrenChanged(Component child, ChildrenChangeType type) {
    if (_child?.parent != this) {
      this.child = null;
    }
  }

  void _updateChildPosition() {
    _child?.position = Vector2(size.x * alignment.x, size.y * alignment.y);
  }

  void _updateChildAnchor() {
    if (!keepChildAnchor) {
      _child?.anchor = _alignment;
    }
  }
}
