import 'package:flutter/material.dart';
import 'package:sqlite/sqlite_db.dart';

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqlite/model/buku.dart';

void main() {
  runApp(const Halaman1());
}

class Halaman1 extends StatelessWidget {
  const Halaman1({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController judulController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();

  List<Map<String, dynamic>> catatan = [];

  void refreshData() async {
    final data = await DatabaseHelper.getBuku();

    setState(() {
      catatan = data;
    });
  }

  @override
  void initState() {
    refreshData();
    super.initState();
  }

  String? photoprofile;
  Future<String> getFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom,
    allowedExtensions: [
      'jpg',
      'png',
      'webm',
    ],);

    if (result != null) {
      PlatformFile sourceFile = result.files.first;
      final destination = await getExternalStorageDirectory();
      File? destinationFile =
          File('${destination!.path}/${sourceFile.name.hashCode}');
      final newFile =
          File(sourceFile.path!).copy(destinationFile.path.toString());
      setState(() {
        photoprofile = destinationFile.path;
      });
      File(sourceFile.path!.toString()).delete();
      return destinationFile.path;
    } else {
      return "Dokumen belum diupload";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: catatan.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: catatan[index]['judul'] != ''
                ? Image.file(File(catatan[index]['photo']),
                    width: 40, height: 40)
                : FlutterLogo(),
            title: Text(catatan[index]['judul']),
            subtitle: Text(catatan[index]['deskripsi']),
            onTap: () {
              Form(catatan[index]['id']);
            },
            trailing: IconButton(
                onPressed: () {
                  hapusBuku(catatan[index]['id']);
                },
                icon: const Icon(Icons.delete)),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Form(null);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void Form(id) async {
    if (id != null) {
      final dataupdate = catatan.firstWhere((element) => element['id'] == id);
      judulController.text = dataupdate['judul'];
      deskripsiController.text = dataupdate['deskripsi'];
    }
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(10),
            width: double.infinity,
            height: 800,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: judulController,
                    decoration: const InputDecoration(hintText: "Judul"),
                  ),
                  TextField(
                    controller: deskripsiController,
                    decoration: const InputDecoration(hintText: "Deskripsi"),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        getFilePicker();
                      },
                      child: Row(
                        children: const [
                          Text("Pilih Gambar"),
                          Icon(Icons.camera)
                        ],
                      )),
                  ElevatedButton(
                      onPressed: () async {
                        if (id != null) {
                          String? photo = photoprofile;
                          final data = Buku(
                              id: id,
                              judul: judulController.text,
                              deskripsi: deskripsiController.text,
                              photo: photo.toString());
                          updateBuku(data);
                          judulController.text = '';
                          deskripsiController.text = '';
                          Navigator.pop(context);
                        } else {
                          String? photo = photoprofile;
                          final data = Buku(
                              judul: judulController.text,
                              deskripsi: deskripsiController.text,
                              photo: photo.toString());
                          tambahBuku(data);
                          judulController.text = '';
                          deskripsiController.text = '';
                          Navigator.pop(context);
                        }
                      },
                      child: Text(id == null ? "Tambah" : 'update'))
                ],
              ),
            ),
          );
        });
  }

  Future<void> tambahBuku(Buku buku) async {
    await DatabaseHelper.tambahBuku(buku);
    return refreshData();
  }

  Future<void> updateBuku(Buku buku) async {
    await DatabaseHelper.updateBuku(buku);
    return refreshData();
  }

  Future<void> hapusBuku(int id) async {
    await DatabaseHelper.deleteBuku(id);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Berhasil Dihapus")));
    return refreshData();
  }
}
