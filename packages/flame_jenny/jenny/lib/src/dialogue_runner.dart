import 'dart:async';

import 'package:jenny/src/dialogue_view.dart';
import 'package:jenny/src/errors.dart';
import 'package:jenny/src/structure/block.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/commands/user_defined_command.dart';
import 'package:jenny/src/structure/dialogue_choice.dart';
import 'package:jenny/src/structure/dialogue_line.dart';
import 'package:jenny/src/structure/node.dart';
import 'package:jenny/src/yarn_project.dart';
import 'package:meta/meta.dart';

/// **DialogueRunner**는 런타임에 Jenny의 대화를
/// 실행하는 엔진입니다.
///
/// [YarnProject]를 여러 [Node]를 "함수"로 가지는 "프로그램"이라고 상상하면,
/// `DialogueRunner`는 그 "프로그램"의 "함수" 하나를 실행할 수 있는
/// 가상 머신입니다.
///
/// 하나의 `DialogueRunner`는 한 번에 하나의 대화 노드만 실행할 수 있습니다.
/// 첫 번째 노드가 끝나기 전에 다른 노드를 실행하려고 하면 오류입니다.
/// 하지만 같은 [YarnProject]에 대해 여러 `DialogueRunner`를 만들 수 있으며,
/// 그러면 여러 대화를 동시에 실행할 수 있습니다
/// (예를 들어 붐비는 방에서는 서로 다른 무리의 사람들 사이에서
/// 여러 대화가 한꺼번에 오갈 수 있습니다).
///
/// `DialogueRunner`의 역할은 대화 대사를 올바른 순서와 적절한 속도로
/// 가져오고, 대화 스크립트의 로직을 실행하며, [DialogueChoice]에서의
/// 사용자 입력에 따라 분기하는 것입니다. 따라서
/// `DialogueRunner`의 출력은 플레이어에게 보여줘야 할 대화 구문의 스트림입니다.
/// 이러한 표시는
/// [DialogueView]가 담당합니다.
class DialogueRunner {
  /// [yarnProject]를 실행하기 위한 `DialogueRunner`를 생성합니다. 대화는
  /// 제공된 모든 [_dialogueViews]에 전달됩니다. 각 대화 뷰는
  /// 한 번에 하나의 `DialogueRunner`에만 할당될 수
  /// 있습니다.
  DialogueRunner({
    required YarnProject yarnProject,
    required this._dialogueViews,
  }) : project = yarnProject;

  final List<DialogueView> _dialogueViews;
  _LineDeliveryPipeline? _linePipeline;
  Node? _currentNode;
  NodeIterator? _currentIterator;
  String? _initialNodeName;
  String? _nextNode;

  /// 이 대화 러너가 실행 중인 `YarnProject`입니다.
  final YarnProject project;

  /// [nodeName] 노드로 대화를 시작하고, 대화 실행이 끝나면 완료되는 future를
  /// 반환합니다. 이 future가 대기 중인 동안에는
  /// `DialogueRunner`가 다른 대화를 시작할 수 없습니다.
  Future<void> startDialogue(String nodeName) async {
    try {
      if (_initialNodeName != null) {
        throw DialogueError(
          'Cannot run node "$nodeName" because another node is '
          'currently running: "$_initialNodeName"',
        );
      }
      _initialNodeName = nodeName;
      _dialogueViews.forEach((view) {
        if (view.dialogueRunner != null) {
          throw DialogueError(
            'DialogueView is currently attached to another DialogueRunner',
          );
        }
        view.dialogueRunner = this;
      });
      await _event((view) => view.onDialogueStart());
      await _runNode(nodeName);
      await _event((view) => view.onDialogueFinish());
    } finally {
      _dialogueViews.forEach((dv) => dv.dialogueRunner = null);
      _initialNodeName = null;
      _nextNode = null;
      _currentIterator = null;
      _currentNode = null;
    }
  }

