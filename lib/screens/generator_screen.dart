import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rotto_app/models/draw_result_data_provider.dart';
import 'package:rotto_app/providers/lotto_generator_provider.dart';
import 'package:rotto_app/states/draw_result_data_state.dart';
import 'package:rotto_app/states/lotto_generator_state.dart';
import 'package:rotto_app/states/lotto_saved_state.dart';

class GeneratorScreen extends ConsumerStatefulWidget {
  const GeneratorScreen({super.key});

  @override
  ConsumerState<GeneratorScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<GeneratorScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lottoGeneratorProvider);
    final viewModel = ref.read(lottoGeneratorProvider.notifier);
    final drawResultDataState = ref.watch(drawResultDataProvider);

    final pState = state as LottoGeneratorState;

    if (state is LottoSavedStateLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    //에러
    if (state is LottoSavedStateError) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text('Error'),
        ),
      );
    }

    final drawResultState = ref.watch(drawResultDataProvider);
    LottoDrawResult? recentResult;
    if (drawResultState is DrawResultDataState &&
        drawResultState.recentResults.isNotEmpty) {
      recentResult = drawResultState.recentResults.first;
    }

    // 날짜 포맷
    String drawDateStr = recentResult != null
        ? DateFormat('yyyy.MM.dd').format(recentResult.drawDate)
        : "";

    void saveSelectedNumbers() {
      print('saveSelectedNumbers');

      if (pState.selectGeneratedNumbers.isNotEmpty) {
        pState.selectGeneratedNumbers.clear();
      }

      if (pState.checkedRows.isEmpty ||
          pState.checkedRows.every((element) => element == false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('선택된 번호가 없습니다.')),
        );

        return;
      }

      for (int i = 0; i < pState.checkedRows.length; i++) {
        if (pState.checkedRows[i]) {
          pState.selectGeneratedNumbers.add(pState.generatedNumbers[i]);
        }
      }
      if (pState.selectGeneratedNumbers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('번호 생성에 문제가 발생하였습니다.')),
        );
        return;
      }

      viewModel.saveNumbers(context, pState.selectGeneratedNumbers);
    }

    // 팝업으로 1~45 번호판 표시, 선택 불가 번호는 빨/파로 표시
    Future<List<int>> showNumberPickerDialog(BuildContext context,
        String title,
        List<int> initialSelected,
        List<int> disabledNumbers,
        Color disabledColor,
        {int maxSelection = 35} // 추가: 최대 선택 개수
        ) async {
      final selectedNumbers = List<int>.from(initialSelected);
      return await showDialog<List<int>>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: GridView.count(
                crossAxisCount: 5,
                children: List.generate(45, (i) {
                  final number = i + 1;
                  final isSelected = selectedNumbers.contains(number);
                  final isDisabled = disabledNumbers.contains(number);

                  return GestureDetector(
                    onTap: () {
                      if (isDisabled) return;

                      if (isSelected) {
                        selectedNumbers.remove(number);
                      } else {
                        if (selectedNumbers.length >= maxSelection) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                              Text('최대 $maxSelection개까지 선택할 수 있습니다.'),
                            ),
                          );
                          return;
                        }
                        selectedNumbers.add(number);
                      }
                      (ctx as Element).markNeedsBuild();
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDisabled
                            ? disabledColor
                            : isSelected
                            ? Colors.orange
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$number',
                          style: TextStyle(
                            color: isDisabled || isSelected
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(initialSelected),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(selectedNumbers),
                child: const Text('확인'),
              ),
            ],
          );
        },
      ) ??
          initialSelected;
    }

    void generateNumbers() {
      final rand = Random();
      final List<List<int>> newNumbers = [];

      for (int row = 0; row < 5; row++) {
        final Set<int> numbers = {...pState.fixedNumbers};

        final availableNumbers = List<int>.generate(45, (i) => i + 1)
            .where((n) =>
        !numbers.contains(n) && !pState.excludedNumbers.contains(n))
            .toList();

        while (numbers.length < 6 && availableNumbers.isNotEmpty) {
          final pick =
          availableNumbers.removeAt(rand.nextInt(availableNumbers.length));
          numbers.add(pick);
        }

        newNumbers.add(numbers.toList()
          ..sort());
      }

      setState(() {
        pState.generatedNumbers = newNumbers;
        pState.checkedRows = List.filled(5, false);
      });
    }

    Color getLottoBallColor(int number) {
      if (number <= 10) return Colors.yellow[700]!;
      if (number <= 20) return Colors.blue[400]!;
      if (number <= 30) return Colors.red[400]!;
      if (number <= 40) return Colors.grey[600]!; // gray가 없으면 Colors.grey
      return Colors.green[400]!;
    }

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 16),
              drawResultDataState is DrawResultDataState ?
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber[700], size: 32),
                      const SizedBox(height: 8),
                      // 회차 텍스트, 숫자만 강조
                      if (recentResult != null)
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "${recentResult.drawNo}회 ",
                                style: TextStyle(
                                  color: Colors.red[500], // 강조색
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24,
                                ),
                              ),
                              const TextSpan(
                                text: "당첨결과",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),

                      const SizedBox(height: 4),
                      Text(
                        drawDateStr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 구간별 컬러 CircleAvatar
                      if (recentResult != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...recentResult.numbers.map((num) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              child: CircleAvatar(
                                backgroundColor: getLottoBallColor(num),
                                radius: 20,
                                child: Text(
                                  "$num",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            )),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                "+",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            // 보너스볼: 파랑색
                            CircleAvatar(
                              backgroundColor: Colors.blue[400],
                              radius: 20,
                              child: Text(
                                "${recentResult.bonus}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ) :  const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 20),
              // 고정수 & 제외수 선택 UI
              Row(
                children: [
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final selected = await showNumberPickerDialog(
                          context,
                          "고정수 선택",
                          pState.fixedNumbers,
                          pState.excludedNumbers,
                          Colors.red,
                          maxSelection: 6,
                        );
                        selected.sort();
                        setState(() => pState.fixedNumbers = selected);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("고정수: "),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                pState.fixedNumbers.isEmpty
                                    ? "-"
                                    : pState.fixedNumbers.join(", "),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final selected = await showNumberPickerDialog(
                          context,
                          "제외수 선택",
                          pState.excludedNumbers,
                          pState.fixedNumbers,
                          Colors.blue,
                          maxSelection: 35,
                        );
                        selected.sort();
                        setState(() => pState.excludedNumbers = selected);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("제외수: "),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                pState.excludedNumbers.isEmpty
                                    ? "-"
                                    : pState.excludedNumbers.join(", "),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: pState.generatedNumbers.isEmpty
                    ? Center(
                  child: Text(
                    '생성된 번호가 없습니다.\n행운의 번호를 생성해보세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: pState.generatedNumbers.length,
                  itemBuilder: (context, index) {
                    final rowNumbers = pState.generatedNumbers[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: pState.checkedRows[index],
                            onChanged: (val) {
                              setState(() {
                                pState.checkedRows[index] = val ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: rowNumbers.map((num) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: CircleAvatar(
                                      radius: 21,
                                      backgroundColor:
                                      getLottoBallColor(num),
                                      child: Text(
                                        '$num',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: generateNumbers,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "번호 생성",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: saveSelectedNumbers,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: Colors.green[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "번호 저장",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
