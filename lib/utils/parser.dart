import 'package:flutter/foundation.dart';
import '../models/character.dart';

List<Character> _parseCharacters(List rawList) {
  return rawList.map((e) => Character.fromJson(Map<String, dynamic>.from(e))).toList();
}

Future<List<Character>> parseCharacters(List rawList) async {
  return compute(_parseCharacters, rawList);
}