  /// 주어진 [signal]을 [DialogueView]의 `onLineSignal(line, signal)` 메서드
  /// 형태로 모든 대화 뷰에 전달합니다. 이는 예를 들어
  /// 대화 뷰들 사이의 통신 수단으로 사용할 수 있습니다.
  ///
  /// 여기서 [signal] 객체는 완전히 임의의 값이며, 어떤 신호를 보내고 받을지는
  /// 구현에서 결정합니다.
  /// 구현은 이해하지 못하는 신호를 무시해야 합니다.
  void sendSignal(dynamic signal) {
    assert(_linePipeline != null);
    final line = _linePipeline!.line;
    for (final view in _dialogueViews) {
      view.onLineSignal(line, signal);
    }
  }

  /// 현재 대사의 표시를 가능한 한 빨리 끝내도록 (`onLineStop()`을 통해)
  /// 요청합니다. 그 후 대화는 정상적으로
  /// 다음 대사로 진행됩니다.
  void stopLine() {
    _linePipeline?.stop();
  }

  Future<void> _runNode(String nodeName) async {
    _nextNode = nodeName;
    while (_nextNode != null) {
      final node = project.nodes[_nextNode!];
      if (node == null) {
        throw NameError('Node "$_nextNode" could not be found');
      }

      _nextNode = null;
      _currentNode = node;
      _currentIterator = node.iterator;

      await _event((view) => view.onNodeStart(node));
      while (_currentIterator?.moveNext() ?? false) {
        final entry = _currentIterator!.current;
        await entry.processInDialogueRunner(this);
      }
      _incrementNodeVisitCount();
      await _event((view) => view.onNodeFinish(node));

      _currentNode = null;
      _currentIterator = null;
    }
  }

  void _incrementNodeVisitCount() {
    final nodeVariable = '@${_currentNode!.title}';
    project.variables.setVariable(
      nodeVariable,
      project.variables.getNumericValue(nodeVariable) + 1,
    );
  }

  @internal
  Future<void> deliverLine(DialogueLine line) async {
    final pipeline = _LineDeliveryPipeline(line, _dialogueViews);
    _linePipeline = pipeline;
    pipeline.start();
    await pipeline.future;
    _linePipeline = null;
  }

  @internal
  Future<void> deliverChoices(DialogueChoice choice) async {
    final futures = <Future<int?>>[];
    final choices = <int>[];
    for (final view in _dialogueViews) {
      final futureOrResult = view.onChoiceStart(choice);
      if (futureOrResult != null) {
        if (futureOrResult is int) {
          choices.add(futureOrResult);
        } else {
          // ignore: cast_nullable_to_non_nullable
          futures.add(futureOrResult as Future<int?>);
        }
      }
    }
    for (final future in futures) {
      final choice = await future;
      if (choice != null) {
        choices.add(choice);
      }
    }

    if (choices.isEmpty) {
      throw DialogueError('No option selected in a DialogueChoice');
    }
    final chosenIndex = choices.first;
    if (chosenIndex < 0 || chosenIndex >= choice.options.length) {
      throw DialogueError(
        'Invalid option index chosen in a dialogue: $chosenIndex',
      );
    }
    final chosenOption = choice.options[chosenIndex];
    if (!chosenOption.isAvailable) {
      throw DialogueError(
        'A dialogue view selected a disabled option: $chosenOption',
      );
    }
    await _event((view) => view.onChoiceFinish(chosenOption));
    enterBlock(chosenOption.block);
  }

  @internal
  Future<void> deliverCommand(Command command) async {
    await _combineFutures([
      // Start execution of commands
      command.execute(this),
      // Call [onCommand] for all the views registered with this runner
      // so they can be notified that execution of the command has started.
      if (command is UserDefinedCommand)
        for (final view in _dialogueViews) view.onCommand(command),
    ]);
    // The thing we actually want to wait for is the result of
    // [command.execute(this)]. It also makes sense to wait until all
    // [onCommand] invocations are complete because conceptually,
    // [onCommand] should always precede [onCommandFinish].
    if (command is UserDefinedCommand) {
      await _combineFutures([
        for (final view in _dialogueViews) view.onCommandFinish(command),
      ]);
    }
  }

