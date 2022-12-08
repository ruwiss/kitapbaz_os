import 'package:dio/dio.dart';

Future<List> searchBook({required String text}) async {
  Dio dio = Dio();
  var response = await dio
      .get("https://api.1000kitap.com/ara?q=$text&sadece=kitap&us=15&fr=1");

  if (response.statusCode == 200) {
    List sonuclar = [];
    if (response.data is Map) {
      sonuclar = response.data['sonuclar'];
    }
    return sonuclar;
  }
  return [];
}
