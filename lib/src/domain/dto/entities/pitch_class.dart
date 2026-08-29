/// The twelve pitch classes of the chromatic scale, independent of octave.
///
/// Naming is deliberately left out here — how a pitch class is displayed
/// (e.g. Western letter names vs. solfège) is a presentation/localization
/// concern, resolved downstream from this abstract value, not a domain one.
enum PitchClass {
  c,
  cSharp,
  d,
  dSharp,
  e,
  f,
  fSharp,
  g,
  gSharp,
  a,
  aSharp,
  b,
}
