import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xterm/frontend/input_behavior_desktop.dart';
import 'package:xterm/xterm.dart';

import 'input_test.mocks.dart';

@GenerateMocks([
  TerminalUiInteraction,
])
void main() {
  group('InputBehaviorDesktop', () {
    test('can handle fast typing', () {
      final mockTerminal = MockTerminalUiInteraction();
      final inputBehavior = InputBehaviorDesktop();

      inputBehavior.onTextEdit(composing('l', -1, -1), mockTerminal);
      verify(mockTerminal.raiseOnInput('l'));
      verifyNever(mockTerminal.updateComposingString(any));

      inputBehavior.onTextEdit(composing('ls', -1, -1), mockTerminal);
      verify(mockTerminal.raiseOnInput('s'));
      verifyNever(mockTerminal.updateComposingString(any));

      inputBehavior.onTextEdit(TextEditingValue.empty, mockTerminal);
      verifyNever(mockTerminal.raiseOnInput(any));
      verifyNever(mockTerminal.updateComposingString(any));
    });

    test('can handle English', () {
      final mockTerminal = MockTerminalUiInteraction();
      final inputBehavior = InputBehaviorDesktop();

      // typing 'hello'

      inputBehavior.onTextEdit(composing('h', 1, 1), mockTerminal);
      verify(mockTerminal.raiseOnInput('h'));
      verifyNever(mockTerminal.updateComposingString(any));

      inputBehavior.onTextEdit(TextEditingValue.empty, mockTerminal);
      inputBehavior.onTextEdit(composing('e', 1, 1), mockTerminal);
      verify(mockTerminal.raiseOnInput('e'));
      verifyNever(mockTerminal.updateComposingString(any));

      inputBehavior.onTextEdit(TextEditingValue.empty, mockTerminal);
      inputBehavior.onTextEdit(composing('l', 1, 1), mockTerminal);
      verify(mockTerminal.raiseOnInput('l'));
      verifyNever(mockTerminal.updateComposingString(any));

      inputBehavior.onTextEdit(TextEditingValue.empty, mockTerminal);
      inputBehavior.onTextEdit(composing('l', 1, 1), mockTerminal);
      verify(mockTerminal.raiseOnInput('l'));
      verifyNever(mockTerminal.updateComposingString(any));

      inputBehavior.onTextEdit(TextEditingValue.empty, mockTerminal);
      inputBehavior.onTextEdit(composing('o', 1, 1), mockTerminal);
      verify(mockTerminal.raiseOnInput('o'));
      verifyNever(mockTerminal.updateComposingString(any));
    });

    test('can handle Chinese', () {
      final mockTerminal = MockTerminalUiInteraction();
      final inputBehavior = InputBehaviorDesktop();

      // typing '??????'

      inputBehavior.onTextEdit(composing('n', 0, 1), mockTerminal);
      inputBehavior.onTextEdit(composing('ni', 0, 2), mockTerminal);
      inputBehavior.onTextEdit(composing('ni h', 0, 4), mockTerminal);
      inputBehavior.onTextEdit(composing('ni ha', 0, 5), mockTerminal);
      inputBehavior.onTextEdit(composing('ni hao', 0, 6), mockTerminal);
      inputBehavior.onTextEdit(composing('??????', 0, 2), mockTerminal);
      verify(mockTerminal.updateComposingString(any)).called(6);
      verifyNever(mockTerminal.raiseOnInput(any));

      inputBehavior.onTextEdit(composing('??????', -1, -1), mockTerminal);
      verify(mockTerminal.raiseOnInput('??????'));
      verify(mockTerminal.updateComposingString(''));
    });

    test('can handle Japanese', () {
      final mockTerminal = MockTerminalUiInteraction();
      final inputBehavior = InputBehaviorDesktop();

      // typing '?????????'

      inputBehavior.onTextEdit(composing('d', 0, 1), mockTerminal);
      inputBehavior.onTextEdit(composing('???', 0, 1), mockTerminal);
      inputBehavior.onTextEdit(composing('??????', 0, 2), mockTerminal);
      inputBehavior.onTextEdit(composing('??????m', 0, 3), mockTerminal);
      inputBehavior.onTextEdit(composing('?????????', 0, 3), mockTerminal);
      verify(mockTerminal.updateComposingString(any)).called(5);
      verifyNever(mockTerminal.raiseOnInput(any));

      inputBehavior.onTextEdit(composing('?????????', -1, -1), mockTerminal);
      verify(mockTerminal.raiseOnInput('?????????'));
      verify(mockTerminal.updateComposingString(''));
    });

    test('can handle Korean', () {
      final mockTerminal = MockTerminalUiInteraction();
      final inputBehavior = InputBehaviorDesktop();

      // typing '??????'

      inputBehavior.onTextEdit(composing('???', 0, 1), mockTerminal);
      inputBehavior.onTextEdit(composing('???', 0, 1), mockTerminal);
      inputBehavior.onTextEdit(composing('???', 0, 1), mockTerminal);
      inputBehavior.onTextEdit(composing('???', 0, 1), mockTerminal);
      verify(mockTerminal.updateComposingString(any)).called(4);
      verifyNever(mockTerminal.raiseOnInput(any));

      inputBehavior.onTextEdit(composing('???', 1, 1), mockTerminal);
      verify(mockTerminal.raiseOnInput('???'));
      verify(mockTerminal.updateComposingString(''));

      inputBehavior.onTextEdit(TextEditingValue.empty, mockTerminal);
      inputBehavior.onTextEdit(composing('???', 0, 1), mockTerminal);
      inputBehavior.onTextEdit(composing('???', 0, 1), mockTerminal);
      inputBehavior.onTextEdit(composing('???', 0, 1), mockTerminal);
      verify(mockTerminal.updateComposingString(any)).called(3);
      verifyNever(mockTerminal.raiseOnInput(any));

      inputBehavior.onTextEdit(composing('???', 1, 1), mockTerminal);
      verify(mockTerminal.raiseOnInput('???'));
      verify(mockTerminal.updateComposingString(''));
    });
  });
}

TextEditingValue composing(String text, int start, int end) {
  return TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
    composing: TextRange(start: start, end: end),
  );
}
