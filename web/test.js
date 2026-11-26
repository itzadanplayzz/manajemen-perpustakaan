const assert = require('node:assert/strict');
const { Buku, Anggota, Peminjaman, Perpustakaan } = require('./perpustakaan.js');

function runTests() {
  const perpus = new Perpustakaan({ batasPinjaman: 2 });

  const b1 = perpus.tambahBuku({
    id: 'BK-001',
    judul: 'Bumi Manusia',
    penulis: 'Pramoedya Ananta Toer',
    stok: 2
  });
  const b2 = perpus.tambahBuku({
    id: 'BK-002',
    judul: 'Filosofi Teras',
    penulis: 'Henry Manampiring',
    stok: 1
  });
  const b3 = perpus.tambahBuku({
    id: 'BK-003',
    judul: 'Negeri 5 Menara',
    penulis: 'Ahmad Fuadi',
    stok: 0
  });

  assert.ok(b1 instanceof Buku);
  assert.equal(b1.statusKetersediaan, 'Tersedia');
  assert.equal(b3.statusKetersediaan, 'Habis');
  assert.equal(perpus.daftarBuku().length, 3);

  assert.throws(
    () => perpus.tambahBuku({ id: 'bk-001', judul: 'Duplikat', penulis: 'Anon', stok: 1 }),
    /sudah terdaftar/
  );
  assert.throws(
    () => perpus.tambahBuku({ id: 'BK-999', judul: 'Negatif', penulis: 'Anon', stok: -1 }),
    /minimal 0/
  );

  assert.equal(perpus.cariBuku('BK-002').length, 1);
  assert.equal(perpus.cariBuku('bumi').length, 1);
  assert.equal(perpus.cariBuku('tidak ada').length, 0);

  assert.equal(perpus.cekKetersediaan('BK-001').tersedia, true);
  assert.equal(perpus.cekKetersediaan('BK-003').tersedia, false);
  assert.equal(perpus.cekKetersediaan('BK-404').ditemukan, false);

  assert.throws(
    () => perpus.catatPeminjaman({ idBuku: 'BK-003', idAnggota: 'A-01', namaAnggota: 'Sari' }),
    /stok.*habis/i
  );

  const trx1 = perpus.catatPeminjaman({
    idBuku: 'BK-001',
    idAnggota: 'A-01',
    namaAnggota: 'Sari'
  });
  assert.ok(trx1 instanceof Peminjaman);
  assert.equal(b1.stok, 1);
  assert.equal(perpus.daftarAnggota[0] instanceof Anggota, true);

  const trx2 = perpus.catatPeminjaman({
    idBuku: 'BK-002',
    idAnggota: 'A-01'
  });
  assert.equal(trx2.namaAnggota, 'Sari');
  assert.equal(b2.stok, 0);
  assert.equal(b2.statusKetersediaan, 'Habis');

  assert.throws(
    () => perpus.catatPeminjaman({ idBuku: 'BK-001', idAnggota: 'A-01', namaAnggota: 'Sari' }),
    /Batas pinjaman tercapai/
  );

  assert.throws(
    () => perpus.catatPengembalian('TRX-999'),
    /tidak tercatat/
  );

  const kembali = perpus.catatPengembalian(trx2.idTransaksi);
  assert.equal(kembali.status, 'Dikembalikan');
  assert.equal(b2.stok, 1);
  assert.equal(b2.statusKetersediaan, 'Tersedia');

  assert.throws(
    () => perpus.catatPengembalian(trx2.idTransaksi),
    /sudah dikembalikan/
  );

  const trx3 = perpus.catatPeminjaman({
    idBuku: 'BK-002',
    namaAnggota: 'Sari'
  });
  assert.equal(trx3.idAnggota, 'A-01');
  assert.equal(perpus.hitungPinjamanAktif('A-01'), 2);

  const pulih = Perpustakaan.fromJSON(JSON.parse(JSON.stringify(perpus.toJSON())));
  assert.equal(pulih.daftarBuku().length, 3);
  assert.equal(pulih.daftarPeminjamanAktif().length, 2);
  assert.equal(pulih.batasPinjaman, 2);

  console.log('Semua pengujian domain Perpustakaan lulus.');
}

runTests();
