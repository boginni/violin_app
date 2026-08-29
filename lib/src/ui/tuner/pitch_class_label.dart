import 'package:flutter/widgets.dart';
import 'package:violin_l10n/violin_l10n.dart';

import '../../domain/dto/entities/pitch_class.dart';
import '../../domain/dto/entities/violin_open_string.dart';

/// Resolves a [PitchClass] to its localized display name — Western letter
/// names in English, solfège in Portuguese — the same way any other
/// user-facing string is localized in this app. Keeping this out of the
/// domain/pitch-analysis pipeline is what lets a different naming scheme be
/// added later by touching only l10n, not the note-detection logic.
extension PitchClassLabel on PitchClass {
  String label(BuildContext context) => switch (this) {
    PitchClass.c => context.l10n.pitch_class_c,
    PitchClass.cSharp => context.l10n.pitch_class_c_sharp,
    PitchClass.d => context.l10n.pitch_class_d,
    PitchClass.dSharp => context.l10n.pitch_class_d_sharp,
    PitchClass.e => context.l10n.pitch_class_e,
    PitchClass.f => context.l10n.pitch_class_f,
    PitchClass.fSharp => context.l10n.pitch_class_f_sharp,
    PitchClass.g => context.l10n.pitch_class_g,
    PitchClass.gSharp => context.l10n.pitch_class_g_sharp,
    PitchClass.a => context.l10n.pitch_class_a,
    PitchClass.aSharp => context.l10n.pitch_class_a_sharp,
    PitchClass.b => context.l10n.pitch_class_b,
  };
}

extension ViolinOpenStringLabel on ViolinOpenString {
  String label(BuildContext context) => '${pitchClass.label(context)}$octave';
}
