import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';

import 'screens/api_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final auth = AuthProvider();
        auth.checkLogin();
        return auth;
      },
      child: const SafeFolderApp(),
    ),
  );
}

class SafeFolderApp extends StatelessWidget {
  const SafeFolderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safe Folder App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: const Color(0xfff7f5fb),
        useMaterial3: true,
      ),
      // home: const FolderListScreen(),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return auth.isLoggedIn
              ? const FolderListScreen()
              : const LoginScreen();
        },
      ),
    );
  }
}

class FolderListScreen extends StatefulWidget {
  const FolderListScreen({super.key});

  @override
  State<FolderListScreen> createState() => _FolderListScreenState();
}

class _FolderListScreenState extends State<FolderListScreen> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  List<Map<String, dynamic>> folders = [];

  @override
  void initState() {
    super.initState();
    loadFolders();
  }

  Future<void> loadFolders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('folders');
    if (data != null) {
      folders = List<Map<String, dynamic>>.from(jsonDecode(data));
      setState(() {});
    }
  }

  Future<void> saveFolders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('folders', jsonEncode(folders));
  }

  void addFolder() {
    final nameController = TextEditingController();
    final passwordController = TextEditingController();

    bool isSecure = false;
    bool useBiometric = false;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text("Create Folder"),
              content: SizedBox(
                width: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "Folder name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text("Secure Folder"),
                      value: isSecure,
                      onChanged: (v) {
                        setDialogState(() => isSecure = v);
                      },
                    ),
                    if (isSecure)
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    if (isSecure)
                      SwitchListTile(
                        title: const Text("Enable Biometric"),
                        value: useBiometric,
                        onChanged: (v) {
                          setDialogState(() => useBiometric = v);
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: () async {
                    final folderName = nameController.text.trim();
                    if (folderName.isEmpty) return;

                    if (isSecure && passwordController.text.isNotEmpty) {
                      await secureStorage.write(
                        key: folderName,
                        value: passwordController.text,
                      );
                    }

                    folders.add({
                      "name": folderName,
                      "secure": isSecure,
                      "passwordKey": folderName,
                      "biometric": useBiometric,
                      "files": [],
                    });

                    await saveFolders();
                    setState(() {});
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Folder created")),
                    );
                  },
                  child: const Text("Create"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void deleteFolder(int index) async {
    final folder = folders[index];
    await secureStorage.delete(key: folder["passwordKey"]);
    folders.removeAt(index);
    await saveFolders();
    setState(() {});
  }

  Future<void> openFolder(Map<String, dynamic> folder) async {
    if (folder["secure"] == true) {
      if (folder["biometric"] == true) {
        final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Biometric Authentication"),
            content: const Text("Simulated biometric success"),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Continue"),
              ),
            ],
          ),
        );

        if (ok != true) return;
      } else {
        final controller = TextEditingController();

        final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Enter Password"),
            content: TextField(controller: controller, obscureText: true),
            actions: [
              FilledButton(
                onPressed: () async {
                  final savedPassword = await secureStorage.read(
                    key: folder["passwordKey"],
                  );

                  Navigator.pop(context, controller.text == savedPassword);
                },
                child: const Text("Unlock"),
              ),
            ],
          ),
        );

        if (ok != true) return;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FolderDetailScreen(folder: folder, onUpdate: saveFolders),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Safe Folder App"), centerTitle: true),
      appBar: AppBar(
        title: const Text("Safe Folder App"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: folders.isEmpty
          ? const Center(child: Text("No folders yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: folders.length,
              itemBuilder: (_, index) {
                final folder = folders[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.deepPurple.shade50,
                      child: Icon(
                        folder["secure"] ? Icons.lock : Icons.folder,
                        color: Colors.deepPurple,
                      ),
                    ),
                    title: Text(
                      folder["name"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      folder["biometric"] == true
                          ? "Biometric enabled"
                          : folder["secure"] == true
                          ? "Password protected"
                          : "Normal folder",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteFolder(index),
                    ),
                    onTap: () => openFolder(folder),
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "api",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ApiScreen()),
              );
            },
            child: const Icon(Icons.cloud),
          ),

          const SizedBox(height: 10),

          FloatingActionButton.extended(
            heroTag: "add",
            onPressed: addFolder,
            icon: const Icon(Icons.add),
            label: const Text("New Folder"),
          ),
        ],
      ),
    );
  }
}

class FolderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> folder;
  final Future<void> Function() onUpdate;

  const FolderDetailScreen({
    super.key,
    required this.folder,
    required this.onUpdate,
  });

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> files = [];
  Timer? autoLockTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    files = List<Map<String, dynamic>>.from(widget.folder["files"] ?? []);
    startAutoLockTimer();
  }

  void startAutoLockTimer() {
    autoLockTimer?.cancel();
    autoLockTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.inactive) &&
        widget.folder["secure"] == true) {
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> saveFiles() async {
    widget.folder["files"] = files;
    await widget.onUpdate();
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final picked = result.files.single;

      files.add({"name": picked.name, "path": picked.path});

      await saveFiles();
      setState(() {});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("File added")));
    }
  }

  void deleteFile(int index) async {
    files.removeAt(index);
    await saveFiles();
    setState(() {});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("File deleted")));
  }

  bool isImage(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith(".png") ||
        lower.endsWith(".jpg") ||
        lower.endsWith(".jpeg");
  }

  bool isPdf(String path) => path.toLowerCase().endsWith(".pdf");

  IconData getFileIcon(String path) {
    if (isPdf(path)) return Icons.picture_as_pdf;
    return Icons.insert_drive_file;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    autoLockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    startAutoLockTimer();

    return Scaffold(
      appBar: AppBar(title: Text(widget.folder["name"])),
      body: files.isEmpty
          ? const Center(child: Text("No files added yet"))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: files.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (_, index) {
                final file = files[index];
                final path = file["path"] ?? "";

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: isImage(path) && File(path).existsSync()
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(path),
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  getFileIcon(path),
                                  size: 60,
                                  color: Colors.deepPurple,
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        file["name"],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteFile(index),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: pickFile,
        icon: const Icon(Icons.upload_file),
        label: const Text("Add File"),
      ),
    );
  }
}