  @internal
  void enterBlock(Block block) {
    _currentIterator!.diveInto(block);
  }

  /// 현재 노드를 멈추고 [nodeName] 실행을 시작합니다. [nodeName]이
  /// null이면 대화를 완전히 멈춥니다.
  ///
  /// 이 명령은 동기적입니다. 즉 노드가 *실제로* 끝나기를(이때
  /// `onNodeFinish` 콜백이 호출됨) 기다리지 않습니다.
  @internal
  void jumpToNode(String? nodeName) {
    _currentIterator = null;
    _nextNode = nodeName;
  }

  @internal
  Future<void> visitNode(String nodeName) async {
    final node = _currentNode;
    final iterator = _currentIterator;
    await _runNode(nodeName);
    _currentNode = node;
    _currentIterator = iterator;
  }

  /// `Future.wait()`와 비슷하지만 `FutureOr`를 받습니다.
  FutureOr<void> _combineFutures(List<FutureOr<void>> maybeFutures) {
    final futures = maybeFutures.whereType<Future<void>>().toList();
    if (futures.isNotEmpty) {
      if (futures.length == 1) {
        return futures[0];
      } else {
        final Future<void> result = Future.wait(futures);
        return result;
      }
    }
  }

  FutureOr<void> _event(FutureOr<void> Function(DialogueView) callback) {
    return _combineFutures([for (final view in _dialogueViews) callback(view)]);
  }
}

class _LineDeliveryPipeline {
  _LineDeliveryPipeline(this.line, this.views)
    : _completer = Completer(),
      _futures = List.generate(views.length, (i) => null, growable: false);

  final DialogueLine line;
  final List<DialogueView> views;
  final List<FutureOr<void>> _futures;
  final Completer<void> _completer;
  int _numPendingFutures = 0;
  bool _interrupted = false;

  Future<void> get future => _completer.future;

  void start() {
    assert(_numPendingFutures == 0);
    for (var i = 0; i < views.length; i++) {
      final maybeFuture = views[i].onLineStart(line);
      if (maybeFuture is Future) {
        // ignore: cast_nullable_to_non_nullable
        final future = maybeFuture as Future<bool>;
        _futures[i] = future.then((_) => startCompleted(i));
        _numPendingFutures++;
      } else {
        continue;
      }
    }
    if (_numPendingFutures == 0) {
      finish();
    }
  }

  void stop() {
    _interrupted = true;
    for (var i = 0; i < views.length; i++) {
      if (_futures[i] != null) {
        final newFuture = views[i].onLineStop(line);
        _futures[i] = newFuture;
        if (newFuture == null) {
          _numPendingFutures -= 1;
        }
      }
    }
    if (_numPendingFutures == 0) {
      finish();
    }
  }

  void finish() {
    assert(_numPendingFutures == 0);
    for (var i = 0; i < views.length; i++) {
      final maybeFuture = views[i].onLineFinish(line);
      if (maybeFuture is Future) {
        // ignore: unnecessary_cast
        final future = maybeFuture as Future<void>;
        _futures[i] = future.then((_) => finishCompleted(i));
        _numPendingFutures++;
      } else {
        continue;
      }
    }
    if (_numPendingFutures == 0) {
      _completer.complete();
    }
  }

  void startCompleted(int i) {
    if (!_interrupted) {
      assert(_futures[i] != null);
      assert(_numPendingFutures > 0);
      _futures[i] = null;
      _numPendingFutures -= 1;
      if (_numPendingFutures == 0) {
        finish();
      }
    }
  }

  void finishCompleted(int i) {
    assert(_futures[i] != null);
    assert(_numPendingFutures > 0);
    _futures[i] = null;
    _numPendingFutures -= 1;
    if (_numPendingFutures == 0) {
      _completer.complete();
    }
  }
}
