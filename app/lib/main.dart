import 'dart:async';
import 'package:flutter/material.dart';
import 'perpustakaan.dart';

void main() {
  runApp(AplikasiPerpustakaan(api: PerpustakaanApi()));
}

class _Palet {
  const _Palet({
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.text,
    required this.muted,
    required this.primary,
    required this.primaryInk,
    required this.accent,
    required this.accentInk,
    required this.border,
    required this.borderSubtle,
    required this.okBg,
    required this.okText,
    required this.errBg,
    required this.errText,
    required this.warnBg,
    required this.warnText,
  });

  final Color bg;
  final Color surface;
  final Color surfaceAlt;
  final Color text;
  final Color muted;
  final Color primary;
  final Color primaryInk;
  final Color accent;
  final Color accentInk;
  final Color border;
  final Color borderSubtle;
  final Color okBg;
  final Color okText;
  final Color errBg;
  final Color errText;
  final Color warnBg;
  final Color warnText;

  static const light = _Palet(
    bg: Color(0xFFF6F1E7),
    surface: Color(0xFFFDFBF7),
    surfaceAlt: Color(0xFFEDE5D6),
    text: Color(0xFF1E2421),
    muted: Color(0xFF4A524D),
    primary: Color(0xFF1F4D3A),
    primaryInk: Color(0xFFFDFBF7),
    accent: Color(0xFFB54426),
    accentInk: Color(0xFFFDFBF7),
    border: Color(0xFF857A69),
    borderSubtle: Color(0xFFC9BFA9),
    okBg: Color(0xFFE3EFE8),
    okText: Color(0xFF184A35),
    errBg: Color(0xFFFBEAE7),
    errText: Color(0xFF8E2417),
    warnBg: Color(0xFFF9EEDB),
    warnText: Color(0xFF6E3B08),
  );

  static const dark = _Palet(
    bg: Color(0xFF151816),
    surface: Color(0xFF1D221F),
    surfaceAlt: Color(0xFF262C28),
    text: Color(0xFFF2ECE1),
    muted: Color(0xFFB9B2A4),
    primary: Color(0xFF6DB893),
    primaryInk: Color(0xFF0F1A14),
    accent: Color(0xFFE07A5F),
    accentInk: Color(0xFF151816),
    border: Color(0xFF7D857E),
    borderSubtle: Color(0xFF3A423D),
    okBg: Color(0xFF1B382A),
    okText: Color(0xFFB8E6CE),
    errBg: Color(0xFF441E19),
    errText: Color(0xFFF7C2BA),
    warnBg: Color(0xFF3D2B12),
    warnText: Color(0xFFF4D7A6),
  );
}

class AplikasiPerpustakaan extends StatefulWidget {
  const AplikasiPerpustakaan({super.key, required this.api});

  final PerpustakaanApi api;

  @override
  State<AplikasiPerpustakaan> createState() => _AplikasiPerpustakaanState();
}

class _AplikasiPerpustakaanState extends State<AplikasiPerpustakaan> {
  bool _darkMode = false;

  ThemeData _tema(_Palet p, Brightness brightness) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(6));
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: p.bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: p.primary,
        onPrimary: p.primaryInk,
        secondary: p.accent,
        onSecondary: p.accentInk,
        error: p.errText,
        onError: p.primaryInk,
        surface: p.surface,
        onSurface: p.text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.surface,
        foregroundColor: p.text,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: p.borderSubtle),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: p.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: p.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: p.accent, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: shape,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: shape,
          side: BorderSide(color: p.border, width: 1.5),
          foregroundColor: p.text,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        indicatorColor: p.surfaceAlt,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? p.text : p.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(color: p.text, fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palet = _darkMode ? _Palet.dark : _Palet.light;
    return MaterialApp(
      title: 'Manajemen Perpustakaan',
      debugShowCheckedModeBanner: false,
      theme: _tema(_Palet.light, Brightness.light),
      darkTheme: _tema(_Palet.dark, Brightness.dark),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: _BerandaPerpustakaan(
        api: widget.api,
        palet: palet,
        darkMode: _darkMode,
        onToggleTema: () => setState(() => _darkMode = !_darkMode),
      ),
    );
  }
}

