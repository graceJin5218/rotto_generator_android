import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rotto_app/models/draw_result_data_provider.dart';
import 'package:rotto_app/states/lotto_compare_result_state.dart';
import 'package:http/http.dart' as http;

final lottoCompareResultProvider =
    StateNotifierProvider<LottoCompareResultProvider, LottoCompareResultStateBase>((ref){
  return LottoCompareResultProvider();
},);

class LottoCompareResultProvider extends StateNotifier<LottoCompareResultStateBase>{
  LottoCompareResultProvider() : super(LottoCompareResultStateLoading()){
    state = LottoCompareResultState();
  }

  Future<LottoDrawResult> fetchLottoResult(int round) async {
    final res = await http.get(Uri.parse(
        'https://www.dhlottery.co.kr/common.do?method=getLottoNumber&drwNo=$round'));
    final json = jsonDecode(res.body);
    return LottoDrawResult(
      drawNo: round,
      drawDate: DateTime.parse(json['drwNoDate']),
      numbers: [
        json['drwtNo1'],
        json['drwtNo2'],
        json['drwtNo3'],
        json['drwtNo4'],
        json['drwtNo5'],
        json['drwtNo6'],
      ],
      bonus: json['bnusNo'],
    );
  }
}