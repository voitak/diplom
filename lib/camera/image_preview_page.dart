import 'dart:io';

import 'package:flutter/material.dart';

class ImagePreviewPage extends StatelessWidget {
  final File imageFile;
  final List<File> fileList;

  const ImagePreviewPage({
    required this.imageFile,
    required this.fileList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.file(imageFile),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Stack(
                    alignment: Alignment.center,
                    children: const [
                      Icon(
                        Icons.circle,
                        color: Colors.black38,
                        size: 60,
                      ),
                      Icon(
                        Icons.clear,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: Stack(
                    alignment: Alignment.center,
                    children: const [
                      Icon(
                        Icons.circle,
                        color: Colors.black38,
                        size: 60,
                      ),
                      Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  ),
                  onPressed: () {

                  },
                ),
//                TextButton(
//                  onPressed: () {
//                    fileList.sort((a, b) {
//                      int nameA =
//                      int.parse(a.path
//                          .split('/')
//                          .last
//                          .split('.')
//                          .first);
//                      int nameB =
//                      int.parse(b.path
//                          .split('/')
//                          .last
//                          .split('.')
//                          .first);
//                      return nameA.compareTo(nameB);
//                    });
//
//                    Navigator.of(context).pushReplacement(
//                      MaterialPageRoute(
//                        builder: (context) =>
//                            CapturesPage(
//                              imageFileList: fileList,
//                            ),
//                      ),
//                    );
//                  },
//                  child: Text('Go to all captures'),
//                  style: TextButton.styleFrom(
//                    primary: Colors.black,
//                    backgroundColor: Colors.white,
//                  ),
//                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
