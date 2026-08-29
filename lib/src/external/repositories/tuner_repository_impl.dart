import 'package:error_handler_with_result/error_handler_with_result.dart';

import '../../domain/dto/entities/detected_note_entity.dart';
import '../../domain/repositories/tuner_repository.dart';
import '../datasources/microphone_datasource.dart';
import '../services/pitch_analysis_transformer.dart';

class TunerRepositoryImpl implements TunerRepository {
  final MicrophoneDatasource datasource;
  final PitchAnalysisTransformer pitchAnalysisTransformer;

  const TunerRepositoryImpl(this.datasource, this.pitchAnalysisTransformer);

  @override
  Future<Result<Stream<DetectedNoteEntity?>>> startListening() async {
    try {
      final pcmStream = await datasource.startStream();

      return Result.success(pcmStream.transform(pitchAnalysisTransformer));
    } catch (e, s) {
      return Result.failureFromCatch(e, s);
    }
  }

  @override
  Future<Result<void>> stopListening() async {
    try {
      await datasource.stopStream();

      return const Result.success();
    } catch (e, s) {
      return Result.failureFromCatch(e, s);
    }
  }

  @override
  Result<Stream<DetectedNoteEntity?>?> getCurrentStream() {
    try {
      final pcmStream = datasource.getCurrentStream();

      if (pcmStream == null) {
        return const Result.success();
      }

      return Result.success(pcmStream.transform(pitchAnalysisTransformer));
    } catch (e, s) {
      return Result.failureFromCatch(e, s);
    }
  }
}
