import 'package:flutter_test/flutter_test.dart';

import 'package:stock_pyme/utils/formatters.dart';

void main() {
  test('Formato de pesos chilenos', () {
    expect(formatCLP(4990), r'$4.990');
    expect(formatCLP(1250000), r'$1.250.000');
  });

  test('Cantidades a granel', () {
    expect(formatQty(3), '3');
    expect(formatQty(1.25), '1,25');
    expect(parseQty('1,5'), 1.5);
  });
}
