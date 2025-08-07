import 'package:chalan_book_app/core/models/chalan.dart';

class NumUtils {
  /// Sorts a list of integers in ascending order.
  static List<int> sortAscending(List<int> numbers) {
    numbers.sort();
    return numbers;
  }

  /// Sorts a list of integers in descending order.
  static List<int> sortDescending(List<int> numbers) {
    numbers.sort((a, b) => b.compareTo(a));
    return numbers;
  }

  /// Extracts and returns a list of chalan numbers as integers from a list of Chalans.
  static List<int> extractChalanNumbers(List<Chalan> chalans) {
    return chalans
        .map((chalan) => int.tryParse(chalan.chalanNumber) ?? 0)
        .toList();
  }

  /// Sorts a list of Chalans based on chalan numbers in ascending order.
  static List<Chalan> sortChalansAscending(List<Chalan> chalans) {
    chalans.sort((a, b) {
      final aNum = int.tryParse(a.chalanNumber) ?? 0;
      final bNum = int.tryParse(b.chalanNumber) ?? 0;
      return aNum.compareTo(bNum);
    });
    return chalans;
  }

  /// Sorts a list of Chalans based on chalan numbers in descending order.
  static List<Chalan> sortChalansDescending(List<Chalan> chalans) {
    chalans.sort((a, b) {
      final aNum = int.tryParse(a.chalanNumber) ?? 0;
      final bNum = int.tryParse(b.chalanNumber) ?? 0;
      return bNum.compareTo(aNum);
    });
    return chalans;
  }
}