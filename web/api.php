<?php
declare(strict_types=1);

const DB_HOST = '127.0.0.1';
const DB_USER = 'root';
const DB_PASS = '';
const DB_NAME = 'db_perpustakaan';
const BATAS_PINJAMAN = 3;

function dbPort(): int
{
    $env = getenv('PERPUSTAKAAN_DB_PORT');
    return ($env !== false && ctype_digit($env)) ? (int) $env : 3306;
}

header('Content-Type: application/json; charset=UTF-8');
header('Cache-Control: no-store, no-cache, must-revalidate');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

function balas(bool $ok, array $payload = [], int $status = 200): void
{
    http_response_code($status);
    echo json_encode(array_merge(['status' => $ok], $payload), JSON_UNESCAPED_UNICODE);
    exit;
}

function sambungDb(): PDO
{
    $dsn = sprintf('mysql:host=%s;port=%d;charset=utf8mb4', DB_HOST, dbPort());
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    // Ensure schema exists even before manual phpMyAdmin import.
    $pdo->exec(
        'CREATE DATABASE IF NOT EXISTS `' . DB_NAME . '` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci'
    );
    $pdo->exec('USE `' . DB_NAME . '`');

    $pdo->exec(
        'CREATE TABLE IF NOT EXISTS buku (
            id VARCHAR(40) NOT NULL PRIMARY KEY,
            judul VARCHAR(200) NOT NULL,
            penulis VARCHAR(150) NOT NULL,
            stok INT NOT NULL DEFAULT 0,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci'
    );

    $pdo->exec(
        'CREATE TABLE IF NOT EXISTS anggota (
            id VARCHAR(40) NOT NULL PRIMARY KEY,
            nama VARCHAR(150) NOT NULL,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci'
    );

    $pdo->exec(
        "CREATE TABLE IF NOT EXISTS peminjaman (
            id_transaksi VARCHAR(40) NOT NULL PRIMARY KEY,
            id_buku VARCHAR(40) NOT NULL,
            judul_buku VARCHAR(200) NOT NULL,
            id_anggota VARCHAR(40) NOT NULL,
            nama_anggota VARCHAR(150) NOT NULL,
            tanggal_pinjam DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            tanggal_kembali DATETIME NULL,
            status ENUM('Dipinjam', 'Dikembalikan') NOT NULL DEFAULT 'Dipinjam',
            urutan INT NOT NULL AUTO_INCREMENT UNIQUE,
            CONSTRAINT fk_peminjaman_buku FOREIGN KEY (id_buku) REFERENCES buku(id) ON UPDATE CASCADE,
            CONSTRAINT fk_peminjaman_anggota FOREIGN KEY (id_anggota) REFERENCES anggota(id) ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci"
    );

    return $pdo;
}

function ambilSemuaState(PDO $pdo): array
{
    $buku = $pdo->query('SELECT id, judul, penulis, stok FROM buku ORDER BY created_at ASC, id ASC')->fetchAll();
    foreach ($buku as &$b) {
        $b['stok'] = (int) $b['stok'];
    }
    unset($b);

    $anggota = $pdo->query('SELECT id, nama FROM anggota ORDER BY created_at ASC, id ASC')->fetchAll();

    $peminjaman = $pdo->query(
        "SELECT
            id_transaksi AS idTransaksi,
            id_buku AS idBuku,
            judul_buku AS judulBuku,
            id_anggota AS idAnggota,
            nama_anggota AS namaAnggota,
            DATE_FORMAT(tanggal_pinjam, '%Y-%m-%dT%H:%i:%s') AS tanggalPinjam,
            DATE_FORMAT(tanggal_kembali, '%Y-%m-%dT%H:%i:%s') AS tanggalKembali,
            status
         FROM peminjaman
         ORDER BY urutan DESC"
    )->fetchAll();

    return [
        'batasPinjaman' => BATAS_PINJAMAN,
        'koleksiBuku' => $buku,
        'daftarAnggota' => $anggota,
        'daftarPeminjaman' => $peminjaman
    ];
}

