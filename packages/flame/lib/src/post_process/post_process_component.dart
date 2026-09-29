import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/post_process.dart';
import 'package:flame/src/camera/camera_component.dart';
import 'package:flame/src/game/notifying_vector2.dart';
import 'package:meta/meta.dart';

/// 자식들에게 후처리(post-processing) 이펙트를 적용하는 [PositionComponent]입니다.
/// 이 컴포넌트는 블룸, 블러 및 기타 프래그먼트 셰이더 이펙트를
/// 여러 컴포넌트에 한꺼번에 적용할 때 유용합니다.
///
/// [CameraComponent.postProcess]와 달리 이 컴포넌트는 후처리를
/// 자신의 자식들에게만 적용합니다. 따라서 전체 화면에
/// 후처리를 적용하려면 대신
/// [CameraComponent.postProcess]를 사용해야 합니다.
///
/// 렌더링 과정에서 이 컴포넌트의 자식들은
/// [PostProcessingContextFinder.findPostProcessFromContext]를 사용해 자신이
/// 후처리 안에서 렌더링되고 있는지 확인할 수 있습니다.
///
/// 특정 [size]를 지정하면 컴포넌트가 그 크기로 렌더링되고,
/// 그렇지 않으면 자식들의 바운딩 박스를 기준으로
/// 크기를 계산합니다.
///
/// 함께 보기:
/// - [PostProcess]: 후처리의 기본 클래스이며, 후처리를 만드는 방법에 대한
/// 자세한 정보가 있습니다.
/// - [PostProcessGroup]: 병렬로 적용되는 후처리들의
/// 그룹입니다.
/// - [CameraComponent.postProcess]: 전체 화면에 후처리를
/// 적용하는 방법입니다.
class PostProcessComponent<T extends PostProcess> extends PositionComponent {
  PostProcessComponent({
    required this.postProcess,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  });

  @override
  PostProcessComponentRenderContext<T> get renderContext => _renderContext;

  final _renderContext = PostProcessComponentRenderContext<T>(
    postProcess: null,
  );

  final T postProcess;

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    await postProcess.onLoad();
    return super.onLoad();
  }

  @override
  @mustCallSuper
  void update(double dt) {
    super.update(dt);
    postProcess.update(dt);
  }

  @override
  @mustCallSuper
  void onChildrenChanged(_, __) {
    _recalculateBoundingSize();
  }

  NotifyingVector2? _maybeBoundingSize;
  NotifyingVector2 get _boundingSizeOfChildren {
    if (_maybeBoundingSize == null) {
      _recalculateBoundingSize();
    }
    return _maybeBoundingSize!;
  }

  void _recalculateBoundingSize() {
    final rectChildren = children.query<PositionComponent>();

    if (rectChildren.isEmpty) {
      (_maybeBoundingSize ??= NotifyingVector2.zero()).setZero();
    }

    final boundingBox = rectChildren
        .map((child) => child.toRect())
        .reduce((a, b) => a.expandToInclude(b));
    (_maybeBoundingSize ??= NotifyingVector2.zero()).setValues(
      boundingBox.width,
      boundingBox.height,
    );
  }

  @override
  NotifyingVector2 get size {
    final superSize = super.size;
    if (superSize.isZero() && hasChildren) {
      return _boundingSizeOfChildren;
    }
    return superSize;
  }

  @override
  @mustCallSuper
  void renderTree(Canvas canvas) {
    decorator.applyChain(
      (canvas) {
        postProcess.render(
          canvas,
          size,
          super.renderTreeWithoutDecorator,
          (context) {
            _renderContext.postProcess = postProcess;
          },
        );
      },
      canvas,
    );
  }
}

class PostProcessComponentRenderContext<T extends PostProcess>
    extends ComponentRenderContext {
  PostProcessComponentRenderContext({
    required this.postProcess,
  });

  T? postProcess;
}

extension PostProcessingContextFinder on Component {
  T? findPostProcessFromContext<T extends PostProcess>() {
    final closestContext =
        findRenderContext<PostProcessComponentRenderContext<T>>();
    if (closestContext != null) {
      return closestContext.postProcess;
    }
    final contextInCamera =
        findRenderContext<CameraRenderContext>()?.currentPostProcess;
    if (contextInCamera is T) {
      return contextInCamera;
    }

    return null;
  }
}
