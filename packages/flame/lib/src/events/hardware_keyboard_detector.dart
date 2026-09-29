import 'package:flame/src/components/core/component.dart';
import 'package:flutter/services.dart';

/// **HardwareKeyboardDetector** 컴포넌트를 사용하면 Flutter의 `Focus` 위젯을
/// 거치지 않고 하드웨어 키보드의 이벤트를 직접 수신할 수 있습니다.
/// 화면(소프트웨어) 키보드의 이벤트는 수신하지 않습니다.
///
/// 이 컴포넌트는 컴포넌트 트리의 어디에든 배치할 수 있습니다. 예를 들어
/// Game 클래스의 루트 레벨이나 조작 중인 플레이어에
/// 붙일 수 있습니다. 여러 개의 `HardwareKeyboardDetector` 컴포넌트가
/// 같은 게임 안에 공존할 수 있으며, 모두 키 이벤트를 받습니다.
///
/// 이 컴포넌트는 [onKeyEvent] 이벤트 핸들러를 제공하며, 이를
/// 오버라이드하거나 생성자의 파라미터로 전달할 수 있습니다. 이 이벤트 핸들러는
/// 사용자가 키보드의 아무 키나 누르거나 뗄 때, 그리고 키를
/// 누르고 있는 동안 호출됩니다.
///
/// 키 이벤트 스트림은 Flutter에 의해 정규화됩니다. 즉,
/// 모든 [KeyDownEvent]에는 항상 대응하는 [KeyUpEvent]가 있으며,
/// 그 사이에 [KeyRepeatEvent]가 몇 개 있을 수 있습니다.
/// 플랫폼에 따라 이 이벤트 중 일부는 "합성(synthesized)"될 수 있는데, 이는
/// 올바른 이벤트 순서를 유지하기 위해 프레임워크가 인위적으로 만든 것을 뜻합니다.
/// 자세한 내용은 Flutter의 [HardwareKeyboard]를 참고하세요.
///
/// 이 컴포넌트가 컴포넌트 트리에 추가되거나 제거될 때도 비슷한 정규화가
/// 보장됩니다. `HardwareKeyboardDetector`가 마운트될 때 사용자가
/// 키를 누르고 있었다면 인위적인 `KeyDownEvent`가
/// 발생하고, 이 컴포넌트가 제거될 때 사용자가 키를 누르고 있었다면
/// `KeyUpEvent`가 합성됩니다.
///
/// [pauseKeyEvents] 속성을 사용해 [onKeyEvent]의 전달을 일시적으로
/// 중지하거나 재개할 수 있습니다. 컴포넌트가 컴포넌트 트리에서 제거될 때도
/// 이벤트 전달이 중지됩니다.
class HardwareKeyboardDetector extends Component {
  HardwareKeyboardDetector({this._onKeyEvent});

  final List<PhysicalKeyboardKey> _physicalKeys = [];
  Set<LogicalKeyboardKey> _logicalKeys = {};
  bool _pause = true;
  final void Function(KeyEvent)? _onKeyEvent;

  /// 현재 키보드(또는 키보드와 유사한 장치)에서 눌려 있는
  /// 키 목록입니다. 키는 눌린 순서대로 나열되지만,
  /// 일부 시스템에서는 modifier 키가
  /// 순서와 다르게 나열될 수 있습니다.
  List<PhysicalKeyboardKey> get physicalKeysPressed => _physicalKeys;

  /// 현재 키보드에서 눌려 있는 논리 키의 집합입니다.
  /// 이 집합은 [physicalKeysPressed] 목록에 대응하며,
  /// 키보드 레이아웃과 무관하게 키를 검색하는 데 사용할 수 있습니다.
  Set<LogicalKeyboardKey> get logicalKeysPressed => _logicalKeys;

