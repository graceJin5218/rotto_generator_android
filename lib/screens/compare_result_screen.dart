// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:rotto_app/models/saved_numbers_data_provider.dart';
// import 'package:rotto_app/providers/lotto_compare_result_provider.dart';
// import 'package:rotto_app/screens/qr_scanner_screen.dart';
// import 'package:rotto_app/states/draw_result_data_state.dart';
// import 'package:rotto_app/states/lotto_saved_state.dart';
// import 'package:rotto_app/states/saved_numbers_data_state.dart';
// import '../models/draw_result_data_provider.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// class CompareResultScreen extends ConsumerStatefulWidget {
//   const CompareResultScreen({Key? key}) : super(key: key);
//
//   @override
//   ConsumerState<CompareResultScreen> createState() =>
//       _CompareResultScreenState();
// }
//
// class _CompareResultScreenState extends ConsumerState<CompareResultScreen> {
//   int? selectedDraw;
//   LottoDrawResult? drawResult;
//   String resultText = '';
//   final List<TextEditingController> controllers =
//       List.generate(6, (_) => TextEditingController());
//   int? selectedSavedIndex;
//
//   void _showError(String message) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('입력 오류'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: const Text('확인'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _getLottoRank({
//     required List<int> myNumbers,
//     required List<int> winNumbers,
//     required int bonusNumber,
//   }) {
//     final matchCount = myNumbers.where((n) => winNumbers.contains(n)).length;
//     final bonusMatched = myNumbers.contains(bonusNumber);
//
//     if (matchCount == 6) return '🥇 1등';
//     if (matchCount == 5 && bonusMatched) return '🥈 2등';
//     if (matchCount == 5) return '🥉 3등';
//     if (matchCount == 4) return '4등';
//     if (matchCount == 3) return '5등';
//     return '미당첨';
//   }
//
//   void _fillFromSaved(List<int> numbers) {
//     for (int i = 0; i < 6; i++) {
//       controllers[i].text = numbers[i].toString();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(lottoCompareResultProvider);
//     final viewModel = ref.watch(lottoCompareResultProvider.notifier);
//     final savedNumbersDataState = ref.watch(savedNumbersDataProvider);
//     final drawResultDataState = ref.watch(drawResultDataProvider);
//
//    List<LottoNumber> savedList = [];
//
//     if (state is LottoSavedStateLoading) {
//       return const Scaffold(
//         backgroundColor: Colors.white,
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }
//
//     //에러
//     if (state is LottoSavedStateError) {
//       return const Scaffold(
//         backgroundColor: Colors.white,
//         body: Center(
//           child: Text('Error'),
//         ),
//       );
//     }
//
//     if (savedNumbersDataState is SavedNumbersDataState) {
//       savedList = savedNumbersDataState.savedNumbers.reversed.toList();
//     }
//
//     Future<void> fetchAndCompare() async {
//       if (selectedDraw == null) return;
//
//       final userNumbers = controllers
//           .map((c) => int.tryParse(c.text))
//           .whereType<int>()
//           .toList();
//
//       // ✅ 입력 검증
//       if (userNumbers.length != 6) {
//         _showError('숫자 6개를 모두 입력하세요.');
//         return;
//       }
//
//       if (userNumbers.toSet().length != 6) {
//         _showError('중복되지 않은 숫자 6개를 입력해야 합니다.');
//         return;
//       }
//
//       if (userNumbers.any((n) => n < 1 || n > 45)) {
//         _showError('로또 번호는 1부터 45 사이여야 합니다.');
//         return;
//       }
//
//       // ✅ 결과 비교
//       final result = await viewModel.fetchLottoResult(selectedDraw!);
//
//       if (result != null) {
//         final rank = _getLottoRank(
//           myNumbers: userNumbers,
//           winNumbers: result.numbers,
//           bonusNumber: result.bonus,
//         );
//         setState(() {
//           drawResult = result;
//           resultText = rank;
//         });
//       }
//     }
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('당첨 결과 확인')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('회차 선택',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               drawResultDataState is DrawResultDataState
//                   ? DropdownButton<int>(
//                       value: selectedDraw,
//                       items: drawResultDataState.recentResults
//                           .map((e) => DropdownMenuItem(
//                               value: e.drawNo,
//                               child: Text(
//                                   '${e.drawNo}회 ${DateFormat('yyyy.MM.dd').format(e.drawDate)}')))
//                           .toList(),
//                       onChanged: (val) {
//                         setState(() => selectedDraw = val);
//                       },
//                     )
//                   : const CircularProgressIndicator(),
//               const SizedBox(height: 16),
//               const Text('내 번호 입력',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Wrap(
//                 spacing: 8,
//                 children: List.generate(6, (i) {
//                   return SizedBox(
//                     width: 50,
//                     child: TextField(
//                       controller: controllers[i],
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(
//                         border: OutlineInputBorder(),
//                         contentPadding:
//                             EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       ),
//                     ),
//                   );
//                 }),
//               ),
//               const SizedBox(height: 12),
//               if (savedList.isNotEmpty) ...[
//                 const Text('저장된 번호 불러오기',
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 savedNumbersDataState is SavedNumbersDataState
//                     ? DropdownButton<int>(
//                         value: selectedSavedIndex,
//                         hint: const Text('번호 선택'),
//                         items: List.generate(savedList.length, (index) {
//                           final n = savedList[index].numbers;
//                           return DropdownMenuItem(
//                             value: index,
//                             child: Text(n.join(', ')),
//                           );
//                         }),
//                         onChanged: (index) {
//                           if (index != null) {
//                             setState(() {
//                               selectedSavedIndex = index;
//                             });
//                             _fillFromSaved(savedList[index].numbers);
//                           }
//                         },
//                       )
//                     : const CircularProgressIndicator(),
//               ],
//               const SizedBox(height: 16),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: fetchAndCompare,
//                   child: const Text('결과 확인'),
//                 ),
//               ),
//               Center(
//                 child: ElevatedButton.icon(
//                   icon: const Icon(Icons.qr_code_scanner),
//                   label: const Text('QR코드 인식'),
//                   onPressed: () async {
//                     final scannedCode =
//                         await Navigator.of(context).push<String>(
//                       MaterialPageRoute(
//                           builder: (_) => const QrScannerScreen()),
//                     );
//                     if (scannedCode != null) {
//                       // QR코드 인식 후 처리 (현재는 그냥 콘솔 출력)
//                       print('스캔된 코드: $scannedCode');
//                       // 필요 시 컨트롤러에 텍스트 채우거나 처리 로직 추가 가능
//                     }
//                   },
//                 ),
//               ),
//               const SizedBox(height: 24),
//               if (drawResult != null) ...[
//                 Text(
//                     '당첨 번호: ${drawResult!.numbers.join(', ')} + 보너스 ${drawResult!.bonus}'),
//                 const SizedBox(height: 8),
//                 Text('결과: $resultText',
//                     style: const TextStyle(
//                         fontSize: 18, fontWeight: FontWeight.bold)),
//               ]
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rotto_app/models/saved_numbers_data_provider.dart';
import 'package:rotto_app/providers/lotto_compare_result_provider.dart';
import 'package:rotto_app/screens/qr_scanner_screen.dart';
import 'package:rotto_app/states/draw_result_data_state.dart';
import 'package:rotto_app/states/lotto_saved_state.dart';
import 'package:rotto_app/states/saved_numbers_data_state.dart';
import '../models/draw_result_data_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CompareResultScreen extends ConsumerStatefulWidget {
  const CompareResultScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CompareResultScreen> createState() =>
      _CompareResultScreenState();
}

class _CompareResultScreenState extends ConsumerState<CompareResultScreen> {
  int? selectedDraw;
  LottoDrawResult? drawResult;
  String resultText = '';
  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());
  int? selectedSavedIndex;

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('입력 오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  String _getLottoRank({
    required List<int> myNumbers,
    required List<int> winNumbers,
    required int bonusNumber,
  }) {
    final matchCount = myNumbers.where((n) => winNumbers.contains(n)).length;
    final bonusMatched = myNumbers.contains(bonusNumber);

    if (matchCount == 6) return '🥇 1등';
    if (matchCount == 5 && bonusMatched) return '🥈 2등';
    if (matchCount == 5) return '🥉 3등';
    if (matchCount == 4) return '4등';
    if (matchCount == 3) return '5등';
    return '미당첨';
  }

  void _fillFromSaved(List<int> numbers) {
    for (int i = 0; i < 6; i++) {
      controllers[i].text = numbers[i].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lottoCompareResultProvider);
    final viewModel = ref.watch(lottoCompareResultProvider.notifier);
    final savedNumbersDataState = ref.watch(savedNumbersDataProvider);
    final drawResultDataState = ref.watch(drawResultDataProvider);

    List<LottoNumber> savedList = [];

    if (state is LottoSavedStateLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is LottoSavedStateError) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text('Error'),
        ),
      );
    }

    if (savedNumbersDataState is SavedNumbersDataState) {
      savedList = savedNumbersDataState.savedNumbers.reversed.toList();
    }

    Future<void> fetchAndCompare() async {
      if (selectedDraw == null) return;

      final userNumbers = controllers
          .map((c) => int.tryParse(c.text))
          .whereType<int>()
          .toList();

      if (userNumbers.length != 6) {
        _showError('숫자 6개를 모두 입력하세요.');
        return;
      }
      if (userNumbers.toSet().length != 6) {
        _showError('중복되지 않은 숫자 6개를 입력해야 합니다.');
        return;
      }
      if (userNumbers.any((n) => n < 1 || n > 45)) {
        _showError('로또 번호는 1부터 45 사이여야 합니다.');
        return;
      }

      final result = await viewModel.fetchLottoResult(selectedDraw!);
      if (result != null) {
        final rank = _getLottoRank(
          myNumbers: userNumbers,
          winNumbers: result.numbers,
          bonusNumber: result.bonus,
        );
        setState(() {
          drawResult = result;
          resultText = rank;
        });
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('당첨 결과 확인')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '회차 선택',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      drawResultDataState is DrawResultDataState
                          ? DropdownButton2<int>(
                              value: selectedDraw,
                              isExpanded: true,
                              hint: const Align(
                                alignment: Alignment.centerLeft,
                                child: Text('회차를 선택하세요',
                                    style: TextStyle(fontSize: 15)),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                maxHeight: 220, // 펼침 최대 높이
                              ),
                              buttonStyleData: ButtonStyleData(
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey[100],
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(Icons.arrow_drop_down),
                              ),
                              items: drawResultDataState.recentResults
                                  .map((e) => DropdownMenuItem(
                                      value: e.drawNo,
                                      child: Text(
                                          '${e.drawNo}회  ${DateFormat('yyyy.MM.dd').format(e.drawDate)}')))
                                  .toList(),
                              onChanged: (val) {
                                setState(() => selectedDraw = val);
                              },
                            )
                          : const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '내 번호 입력',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (i) {
                          return SizedBox(
                            width: 48,
                            child: TextField(
                              controller: controllers[i],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      if (savedList.isNotEmpty) ...[
                        const Text(
                          '저장된 번호 불러오기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButton2<int>(
                          value: selectedSavedIndex,
                          isExpanded: true,
                          hint: const Text('저장된 번호 선택',
                              style: TextStyle(fontSize: 15)),
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            maxHeight: 220,
                          ),
                          buttonStyleData: ButtonStyleData(
                            height: 48,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[100],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(Icons.keyboard_arrow_down),
                          ),
                          items: List.generate(savedList.length, (index) {
                            final n = savedList[index].numbers;
                            return DropdownMenuItem(
                              value: index,
                              child: Text(
                                n.join(', '),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            );
                          }),
                          onChanged: (index) {
                            if (index != null) {
                              setState(() {
                                selectedSavedIndex = index;
                              });
                              _fillFromSaved(savedList[index].numbers);
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: fetchAndCompare,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: Colors.amber[600],
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                child: const Text('결과 확인'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner, color: Colors.black87),
                label: const Text('QR코드 인식',
                    style: TextStyle(color: Colors.black87)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final scannedCode = await Navigator.of(context).push<String>(
                    MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                  );
                  if (scannedCode != null) {
                    print('스캔된 코드: $scannedCode');
                  }
                },
              ),
              const SizedBox(height: 28),
              if (drawResult != null) ...[
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  color: Colors.green[50],
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '당첨 번호:  ${drawResult!.numbers.join(', ')}  + 보너스 ${drawResult!.bonus}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('결과: $resultText',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.green)),
                      ],
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
