import 'package:get/get.dart';

class UserController extends GetxController {
  var userPhoto = "yok".obs;
  var likesComments = {}.obs;

  setUserPhoto(String photo) => userPhoto.value = photo;
  setLikesComments(Map value) => likesComments.addAll(value);
  removeLikesComments() => likesComments.clear();
}