  /// <kbd>Ctrl</kbd> 키가 현재 눌려 있으면 true입니다.
  bool get isControlPressed =>
      _logicalKeys.contains(LogicalKeyboardKey.controlLeft) ||
      _logicalKeys.contains(LogicalKeyboardKey.controlRight);

  /// <kbd>Shift</kbd> 키가 현재 눌려 있으면 true입니다.
  bool get isShiftPressed =>
      _logicalKeys.contains(LogicalKeyboardKey.shiftLeft) ||
      _logicalKeys.contains(LogicalKeyboardKey.shiftRight);

  /// <kbd>Alt</kbd> 키가 현재 눌려 있으면 true입니다.
  bool get isAltPressed =>
      _logicalKeys.contains(LogicalKeyboardKey.altLeft) ||
      _logicalKeys.contains(LogicalKeyboardKey.altRight);

  /// <kbd>Num Lock</kbd>이 현재 켜져 있으면 true입니다.
  bool get isNumLockOn => _hasLock(KeyboardLockMode.numLock);

  /// <kbd>Caps Lock</kbd>이 현재 켜져 있으면 true입니다.
  bool get isCapsLockOn => _hasLock(KeyboardLockMode.capsLock);

  /// <kbd>Scroll Lock</kbd>이 현재 켜져 있으면 true입니다.
  bool get isScrollLockOn => _hasLock(KeyboardLockMode.scrollLock);

  bool _hasLock(KeyboardLockMode key) =>
      HardwareKeyboard.instance.lockModesEnabled.contains(key);

  /// `true`이면 키 이벤트 전달이 일시 중지됩니다.
  ///
  /// 이 속성을 true로 설정하면 시스템은 현재 누르고 있는 모든 키에 대해
  /// 사용자가 키를 뗀 것처럼 KeyUp 이벤트를 생성합니다.
  /// 반대로 이 속성을 다시 `false`로 바꿀 때 사용자가
  /// 키를 누르고 있었다면, 시스템은 사용자가 방금 그 버튼을 누르기 시작한 것처럼
  /// KeyDown 이벤트를 생성합니다.
  bool get pauseKeyEvents => _pause;
  set pauseKeyEvents(bool value) {
    if (value == _pause) {
      return;
    }
    _pause = value;
    final timeStamp = ServicesBinding.instance.currentSystemFrameTimeStamp;
    for (final physicalKey in _physicalKeys) {
      final logicalKey = HardwareKeyboard.instance.lookUpLayout(physicalKey)!;
      onKeyEvent(
        (_pause ? KeyUpEvent.new : KeyDownEvent.new)(
          physicalKey: physicalKey,
          logicalKey: logicalKey,
          timeStamp: timeStamp,
          synthesized: true,
        ),
      );
    }
  }

  /// 키보드의 키가 눌리거나, 눌린 채 유지되거나, 떼어질 때마다 알림을 받고 싶다면
  /// 이 이벤트 핸들러를 오버라이드하세요. [event]는 각각
  /// [KeyDownEvent], [KeyRepeatEvent], [KeyUpEvent] 중 하나입니다.
  void onKeyEvent(KeyEvent event) => _onKeyEvent?.call(event);

  /// 원시(raw) 키 이벤트의 내부 핸들러입니다.
  bool _handleKeyEvent(KeyEvent event) {
    _logicalKeys = HardwareKeyboard.instance.logicalKeysPressed;
    if (event is KeyDownEvent) {
      _physicalKeys.add(event.physicalKey);
    } else if (event is KeyUpEvent) {
      _physicalKeys.remove(event.physicalKey);
    }
    if (!_pause) {
      onKeyEvent(event);
    }
    return true; // handled
  }

  @override
  void onMount() {
    super.onMount();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    _physicalKeys.addAll(HardwareKeyboard.instance.physicalKeysPressed);
    pauseKeyEvents = false;
  }

  @override
  void onRemove() {
    super.onRemove();
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    pauseKeyEvents = true;
    _physicalKeys.clear();
  }
}
