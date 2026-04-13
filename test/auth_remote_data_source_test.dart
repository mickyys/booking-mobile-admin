import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:reservaloya_admin/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:reservaloya_admin/features/auth/data/models/user_model.dart';

@GenerateMocks([Auth0, WebAuthentication, Credentials])
void main() {
  test('placeholder for auth tests', () {
    expect(true, true);
  });
}
