import 'package:dio/dio.dart';

Future<void> main() async {
  var dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        print(options.path);
        // options.headers['Authorization'] = '123';
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response de ${response.requestOptions.path}');
        print('A Resposta foi ${response.data}');

        return handler.next(response);
      },
      onError: (DioError error, handler) async {
        print('A Resposta foi ${error.response.statusCode}');

        if (error.response.statusCode == 401 ||
            error.response.statusCode == 403) {
          var responseLogin = await dio.post(
              'https://teste-dio.free.beeceptor.com/login',
              data: {'login': 'login@login.com', 'senha': 'senha123'});

          var token = responseLogin.data['token'];
          error.requestOptions.headers['Authorization'] = token;
          error.requestOptions.path = error.requestOptions.path + '2';
          return dio.fetch(error.requestOptions);
        }
      },
    ),
  );

  var resonse = await dio.get('https://teste-dio.free.beeceptor.com/teste');
  print(resonse);
}
