import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env.dev', obfuscate: true)
abstract class EnvDev {
  @EnviedField(varName: 'API_BASE_URL')
  static final String apiBaseUrl = _EnvDev.apiBaseUrl;
}

@Envied(path: '.env.staging', obfuscate: true)
abstract class EnvStaging {
  @EnviedField(varName: 'API_BASE_URL')
  static final String apiBaseUrl = _EnvStaging.apiBaseUrl;
}

@Envied(path: '.env.prod', obfuscate: true)
abstract class EnvProd {
  @EnviedField(varName: 'API_BASE_URL')
  static final String apiBaseUrl = _EnvProd.apiBaseUrl;
}
