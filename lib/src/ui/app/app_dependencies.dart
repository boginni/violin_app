import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:record/record.dart';

import '../../domain/repositories/device_runtime_repository.dart';
import '../../domain/repositories/shorten_url_repository.dart';
import '../../domain/repositories/tuner_repository.dart';
import '../../external/datasources/device_runtime_datasource.dart';
import '../../external/datasources/microphone_datasource.dart';
import '../../external/datasources/microphone_recorder.dart';
import '../../external/datasources/shorten_url_datasource.dart';
import '../../external/interceptors/dio_failure_handling_interceptor.dart';
import '../../external/provider/shorten_url_history_provider.dart';
import '../../external/repositories/device_runtime_repository_impl.dart';
import '../../external/repositories/shorten_url_repository_impl.dart';
import '../../external/repositories/tuner_repository_impl.dart';
import '../../external/services/pitch_analysis_transformer.dart';
import '../../external/services/pitch_class_mapper.dart';
import '../../external/services/pitch_detector.dart';
import '../../external/services/violin_open_string_locator.dart';
import 'controllers/app_store.dart';

class AppDependencies {
  static final GetIt _app = GetIt.asNewInstance();

  static void init() {
    _init(_app);
  }

  static void _init(GetIt i) {
    final dio = Dio();

    dio.interceptors.add(DioFailureHandlingInterceptor());

    i.registerSingleton(dio);
    i.registerSingleton(AppStore());

    i.registerFactory(ShortenUrlHistoryProvider.new);

    i.registerFactory(
      () => ShortenUrlDatasource(
        dio,
        i.get(),
      ),
    );

    i.registerFactory(
      () => const DeviceRuntimeDatasource(),
    );

    i.registerFactory<DeviceRuntimeRepository>(
      () => DeviceRuntimeRepositoryImpl(
        i.get(),
      ),
    );

    i.registerFactory<ShortenUrlRepository>(
      () => ShortenUrlRepositoryImpl(i.get()),
    );

    i.registerSingleton(MicrophoneRecorder(AudioRecorder()));

    i.registerFactory(() => MicrophoneDatasource(i.get()));

    i.registerFactory(PitchDetector.new);

    i.registerFactory(PitchClassMapper.new);

    i.registerFactory(ViolinOpenStringLocator.new);

    i.registerFactory(
      () => PitchAnalysisTransformer(i.get(), i.get(), i.get()),
    );

    i.registerFactory<TunerRepository>(
      () => TunerRepositoryImpl(i.get(), i.get()),
    );

    // --
  }

  static void restart() {
    _app.reset();
  }

  static T get<T extends Object>({
    dynamic param1,
    dynamic param2,
    String? instanceName,
    Type? type,
  }) => _app.get();

  static void registerSingleton<T extends Object>(T instance) {
    _app.registerSingleton(instance);
  }
}
