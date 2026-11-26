import 'dart:convert';
import 'dart:io';

String _wajibTeks(String? nilai, String namaField) {
  final teks = (nilai ?? '').trim();
  if (teks.isEmpty) {
    throw ArgumentError('$namaField wajib diisi.');
  }
  return teks;
}

String _norm(String? nilai) => (nilai ?? '').trim().toLowerCase();

class Buku {
  Buku({
    required String id,
    required String judul,
    required String penulis,
    required int stok,
  }) : id = _wajibTeks(id, 'ID buku'),
       judul = _wajibTeks(judul, 'Judul buku'),
       penulis = _wajibTeks(penulis, 'Penulis buku'),
       stok = stok >= 0
           ? stok
           : throw ArgumentError('Stok buku harus minimal 0.');

  factory Buku.fromJson(Map<String, dynamic> json) {
    return Buku(
      id: (json['id'] ?? '').toString(),
      judul: (json['judul'] ?? '').toString(),
      penulis: (json['penulis'] ?? '').toString(),
      stok: (json['stok'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String judul;
  final String penulis;
  int stok;

  bool get tersedia => stok > 0;
  String get statusKetersediaan => stok > 0 ? 'Tersedia' : 'Habis';
}

class Anggota {
  Anggota({required String id, required String nama})
    : id = _wajibTeks(id, 'ID anggota'),
      nama = _wajibTeks(nama, 'Nama anggota');

  factory Anggota.fromJson(Map<String, dynamic> json) {
    return Anggota(
      id: (json['id'] ?? '').toString(),
      nama: (json['nama'] ?? '').toString(),
    );
  }

  final String id;
  final String nama;
}

class Peminjaman {
  Peminjaman({
    required String idTransaksi,
    required String idBuku,
    required String judulBuku,
    required String idAnggota,
    required String namaAnggota,
    required this.tanggalPinjam,
    this.tanggalKembali,
    String status = 'Dipinjam',
  }) : idTransaksi = _wajibTeks(idTransaksi, 'ID transaksi'),
       idBuku = _wajibTeks(idBuku, 'ID buku'),
       judulBuku = _wajibTeks(judulBuku, 'Judul buku'),
       idAnggota = _wajibTeks(idAnggota, 'ID anggota'),
       namaAnggota = _wajibTeks(namaAnggota, 'Nama anggota'),
       status = status == 'Dikembalikan' ? 'Dikembalikan' : 'Dipinjam';

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    return Peminjaman(
      idTransaksi: (json['idTransaksi'] ?? '').toString(),
      idBuku: (json['idBuku'] ?? '').toString(),
      judulBuku: (json['judulBuku'] ?? '').toString(),
      idAnggota: (json['idAnggota'] ?? '').toString(),
      namaAnggota: (json['namaAnggota'] ?? '').toString(),
      tanggalPinjam: (json['tanggalPinjam'] ?? '').toString(),
      tanggalKembali: json['tanggalKembali']?.toString(),
      status: (json['status'] ?? 'Dipinjam').toString(),
    );
  }

  final String idTransaksi;
  final String idBuku;
  final String judulBuku;
  final String idAnggota;
  final String namaAnggota;
  final String tanggalPinjam;
  String? tanggalKembali;
  String status;
}

class InfoKetersediaan {
  const InfoKetersediaan({
    required this.ditemukan,
    required this.tersedia,
    required this.stok,
    required this.status,
    this.buku,
  });

  final bool ditemukan;
  final bool tersedia;
  final int stok;
  final String status;
  final Buku? buku;
}

class Perpustakaan {
  Perpustakaan({this.batasPinjaman = 3}) {
    if (batasPinjaman < 1) {
      throw ArgumentError('Batas pinjaman minimal 1.');
    }
  }

  factory Perpustakaan.fromJson(Map<String, dynamic> json) {
    final batas = (json['batasPinjaman'] as num?)?.toInt() ?? 3;
    final perpus = Perpustakaan(batasPinjaman: batas < 1 ? 3 : batas);
    final rawBuku = json['koleksiBuku'] as List<dynamic>? ?? const [];
    final rawAnggota = json['daftarAnggota'] as List<dynamic>? ?? const [];
    final rawPinjam = json['daftarPeminjaman'] as List<dynamic>? ?? const [];

    perpus.koleksiBuku.addAll(
      rawBuku.map((e) => Buku.fromJson(Map<String, dynamic>.from(e as Map))),
    );
    perpus.daftarAnggota.addAll(
      rawAnggota.map(
        (e) => Anggota.fromJson(Map<String, dynamic>.from(e as Map)),
      ),
    );
    perpus.daftarPeminjaman.addAll(
      rawPinjam.map(
        (e) => Peminjaman.fromJson(Map<String, dynamic>.from(e as Map)),
      ),
    );
    return perpus;
  }

  final int batasPinjaman;
  final List<Buku> koleksiBuku = [];
  final List<Anggota> daftarAnggota = [];
  final List<Peminjaman> daftarPeminjaman = [];
  int _urutanTransaksi = 1;

  Buku? cariBukuById(String id) {
    final target = _norm(id);
    if (target.isEmpty) return null;
    for (final b in koleksiBuku) {
      if (_norm(b.id) == target) return b;
    }
    return null;
  }

  List<Buku> cariBuku([String kataKunci = '']) {
    final q = _norm(kataKunci);
    if (q.isEmpty) return List<Buku>.unmodifiable(koleksiBuku);
    return koleksiBuku
        .where((b) => _norm(b.id).contains(q) || _norm(b.judul).contains(q))
        .toList(growable: false);
  }

  InfoKetersediaan cekKetersediaan(String idBuku) {
    final buku = cariBukuById(idBuku);
    if (buku == null) {
      return const InfoKetersediaan(
        ditemukan: false,
        tersedia: false,
        stok: 0,
        status: 'Tidak ditemukan',
      );
    }
    return InfoKetersediaan(
      ditemukan: true,
      tersedia: buku.tersedia,
      stok: buku.stok,
      status: buku.statusKetersediaan,
      buku: buku,
    );
  }

  int hitungPinjamanAktif(String idAnggota) {
    final target = _norm(idAnggota);
    if (target.isEmpty) return 0;
    return daftarPeminjaman
        .where((p) => _norm(p.idAnggota) == target && p.status == 'Dipinjam')
        .length;
  }

  List<Peminjaman> daftarPeminjamanAktif() {
    return daftarPeminjaman
        .where((p) => p.status == 'Dipinjam')
        .toList(growable: false);
  }

  int get totalStokTersedia =>
      koleksiBuku.fold<int>(0, (sum, buku) => sum + buku.stok);

  Buku tambahBuku({
    required String id,
    required String judul,
    required String penulis,
    required int stok,
  }) {
    final buku = Buku(id: id, judul: judul, penulis: penulis, stok: stok);
    if (cariBukuById(buku.id) != null) {
      throw StateError('Buku dengan ID "${buku.id}" sudah terdaftar.');
    }
    koleksiBuku.add(buku);
    return buku;
  }

  Anggota _selesaikanAnggota(String idAnggota, String namaAnggota) {
    final idTeks = idAnggota.trim();
    final namaTeks = namaAnggota.trim();
    if (idTeks.isEmpty && namaTeks.isEmpty) {
      throw StateError('Masukkan ID dan nama anggota peminjam.');
    }

    if (idTeks.isNotEmpty) {
      for (final a in daftarAnggota) {
        if (_norm(a.id) == _norm(idTeks)) {
          if (namaTeks.isNotEmpty && _norm(a.nama) != _norm(namaTeks)) {
            throw StateError(
              'ID anggota "${a.id}" sudah tercatat atas nama "${a.nama}".',
            );
          }
          return a;
        }
      }
      if (namaTeks.isEmpty) {
        throw StateError(
          'Anggota dengan ID "$idTeks" belum terdaftar. Isi nama anggota.',
        );
      }
      final baru = Anggota(id: idTeks, nama: namaTeks);
      daftarAnggota.add(baru);
      return baru;
    }

    final cocok = daftarAnggota
        .where((a) => _norm(a.nama) == _norm(namaTeks))
        .toList();
    if (cocok.length == 1) return cocok.first;
    if (cocok.length > 1) {
      throw StateError(
        'Ditemukan lebih dari satu anggota bernama sama. Masukkan ID anggota.',
      );
    }
    throw StateError('Anggota baru wajib menyertakan ID dan nama anggota.');
  }

  Peminjaman catatPeminjaman({
    required String idBuku,
    String idAnggota = '',
    String namaAnggota = '',
  }) {
    final info = cekKetersediaan(idBuku);
    if (!info.ditemukan || info.buku == null) {
      throw StateError('Buku dengan ID "${idBuku.trim()}" tidak ditemukan.');
    }
    if (!info.tersedia) {
      throw StateError(
        'Stok buku "${info.buku!.judul}" habis, tidak dapat dipinjam.',
      );
    }

    final anggota = _selesaikanAnggota(idAnggota, namaAnggota);
    final aktif = hitungPinjamanAktif(anggota.id);
    if (aktif >= batasPinjaman) {
      throw StateError(
        'Batas pinjaman tercapai: ${anggota.nama} (${anggota.id}) sudah meminjam $aktif dari maksimal $batasPinjaman buku aktif.',
      );
    }

    info.buku!.stok -= 1;
    late String idTrx;
    do {
      idTrx = 'TRX-${_urutanTransaksi.toString().padLeft(3, '0')}';
      _urutanTransaksi++;
    } while (daftarPeminjaman.any((p) => _norm(p.idTransaksi) == _norm(idTrx)));

    final transaksi = Peminjaman(
      idTransaksi: idTrx,
      idBuku: info.buku!.id,
      judulBuku: info.buku!.judul,
      idAnggota: anggota.id,
      namaAnggota: anggota.nama,
      tanggalPinjam: DateTime.now().toIso8601String(),
    );
    daftarPeminjaman.insert(0, transaksi);
    return transaksi;
  }

  Peminjaman catatPengembalian(String idTransaksi) {
    final target = _wajibTeks(idTransaksi, 'ID transaksi');
    Peminjaman? trx;
    for (final p in daftarPeminjaman) {
      if (_norm(p.idTransaksi) == _norm(target)) {
        trx = p;
        break;
      }
    }
    if (trx == null) {
      throw StateError(
        'Transaksi "$target" tidak tercatat. Pengembalian ditolak.',
      );
    }
    if (trx.status == 'Dikembalikan') {
      throw StateError(
        'Transaksi "${trx.idTransaksi}" sudah dikembalikan sebelumnya.',
      );
    }

    final buku = cariBukuById(trx.idBuku);
    if (buku != null) {
      buku.stok += 1;
    }
    trx.status = 'Dikembalikan';
    trx.tanggalKembali = DateTime.now().toIso8601String();
    return trx;
  }
}

class ApiRespon {
  const ApiRespon({required this.perpus, required this.pesan});

  final Perpustakaan perpus;
  final String pesan;
}

class PerpustakaanApi {
  PerpustakaanApi({
    String? baseUrl,
  }) : baseUrl = baseUrl ?? defaultBaseUrl;

  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.3.144/manajemen_perpustakaan/api.php',
  );

  final String baseUrl;

  Future<ApiRespon> ambilState() => _kirim('GET', 'state');

  Future<ApiRespon> muatContoh() => _kirim('POST', 'muat_contoh', const {});

  Future<ApiRespon> tambahBuku({
    required String id,
    required String judul,
    required String penulis,
    required int stok,
  }) {
    return _kirim('POST', 'tambah_buku', {
      'id': id,
      'judul': judul,
      'penulis': penulis,
      'stok': stok,
    });
  }

  Future<ApiRespon> catatPeminjaman({
    required String idBuku,
    required String idAnggota,
    required String namaAnggota,
  }) {
    return _kirim('POST', 'pinjam', {
      'idBuku': idBuku,
      'idAnggota': idAnggota,
      'namaAnggota': namaAnggota,
    });
  }

  Future<ApiRespon> catatPengembalian(String idTransaksi) {
    return _kirim('POST', 'kembali', {'idTransaksi': idTransaksi});
  }

  Future<ApiRespon> resetDatabase() => _kirim('POST', 'reset', const {});

  Future<ApiRespon> _kirim(
    String method,
    String aksi, [
    Map<String, dynamic>? body,
  ]) async {
    final uri = Uri.parse(baseUrl).replace(queryParameters: {'aksi': aksi});
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 8);

    try {
      final request = method == 'GET'
          ? await client.getUrl(uri)
          : await client.postUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.add(utf8.encode(jsonEncode(body)));
      }

      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );
      final raw = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Respons server tidak berformat JSON.');
      }

      final ok = decoded['status'] == true;
      final pesan = (decoded['pesan'] ?? '').toString();
      if (response.statusCode >= 400 || !ok) {
        throw HttpException(
          pesan.isNotEmpty ? pesan : 'Permintaan gagal (${response.statusCode}).',
        );
      }

      final data = Map<String, dynamic>.from(decoded['data'] as Map);
      return ApiRespon(perpus: Perpustakaan.fromJson(data), pesan: pesan);
    } on SocketException {
      throw HttpException(
        'Tidak dapat terhubung ke $baseUrl. Pastikan HP dan laptop di Wi-Fi yang sama, XAMPP Apache & MySQL aktif, dan firewall port 80 mengizinkan akses.',
      );
    } on FormatException {
      throw const HttpException(
        'Respons server tidak valid. Pastikan alamat mengarah ke api.php.',
      );
    } finally {
      client.close();
    }
  }
}
