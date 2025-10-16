
abstract class  LottoGeneratorStateBase{}

class LottoGeneratorLoadStateError extends LottoGeneratorStateBase{
  final String? statusMessage;
  final int? statusCode;

  LottoGeneratorLoadStateError({
    required this.statusMessage,
    required this.statusCode,
  });
}

class LottoGeneratorStateLoading extends LottoGeneratorStateBase {}

class LottoGeneratorState extends LottoGeneratorStateBase {
  List<int> fixedNumbers;
  List<int> excludedNumbers;
  List<List<int>> generatedNumbers;
  List<List<int>> selectGeneratedNumbers;
  List<bool> checkedRows;

  LottoGeneratorState({
    required this.fixedNumbers,
    required this.excludedNumbers,
    required this.generatedNumbers,
    required this.selectGeneratedNumbers,
    required this.checkedRows,
  });

}