import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_app/config/api_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('dotenv loads GOOGLE_CLIENT_ID correctly and matches ApiConfig', () {
    dotenv.loadFromString(
      envString: 'GOOGLE_CLIENT_ID=561060062269-aecas36lfi3o4u58tn14r2h3hf2f2cvv.apps.googleusercontent.com',
    );

    expect(dotenv.env['GOOGLE_CLIENT_ID'], equals('561060062269-aecas36lfi3o4u58tn14r2h3hf2f2cvv.apps.googleusercontent.com'));
    expect(ApiConfig.googleClientId, equals('561060062269-aecas36lfi3o4u58tn14r2h3hf2f2cvv.apps.googleusercontent.com'));
  });
}
