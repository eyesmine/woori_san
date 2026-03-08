import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woori_san/main.dart';
import 'package:woori_san/services/storage_service.dart';
import 'package:woori_san/providers/app_state.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(storage),
        child: const WooriSanApp(),
      ),
    );

    expect(find.text('우리산 🏔️'), findsOneWidget);
  });
}
