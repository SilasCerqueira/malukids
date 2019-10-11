import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class CurrencyInputFormatter extends TextInputFormatter {

  double valueDouble = 0.00;

  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {

    if(newValue.selection.baseOffset == 0){
      print(true);
      return newValue;
    }

    double value = double.parse(newValue.text);
    valueDouble = value/100;
    final formatter = new NumberFormat("###,###,###,##0.00", "pt-br");

    String newText = formatter.format(valueDouble);

    return newValue.copyWith(
        text: newText,
        selection: new TextSelection.collapsed(offset: newText.length));
  }

  double getValorDouble(){
    return valueDouble;
  }
}