import 'dart:convert';

import 'package:bigfamily/constants/db.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' as gt;
import 'package:hive/hive.dart';

import 'home_screen_controller.dart';

Dio _dio = Dio();
final quotesController = gt.Get.put(HomeScreenController());

bool _qouteFinished = false;
int _navigationIndex = 0;
int _userId = -1;

Future getQuotes(int limit, {bool? like}) async {
  quotesController.setIsLoading(true);
  if (_qouteFinished && limit != 0) {
    quotesController.setIsLoading(false);
    return;
  } else {
    if (limit == 0) {
      quotesController.setQuotes([]); //temizle
    }

    _qouteFinished = false; //limit 0 olabilir
    String path =
        like == null ? getQuotesPath(limit) : getQuotesLikePath(limit);
    if (quotesController.blockedUsers.isNotEmpty) {
      path += "&block=" + quotesController.blockedUsers.join(', ');
    }
    var response = await _dio.get(path);
    if (response.statusCode == 200) {
      var data = response.data;
      if (data is List) {
        if (data.isEmpty) {
          _qouteFinished = true;
        } else {
          // beğenileri controller'a kaydet
          for (Map veriler in data) {
            final List begeniler = veriler['veri1']['begeni'];
            final int id = veriler['veri1']['id'];

            quotesController.setLikedQuotes(
                id, begeniler.length, begeniler.contains(await getUserId()));
          }
          if (limit == 0) {
            quotesController.setQuotes(response.data);
          } else {
            quotesController.addAllQuotes(response.data);
          }
        }
      } else {
        _qouteFinished = true;
      }
    } else {
      getQuotes(limit, like: like);
      _qouteFinished = true;
    }
    quotesController.setIsLoading(false);
  }
}

Future likeQuote({required int id, required String islem}) async {
  if (islem == "like") {
    quotesController.setLikedQuotes(
        id, quotesController.likedQuotes[id] + 1, true);
  } else if (islem == "unlike") {
    quotesController.removeLikedQuotes(id);
  }
  await _dio.post(likeQuotePath,
      data: FormData.fromMap(
          {'id': id, 'mail': await getUserMail(), 'islem': islem}));
}

Future favoriteQuote({required int id, required String islem}) async {
  if (islem == "favorite") {
    quotesController.setFavorites([], id, "add");
  } else if (islem == "unfavorite") {
    quotesController.setFavorites([], id, "remove");
  }
  await _dio.post(favoriteQuotePath,
      data: FormData.fromMap(
          {'id': id, 'mail': await getUserMail(), 'islem': islem}));
}

Future getFavorites() async {
  var response = await _dio.post(getFavoritesPath,
      data: FormData.fromMap({'mail': await getUserMail()}));

  if (response.statusCode != 200 || response.data == "") {
    quotesController.setFavorites([], 0, "set");
  } else {
    List data = response.data.toString().replaceAll('|', '').split(',');
    List intData = data.map((e) => int.parse(e.toString())).toList();

    quotesController.setFavorites(intData, 0, 'set');
  }
}

Future reportQuote(
    {required dynamic info,
    required String message,
    required reportType}) async {
  await _dio.post(reportQuotePath,
      data: FormData.fromMap({
        'id': info,
        'reportType': reportType,
        'message': message,
        'mail': await getUserMail()
      }));
}

Future getFavoritePosts() async {
  var response = await _dio.post(getFavoritePostsPath,
      data: FormData.fromMap({'mail': await getUserMail()}));
  if (response.statusCode == 200) {
    var data = response.data;
    if (data is List) {
      if (data.isEmpty) {
        return false;
      } else {
        quotesController.setQuotes(data.reversed.toList());
      }
    } else {
      return false;
    }
  } else {
    return false;
  }
}

Future onNavigationSelect(int index) async {
  if (_navigationIndex != index) {
    _navigationIndex = index;
    if (index == 0) {
      getQuotes(0);
    } else if (index == 1) {
      getQuotes(0, like: true);
    } else {
      return await getFavoritePosts();
    }
  }
}

Future deleteQuote({required int id, required int navIndex}) async {
  EasyLoading.show(status: 'Siliniyor');
  var response = await _dio.post(deleteQuotePath,
      data: FormData.fromMap({'mail': await getUserMail(), 'id': id}));

  if (response.statusCode == 200) {
    if (response.data == 'silindi') {
      EasyLoading.showSuccess('Silindi');
      if (navIndex == 0) {
        getQuotes(0);
      } else if (navIndex == 1) {
        getQuotes(0, like: true);
      }
    } else {
      EasyLoading.showError('Bir sorun oluştu');
    }
  } else {
    EasyLoading.showError('Bir sorun oluştu');
  }
  EasyLoading.dismiss();
}

Future<String> getUserMail() async {
  var box = await Hive.openBox('user');
  return box.get('mail');
}

Future<int> getUserId() async {
  if (_userId == -1) {
    var box = await Hive.openBox('user');
    var response = await _dio.post(getUserIdPath,
        data: FormData.fromMap({'mail': box.get('mail')}));
    if (response.data.toString().isNotEmpty) {
      return int.parse(response.data);
    } else {
      return -1;
    }
  } else {
    return _userId;
  }
}

Future getBlockedUsers() async {
  var box = await Hive.openBox('user');
  var response = await _dio.get(blockUserPath + "?mail=${box.get("mail")}");

  if (response.data.isNotEmpty) {
    var data = response.data['users'];
    if (data is List && data.isNotEmpty) {
      quotesController.setBlockedUsers(data);
    } else {
      var newData = jsonDecode(data);
      if (newData is List) {
        quotesController.setBlockedUsers(newData);
      } else {
        quotesController.setBlockedUsers(newData.values.toList());
      }
    }
  }

  getQuotes(0);
}
