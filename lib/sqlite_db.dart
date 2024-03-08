import 'package:sqlite/model/buku.dart';
import 'package:sqlite/model/kategori.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import 'dart:async';


import 'package:flutter/widgets.dart';

class DatabaseHelper {
  


  static Future<sql.Database> db() async {
    return sql.openDatabase(join(await sql.getDatabasesPath(), 'catatan.db'),
        version: 2, onCreate: (database, version) async {
    await database.execute("""
        CREATE TABLE buku (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          judul TEXT,
          deskripsi TEXT,
          photo TEXT

        )
      """);
    await database.execute("""
        CREATE TABLE kategori (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          judul TEXT,
          deskripsi TEXT,
          photo TEXT

        )
      """);
    });
  }

  static Future<int> tambahBuku(Buku buku) async {
    final db = await DatabaseHelper.db();
    final data = buku.toList();
    return db.insert('buku', data);
  }
  static Future<int> tambahKategori(Kategori kategori) async {
    final db = await DatabaseHelper.db();
    final data = kategori.toList();
    return db.insert('kategori', data);
  }


  static Future<List<Map<String, dynamic>>> getBuku() async {
    final db = await DatabaseHelper.db();
    return db.query("buku");
  }
  static Future<List<Map<String, dynamic>>> getKategori() async {
    final db = await DatabaseHelper.db();
    return db.query("kategori");
  }

  
  static Future<int> updateBuku(Buku buku) async {
    final db = await DatabaseHelper.db();
    final data =  buku.toList();
    return db.update('buku', data, where: "id=?", whereArgs: [buku.id]);
  }
  static Future<int> updateKategori(Kategori kategori) async {
    final db = await DatabaseHelper.db();
    final data =  kategori.toList();
    return db.update('kategori', data, where: "id=?", whereArgs: [kategori.id]);
  }


  static Future<int> deleteBuku(int id) async {
    final db = await DatabaseHelper.db();
    return db.delete('buku', where: 'id=$id');
  }
  static Future<int> deleteKategori(int id) async {
    final db = await DatabaseHelper.db();
    return db.delete('kategori', where: 'id=$id');
  }

}
