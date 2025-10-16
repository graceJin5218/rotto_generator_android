
abstract class  LottoCompareResultStateBase{}

class LottoCompareResultStateError extends LottoCompareResultStateBase{
  final String? statusMessage;
  final int? statusCode;

  LottoCompareResultStateError({
    required this.statusMessage,
    required this.statusCode,
  });
}

class LottoCompareResultStateLoading extends LottoCompareResultStateBase {}

class LottoCompareResultState extends LottoCompareResultStateBase {}