import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission() async {
  return await Permission.photos.request().isGranted ||
      await Permission.storage.request().isGranted ||
      await Permission.mediaLibrary.request().isGranted;
}
