import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rotto_app/states/saved_numbers_data_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

final savedNumbersDataProvider =
    StateNotifierProvider<SavedNumbersDataProvider, SavedNumbersDataStateBase>(
  (ref) {
    return SavedNumbersDataProvider();
  },
);

class SavedNumbersDataProvider
    extends StateNotifier<SavedNumbersDataStateBase> {
  SavedNumbersDataProvider() : super(SavedNumbersDataStateLoading()) {
    initialize();
  }

  Future<void> initialize() async {
    await loadSavedNumbers();
  }

  Future<void> loadSavedNumbers() async {
    print("loadSavedNumbers");
    state = SavedNumbersDataStateLoading();

    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('savedNumbers');

    List<LottoNumber> savedNumbers = [];

    if(data != null){
      final List<dynamic> jsonList = jsonDecode(data);
      savedNumbers.addAll(
        jsonList.map((e) => LottoNumber.fromJson(e)).toList(),
      );
    }
    state = SavedNumbersDataState(savedNumbers: savedNumbers);
  }


  Future<void> saveToLocal() async{
    print("번호를 로컬에 저장했습니다.");

    final pState = state as SavedNumbersDataState;

    final prefs = await SharedPreferences.getInstance();
    final data = pState.savedNumbers?.map((e) => e.toJson()).toList();

    await prefs.setString('savedNumbers', jsonEncode(data));
  }
}

class LottoNumber {
  final List<int> numbers;
  final DateTime timestamp;
  bool isFavorite; // 추가됨

  LottoNumber({
    required this.numbers,
    required this.timestamp,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'numbers': numbers,
      'timestamp': timestamp.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory LottoNumber.fromJson(Map<String, dynamic> json) {
    return LottoNumber(
      numbers: List<int>.from(json['numbers']),
      timestamp: DateTime.parse(json['timestamp']),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LottoNumber &&
        timestamp == other.timestamp &&
        numbers.join(',') == other.numbers.join(',');
  }

  @override
  int get hashCode => timestamp.hashCode ^ numbers.join(',').hashCode;
}

