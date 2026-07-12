import 'package:get/get.dart';
import 'messages_en.dart';
import 'messages_hi.dart';
import 'messages_major.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        ...enTranslations,
        ...hiTranslations,
        ...otherMajorTranslations,
      };
}
