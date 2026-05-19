// ============================================================
// core/models/cell.dart
// ============================================================
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum CellType { normal, rowClear, areaClear, colClear, mega }

class Cell {
  String letter;
  int row;
  int col;
  CellType type;
  bool isSelected;
  bool isNew; // for drop animation
  bool isExploding; // for explosion effect

  Cell({
    required this.letter,
    required this.row,
    required this.col,
    this.type = CellType.normal,
    this.isSelected = false,
    this.isNew = false,
    this.isExploding = false,
  });

  Cell copyWith({
    String? letter,
    int? row,
    int? col,
    CellType? type,
    bool? isSelected,
    bool? isNew,
    bool? isExploding,
  }) {
    return Cell(
      letter: letter ?? this.letter,
      row: row ?? this.row,
      col: col ?? this.col,
      type: type ?? this.type,
      isSelected: isSelected ?? this.isSelected,
      isNew: isNew ?? this.isNew,
      isExploding: isExploding ?? this.isExploding,
    );
  }

  String get powerSymbol {
    switch (type) {
      case CellType.rowClear:  return '⇆';
      case CellType.areaClear: return '✹';
      case CellType.colClear:  return '⇅';
      case CellType.mega:      return '✪';
      case CellType.normal:    return '';
    }
  }

  Color get powerColor {
    switch (type) {
      case CellType.rowClear:  return AppColors.cellRowClear;
      case CellType.areaClear: return AppColors.cellAreaClear;
      case CellType.colClear:  return AppColors.cellColClear;
      case CellType.mega:      return AppColors.cellMega;
      case CellType.normal:    return AppColors.cellDefault;
    }
  }

  bool get isPower => type != CellType.normal;

  @override
  bool operator ==(Object other) =>
      other is Cell && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);
}
