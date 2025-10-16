import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rotto_app/states/draw_result_data_state.dart';
import 'package:rotto_app/utils/load_draw_result.dart';

final drawResultDataProvider = StateNotifierProvider<DrawResultDataProvider,DrawResultDataStateBase>((ref) {
  return DrawResultDataProvider();
},);

class DrawResultDataProvider extends StateNotifier<DrawResultDataStateBase>{
  List<LottoDrawResult> _recentResults = [];

  DrawResultDataProvider():super(DrawResultDataStateLoading()){
    initialize();
  }

  Future<void> initialize() async {
    final loadData = LoadData();
    List<LottoDrawResult>? drawResult = await loadData.loadDrawResult();

    if (drawResult == null) return;
    _recentResults = drawResult;

    state = DrawResultDataState(recentResults: _recentResults);
  }
}

class LottoDrawResult {
  final int drawNo;
  final DateTime drawDate;
  final List<int> numbers;
  final int bonus;

  LottoDrawResult({
    required this.drawNo,
    required this.drawDate,
    required this.numbers,
    required this.bonus,
  });

  // JSON으로 직렬화할 때 사용
  Map<String, dynamic> toJson() => {
        'drawNo': drawNo,
        'drawDate': drawDate.toIso8601String(),
        'drwtNo': numbers,
        'bnusNo': bonus,
      };

  factory LottoDrawResult.fromJson(Map<String, dynamic> json) {
    return LottoDrawResult(
      drawNo: json['drwNo'],
      drawDate: json['drwNoDate'],
      numbers: List.generate(6, (i) => json['drwtNo${i + 1}']),
      bonus: json['bnusNo'],
    );
  }
}
