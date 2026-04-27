import 'package:redstreakapp/core/utils/app_imports.dart';

enum OptionMode {
  share, remove, none
}

extension OptionModeExtension on OptionMode {
  bool get isShare => this == OptionMode.share;
  bool get isRemove => this == OptionMode.remove;
  bool get isNone => this == OptionMode.none;
}


class YourBooksProvider extends ChangeNotifier {
  OptionMode _optionMode = OptionMode.none;
  OptionMode get optionMode => _optionMode;
  final Set<int> _selectedBookIndexes = <int>{};
  Set<int> get selectedBookIndexes => _selectedBookIndexes;
  bool get hasSelection => _selectedBookIndexes.isNotEmpty;

  void setOptionMode(OptionMode mode) {
    _optionMode = mode;
    _selectedBookIndexes.clear();
    notifyListeners();
  }

  bool isBookSelected(int index) => _selectedBookIndexes.contains(index);

  void toggleBookSelection(int index) {
    if (_selectedBookIndexes.contains(index)) {
      _selectedBookIndexes.remove(index);
    } else {
      _selectedBookIndexes.add(index);
    }
    notifyListeners();
  }

  void clearBookSelection() {
    _selectedBookIndexes.clear();
    notifyListeners();
  }
}