function bacaJsonInput(): array
{
    $mentah = file_get_contents('php://input');
    if ($mentah === false || trim($mentah) === '') {
        return [];
    }
    $data = json_decode($mentah, true);
    if (!is_array($data)) {
        balas(false, ['pesan' => 'Format JSON tidak valid.'], 400);
    }
    return $data;
}

function buatIdTransaksiBaru(PDO $pdo): string
{
    $rows = $pdo->query('SELECT id_transaksi FROM peminjaman FOR UPDATE')->fetchAll();
    $maks = 0;
    $terpakai = [];
    foreach ($rows as $row) {
        $kode = (string) $row['id_transaksi'];
        $terpakai[strtolower($kode)] = true;
        if (preg_match('/^TRX-(\d+)$/i', $kode, $m)) {
            $num = (int) $m[1];
            if ($num > $maks) {
                $maks = $num;
            }
        }
    }
    $urutan = max($maks + 1, count($rows) + 1);
    do {
        $kandidat = 'TRX-' . str_pad((string) $urutan, 3, '0', STR_PAD_LEFT);
        $urutan++;
    } while (isset($terpakai[strtolower($kandidat)]));
    return $kandidat;
}

$aksi = trim((string) ($_GET['aksi'] ?? 'state'));

try {
    $pdo = sambungDb();

    if ($_SERVER['REQUEST_METHOD'] === 'GET' && $aksi === 'state') {
        balas(true, ['data' => ambilSemuaState($pdo)]);
    }

    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        balas(false, ['pesan' => 'Metode atau aksi tidak didukung.'], 405);
    }

    $input = bacaJsonInput();

    if ($aksi === 'tambah_buku') {
        $id = trim((string) ($input['id'] ?? ''));
        $judul = trim((string) ($input['judul'] ?? ''));
        $penulis = trim((string) ($input['penulis'] ?? ''));
        $stokMentah = $input['stok'] ?? null;

        if ($id === '' || $judul === '' || $penulis === '') {
            balas(false, ['pesan' => 'ID buku, judul, dan penulis wajib diisi.'], 400);
        }
        if ($stokMentah === null || $stokMentah === '' || !is_numeric($stokMentah) || (int) $stokMentah != $stokMentah || (int) $stokMentah < 0) {
            balas(false, ['pesan' => 'Stok buku harus berupa bilangan bulat minimal 0.'], 400);
        }
        $stok = (int) $stokMentah;

        $cek = $pdo->prepare('SELECT id FROM buku WHERE LOWER(id) = LOWER(?) LIMIT 1');
        $cek->execute([$id]);
        if ($cek->fetch()) {
            balas(false, ['pesan' => "Buku dengan ID \"$id\" sudah terdaftar."], 409);
        }

        $ins = $pdo->prepare('INSERT INTO buku (id, judul, penulis, stok) VALUES (?, ?, ?, ?)');
        $ins->execute([$id, $judul, $penulis, $stok]);

        balas(true, [
            'pesan' => "Buku \"$judul\" ($id) ditambahkan dengan stok $stok.",
            'data' => ambilSemuaState($pdo)
        ], 201);
    }

    if ($aksi === 'muat_contoh') {
        $contoh = [
            ['BK-001', 'Bumi Manusia', 'Pramoedya Ananta Toer', 2],
            ['BK-002', 'Filosofi Teras', 'Henry Manampiring', 1],
            ['BK-003', 'Negeri 5 Menara', 'Ahmad Fuadi', 0],
            ['BK-004', 'Laskar Pelangi', 'Andrea Hirata', 3]
        ];
        $pdo->beginTransaction();
        $cek = $pdo->prepare('SELECT id FROM buku WHERE LOWER(id) = LOWER(?) LIMIT 1');
        $ins = $pdo->prepare('INSERT INTO buku (id, judul, penulis, stok) VALUES (?, ?, ?, ?)');
        $ditambah = 0;
        foreach ($contoh as $item) {
            $cek->execute([$item[0]]);
            if (!$cek->fetch()) {
                $ins->execute($item);
                $ditambah++;
            }
        }
        $pdo->commit();
        balas(true, [
            'pesan' => "Contoh katalog uji dimuat ($ditambah buku baru).",
            'data' => ambilSemuaState($pdo)
        ]);
    }

    if ($aksi === 'pinjam') {
        $idBukuInput = trim((string) ($input['idBuku'] ?? ''));
        $idAnggotaInput = trim((string) ($input['idAnggota'] ?? ''));
        $namaAnggotaInput = trim((string) ($input['namaAnggota'] ?? ''));

        if ($idBukuInput === '') {
            balas(false, ['pesan' => 'ID buku wajib diisi.'], 400);
        }
        if ($idAnggotaInput === '' && $namaAnggotaInput === '') {
            balas(false, ['pesan' => 'Masukkan ID dan nama anggota peminjam.'], 400);
        }

        $pdo->beginTransaction();

        $qBuku = $pdo->prepare('SELECT id, judul, stok FROM buku WHERE LOWER(id) = LOWER(?) FOR UPDATE');
        $qBuku->execute([$idBukuInput]);
        $buku = $qBuku->fetch();

        if (!$buku) {
            $pdo->rollBack();
            balas(false, ['pesan' => "Buku dengan ID \"$idBukuInput\" tidak ditemukan."], 404);
        }
        if ((int) $buku['stok'] <= 0) {
            $pdo->rollBack();
            balas(false, ['pesan' => "Stok buku \"{$buku['judul']}\" habis, tidak dapat dipinjam."], 409);
        }

        $anggota = null;
        if ($idAnggotaInput !== '') {
            $qAnggota = $pdo->prepare('SELECT id, nama FROM anggota WHERE LOWER(id) = LOWER(?) FOR UPDATE');
            $qAnggota->execute([$idAnggotaInput]);
            $terdaftar = $qAnggota->fetch();
            if ($terdaftar) {
                if ($namaAnggotaInput !== '' && strtolower($terdaftar['nama']) !== strtolower($namaAnggotaInput)) {
                    $pdo->rollBack();
                    balas(false, ['pesan' => "ID anggota \"{$terdaftar['id']}\" sudah tercatat atas nama \"{$terdaftar['nama']}\"."], 409);
                }
                $anggota = $terdaftar;
            } else {
                if ($namaAnggotaInput === '') {
                    $pdo->rollBack();
                    balas(false, ['pesan' => "Anggota dengan ID \"$idAnggotaInput\" belum terdaftar. Isi nama anggota."], 400);
                }
                $insAnggota = $pdo->prepare('INSERT INTO anggota (id, nama) VALUES (?, ?)');
                $insAnggota->execute([$idAnggotaInput, $namaAnggotaInput]);
                $anggota = ['id' => $idAnggotaInput, 'nama' => $namaAnggotaInput];
            }
        } else {
            $qNama = $pdo->prepare('SELECT id, nama FROM anggota WHERE LOWER(nama) = LOWER(?) FOR UPDATE');
            $qNama->execute([$namaAnggotaInput]);
            $cocok = $qNama->fetchAll();
            if (count($cocok) === 1) {
                $anggota = $cocok[0];
            } elseif (count($cocok) > 1) {
                $pdo->rollBack();
                balas(false, ['pesan' => 'Ditemukan lebih dari satu anggota bernama sama. Masukkan ID anggota.'], 409);
            } else {
                $pdo->rollBack();
                balas(false, ['pesan' => 'Anggota baru wajib menyertakan ID dan nama anggota.'], 400);
            }
        }

        $qAktif = $pdo->prepare("SELECT COUNT(*) FROM peminjaman WHERE LOWER(id_anggota) = LOWER(?) AND status = 'Dipinjam' FOR UPDATE");
        $qAktif->execute([$anggota['id']]);
        $jumlahAktif = (int) $qAktif->fetchColumn();

        if ($jumlahAktif >= BATAS_PINJAMAN) {
            $pdo->rollBack();
            balas(false, [
                'pesan' => "Batas pinjaman tercapai: {$anggota['nama']} ({$anggota['id']}) sudah meminjam $jumlahAktif dari maksimal " . BATAS_PINJAMAN . ' buku aktif.'
            ], 409);
        }

        $idTransaksi = buatIdTransaksiBaru($pdo);

        $updStok = $pdo->prepare('UPDATE buku SET stok = stok - 1 WHERE id = ?');
        $updStok->execute([$buku['id']]);

        $insPinjam = $pdo->prepare(
            "INSERT INTO peminjaman (id_transaksi, id_buku, judul_buku, id_anggota, nama_anggota, status)
             VALUES (?, ?, ?, ?, ?, 'Dipinjam')"
        );
        $insPinjam->execute([
            $idTransaksi,
            $buku['id'],
            $buku['judul'],
            $anggota['id'],
            $anggota['nama']
        ]);

        $pdo->commit();

        balas(true, [
            'pesan' => "Peminjaman $idTransaksi untuk \"{$buku['judul']}\" atas nama {$anggota['nama']} berhasil dicatat.",
            'data' => ambilSemuaState($pdo)
        ], 201);
    }

    if ($aksi === 'kembali') {
        $idTransaksiInput = trim((string) ($input['idTransaksi'] ?? ''));
        if ($idTransaksiInput === '') {
            balas(false, ['pesan' => 'ID transaksi wajib diisi.'], 400);
        }

        $pdo->beginTransaction();

        $qTrx = $pdo->prepare(
            'SELECT id_transaksi, id_buku, judul_buku, status FROM peminjaman WHERE LOWER(id_transaksi) = LOWER(?) FOR UPDATE'
        );
        $qTrx->execute([$idTransaksiInput]);
        $trx = $qTrx->fetch();

        if (!$trx) {
            $pdo->rollBack();
            balas(false, ['pesan' => "Transaksi \"$idTransaksiInput\" tidak tercatat. Pengembalian ditolak."], 404);
        }
        if ($trx['status'] === 'Dikembalikan') {
            $pdo->rollBack();
            balas(false, ['pesan' => "Transaksi \"{$trx['id_transaksi']}\" sudah dikembalikan sebelumnya."], 409);
        }

        $updTrx = $pdo->prepare(
            "UPDATE peminjaman SET status = 'Dikembalikan', tanggal_kembali = NOW() WHERE id_transaksi = ?"
        );
        $updTrx->execute([$trx['id_transaksi']]);

        $updStok = $pdo->prepare('UPDATE buku SET stok = stok + 1 WHERE id = ?');
        $updStok->execute([$trx['id_buku']]);

        $pdo->commit();

        balas(true, [
            'pesan' => "Pengembalian {$trx['id_transaksi']} ({$trx['judul_buku']}) dicatat. Stok bertambah 1.",
            'data' => ambilSemuaState($pdo)
        ]);
    }

    if ($aksi === 'reset') {
        $pdo->beginTransaction();
        $pdo->exec('DELETE FROM peminjaman');
        $pdo->exec('DELETE FROM anggota');
        $pdo->exec('DELETE FROM buku');
        $pdo->commit();

        balas(true, [
            'pesan' => 'Seluruh data perpustakaan di database MySQL telah dikosongkan.',
            'data' => ambilSemuaState($pdo)
        ]);
    }

    balas(false, ['pesan' => 'Aksi API tidak dikenal.'], 404);
} catch (Throwable $e) {
    if (isset($pdo) && $pdo instanceof PDO && $pdo->inTransaction()) {
        $pdo->rollBack();
    }
    $detail = $e->getMessage();
    $pesan = 'Gagal terhubung ke MySQL XAMPP. Pastikan layanan MySQL aktif di XAMPP Control Panel.';
    if (stripos($detail, 'caching_sha2_password') !== false || stripos($detail, '1045') !== false) {
        $pesan = 'Port 3306 sedang dipakai layanan MySQL80 lain, bukan MariaDB XAMPP. Hentikan layanan MySQL80 di Services Windows lalu nyalakan MySQL di XAMPP.';
    }
    balas(false, ['pesan' => $pesan], 500);
}
