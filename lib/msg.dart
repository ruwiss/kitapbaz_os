import 'package:bigfamily/constants/db.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

Future<String> sifreliTokenOlustur() async {
  Dio dio = Dio();
  var box = await Hive.openBox('user');

  var response = await dio.post(getUserTokenPath,
      data: FormData.fromMap({"mail": box.get('mail')}));

  String token = response.data;

  String msg = token
      .split("")
      .reversed
      .join()
      .replaceAll("a", "p")
      .replaceAll("c", "2")
      .replaceAll("f", "k")
      .replaceAll("1", "9")
      .replaceAll("0", "c");
  return msg;
}
