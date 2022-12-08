import 'package:flutter/material.dart';
import 'package:get/get.dart';

void pictureZoom(String path, bool network) {
  Get.dialog(Center(
    child: InteractiveViewer(
      panEnabled: false, // Set it to false
      boundaryMargin: const EdgeInsets.all(100),
      minScale: 1,
      maxScale: 2,
      child: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 50),
            height: 500,
            child: network
                ? Image.network(path)
                : Image.asset('assets/images/avatar.png')),
      ),
    ),
  ));
}
