import 'package:rotto_app/models/saved_numbers_data_provider.dart';

abstract class  SavedNumbersDataStateBase{}

class SavedNumbersDataStateError extends SavedNumbersDataStateBase{
  final String? statusMessage;
  final int? statusCode;

  SavedNumbersDataStateError({
    required this.statusMessage,
    required this.statusCode,
  });
}

class SavedNumbersDataStateLoading extends SavedNumbersDataStateBase {}

class SavedNumbersDataState extends SavedNumbersDataStateBase {
  List<LottoNumber> savedNumbers;

  SavedNumbersDataState({
    required this.savedNumbers,
  });

}