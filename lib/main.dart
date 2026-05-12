import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SharedPreferences',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController controller = TextEditingController();
  List<String> nomes = [];

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString('nomes');

    if (dados != null) {
      setState(() {
        nomes = List<String>.from(jsonDecode(dados));
      });
    }
  }

  Future<void> salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nomes', jsonEncode(nomes));
  }

  Future<void> adicionarNome() async {
    if (controller.text.trim().isEmpty) return;

    setState(() {
      nomes.add(controller.text.trim());
    });

    await salvarDados();
    controller.clear();
  }

  Future<void> editarNome(int index) async {
    final novoNome = await showDialog<String>(
      context: context,
      builder: (context) {
        final editController = TextEditingController(text: nomes[index]);
        return AlertDialog(
          title: const Text('Editar nome'),
          content: TextField(controller: editController),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, editController.text.trim()),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (novoNome != null && novoNome.isNotEmpty) {
      setState(() {
        nomes[index] = novoNome;
      });
      await salvarDados();
    }
  }

  Future<void> excluirNome(int index) async {
    setState(() {
      nomes.removeAt(index);
    });
    await salvarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SharedPreferences')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Digite um nome'),
            ),
            ElevatedButton(
              onPressed: adicionarNome,
              child: const Text('Adicionar'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: nomes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(nomes[index]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => editarNome(index),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () => excluirNome(index),
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
