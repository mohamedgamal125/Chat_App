import 'package:file_picker/file_picker.dart';

class MediaService {


  MediaService() {}

  // this to pick files from phone
  Future<PlatformFile?> pickImageFromLibrary() async {
    FilePickerResult? _result =
    await FilePicker.platform.pickFiles(type: FileType.image);
    if (_result != null) {
      return _result.files[0];
    }
    return null;
  }
}