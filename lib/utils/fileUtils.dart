import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> getFile(String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/$fileName');
}

Future<void> writeToFile(String str, String fileName) async {
  final file = await getFile(fileName);
  await file.writeAsString(str);
}

Future<String?> readFromFile(String fileName) async {
  try {
    final file = await getFile(fileName);
    return await file.readAsString();
  } catch (e) {
    return null;
  }
}
