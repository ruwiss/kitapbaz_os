import 'package:get/get.dart';

class CommentController extends GetxController {
  var comments = [].obs;

  setComment(List c) => comments.value = c;
  addComment(List c) => comments.addAll(c);
}
