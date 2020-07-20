import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';

part 'config.g.dart';

enum EConfigEnv { prod, dev, staging }

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class _ConfigData {
  final String frontendUrl;
  _ConfigData({this.frontendUrl});

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_XXXFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory _ConfigData.fromJson(Map<String, dynamic> json) =>
      _$_ConfigDataFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_XXXToJson`.
  Map<String, dynamic> toJson() => _$_ConfigDataToJson(this);

  _ConfigData _overrideConfigFromConfigData(_ConfigData data) {
    return _ConfigData(frontendUrl: data.frontendUrl ?? this.frontendUrl);
  }
}

class Config {
  _ConfigData _data;

  static final Config _config = Config._internal();
  Config._internal();

  factory Config() {
    return _config;
  }

  _ConfigData getConfig() {
    if (this._data == null) {
      throw Exception("Please setup config first");
    }
    return this._data;
  }

  Future<void> setupConfig(EConfigEnv env) async {
    final enumString = env.toString().split(".").last;

    final defaultConfigString =
        await rootBundle.loadString('assets/config/default.json');
    final defaultConfig = _ConfigData.fromJson(jsonDecode(defaultConfigString));
    final configStringFromAsset =
        await rootBundle.loadString('assets/config/$enumString.json');
    this._data = defaultConfig._overrideConfigFromConfigData(
        _ConfigData.fromJson(jsonDecode(configStringFromAsset)));
  }
}
