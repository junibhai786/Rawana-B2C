import 'dart:io';
import 'package:moonbnd/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddImageComponent extends StatelessWidget {
  final List<File?>? imageArr;
  final VoidCallback? onTapAdd;
  final String? existingImage;
  final Function(int)? onTapRemove;
  final VoidCallback? onTapDownload;
  final bool? camerashow;
  final File? pickedimage;

  const AddImageComponent({
    Key? key,
    this.imageArr,
    this.camerashow,
    this.onTapAdd,
    this.existingImage,
    this.onTapRemove,
    this.pickedimage,
    this.onTapDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            camerashow == false
                ? SizedBox()
                : SizedBox(
                    height: 50,
                    width: 200,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                      ),
                      child: InkWell(
                          onTap: onTapAdd,
                          child: Container(
                            decoration: BoxDecoration(
                                color: kSecondaryColor,
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.upload,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Upload Image".tr,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                          )),
                    ),
                  ),
            SizedBox(
              width: 10,
            ),
            SizedBox(
              height: 92,
              width: (80 * (imageArr?.length ?? 0)) +
                  (12 * ((imageArr?.length ?? 0) + 1)),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageArr?.length ?? 0,
                itemBuilder: (context, index) {
                  return imageArr![index] != null
                      ? Stack(
                          children: [
                            Container(
                                padding: const EdgeInsets.only(
                                    right: 12.0, top: 12.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                                child: Image.file(
                                  imageArr![index]!,
                                  width: 76,
                                  height: 85,
                                  fit: BoxFit.fill,
                                )),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 25,
                                margin: const EdgeInsets.only(right: 12.0),
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                                child: InkWell(
                                  onTap: () => onTapRemove!(index),
                                  child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Center(child: Icon(Icons.close))),
                                ),
                              ),
                            ),
                          ],
                        )
                      : SizedBox();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
