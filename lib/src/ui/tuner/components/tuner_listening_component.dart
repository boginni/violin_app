import 'package:flutter/material.dart';
import 'package:violin_l10n/violin_l10n.dart';

import '../../../domain/dto/entities/detected_note_entity.dart';
import '../../app/extensions/context_extensions.dart';
import '../pitch_class_label.dart';

class TunerListeningComponent extends StatelessWidget {
  const TunerListeningComponent({
    super.key,
    required this.note,
    required this.onStop,
  });

  final DetectedNoteEntity? note;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final currentNote = note;

    return Padding(
      padding: const .all(24),
      child: Column(
        spacing: 24,
        children: [
          Expanded(
            child: Center(
              child: currentNote == null
                  ? Text(
                      context.l10n.tuner_listening_hint,
                      style: context.textTheme.titleMedium,
                      textAlign: .center,
                    )
                  : _NoteDetailsComponent(note: currentNote),
            ),
          ),
          OutlinedButton.icon(
            onPressed: onStop,
            icon: const Icon(Icons.stop),
            label: Text(context.l10n.tuner_stop_listening),
          ),
        ],
      ),
    );
  }
}

class _NoteDetailsComponent extends StatelessWidget {
  const _NoteDetailsComponent({required this.note});

  final DetectedNoteEntity note;

  @override
  Widget build(BuildContext context) {
    final statusColor = note.isInTune
        ? Colors.green
        : context.colorScheme.error;

    final statusText = note.isInTune
        ? context.l10n.tuner_in_tune
        : note.centsOffset < 0
        ? context.l10n.tuner_too_flat
        : context.l10n.tuner_too_sharp;

    return Column(
      mainAxisSize: .min,
      spacing: 12,
      children: [
        Text(
          '${note.pitchClass.label(context)}${note.octave}',
          style: context.textTheme.displayLarge,
        ),
        Text(
          context.l10n.tuner_frequency_hz(note.frequency.toStringAsFixed(1)),
          style: context.textTheme.bodyLarge,
        ),
        _CentsGaugeComponent(centsOffset: note.centsOffset, color: statusColor),
        Text(
          statusText,
          style: context.textTheme.titleMedium?.copyWith(color: statusColor),
        ),
        if (note.closestOpenString case final closestOpenString?)
          Text(
            context.l10n.tuner_closest_string(closestOpenString.label(context)),
          ),
      ],
    );
  }
}

class _CentsGaugeComponent extends StatelessWidget {
  const _CentsGaugeComponent({
    required this.centsOffset,
    required this.color,
  });

  final double centsOffset;
  final Color color;

  static const _maxCents = 50.0;

  @override
  Widget build(BuildContext context) {
    final fraction = centsOffset.clamp(-_maxCents, _maxCents) / _maxCents;

    return SizedBox(
      width: 220,
      height: 24,
      child: Stack(
        alignment: .center,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: context.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(width: 2, height: 24, color: context.colorScheme.outline),
          Align(
            alignment: Alignment(fraction, 0),
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(color: color, shape: .circle),
            ),
          ),
        ],
      ),
    );
  }
}
