import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:ilikepdf/pdf_viewer.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _pdfFiles = [];
  List<String> _filteredFiles = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    baseDirectory();
  }

//Get Permission & root directories to get all pdf files from all folder
  Future<void> baseDirectory() async {
    PermissionStatus permissionStatus =
        await Permission.manageExternalStorage.request();
    if (permissionStatus.isGranted) {
      var rootDirectory = await ExternalPath.getExternalStorageDirectories();
      setState(() {
        _pdfFiles.clear();
        _filteredFiles.clear();
      });
      await getFiles(rootDirectory.first);
    }
  }

//Get all PDF files from every folder/directory
  Future<void> getFiles(String directoryPath) async {
    try {
      var rootDirectory = Directory(directoryPath);
      var directories = rootDirectory.list(recursive: false);

      await for (var element in directories) {
        if (element is File) {
          if (element.path.endsWith('.pdf')) {
            setState(() {
              _pdfFiles.add(element.path);
              _filteredFiles = _pdfFiles;
            });
          }
        } else {
          await getFiles(element.path);
        }
      }
    } catch (e) {
      print(e);
    }
  }

//For Searching PDF Files
  void _filterFiles(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredFiles = _pdfFiles;
      });
    } else {
      setState(() {
        _filteredFiles = _pdfFiles
            .where((file) => file
                .split('/')
                .last
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: !_isSearching
            ? const Text("iLikePDF",
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black))
            : TextField(
                decoration: const InputDecoration(
                    hintText: "Search PDF",
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 20, color: Colors.black)),
                onChanged: (value) {
                  _filterFiles(value);
                },
              ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  _filteredFiles = _pdfFiles;
                });
              },
              icon: Icon(
                _isSearching ? Icons.cancel : Icons.search,
                color: Colors.black,
                size: 30,
              ))
        ],
      ),
      body: _filteredFiles.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _filteredFiles.length,
              itemBuilder: (context, index) {
                String filePath = _filteredFiles[index];
                String fileName = path.basename(filePath);
                return Card(
                  color: Colors.white,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      fileName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    leading: const Icon(
                      Icons.picture_as_pdf_sharp,
                      color: Colors.redAccent,
                      size: 30,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfViewerScreen(
                              pdfName: fileName,
                              pdfPath: filePath,
                            ),
                          ));
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          baseDirectory();
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
