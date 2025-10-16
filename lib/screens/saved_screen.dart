import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rotto_app/models/draw_result_data_provider.dart';
import 'package:rotto_app/states/draw_result_data_state.dart';
import 'package:rotto_app/states/lotto_saved_state.dart';
import 'package:rotto_app/states/saved_numbers_data_state.dart';
import '../providers/lotto_saved_provider.dart';
import '../models/saved_numbers_data_provider.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  Color getBallColor(int num) {
    if (num <= 10) return Colors.amber.shade700;
    if (num <= 20) return Colors.blue.shade400;
    if (num <= 30) return Colors.red.shade400;
    if (num <= 40) return Colors.grey.shade600;
    return Colors.green.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy.MM.dd');

    final state = ref.watch(lottoSavedProvider);
    final viewModel = ref.watch(lottoSavedProvider.notifier);
    final savedNumbersDataState = ref.watch(savedNumbersDataProvider);
    final drawResultDataState = ref.watch(drawResultDataProvider);

    List<LottoNumber> savedList = [];
    List<LottoDrawResult> recentResults = [];

    if (state is LottoSavedStateLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is LottoSavedStateError) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('Error')),
      );
    }

    final grouped = <String, List<LottoNumber>>{};
    List<MapEntry<String, List<LottoNumber>>> sortedEntries = [];

    if (savedNumbersDataState is SavedNumbersDataState) {
      savedList = savedNumbersDataState.savedNumbers;


      if (savedList != null && savedList != []) {
        for (var item in savedList) {
          final dateKey = DateFormat('yyyy.MM.dd').format(item.timestamp);
          grouped.putIfAbsent(dateKey, () => []).add(item);
        }

        sortedEntries = grouped.entries.toList();

        // grouped.entries를 리스트로 변환하고 정렬
        sortedEntries.sort(
              (a, b) {
            final dateA = dateFormat.parse(a.key);
            final dateB = dateFormat.parse(b.key);
            return dateB.compareTo(dateA); // 최신이 위로
          },
        );
        //print(sortedEntries[0].value);
      }
    }

      if(drawResultDataState is DrawResultDataState){
          recentResults = drawResultDataState.recentResults;
      }


    return Scaffold(
      appBar: AppBar(
        title: const Text("저장된 번호"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: "전체 삭제",
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("전체 삭제"),
                  content: const Text("정말 모든 저장된 번호를 삭제할까요?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("취소"),
                    ),
                    TextButton(
                      onPressed: () {
                        viewModel.deleteAllSavedNumbers(context);
                        Navigator.pop(context);
                      },
                      child: const Text("삭제"),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: grouped.isEmpty
          ? const Center(child: Text("저장된 번호가 없습니다."))
          : ListView(
              children: sortedEntries.map((entry) {
                final date = entry.key;
                final items = entry.value
                  ..sort((a, b) =>
                      b.timestamp.compareTo(a.timestamp)); // 그룹 내에서도 최신이 위로

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Text(
                        date,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    ...items.map((item) {
                      final uniqueKey = ValueKey(
                        'saved_${item.timestamp.millisecondsSinceEpoch}_${item.numbers.join(',')}',
                      );
                      return Dismissible(
                        key: uniqueKey,
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          Future.microtask(() async{
                            await viewModel.deleteSpecificSavedNumber(context, item);
                          });
                        },
                        child:GestureDetector(
                          onTap: (){
                            final matches = recentResults.map((draw) {
                              return viewModel.checkRank(item, draw);
                            }).where((m) => m.result != null).toList();
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('당첨 내역 비교 (과거 1년치)'),
                                content: drawResultDataState is DrawResultDataState ? SizedBox(
                                    width: double.maxFinite,
                                    child: matches.isEmpty
                                    ? const Text('지난 1년간 당첨 내역이 없습니다.')
                                    : SingleChildScrollView(
                              child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                                children: matches.map((m) {
                                  return Text('${m.round}회차: ${m.result}');
                                }).toList(),
                              ),
                            ),
                            ) : const Center(heightFactor: 3, child: CircularProgressIndicator()),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('닫기'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: item.numbers.map((num) {
                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            child: CircleAvatar(
                                              radius: 20,
                                              backgroundColor: getBallColor(num),
                                              child: CircleAvatar(
                                                radius: 17,
                                                backgroundColor: Colors.white,
                                                child: Text(
                                                  '$num',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
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
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            ),
    );
  }
}
