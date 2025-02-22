// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:sample_app/utils/localizations.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

typedef ChipBuilder<T> = Widget Function(BuildContext context, T chip);
typedef OnChipAdded<T> = void Function(T chip);
typedef OnChipRemoved<T> = void Function(T chip);

class ChipsInputTextField<T> extends StatefulWidget {
  const ChipsInputTextField({
    super.key,
    required this.chipBuilder,
    required this.controller,
    this.onInputChanged,
    this.focusNode,
    this.onChipAdded,
    this.onChipRemoved,
    this.hint = 'Type a name',
  });
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onInputChanged;
  final ChipBuilder<T> chipBuilder;
  final OnChipAdded<T>? onChipAdded;
  final OnChipRemoved<T>? onChipRemoved;
  final String hint;

  @override
  ChipInputTextFieldState<T> createState() => ChipInputTextFieldState<T>();
}

class ChipInputTextFieldState<T> extends State<ChipsInputTextField<T>> {
  final _chips = <T>{};
  bool _pauseItemAddition = false;

  void addItem(T item) {
    setState(() => _chips.add(item));
    widget.onChipAdded?.call(item);
  }

  void removeItem(T item) {
    setState(() {
      _chips.remove(item);
      if (_chips.isEmpty) resumeItemAddition();
    });
    widget.onChipRemoved?.call(item);
  }

  void pauseItemAddition() {
    if (!_pauseItemAddition) {
      setState(() => _pauseItemAddition = true);
    }
    widget.focusNode?.unfocus();
  }

  void resumeItemAddition() {
    if (_pauseItemAddition) {
      setState(() => _pauseItemAddition = false);
    }
    widget.focusNode?.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pauseItemAddition ? resumeItemAddition : null,
      child: Material(
        elevation: 1,
        color: StreamChatTheme.of(context).colorTheme.barsBg,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${AppLocalizations.of(context).to.toUpperCase()}:',
                  style: StreamChatTheme.of(context)
                      .textTheme
                      .footnote
                      .copyWith(
                          color: StreamChatTheme.of(context)
                              .colorTheme
                              .textHighEmphasis
                              .withOpacity(.5)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _chips.map((item) {
                        return widget.chipBuilder(context, item);
                      }).toList(),
                    ),
                    if (!_pauseItemAddition)
                      TextField(
                        controller: widget.controller,
                        onChanged: widget.onInputChanged,
                        focusNode: widget.focusNode,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.only(top: 4),
                          hintText: widget.hint,
                          hintStyle: StreamChatTheme.of(context)
                              .textTheme
                              .body
                              .copyWith(
                                  color: StreamChatTheme.of(context)
                                      .colorTheme
                                      .textHighEmphasis
                                      .withOpacity(.5)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Align(
                alignment: Alignment.bottomCenter,
                child: IconButton(
                  icon: _chips.isEmpty
                      ? StreamSvgIcon(
                          icon: StreamSvgIcons.user,
                          color: StreamChatTheme.of(context)
                              .colorTheme
                              .textHighEmphasis
                              .withOpacity(0.5),
                          size: 24,
                        )
                      : StreamSvgIcon(
                          icon: StreamSvgIcons.userAdd,
                          color: StreamChatTheme.of(context)
                              .colorTheme
                              .textHighEmphasis
                              .withOpacity(0.5),
                          size: 24,
                        ),
                  onPressed: resumeItemAddition,
                  alignment: Alignment.topRight,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  splashRadius: 24,
                  constraints: const BoxConstraints.tightFor(
                    height: 24,
                    width: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
