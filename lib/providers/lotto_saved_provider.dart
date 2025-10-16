import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rotto_app/models/draw_result_data_provider.dart';
import 'package:rotto_app/models/lotto_match_result.dart';
import 'package:rotto_app/states/lotto_saved_state.dart';
import 'package:rotto_app/states/saved_numbers_data_state.dart';
import '../models/saved_numbers_data_provider.dart';

final lottoSavedProvider =
    StateNotifierProvider<LottoSavedProvider, LottoSavedStateBase>((ref) {
  final savedNumbersDataViewModel = ref.read(savedNumbersDataProvider.notifier);
  final drawResultDataViewModel = ref.read(drawResultDataProvider.notifier);

  return LottoSavedProvider(
      savedNumbersDataViewModel: savedNumbersDataViewModel,
      drawResultDataViewModel: drawResultDataViewModel);
});

class LottoSavedProvider extends StateNotifier<LottoSavedStateBase> {
  final SavedNumbersDataProvider savedNumbersDataViewModel;
  final DrawResultDataProvider drawResultDataViewModel;

  LottoSavedProvider({
    required this.savedNumbersDataViewModel,
    required this.drawResultDataViewModel,
  }) : super(LottoSavedStateLoading()) {
    state = LottoSavedState();
  }

  Future<void> deleteSpecificSavedNumber(BuildContext context, LottoNumber item) async {
    state = LottoSavedStateLoading();

    final pSavedNumbersDataState =
        savedNumbersDataViewModel.state as SavedNumbersDataState;

    if (pSavedNumbersDataState.savedNumbers == null) return;

    pSavedNumbersDataState.savedNumbers!.remove(item);

    savedNumbersDataViewModel.saveToLocal();

    state = LottoSavedState();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('번호가 삭제되었습니다.')),
    );
  }

  Future<void> deleteAllSavedNumbers(BuildContext context) async {
    state = LottoSavedStateLoading();

    final pSavedNumbersDataState =
        savedNumbersDataViewModel.state as SavedNumbersDataState;

    if (pSavedNumbersDataState.savedNumbers == null) return;

    pSavedNumbersDataState.savedNumbers!.clear();

    savedNumbersDataViewModel.saveToLocal();

    state = LottoSavedState();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('번호가 전체 삭제되었습니다.')),
    );
  }

LottoMatchResult checkRank(LottoNumber myNumbers, LottoDrawResult pastResult) {
  final matched = myNumbers.numbers.where(pastResult.numbers.contains).length;
  final bonusMatched = myNumbers.numbers.contains(pastResult.bonus);

  String rank;
  if (matched == 6) {
    rank = "1등";
  } else if (matched == 5 && bonusMatched) {
    rank = "2등";
  } else if (matched == 5) {
    rank = "3등";
  } else if (matched == 4) {
    rank = "4등";
  } else if (matched == 3) {
    rank = "5등";
  } else {
    return LottoMatchResult(round: pastResult.drawNo, result: null);
  }

  return LottoMatchResult(round: pastResult.drawNo, result: "$rank ($matched개 일치)");
}
}
