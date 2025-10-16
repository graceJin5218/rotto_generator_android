import 'package:rotto_app/models/draw_result_data_provider.dart';
import 'package:rotto_app/models/saved_numbers_data_provider.dart';

abstract class LottoSavedStateBase {}

class LottoSavedStateError extends LottoSavedStateBase {
  final String? statusMessage;
  final int? statusCode;

  LottoSavedStateError({
    required this.statusMessage,
    required this.statusCode,
  });
}

class LottoSavedStateLoading extends LottoSavedStateBase {}

class LottoSavedState extends LottoSavedStateBase {}
