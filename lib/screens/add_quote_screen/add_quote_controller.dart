import 'package:get/state_manager.dart';

class AddQuoteController extends GetxController {
  var kitapList = [].obs;
  var secilenKitap = {}.obs;

  setKitapList(List sonuc) => kitapList.value = sonuc;
  setSecilenKitap(Map kitap) => secilenKitap.value = kitap;
}
