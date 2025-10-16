import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rotto_app/models/saved_numbers_data_provider.dart';
import 'package:rotto_app/states/lotto_generator_state.dart';
import 'package:collection/collection.dart';
import 'package:rotto_app/states/saved_numbers_data_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

final lottoGeneratorProvider =
    StateNotifierProvider<LottoGeneratorProvider, LottoGeneratorStateBase>(
        (ref) {
  final savedNumbersDataState = ref.read(savedNumbersDataProvider);
  final savedNumbersDataViewModel = ref.read(savedNumbersDataProvider.notifier);
  return LottoGeneratorProvider(
      savedNumbersDataState: savedNumbersDataState,
      savedNumbersDataViewModel: savedNumbersDataViewModel);
});

class LottoGeneratorProvider extends StateNotifier<LottoGeneratorStateBase> {
  SavedNumbersDataStateBase savedNumbersDataState;
  SavedNumbersDataProvider savedNumbersDataViewModel;

  final List<int> _fixedNumbers = [];
  final List<int> _excludedNumbers = [];
  final List<List<int>> _generatedNumbers = [];
  final List<List<int>> _selectGeneratedNumbers = [];
  final List<bool> _checkedRows = [];
  final List<LottoNumber> _savedNumbers = [];

  List<int> get fixedNumbers => _fixedNumbers;

  List<int> get excludedNumbers => _excludedNumbers;

  List<List<int>> get generatedNumbers => _generatedNumbers;

  List<List<int>> get selectGeneratedNumbers => _selectGeneratedNumbers;

  List<bool> get checkedRows => _checkedRows;

  List<LottoNumber> get savedNumbers => _savedNumbers;

  LottoGeneratorProvider({
    required this.savedNumbersDataState,
    required this.savedNumbersDataViewModel,
  }) : super(LottoGeneratorStateLoading()) {
    state = LottoGeneratorState(
      fixedNumbers: _fixedNumbers,
      excludedNumbers: _excludedNumbers,
      generatedNumbers: _generatedNumbers,
      selectGeneratedNumbers: _selectGeneratedNumbers,
      checkedRows: _checkedRows,
    );
  }

  void saveNumbers(BuildContext context, List<List<int>> numbersList) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('savedNumbers');

    if (raw != null) {
      print("맞나요?");
      final List<dynamic> jsonList = jsonDecode(raw);
      _savedNumbers
        ..clear()
        ..addAll(jsonList.map((e) => LottoNumber.fromJson(e)));
    }

    bool _needSnackBar = false;
    // ② 새로 들어온 번호들(numbersList)을 _savedNumbers 위에 붙이기
    for (var nums in numbersList) {
      if (_savedNumbers
          .any((item) => const ListEquality().equals(item.numbers, nums))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$nums 는 이미 저장된 번호입니다.'),
          duration: const Duration(milliseconds: 800),),
        );
      } else {
        _needSnackBar = true;

        _savedNumbers.add(
          LottoNumber(
            numbers: List.from(nums),
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    savedNumbersDataViewModel.state =
        SavedNumbersDataState(savedNumbers: _savedNumbers);
    savedNumbersDataViewModel.saveToLocal();

    if (_needSnackBar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('번호가 저장되었습니다.'),
          duration: const Duration(milliseconds: 800),),
      );
    }
  }
}
