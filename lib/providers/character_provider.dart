import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/character.dart';
import '../services/character_service.dart';

class CharacterProvider with ChangeNotifier {
  final _service = CharacterService();
  final List<Character> _characters = [];
  final List<Character> _favorites = [];

  int _currentPage = 1;
  bool _isFetching = false;
  bool _hasMore = true;

  List<Character> get characters => _characters;
  List<Character> get favorites => _favorites;
  bool get isFetching => _isFetching;
  bool get hasMore => _hasMore;

  Future<void> loadInitialCharacters() async {
    final cache = Hive.box('charactersCacheBox');
    if (cache.containsKey('page_1')) {
      final cached = cache.get('page_1') as List;
      final cachedCharacters = cached.map((e) => Character.fromJson(Map<String, dynamic>.from(e))).toList();
      for (var character in cachedCharacters) {
        if (!_characters.any((c) => c.id == character.id)) {
          _characters.add(character);
        }
      }
      notifyListeners();
    } else {
      await fetchCharacters();
    }

    final favBox = Hive.box('favoritesBox');
    _favorites.clear();
    _favorites.addAll(
      favBox.values.map((e) => Character.fromJson(Map<String, dynamic>.from(e))),
    );
  }

  Future<void> fetchCharacters() async {
    if (_isFetching || !_hasMore) return;

    _isFetching = true;
    notifyListeners();

    try {
      final connectivity = await Connectivity().checkConnectivity();
      final cacheKey = 'page_$_currentPage';
      final cacheBox = Hive.box('charactersCacheBox');

      if (connectivity == ConnectivityResult.none) {
        if (cacheBox.containsKey(cacheKey)) {
          final cached = cacheBox.get(cacheKey) as List;
          final cachedCharacters = cached
              .map((e) => Character.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          _characters.addAll(cachedCharacters);
          _currentPage++;
        } else {
          _hasMore = false;
        }
      } else {
        final newCharacters = await _service.fetchCharacters(_currentPage);
        for (var character in newCharacters) {
          if (!_characters.any((c) => c.id == character.id)) {
            _characters.add(character);
          }
        }

        await cacheBox.put(
          cacheKey,
          newCharacters.map((c) => c.toJson()).toList(),
        );

        if (newCharacters.isEmpty) {
          _hasMore = false;
        } else {
          _currentPage++;
        }
      }
    } catch (e) {
      debugPrint('Error during fetch: $e');
      _hasMore = false;
    }

    _isFetching = false;
    notifyListeners();
  }

  void toggleFavorite(Character character) {
    final favBox = Hive.box('favoritesBox');
    final exists = _favorites.any((c) => c.id == character.id);

    if (exists) {
      _favorites.removeWhere((c) => c.id == character.id);
      favBox.delete(character.id);
    } else {
      _favorites.add(character);
      favBox.put(character.id, character.toJson());
    }

    notifyListeners();
  }

  Character? removeFavorite(Character character) {
    final index = _favorites.indexWhere((c) => c.id == character.id);
    if (index != -1) {
      final removed = _favorites.removeAt(index);
      Hive.box('favoritesBox').delete(character.id);
      notifyListeners();
      return removed;
    }
    return null;
  }

  bool isFavorite(Character character) {
    return _favorites.any((c) => c.id == character.id);
  }

  void sortFavoritesByName() {
    _favorites.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  void sortFavoritesByStatus() {
    _favorites.sort((a, b) => a.status.compareTo(b.status));
    notifyListeners();
  }

  void sortFavoritesBySpecies() {
    _favorites.sort((a, b) => a.species.compareTo(b.species));
    notifyListeners();
  }
}
