import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/ui/receipt/receipt_paper_view.dart';

void main() {
  testWidgets('teks struk tidak ikut skala huruf sistem agar kolom pas', (
    tester,
  ) async {
    const line = ReceiptLine('TOTAL                     180.000');
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 300,
              child: ReceiptPaperView(
                lines: [line],
                paper: ReceiptPaper.mm58,
              ),
            ),
          ),
        ),
      ),
    );
    final text = tester.widget<Text>(find.text(line.text));
    expect(text.textScaler, TextScaler.noScaling);
  });
}
