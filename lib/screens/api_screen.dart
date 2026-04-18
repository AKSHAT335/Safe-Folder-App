import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ApiScreen extends StatefulWidget {
  const ApiScreen({super.key});

  @override
  State<ApiScreen> createState() => _ApiScreenState();
}

class _ApiScreenState extends State<ApiScreen> {
  final api = ApiService();
  List data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    try {
      data = await api.fetchData();
    } catch (e) {
      data = [];
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("API Data")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
          ? const Center(child: Text("No data / Check internet"))
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (_, i) {
                return ListTile(title: Text(data[i]["title"]));
              },
            ),
    );
  }
}
