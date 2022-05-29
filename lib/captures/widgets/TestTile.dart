import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';

class TestTile extends StatelessWidget {
  int index;

  List<File> fileList = camServ.allFileList;

  TestTile(this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () async {
            await showDialog(
                context: context,
                builder: (_) {
                  final double height = MediaQuery.of(context).size.height;
                  final double width = MediaQuery.of(context).size.width;
                  return Dialog(
                    /*
                    Show selected image and allow user to slide to another images
                     */
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: height / 1.5,
                        viewportFraction: 1.0,
                        enableInfiniteScroll: false,
                        //enlargeCenterPage: true,
                        initialPage: index,
                      ),
                      items: fileList
                          .map(
                            (item) => Center(
                              child: InkWell(
                                child: Image.file(
                                  item,
                                  fit: BoxFit.cover,
                                  height: height,
                                  width: width,
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                });
          },
          //onLongPress: _callback,
          child: Image.file(
            camServ.allFileList[index],
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
