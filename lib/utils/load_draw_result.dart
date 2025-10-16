import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:rotto_app/models/draw_result_data_provider.dart';
import 'package:http/http.dart' as http;

class LoadData {
  Future<List<LottoDrawResult>?> loadDrawResult() async{
    final dir = await getApplicationDocumentsDirectory();
    final jsonFile = File('${dir.path}/lotto_results.json');

    try{
      // 1) 파일 없으면 assets에서 복사
      if (!await jsonFile.exists()) {
        print('🚨 lotto_results.json 파일이 없어 assets에서 복사합니다.');
        await copyLottoJsonFromAssets(jsonFile);
      }

      // 2) 파일에 저장된 기록 불러오기
      List<LottoDrawResult> storedResults =
      await loadLottoResultsFromJson(jsonFile);

      // 3) 최신 회차 조회
      final latestRound = await fetchLatestRoundNumber();
      if (latestRound == null) return null;

      final oneYearRounds = List<int>.generate(52, (i) => latestRound - i);

      // 4) 파일에 있는 데이터로 가져오기
      List<LottoDrawResult> finalResults = [];
      final storedMap = {for (var r in storedResults) r.drawNo: r};

      for (var round in oneYearRounds) {
        if (storedMap.containsKey(round)) {
          finalResults.add(storedMap[round]!);
        }
      }

      // 5) 파일에 없는 회차는 API로 가져오기 + 파일 업데이트
      for (var round in oneYearRounds.where((r) => !storedMap.containsKey(r))) {
        try {
          final result = await fetchLottoResult(round);
          finalResults.add(result);
          storedResults.add(result); // 기존 기록에 추가
          await updateLottoResultsJson(jsonFile, storedResults);
          print('✅ API로 가져와 추가: ${result.drawNo}회');
        } catch (e) {
          print('❌ ${round}회 API 가져오기 실패: $e');
        }
      }

      // 최신순 정렬
      finalResults.sort((a, b) => b.drawNo.compareTo(a.drawNo));
      return finalResults;

      //savedLottoDrawResultList.savedLottoDrawResultList = finalResults;
    }
    catch(e){
      print('loadDrawResult 에러 : $e');
    }
  }

  Future<void> copyLottoJsonFromAssets(File targetFile) async {
    final jsonStr = await rootBundle.loadString('assets/lotto_results.json');
    await targetFile.writeAsString(jsonStr);
    print('✅ assets에서 lotto_results.json 복사 완료');
  }

  Future<List<LottoDrawResult>> loadLottoResultsFromJson(File file) async {
    try {
      final jsonData = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonData);
      return jsonList.map((e) => LottoDrawResult.fromJson(e)).toList();
    } catch (e) {
      print('⚠️ JSON 로드 실패: $e');
      return [];
    }
  }

  Future<void> updateLottoResultsJson(
      File file, List<LottoDrawResult> allResults) async {
    allResults.sort((a, b) => b.drawNo.compareTo(a.drawNo));
    final updatedJson = jsonEncode(allResults.map((e) => e.toJson()).toList());
    await file.writeAsString(updatedJson);
  }


  Future<int?> fetchLatestRoundNumber(
      {int start = 1177, int maxTries = 1000}) async {
    for (int i = 0; i < maxTries; i++) {
      final drawNo = start + i;
      final url = Uri.parse(
          'https://www.dhlottery.co.kr/common.do?method=getLottoNumber&drwNo=$drawNo');
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final json = jsonDecode(utf8.decode(response.bodyBytes));
          if (json['returnValue'] != 'success') return drawNo - 1;
        } else {
          return null;
        }
      } catch (_) {
        return null;
      }
    }
    return null;
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