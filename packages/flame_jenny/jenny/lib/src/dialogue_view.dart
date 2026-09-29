import 'dart:async';

import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/user_defined_command.dart';
import 'package:jenny/src/structure/dialogue_choice.dart';
import 'package:jenny/src/structure/dialogue_line.dart';
import 'package:jenny/src/structure/dialogue_option.dart';
import 'package:jenny/src/structure/node.dart';
import 'package:jenny/src/yarn_project.dart';
import 'package:meta/meta.dart';

/// **DialogueView** 클래스는 Jenny를 게임 엔진과 통합하는 핵심 메커니즘입니다.
/// 이 클래스는 {ref}`line <DialogueLine>`(대사)과
/// {ref}`option <DialogueOption>`(선택지)을 사용자에게 어떻게 보여줄지 정의합니다.
///
/// 이 클래스를 사용하는 방법은 두 가지입니다.
///
/// - DialogueView를 상속하기
/// - DialogueView를 믹스인으로 추가하기
///
/// 두 경우 모두 Jenny의 대화 시스템을 사용하려면 추상 이벤트 핸들러
/// 메서드들의 구체적인 구현을 만들어야 합니다.
/// 이렇게 만든 구체적인 `DialogueView` 객체를 [DialogueRunner]에 전달하면,
/// [DialogueRunner]가 대화의 진행을 조율합니다.
///
/// 이 클래스는 여러 "이벤트 핸들러" 메서드를 정의하며, 서브클래스에서 이를
/// 오버라이드하여 해당 이벤트에 대응할 수 있습니다.
/// 각 메서드에는 아무 동작도 하지 않는 기본 구현이 있으므로, 관심 있는
/// 메서드만 오버라이드하면 됩니다.
///
/// 대부분의 이벤트 핸들러 메서드는 [FutureOr]를 반환하므로, 동기 또는 비동기로
/// 구현할 수 있습니다. 비동기로 구현한 경우 대화 러너는 future가 완료될 때까지
/// 기다린 뒤 다음으로 진행합니다
/// (여러 대화 뷰의 future는 동시에 기다립니다).
abstract mixin class DialogueView {
  DialogueRunner? _dialogueRunner;

  /// 이 `DialogueView`의 소유자입니다. 대화 뷰가 아직 어떤 `DialogueRunner`에도
  /// 연결되지 않았다면 이 속성은 `null`입니다.
  ///
  /// 이 속성을 사용해 부모 [YarnProject]에 접근하거나,
  /// 형제 `DialogueView`들에 신호를 보낼 수 있습니다.
  DialogueRunner? get dialogueRunner => _dialogueRunner;
  @internal
  set dialogueRunner(DialogueRunner? value) => _dialogueRunner = value;

  /// 새 대화가 시작되기 전, 즉 대사, 선택지, 명령이 전달되기 전에
  /// 호출됩니다.
  ///
  /// 이 메서드는 대화 패널을 페이드 인하거나 애니메이션하는 등 게임 UI를 준비하거나
  /// 리소스를 로드하기에 좋은 곳입니다. 이 메서드가 future를 반환하면,
  /// 대화는 그 future가 완료된 후에야 실행을
  /// 시작합니다.
  FutureOr<void> onDialogueStart() {}

  /// 대화가 끝났을 때 호출됩니다.
  ///
  /// 이 메서드는 대화 UI를 정리하는 데 사용할 수 있습니다. 반환된
  /// future는 대화 러너가 작업을 마쳤다고 판단하기 전에
  /// await됩니다.
  FutureOr<void> onDialogueFinish() {}

  /// 대화가 새 [node]에 진입할 때 호출됩니다.
  ///
  /// 이 메서드는 [onDialogueStart] 직후에 호출되며, 대화가 다른 노드로
  /// 점프하면 대화 도중 여러 번 더 호출될 수 있습니다.
  /// 이 메서드는 노드별 초기화를 수행하기에 좋은 곳입니다.
  /// 예를 들어 [node]의 속성이나 메타데이터를
  /// 조회할 수 있습니다.
  ///
  /// 이 메서드가 future를 반환하면, 대화 러너는 그 future가 완료될 때까지
  /// 기다린 뒤 실제 대화를 진행합니다.
  FutureOr<void> onNodeStart(Node node) {}

  /// 대화가 [node]에서 나갈 때 호출됩니다.
  ///
  /// 예를 들어 [[<<jump>>]] 중에는 현재 노드로 이 콜백이 호출되고,
  /// 이어서 새 노드로 [onNodeStart]가 호출됩니다.
  /// 마찬가지로 [[<<stop>>]] 명령도 이 콜백을 호출합니다. 반면
  /// [[<<visit>>]] 중에는 이 콜백이 호출되지 않습니다.
  ///
  /// 이 콜백은 [onNodeStart]에서 수행한 준비 작업을 정리하는 데
  /// 사용할 수 있습니다.
  FutureOr<void> onNodeFinish(Node node) {}

  /// 다음 대화 [line]을 사용자에게 보여줘야 할 때 호출됩니다.
  ///
  /// [DialogueView]는 [line]을 원하는 방식으로 보여주거나, 아예 보여주지 않기로
  /// 결정할 수 있습니다. 예를 들어 대화 뷰는 다음과 같은 일을 할 수 있습니다:
  /// 대사 객체를 보강하기, 화면의 특정 위치에 대사를 렌더링하기,
  /// 캐릭터 이름만 렌더링하기, 말하는 사람의 초상화를 보여주기,
  /// 말풍선 안에 텍스트를 보여주기, 음성 오디오 파일을 재생하기,
  /// 텍스트를 플레이어의 대화 기록에 저장하기, 말하는 사람을 보여주도록
  /// 카메라를 이동하기 등.
  ///
  /// 이러한 전달 방식 중 일부는 "주(primary)" 방식으로, 나머지는 "보조(auxiliary)"
  /// 방식으로 볼 수 있습니다. "주" [DialogueView]는 `true`를 반환해야 하고,
  /// 나머지는 모두 `false`를 반환해야 합니다(특히 대사를 완전히 무시하는 대화 뷰라면).
  /// 이는 견고성 검사에 사용됩니다. 어떤 대화 뷰도 `true`를 반환하지
  /// 않으면, 대사가 사용자에게 의미 있는 방식으로 보여지지 않았으므로
  /// `DialogueError`가 발생합니다.
  ///
  /// 이 메서드가 future를 반환하면, 대화 러너는 그 future가 완료될 때까지
  /// 기다린 뒤 다음 대사로 넘어갑니다. 여러
  /// [DialogueView]가 이런 future를 반환하면, 대화 러너는 모두 완료될 때까지
  /// 기다린 뒤 진행합니다.
  ///
  /// 단순하지 않은 [DialogueView]에서는 future를 반환하는 것이 꽤 일반적입니다.
  /// 결국 이 메서드가 즉시 반환된다면 대화 러너는 곧바로 다음 대사로
  /// 넘어가 버리고, 플레이어는 첫 번째 대사를 읽을 시간이 없을 것입니다.
  /// 따라서 흔한 시나리오는 대사를 점진적으로 드러낸 뒤 잠시 기다렸다가
  /// 반환하는 것입니다. 또는 버튼 클릭이나 키보드 키 입력 같은
  /// 사용자 동작에 따라 완료되는 [Completer] 기반 future를
  /// 반환할 수도 있습니다.
  ///
  /// 이 메서드는 대사를 플레이어에게 *보여주는* 역할만 해야 하므로,
  /// 마지막에 대사를 숨기려고 하지 마세요. 그 용도로는 전용 메서드
  /// [onLineFinish]가 있습니다.
  ///
  /// 또한 이 메서드는 상당한 시간이 걸릴 수 있으므로, 이 과정에 개입할 수 있는
  /// 추가 메서드가 두 개
  /// 있습니다: [onLineSignal]과 [onLineStop].
  FutureOr<bool> onLineStart(DialogueLine line) => false;

  /// 대화 러너가 모든 대화 뷰에 [signal]을 보낼 때 호출됩니다.
  ///
  /// 신호는 [onLineStart] 실행을 마쳤는지 여부와 관계없이 모든 뷰에
  /// 전달됩니다. 신호를 어떻게 해석하고
  /// 어떻게 대응할지는 각 대화 뷰가 결정합니다.
  ///
  /// 예를 들어 RUSH 신호에 대한 응답으로 타자기 이펙트의 속도를 높여
  /// 텍스트를 즉시 드러내는 시나리오를 생각할 수 있습니다.
  /// 또는 OMG 이벤트에 대한 응답으로 끼어드는 말을 하거나,
  /// PAUSE 신호에 대한 응답으로 표시를 일시 정지하거나, 플레이어가 무기를 꺼내는
  /// 것 같은 적대적 제스처를 취하면 경고를 줄 수도 있습니다.
  void onLineSignal(DialogueLine line, dynamic signal) {}

  /// 게임이 [line]의 표시를 가능한 한 빨리 끝내도록 요구할 때
  /// 호출됩니다.
  ///
  /// 대화 러너는 스스로 이 메서드를 호출하지 않습니다. 하지만
  /// 게임(또는 대화 뷰 중 하나)의 명시적인 요청에 의해 호출될 수 있습니다.
  /// 이것이 적절한 예시는 다음과 같습니다: (a) 플레이어가 NPC와 대화하는 도중
  /// 공격을 받은 경우 -- 대화를 멈추고 목숨을 걸고 싸우는 편이 낫습니다,
  /// (b) 사용자가 "대화 건너뛰기" 버튼을 누른 경우 -- 현재 대사를 멈추고
  /// 최대한 빨리 다음 대사로 진행해야 합니다.
  ///
  /// 이 메서드는 대화의 다음 대사로 넘어가기 전에 await될 future를
  /// 반환합니다. 동시에, [onLineStart] 호출에서 아직 대기 중인
  /// future는 버려지며 더 이상 await되지 않습니다.
  /// [onLineFinish] 메서드도 호출되지 않습니다.
  FutureOr<void> onLineStop(DialogueLine line) {}

  /// 모든 대화 뷰에서 [line] 표시가 끝났을 때 호출됩니다.
  ///
  /// 일부 대화 뷰는 이 이벤트가 발생하면 화면을 지우거나, 다음 대사를 받기 위한
  /// 다른 준비를 해야 할 수 있습니다.
  /// 이 메서드가 future를 반환하면, 그 future는 대화의 다음 대사로 넘어가기 전에
  /// await됩니다.
  FutureOr<void> onLineFinish(DialogueLine line) {}

  /// 대화가 선택지 집합에 도달하여 플레이어가 이제 어떻게 진행할지
  /// 선택해야 할 때 호출됩니다. 대화 뷰가 이 선택을 플레이어에게 보여주고
  /// 선택할 수 있게 한다면, 선택이 이루어졌을 때 완료되는 future를
  /// 반환해야 합니다. 대화 뷰가 메뉴 선택지를 표시하지 않는다면
  /// `null`을 반환해야 합니다(`Future`로 감싸서 반환해도
  /// 됩니다).
  ///
  /// 이 메서드가 반환하는 future는 선택된 선택지의 인덱스를 정수 값으로
  /// 전달해야 합니다. 이 인덱스는 [choice] 목록의 길이를 넘으면 안 되며,
  /// 가리키는 선택지가 "사용 불가"로 표시되어 있어도 안 됩니다.
  /// 이 조건을 위반하면 예외가
  /// 발생합니다.
  FutureOr<int?> onChoiceStart(DialogueChoice choice) => null;

  /// 선택이 이루어져 [option]이 선택되었을 때 호출됩니다.
  ///
  /// [option]은 대화 뷰 중 하나가 [onChoiceStart] 메서드에서 반환한
  /// 선택지입니다.
  FutureOr<void> onChoiceFinish(DialogueOption option) {}

  /// 대화가 [[user-defined command]]를 만났을 때 호출됩니다.
  ///
  /// 이 메서드는 명령 자체가 실행된 직후, 그러나 실행 결과를
  /// await하기 전에 호출됩니다.
  /// ([onCommandFinish] 참고) 따라서 명령의 효과가 비동기라면,
  /// 그 효과는 대화 뷰로 전달되는 것과 *동시에* 실행됩니다.
  ///
  /// 명령의 효과가 게임 내에서 발생하는 경우에는 이 메서드를 구현할
  /// 필요가 없을 수 있습니다. 하지만 대화 뷰 자체에 영향을 주는 명령을
  /// 만들고 싶다면, 이 메서드가 그것을 구현하는
  /// 방법을 제공합니다.
  FutureOr<void> onCommand(UserDefinedCommand command) {}

  /// [command]의 결과를 await한 후에 호출됩니다.
  FutureOr<void> onCommandFinish(UserDefinedCommand command) {}
}
