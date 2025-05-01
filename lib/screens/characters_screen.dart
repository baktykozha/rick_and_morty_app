import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/character_card.dart';

class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key});

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CharacterProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.loadInitialCharacters();
    });

    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300) {
          provider.fetchCharacters();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CharacterProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Список персонажей'),
            actions: [
              IconButton(
                icon: const Icon(Icons.brightness_6),
                onPressed: () {
                  context.read<ThemeProvider>().toggleTheme();
                },
              )
            ],
          ),

          body: provider.characters.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            controller: _scrollController,
            itemCount: provider.characters.length +
                (provider.isFetching ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < provider.characters.length) {
                final character = provider.characters[index];
                return CharacterCard(character: character);
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        );
      },
    );
  }
}

