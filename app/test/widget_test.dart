import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplikasi_perpustakaan/main.dart';
import 'package:aplikasi_perpustakaan/perpustakaan.dart';

class _FakeApi extends PerpustakaanApi {
  _FakeApi() : super(baseUrl: 'http://127.0.0.1/api.php');

  final Perpustakaan _db = Perpustakaan(batasPinjaman: 3);

  @override
  Future<ApiRespon> ambilState() async {
    return ApiRespon(perpus: _klon(), pesan: 'OK');
  }

  @override
  Future<ApiRespon> muatContoh() async {
    final contoh = [
      ('BK-001', 'Bumi Manusia', 'Pramoedya Ananta Toer', 2),
      ('BK-002', 'Filosofi Teras', 'Henry Manampiring', 1),
      ('BK-003', 'Negeri 5 Menara', 'Ahmad Fuadi', 0),
    ];
    for (final c in contoh) {
      if (_db.cariBukuById(c.$1) == null) {
        _db.tambahBuku(id: c.$1, judul: c.$2, penulis: c.$3, stok: c.$4);
      }
    }
    return ApiRespon(perpus: _klon(), pesan: 'Contoh katalog uji dimuat.');
  }

  @override
  Future<ApiRespon> tambahBuku({
    required String id,
    required String judul,
    required String penulis,
    required int stok,
  }) async {
    _db.tambahBuku(id: id, judul: judul, penulis: penulis, stok: stok);
    return ApiRespon(perpus: _klon(), pesan: 'Buku "$judul" ditambahkan.');
  }

  @override
  Future<ApiRespon> catatPeminjaman({
    required String idBuku,
    required String idAnggota,
    required String namaAnggota,
  }) async {
    final trx = _db.catatPeminjaman(
      idBuku: idBuku,
      idAnggota: idAnggota,
      namaAnggota: namaAnggota,
    );
    return ApiRespon(perpus: _klon(), pesan: 'Peminjaman ${trx.idTransaksi} dicatat.');
  }

  @override
  Future<ApiRespon> catatPengembalian(String idTransaksi) async {
    final trx = _db.catatPengembalian(idTransaksi);
    return ApiRespon(perpus: _klon(), pesan: 'Pengembalian ${trx.idTransaksi} dicatat.');
  }

  @override
  Future<ApiRespon> resetDatabase() async {
    _db.koleksiBuku.clear();
    _db.daftarAnggota.clear();
    _db.daftarPeminjaman.clear();
    return ApiRespon(perpus: _klon(), pesan: 'Database dikosongkan.');
  }

  Perpustakaan _klon() {
    return Perpustakaan.fromJson({
      'batasPinjaman': _db.batasPinjaman,
      'koleksiBuku': _db.koleksiBuku
          .map((b) => {'id': b.id, 'judul': b.judul, 'penulis': b.penulis, 'stok': b.stok})
          .toList(),
      'daftarAnggota': _db.daftarAnggota
          .map((a) => {'id': a.id, 'nama': a.nama})
          .toList(),
      'daftarPeminjaman': _db.daftarPeminjaman
          .map(
            (p) => {
              'idTransaksi': p.idTransaksi,
              'idBuku': p.idBuku,
              'judulBuku': p.judulBuku,
              'idAnggota': p.idAnggota,
              'namaAnggota': p.namaAnggota,
              'tanggalPinjam': p.tanggalPinjam,
              'tanggalKembali': p.tanggalKembali,
              'status': p.status,
            },
          )
          .toList(),
    });
  }
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  test('Domain OOP Perpustakaan menjaga seluruh aturan', () {
    final perpus = Perpustakaan(batasPinjaman: 2);
    final b1 = perpus.tambahBuku(
      id: 'BK-001',
      judul: 'Bumi Manusia',
      penulis: 'Pramoedya',
      stok: 2,
    );
    final b2 = perpus.tambahBuku(
      id: 'BK-002',
      judul: 'Kosong',
      penulis: 'Anon',
      stok: 0,
    );

    expect(perpus.cariBuku('bumi').length, 1);
    expect(b2.statusKetersediaan, 'Habis');
    expect(
      () => perpus.catatPeminjaman(idBuku: 'BK-002', idAnggota: 'A-01', namaAnggota: 'Sari'),
      throwsStateError,
    );

    final trx1 = perpus.catatPeminjaman(
      idBuku: 'BK-001',
      idAnggota: 'A-01',
      namaAnggota: 'Sari',
    );
    perpus.catatPeminjaman(idBuku: 'BK-001', idAnggota: 'A-01');
    expect(b1.stok, 0);
    expect(
      () => perpus.catatPeminjaman(idBuku: 'BK-001', idAnggota: 'A-01'),
      throwsStateError,
    );
    expect(() => perpus.catatPengembalian('TRX-999'), throwsStateError);

    perpus.catatPengembalian(trx1.idTransaksi);
    expect(b1.stok, 1);
    expect(trx1.status, 'Dikembalikan');
  });

  testWidgets('UI katalog, peminjaman, pengembalian, dan toggle tema berjalan', (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(AplikasiPerpustakaan(api: _FakeApi()));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada buku di katalog.'), findsOneWidget);

    await _tap(tester, find.text('Muat Contoh Buku Uji'));
    expect(find.text('Bumi Manusia'), findsOneWidget);
    final listScrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Stok Habis'),
      200,
      scrollable: listScrollable,
    );
    expect(find.text('Stok Habis'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Pinjam Buku Ini').first,
      -200,
      scrollable: listScrollable,
    );
    await _tap(tester, find.text('Pinjam Buku Ini').first);
    expect(find.text('Tersedia: 2 eksemplar (Bumi Manusia).'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'ID Anggota'), 'A-01');
    await tester.enterText(find.widgetWithText(TextField, 'Nama Anggota'), 'Sari');
    await _tap(tester, find.text('Catat Peminjaman'));

    await _tap(tester, find.text('Riwayat'));
    expect(find.text('TRX-001'), findsOneWidget);

    await _tap(tester, find.text('Kembalikan'));
    expect(find.text('Dikembalikan'), findsOneWidget);

    await _tap(tester, find.byTooltip('Ganti ke Mode Gelap'));
    expect(find.byTooltip('Ganti ke Mode Terang'), findsOneWidget);
    expect(find.byTooltip('Pengaturan alamat server XAMPP'), findsNothing);
    expect(find.text('Ubah Alamat Server'), findsNothing);
  });

  testWidgets('Data baru dari web otomatis tersinkronisasi di APK tanpa relog', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(AplikasiPerpustakaan(api: api));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada buku di katalog.'), findsOneWidget);

    await api.tambahBuku(
      id: 'BK-900',
      judul: 'Buku Dari Web',
      penulis: 'Penulis Web',
      stok: 4,
    );

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Buku Dari Web'), findsOneWidget);
  });
}
