import 'package:get/get.dart';

class HomeScreenController extends GetxController {
  var quotes = [].obs;
  var likedQuotes = {}.obs;
  var favorites = [].obs;
  var isLoading = false.obs;
  var blockedUsers = [].obs;
  var blockedUserNames = [].obs;

  setBlockedUsers(List users) => blockedUsers.addAll(users);
  removeBlockedUser(int id) => blockedUsers
      .removeWhere((element) => element.toString() == id.toString());

  setBlockedUserNames(List users) => blockedUserNames.value = users;
  removeBlockedUserNames(String name) =>
      blockedUserNames.removeWhere((element) => element == name);

  addAllQuotes(List q) => quotes.addAll(q);
  setQuotes(List q) => quotes.value = q;

  setLikedQuotes(int id, int begeniler, bool isLiked) {
    likedQuotes[id] = begeniler;
    likedQuotes['$id-begeni'] = isLiked;
    likedQuotes.refresh();
  }

  removeLikedQuotes(int id) {
    likedQuotes[id] = likedQuotes[id] - 1;
    likedQuotes['$id-begeni'] = false;
    likedQuotes.refresh();
  }

  setFavorites(List fav, int id, String islem) {
    if (islem == 'set') {
      favorites.value = fav;
    } else if (islem == 'add') {
      favorites.add(id);
    } else if (islem == 'remove') {
      favorites.removeWhere((element) => element == id);
    }
  }

  setIsLoading(bool value) => isLoading.value = value;
}