class _BerandaPerpustakaan extends StatefulWidget {
  const _BerandaPerpustakaan({
    required this.api,
    required this.palet,
    required this.darkMode,
    required this.onToggleTema,
  });

  final PerpustakaanApi api;
  final _Palet palet;
  final bool darkMode;
  final VoidCallback onToggleTema;

  @override
  State<_BerandaPerpustakaan> createState() => _BerandaPerpustakaanState();
}

class _BerandaPerpustakaanState extends State<_BerandaPerpustakaan>
    with WidgetsBindingObserver {
  Perpustakaan _perpus = Perpustakaan();
  int _tabNav = 0;
  int _tabSirkulasi = 0;
  bool _memuat = true;
  bool _sedangKirim = false;
  bool _sedangSinkron = false;
  Timer? _timerSinkron;
  String? _galatGlobal;

  String _kataKunci = '';
  String _filterStok = 'semua';
  String _filterTransaksi = 'semua';

  final _cariCtrl = TextEditingController();
  final _pinjamBukuCtrl = TextEditingController();
  final _pinjamIdAnggotaCtrl = TextEditingController();
  final _pinjamNamaAnggotaCtrl = TextEditingController();
  final _kembaliIdTrxCtrl = TextEditingController();
  final _tambahIdCtrl = TextEditingController();
  final _tambahJudulCtrl = TextEditingController();
  final _tambahPenulisCtrl = TextEditingController();
  final _tambahStokCtrl = TextEditingController();

  String? _galatPinjam;
  String? _galatKembali;
  String? _galatTambah;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _muatDariServer();
    _mulaiTimerSinkron();
  }

  @override
  void dispose() {
    _timerSinkron?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _cariCtrl.dispose();
    _pinjamBukuCtrl.dispose();
    _pinjamIdAnggotaCtrl.dispose();
    _pinjamNamaAnggotaCtrl.dispose();
    _kembaliIdTrxCtrl.dispose();
    _tambahIdCtrl.dispose();
    _tambahJudulCtrl.dispose();
    _tambahPenulisCtrl.dispose();
    _tambahStokCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sinkronDiam();
      _mulaiTimerSinkron();
    } else if (state == AppLifecycleState.paused) {
      _timerSinkron?.cancel();
      _timerSinkron = null;
    }
  }

  void _mulaiTimerSinkron() {
    _timerSinkron?.cancel();
    _timerSinkron = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _sinkronDiam(),
    );
  }

  bool _samaState(Perpustakaan a, Perpustakaan b) {
    if (a.koleksiBuku.length != b.koleksiBuku.length ||
        a.daftarAnggota.length != b.daftarAnggota.length ||
        a.daftarPeminjaman.length != b.daftarPeminjaman.length) {
      return false;
    }
    for (var i = 0; i < a.koleksiBuku.length; i++) {
      final x = a.koleksiBuku[i];
      final y = b.koleksiBuku[i];
      if (x.id != y.id || x.judul != y.judul || x.penulis != y.penulis || x.stok != y.stok) {
        return false;
      }
    }
    for (var i = 0; i < a.daftarPeminjaman.length; i++) {
      final x = a.daftarPeminjaman[i];
      final y = b.daftarPeminjaman[i];
      if (x.idTransaksi != y.idTransaksi || x.status != y.status) {
        return false;
      }
    }
    return true;
  }

  Future<void> _sinkronDiam() async {
    if (!mounted || _memuat || _sedangKirim || _sedangSinkron) return;
    _sedangSinkron = true;
    try {
      final res = await widget.api.ambilState();
      if (!mounted) return;
      if (!_samaState(_perpus, res.perpus) || _galatGlobal != null) {
        setState(() {
          _perpus = res.perpus;
          _galatGlobal = null;
        });
      }
    } catch (_) {
      // Keep UI undisturbed if a periodic background poll fails momentarily.
    } finally {
      _sedangSinkron = false;
    }
  }

  void _infoSingkat(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _muatDariServer() async {
    setState(() {
      _memuat = true;
      _galatGlobal = null;
    });
    try {
      final res = await widget.api.ambilState();
      if (!mounted) return;
      setState(() {
        _perpus = res.perpus;
        _memuat = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _memuat = false;
        _galatGlobal = e.toString().replaceFirst('HttpException: ', '');
      });
    }
  }

  Future<void> _muatContoh() async {
    setState(() => _sedangKirim = true);
    try {
      final res = await widget.api.muatContoh();
      if (!mounted) return;
      setState(() {
        _perpus = res.perpus;
        _galatGlobal = null;
      });
      _infoSingkat(res.pesan);
    } catch (e) {
      if (!mounted) return;
      setState(() => _galatGlobal = e.toString().replaceFirst('HttpException: ', ''));
    } finally {
      if (mounted) setState(() => _sedangKirim = false);
    }
  }

  Future<void> _kirimTambahBuku() async {
    setState(() => _galatTambah = null);
    final stok = int.tryParse(_tambahStokCtrl.text.trim()) ?? -1;
    try {
      Perpustakaan.fromJson({
        'batasPinjaman': _perpus.batasPinjaman,
        'koleksiBuku': _perpus.koleksiBuku
            .map((b) => {'id': b.id, 'judul': b.judul, 'penulis': b.penulis, 'stok': b.stok})
            .toList(),
      }).tambahBuku(
        id: _tambahIdCtrl.text,
        judul: _tambahJudulCtrl.text,
        penulis: _tambahPenulisCtrl.text,
        stok: stok,
      );

      setState(() => _sedangKirim = true);
      final res = await widget.api.tambahBuku(
        id: _tambahIdCtrl.text.trim(),
        judul: _tambahJudulCtrl.text.trim(),
        penulis: _tambahPenulisCtrl.text.trim(),
        stok: stok,
      );
      if (!mounted) return;
      _tambahIdCtrl.clear();
      _tambahJudulCtrl.clear();
      _tambahPenulisCtrl.clear();
      _tambahStokCtrl.clear();
      setState(() {
        _perpus = res.perpus;
        _galatGlobal = null;
      });
      _infoSingkat(res.pesan);
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _galatTambah = e.toString().replaceFirst('Bad state: ', '').replaceFirst('Invalid argument(s): ', '').replaceFirst('HttpException: ', ''),
      );
    } finally {
      if (mounted) setState(() => _sedangKirim = false);
    }
  }

  Future<void> _kirimPeminjaman() async {
    setState(() => _galatPinjam = null);
    try {
      final salinan = Perpustakaan(batasPinjaman: _perpus.batasPinjaman)
        ..koleksiBuku.addAll(
          _perpus.koleksiBuku.map(
            (b) => Buku(id: b.id, judul: b.judul, penulis: b.penulis, stok: b.stok),
          ),
        )
        ..daftarAnggota.addAll(
          _perpus.daftarAnggota.map((a) => Anggota(id: a.id, nama: a.nama)),
        )
        ..daftarPeminjaman.addAll(
          _perpus.daftarPeminjaman.map(
            (p) => Peminjaman(
              idTransaksi: p.idTransaksi,
              idBuku: p.idBuku,
              judulBuku: p.judulBuku,
              idAnggota: p.idAnggota,
              namaAnggota: p.namaAnggota,
              tanggalPinjam: p.tanggalPinjam,
              tanggalKembali: p.tanggalKembali,
              status: p.status,
            ),
          ),
        );

      salinan.catatPeminjaman(
        idBuku: _pinjamBukuCtrl.text,
        idAnggota: _pinjamIdAnggotaCtrl.text,
        namaAnggota: _pinjamNamaAnggotaCtrl.text,
      );

      setState(() => _sedangKirim = true);
      final res = await widget.api.catatPeminjaman(
        idBuku: _pinjamBukuCtrl.text.trim(),
        idAnggota: _pinjamIdAnggotaCtrl.text.trim(),
        namaAnggota: _pinjamNamaAnggotaCtrl.text.trim(),
      );
      if (!mounted) return;
      _pinjamBukuCtrl.clear();
      _pinjamIdAnggotaCtrl.clear();
      _pinjamNamaAnggotaCtrl.clear();
      setState(() {
        _perpus = res.perpus;
        _galatGlobal = null;
      });
      _infoSingkat(res.pesan);
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _galatPinjam = e.toString().replaceFirst('Bad state: ', '').replaceFirst('Invalid argument(s): ', '').replaceFirst('HttpException: ', ''),
      );
    } finally {
      if (mounted) setState(() => _sedangKirim = false);
    }
  }

  Future<void> _kirimPengembalian(String idTransaksi) async {
    setState(() => _galatKembali = null);
    try {
      setState(() => _sedangKirim = true);
      final res = await widget.api.catatPengembalian(idTransaksi.trim());
      if (!mounted) return;
      _kembaliIdTrxCtrl.clear();
      setState(() {
        _perpus = res.perpus;
        _galatGlobal = null;
      });
      _infoSingkat(res.pesan);
    } catch (e) {
      if (!mounted) return;
      final pesan = e.toString().replaceFirst('HttpException: ', '');
      if (_tabNav == 1) {
        setState(() => _galatKembali = pesan);
      } else {
        _infoSingkat(pesan);
      }
    } finally {
      if (mounted) setState(() => _sedangKirim = false);
    }
  }

  Future<void> _konfirmasiReset() async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kosongkan seluruh data di database?'),
        content: const Text(
          'Tindakan ini menghapus daftar buku, anggota, dan riwayat transaksi di database MySQL db_perpustakaan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: widget.palet.errText,
              foregroundColor: widget.palet.bg,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus Semua Data'),
          ),
        ],
      ),
    );
    if (ya != true) return;
    setState(() => _sedangKirim = true);
    try {
      final res = await widget.api.resetDatabase();
      if (!mounted) return;
      setState(() => _perpus = res.perpus);
      _infoSingkat(res.pesan);
    } catch (e) {
      if (!mounted) return;
      setState(() => _galatGlobal = e.toString().replaceFirst('HttpException: ', ''));
    } finally {
      if (mounted) setState(() => _sedangKirim = false);
    }
  }

  Widget _tagStatus(String teks, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: fg),
      ),
      child: Text(
        teks,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _ringkasanLedger(_Palet p) {
    final items = [
      ('Judul', _perpus.koleksiBuku.length.toString()),
      ('Total stok', _perpus.totalStokTersedia.toString()),
      ('Dipinjam', _perpus.daftarPeminjamanAktif().length.toString()),
      ('Batas aktif', '${_perpus.batasPinjaman} / org'),
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.borderSubtle),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 10,
        children: items
            .map(
              (item) => SizedBox(
                width: 125,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.$1, style: TextStyle(color: p.muted, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      item.$2,
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: p.text,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _bannerGalat(_Palet p) {
    if (_galatGlobal == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.errBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: p.errText),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _galatGlobal!,
            style: TextStyle(color: p.errText, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _muatDariServer,
            child: const Text('Coba Hubungkan Ulang'),
          ),
        ],
      ),
    );
  }

  Widget _halamanKatalog(_Palet p) {
    final semua = _perpus.koleksiBuku;
    final hasil = _perpus.cariBuku(_kataKunci).where((b) {
      if (_filterStok == 'tersedia') return b.tersedia;
      if (_filterStok == 'habis') return !b.tersedia;
      return true;
    }).toList();

    return RefreshIndicator(
      onRefresh: _muatDariServer,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Katalog Buku',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: p.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cari koleksi berdasarkan ID atau judul, lalu periksa stoknya.',
            style: TextStyle(color: p.muted),
          ),
          const SizedBox(height: 12),
          _ringkasanLedger(p),
          const SizedBox(height: 14),
          _bannerGalat(p),
          if (_memuat)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: p.borderSubtle),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Memuat data dari server XAMPP...',
                      style: TextStyle(color: p.muted),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            TextField(
              controller: _cariCtrl,
              decoration: InputDecoration(
                labelText: 'Cari buku (ID atau judul)',
                hintText: 'Ketik BK-001 atau kata pada judul',
                suffixIcon: _kataKunci.isNotEmpty
                    ? IconButton(
                        tooltip: 'Bersihkan pencarian',
                        onPressed: () {
                          _cariCtrl.clear();
                          setState(() => _kataKunci = '');
                        },
                        icon: const Icon(Icons.close),
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _kataKunci = v),
            ),
            const SizedBox(height: 10),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'semua', label: Text('Semua')),
                ButtonSegment(value: 'tersedia', label: Text('Tersedia')),
                ButtonSegment(value: 'habis', label: Text('Habis')),
              ],
              selected: {_filterStok},
              onSelectionChanged: (s) => setState(() => _filterStok = s.first),
            ),
            const SizedBox(height: 14),
            if (hasil.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: p.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      semua.isEmpty
                          ? 'Belum ada buku di katalog.'
                          : 'Tidak ada buku yang cocok dengan pencarian.',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      semua.isEmpty
                          ? 'Tambahkan buku baru di tab Sirkulasi, atau muat contoh data uji untuk langsung mencoba alur peminjaman.'
                          : 'Periksa ejaan ID atau judul, atau reset filter untuk melihat seluruh koleksi.',
                      style: TextStyle(color: p.muted),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: semua.isEmpty
                          ? [
                              FilledButton(
                                onPressed: () => setState(() {
                                  _tabNav = 1;
                                  _tabSirkulasi = 2;
                                }),
                                child: const Text('Tambah Buku Pertama'),
                              ),
                              OutlinedButton(
                                onPressed: _sedangKirim ? null : _muatContoh,
                                child: const Text('Muat Contoh Buku Uji'),
                              ),
                            ]
                          : [
                              OutlinedButton(
                                onPressed: () {
                                  _cariCtrl.clear();
                                  setState(() {
                                    _kataKunci = '';
                                    _filterStok = 'semua';
                                  });
                                },
                                child: const Text('Tampilkan Semua Buku'),
                              ),
                            ],
                    ),
                  ],
                ),
              )
            else
              ...hasil.map(
                (buku) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  buku.id,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w700,
                                    color: p.muted,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _tagStatus(
                                '${buku.statusKetersediaan} (${buku.stok} eks.)',
                                buku.tersedia ? p.okBg : p.errBg,
                                buku.tersedia ? p.okText : p.errText,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            buku.judul,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: p.text,
                            ),
                          ),
                          Text(buku.penulis, style: TextStyle(color: p.muted)),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: buku.tersedia
                                  ? () {
                                      _pinjamBukuCtrl.text = buku.id;
                                      setState(() {
                                        _tabNav = 1;
                                        _tabSirkulasi = 0;
                                        _galatPinjam = null;
                                      });
                                    }
                                  : null,
                              child: Text(buku.tersedia ? 'Pinjam Buku Ini' : 'Stok Habis'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _kotakBacaan(_Palet p, String teks, {Color? bg, Color? fg}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg ?? p.surfaceAlt,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg ?? p.borderSubtle),
      ),
      child: Text(
        teks,
        style: TextStyle(color: fg ?? p.text, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _halamanSirkulasi(_Palet p) {
    final idBuku = _pinjamBukuCtrl.text.trim();
    final infoStok = idBuku.isEmpty ? null : _perpus.cekKetersediaan(idBuku);

    final idAnggota = _pinjamIdAnggotaCtrl.text.trim();
    final namaAnggota = _pinjamNamaAnggotaCtrl.text.trim();
    Anggota? anggotaCocok;
    if (idAnggota.isNotEmpty) {
      for (final a in _perpus.daftarAnggota) {
        if (a.id.toLowerCase() == idAnggota.toLowerCase()) {
          anggotaCocok = a;
          break;
        }
      }
    } else if (namaAnggota.isNotEmpty) {
      final list = _perpus.daftarAnggota
          .where((a) => a.nama.toLowerCase() == namaAnggota.toLowerCase())
          .toList();
      if (list.length == 1) anggotaCocok = list.first;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Meja Sirkulasi',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: p.text,
          ),
        ),
        const SizedBox(height: 10),
        _bannerGalat(p),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: FittedBox(fit: BoxFit.scaleDown, child: Text('Pinjam'))),
            ButtonSegment(value: 1, label: FittedBox(fit: BoxFit.scaleDown, child: Text('Kembalikan'))),
            ButtonSegment(value: 2, label: FittedBox(fit: BoxFit.scaleDown, child: Text('Tambah Buku'))),
          ],
          selected: {_tabSirkulasi},
          onSelectionChanged: (s) => setState(() => _tabSirkulasi = s.first),
        ),
        const SizedBox(height: 16),
        if (_tabSirkulasi == 0)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _pinjamBukuCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ID Buku',
                      hintText: 'Contoh: BK-001',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  if (infoStok == null)
                    _kotakBacaan(p, 'Masukkan ID buku untuk memeriksa ketersediaan stok.')
                  else if (!infoStok.ditemukan)
                    _kotakBacaan(
                      p,
                      'Buku dengan ID "$idBuku" tidak ditemukan di katalog.',
                      bg: p.errBg,
                      fg: p.errText,
                    )
                  else if (infoStok.tersedia)
                    _kotakBacaan(
                      p,
                      'Tersedia: ${infoStok.stok} eksemplar (${infoStok.buku!.judul}).',
                      bg: p.okBg,
                      fg: p.okText,
                    )
                  else
                    _kotakBacaan(
                      p,
                      'Stok habis: 0 eksemplar (${infoStok.buku!.judul}). Peminjaman ditolak.',
                      bg: p.errBg,
                      fg: p.errText,
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pinjamIdAnggotaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ID Anggota',
                      hintText: 'Contoh: A-01',
                    ),
                    onChanged: (v) {
                      for (final a in _perpus.daftarAnggota) {
                        if (a.id.toLowerCase() == v.trim().toLowerCase() &&
                            _pinjamNamaAnggotaCtrl.text.trim().isEmpty) {
                          _pinjamNamaAnggotaCtrl.text = a.nama;
                          break;
                        }
                      }
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pinjamNamaAnggotaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Anggota',
                      hintText: 'Wajib diisi untuk anggota baru',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  if (anggotaCocok == null)
                    _kotakBacaan(
                      p,
                      'Maksimal ${_perpus.batasPinjaman} buku aktif per anggota.',
                    )
                  else
                    () {
                      final aktif = _perpus.hitungPinjamanAktif(anggotaCocok!.id);
                      final penuh = aktif >= _perpus.batasPinjaman;
                      return _kotakBacaan(
                        p,
                        penuh
                            ? 'Kuota penuh: ${anggotaCocok.nama} (${anggotaCocok.id}) meminjam $aktif dari ${_perpus.batasPinjaman} buku.'
                            : 'Pinjaman aktif ${anggotaCocok.nama} (${anggotaCocok.id}): $aktif dari ${_perpus.batasPinjaman} buku.',
                        bg: penuh ? p.errBg : p.warnBg,
                        fg: penuh ? p.errText : p.warnText,
                      );
                    }(),
                  if (_galatPinjam != null) ...[
                    const SizedBox(height: 10),
                    _kotakBacaan(p, _galatPinjam!, bg: p.errBg, fg: p.errText),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: p.accent,
                        foregroundColor: p.accentInk,
                      ),
                      onPressed: _sedangKirim ? null : _kirimPeminjaman,
                      child: const Text('Catat Peminjaman'),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_tabSirkulasi == 1)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _kembaliIdTrxCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ID Transaksi Peminjaman',
                      hintText: 'Contoh: TRX-001',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pengembalian hanya diproses untuk transaksi yang tercatat dan masih berstatus Dipinjam. Stok buku otomatis bertambah 1.',
                    style: TextStyle(color: p.muted, fontSize: 13),
                  ),
                  if (_galatKembali != null) ...[
                    const SizedBox(height: 10),
                    _kotakBacaan(p, _galatKembali!, bg: p.errBg, fg: p.errText),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _sedangKirim
                          ? null
                          : () => _kirimPengembalian(_kembaliIdTrxCtrl.text),
                      child: const Text('Catat Pengembalian'),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _tambahIdCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ID Buku',
                      hintText: 'Kode unik, mis. BK-005',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tambahJudulCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Judul Buku',
                      hintText: 'Judul lengkap buku',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tambahPenulisCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Penulis',
                      hintText: 'Nama penulis buku',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tambahStokCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Stok',
                      hintText: 'Jumlah eksemplar, minimal 0',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  if (_galatTambah != null) ...[
                    const SizedBox(height: 10),
                    _kotakBacaan(p, _galatTambah!, bg: p.errBg, fg: p.errText),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _sedangKirim ? null : _kirimTambahBuku,
                      child: const Text('Simpan Buku'),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _halamanRiwayat(_Palet p) {
    final transaksi = _perpus.daftarPeminjaman
        .where((t) => _filterTransaksi == 'semua' || t.status == _filterTransaksi)
        .toList();

    return RefreshIndicator(
      onRefresh: _muatDariServer,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Transaksi & Anggota',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: p.text,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _sedangKirim ? null : _konfirmasiReset,
                child: const Text('Reset DB'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _bannerGalat(p),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'semua', label: Text('Semua')),
              ButtonSegment(value: 'Dipinjam', label: Text('Dipinjam')),
              ButtonSegment(value: 'Dikembalikan', label: Text('Kembali')),
            ],
            selected: {_filterTransaksi},
            onSelectionChanged: (s) => setState(() => _filterTransaksi = s.first),
          ),
          const SizedBox(height: 14),
          if (transaksi.isEmpty)
            _kotakBacaan(
              p,
              'Belum ada transaksi pada filter ini. Catat peminjaman melalui tab Sirkulasi.',
            )
          else
            ...transaksi.map(
              (trx) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                trx.idTransaksi,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w700,
                                  color: p.muted,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _tagStatus(
                              trx.status,
                              trx.status == 'Dipinjam' ? p.warnBg : p.okBg,
                              trx.status == 'Dipinjam' ? p.warnText : p.okText,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${trx.judulBuku} (${trx.idBuku})',
                          style: TextStyle(fontWeight: FontWeight.w700, color: p.text),
                        ),
                        Text(
                          'Peminjam: ${trx.namaAnggota} (${trx.idAnggota})',
                          style: TextStyle(color: p.muted),
                        ),
                        if (trx.status == 'Dipinjam') ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _sedangKirim
                                  ? null
                                  : () => _kirimPengembalian(trx.idTransaksi),
                              child: const Text('Kembalikan'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 18),
          Text(
            'Anggota dan Kuota Pinjaman',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: p.text,
            ),
          ),
          const SizedBox(height: 8),
          if (_perpus.daftarAnggota.isEmpty)
            _kotakBacaan(
              p,
              'Belum ada anggota terdaftar. Anggota tercatat otomatis saat transaksi peminjaman pertama dibuat.',
            )
          else
            ..._perpus.daftarAnggota.map((a) {
              final aktif = _perpus.hitungPinjamanAktif(a.id);
              final penuh = aktif >= _perpus.batasPinjaman;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    title: Text(
                      a.nama,
                      style: TextStyle(fontWeight: FontWeight.w700, color: p.text),
                    ),
                    subtitle: Text(
                      a.id,
                      style: TextStyle(fontFamily: 'monospace', color: p.muted),
                    ),
                    trailing: _tagStatus(
                      '$aktif / ${_perpus.batasPinjaman} buku',
                      penuh ? p.errBg : p.okBg,
                      penuh ? p.errText : p.okText,
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palet;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Arsip Pustaka',
          style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: widget.darkMode ? 'Ganti ke Mode Terang' : 'Ganti ke Mode Gelap',
            onPressed: widget.onToggleTema,
            icon: Icon(widget.darkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          ),
        ],
      ),
      body: switch (_tabNav) {
        0 => _halamanKatalog(p),
        1 => _halamanSirkulasi(p),
        _ => _halamanRiwayat(p),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabNav,
        onDestinationSelected: (idx) {
          setState(() => _tabNav = idx);
          _sinkronDiam();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Katalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Sirkulasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}
