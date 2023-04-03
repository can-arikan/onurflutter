import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

uploadIpfs(File filePath) async {
  String credentials = "2NcZX5XIMCSEZl0ATtoOAoLjUc0:6d1b9bc5227592e7890202a88b6710c4";
  final auth = base64.encode(utf8.encode(credentials));
  var fName = filePath.path.substring(filePath.path.lastIndexOf("/") + 1);
  Dio ipfsClient = Dio(
      BaseOptions(
          baseUrl: "https://ipfs.infura.io:5001/api/v0",
          headers: {
            "Abspath": filePath.path,
            "Content-Disposition": 'form-data; filename="$fName"',
            "Authorization": "Basic $auth",
          }
      )
  );
  FormData formData = FormData.fromMap({
    "file": await MultipartFile.fromFile(filePath.path, filename: filePath.path.substring(filePath.path.lastIndexOf("/") + 1)),
  });
  return await ipfsClient.post("/add", data: formData)
      .onError((error, stackTrace) {
    print(error);
    throw Exception(error);});
}