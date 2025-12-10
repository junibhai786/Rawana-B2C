import 'package:moonbnd/language/en.dart';
import 'package:moonbnd/language/ar.dart';

import 'package:get/get.dart';

///Example ara Arabic
// Emoje flags   https://emojipedia.org/flags/.

String languagedefault = eng;
String arabic = "Arabic 🇸🇦";
String english = "English 🇬🇧";

////
String ara = "ar";
String eng = "en";

////////////////////////////////////////

class LocaliztionApp extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        ara: ar,
        eng: en,
      };
}
