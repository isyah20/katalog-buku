class Kategori {
  final int? id;
  final String judul;
  final String deskripsi;
  final String photo;

  const Kategori({this.id, required this.judul, required this.deskripsi, required this.photo});
  Map<String, dynamic> toList() {
    return {'id': id, 'judul': judul, 'deskripsi': deskripsi,'photo': photo };
  }

  @override
  String toString() {
    return "{'id': id, 'judul': judul, 'deskripsi': deskripsi,'photo': photo }";
  }
}