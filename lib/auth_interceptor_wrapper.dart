import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class AuthInterceptorWrapper extends InterceptorsWrapper {
  var logger = Logger();
  final Dio _dio;

  AuthInterceptorWrapper(this._dio);

  @override
  Future onRequest(RequestOptions options) async {
    var isDev = true;

    if (isDev) {
      logger.d('#################### REQUEST LOG ####################');
      logger.d('#### URL: ${options.path}');
      logger.d('#### METHOD: ${options.method}');
      logger.d('#### DATA: ${options.data}');
      logger.d('#### HEADERS: ${options.headers}');
      logger.d('#################### END REQUEST LOG ####################');
    }
  }

  @override
  Future onResponse(Response response) async {
    var isDev = true;
    if (isDev) {
      logger.d('#################### RESPONSE LOG ####################');
      logger.d('#### DATA: ${response.data}');
      logger.d('#################### END RESPONSE LOG ####################');
    }
  }

  @override
  Future onError(DioError err) async {
    var isDev = true;
    if (isDev) {
      logger.d('#################### ERROR REQUEST LOG ####################');
      logger.d('#### RESPONSE: ${err.response}');
      logger
          .d('#################### END ERROR REQUEST LOG ####################');
    }

    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      await _refreshToken();

      logger.d('#################### REFRESH TOKEN ####################');
      logger.d('#################### TOKEN ATUALIZADO #################');

      return _dio.request(err.request.path, options: err.request);
    }
    return err;
  }

  Future<void> _refreshToken() async {
    //CONSULTAR tokens no SharedPrefs
    var accessToken = '123456789 access';
    var refreshToken = '123456789 REFRESH';

    try {
      var refreshResult = await _dio.post(
        '/login/refresh',
        data: {
          'access_token': accessToken,
          'refresh_token': refreshToken,
        },
      );

      //ATUALIZAR SharedPrefs com os tokens novos
      var accessTokenAtualizado = refreshResult.data['access_token'];
      var refreshTokenAtualizado = refreshResult.data['refresh_token'];
    } catch (e) {
      logger.e(e);

      // LOGOUT || RESET || CLEAN access e refresh token

      //Redirecionar para home/login | colocar isso dentro do logout
      // await Modular.to.pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
    }
  }
}
