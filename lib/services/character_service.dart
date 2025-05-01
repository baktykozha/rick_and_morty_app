import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import 'dart:developer';

class CharacterService {
  static const String _baseUrl = 'https://rickandmortyapi.com/api/character';

  Future<List<Character>> fetchCharacters(int page) async {
    final response = await http.get(Uri.parse("$_baseUrl?page=$page"));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final results = jsonData['results'] as List;
      return results.map((charJson) => Character.fromJson(charJson)).toList();
    } else {
      throw Exception("Ошибка загрузки персонажей");
    }
  }
}

