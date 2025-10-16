import 'package:rotto_app/models/draw_result_data_provider.dart';

abstract class  DrawResultDataStateBase{}

class DrawResultDataStateError extends DrawResultDataStateBase{
  final String? statusMessage;
  final int? statusCode;

  DrawResultDataStateError({
    required this.statusMessage,
    required this.statusCode,
  });
}

class DrawResultDataStateLoading extends DrawResultDataStateBase {}

class DrawResultDataState extends DrawResultDataStateBase {
  List<LottoDrawResult> recentResults;

  DrawResultDataState({
    required this.recentResults,
  });

}