import 'package:local_video_player/constants/db_enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToDoDB {
  static final ToDoDB instance = ToDoDB._init();

  ToDoDB._init();

  double volume = 0.4667;
  double screenBrightness = 0.5009506344795227;

  SharedPreferences? _db;

  Future<void> init() async {
    _db = await SharedPreferences.getInstance();
    loadData();
  }

  //? run this if this is it first time ever opening the app
  void createInitialData() {
    _db?.setDouble(DBNames.screenBrightness.name, screenBrightness);
    _db?.setDouble(DBNames.volume.name, volume);
  }

  //? load only the brightness and volume
  void loadData() {
    double? savedScreenBrightness =
        _db?.getDouble(DBNames.screenBrightness.name);
    double? savedVolume = _db?.getDouble(DBNames.volume.name);

    if (savedScreenBrightness == null || savedVolume == null) {
      createInitialData();
      return;
    } else {
      screenBrightness = savedScreenBrightness;
      volume = savedVolume;
    }
  }

  void setBrightnessAndVolume({double? brightness, double? volume}) {
    _db?.setDouble(
        DBNames.screenBrightness.name, brightness ?? screenBrightness);
    _db?.setDouble(DBNames.volume.name, volume ?? this.volume);
    screenBrightness = brightness ?? screenBrightness;
    this.volume = volume ?? this.volume;
  }
}
