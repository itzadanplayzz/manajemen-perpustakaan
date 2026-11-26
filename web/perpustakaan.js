(function (root) {
  'use strict';

  function wajibTeks(nilai, namaField) {
    const teks = String(nilai == null ? '' : nilai).trim();
    if (!teks) {
      throw new Error(`${namaField} wajib diisi.`);
    }
    return teks;
  }

  function norm(nilai) {
    return String(nilai == null ? '' : nilai).trim().toLowerCase();
  }

  class Buku {
    constructor({ id, judul, penulis, stok }) {
      this.id = wajibTeks(id, 'ID buku');
      this.judul = wajibTeks(judul, 'Judul buku');
      this.penulis = wajibTeks(penulis, 'Penulis buku');
      const jumlah = Number(stok);
      if (!Number.isInteger(jumlah) || jumlah < 0) {
        throw new Error('Stok buku harus berupa bilangan bulat minimal 0.');
      }
      this.stok = jumlah;
    }

    get tersedia() {
      return this.stok > 0;
    }

    get statusKetersediaan() {
      return this.stok > 0 ? 'Tersedia' : 'Habis';
    }

    toJSON() {
      return {
        id: this.id,
        judul: this.judul,
        penulis: this.penulis,
        stok: this.stok
      };
    }
  }

  class Anggota {
    constructor({ id, nama }) {
      this.id = wajibTeks(id, 'ID anggota');
      this.nama = wajibTeks(nama, 'Nama anggota');
    }

    toJSON() {
      return { id: this.id, nama: this.nama };
    }
  }

  class Peminjaman {
    constructor({
      idTransaksi,
      idBuku,
      judulBuku,
      idAnggota,
      namaAnggota,
      tanggalPinjam,
      tanggalKembali = null,
      status = 'Dipinjam'
    }) {
      this.idTransaksi = wajibTeks(idTransaksi, 'ID transaksi');
      this.idBuku = wajibTeks(idBuku, 'ID buku');
      this.judulBuku = wajibTeks(judulBuku, 'Judul buku');
      this.idAnggota = wajibTeks(idAnggota, 'ID anggota');
      this.namaAnggota = wajibTeks(namaAnggota, 'Nama anggota');
      this.tanggalPinjam = tanggalPinjam || new Date().toISOString();
      this.tanggalKembali = tanggalKembali || null;
      this.status = status === 'Dikembalikan' ? 'Dikembalikan' : 'Dipinjam';
    }

    toJSON() {
      return {
        idTransaksi: this.idTransaksi,
        idBuku: this.idBuku,
        judulBuku: this.judulBuku,
        idAnggota: this.idAnggota,
        namaAnggota: this.namaAnggota,
        tanggalPinjam: this.tanggalPinjam,
        tanggalKembali: this.tanggalKembali,
        status: this.status
      };
    }
  }

  class Perpustakaan {
    constructor({ batasPinjaman = 3 } = {}) {
      const batas = Number(batasPinjaman);
      if (!Number.isInteger(batas) || batas < 1) {
        throw new Error('Batas pinjaman harus bilangan bulat minimal 1.');
      }
      this.batasPinjaman = batas;
      this.koleksiBuku = [];
      this.daftarAnggota = [];
      this.daftarPeminjaman = [];
      this._urutanTransaksi = 1;
    }

    tambahBuku({ id, judul, penulis, stok }) {
      const buku = new Buku({ id, judul, penulis, stok });
      if (this.cariBukuById(buku.id)) {
        throw new Error(`Buku dengan ID "${buku.id}" sudah terdaftar.`);
      }
      this.koleksiBuku.push(buku);
      return buku;
    }

    daftarBuku() {
      return this.koleksiBuku.slice();
    }

    cariBukuById(id) {
      const target = norm(id);
      if (!target) return null;
      return this.koleksiBuku.find(b => norm(b.id) === target) || null;
    }

    cariBuku(kataKunci = '') {
      const q = norm(kataKunci);
      if (!q) return this.daftarBuku();
      return this.koleksiBuku.filter(
        b => norm(b.id).includes(q) || norm(b.judul).includes(q)
      );
    }

    cekKetersediaan(idBuku) {
      const buku = this.cariBukuById(idBuku);
      if (!buku) {
        return {
          ditemukan: false,
          tersedia: false,
          stok: 0,
          status: 'Tidak ditemukan',
          buku: null
        };
      }
      return {
        ditemukan: true,
        tersedia: buku.tersedia,
        stok: buku.stok,
        status: buku.statusKetersediaan,
        buku
      };
    }

    _selesaikanAnggota({ idAnggota, namaAnggota }) {
      const idTeks = String(idAnggota == null ? '' : idAnggota).trim();
      const namaTeks = String(namaAnggota == null ? '' : namaAnggota).trim();

      if (!idTeks && !namaTeks) {
        throw new Error('Masukkan ID dan nama anggota peminjam.');
      }

      if (idTeks) {
        const terdaftar = this.daftarAnggota.find(a => norm(a.id) === norm(idTeks));
        if (terdaftar) {
          if (namaTeks && norm(terdaftar.nama) !== norm(namaTeks)) {
            throw new Error(
              `ID anggota "${terdaftar.id}" sudah tercatat atas nama "${terdaftar.nama}".`
            );
          }
          return terdaftar;
        }
        if (!namaTeks) {
          throw new Error(`Anggota dengan ID "${idTeks}" belum terdaftar. Isi nama anggota.`);
        }
        const baru = new Anggota({ id: idTeks, nama: namaTeks });
        this.daftarAnggota.push(baru);
        return baru;
      }

      const cocokNama = this.daftarAnggota.filter(a => norm(a.nama) === norm(namaTeks));
      if (cocokNama.length === 1) {
        return cocokNama[0];
      }
      if (cocokNama.length > 1) {
        throw new Error('Ditemukan lebih dari satu anggota bernama sama. Masukkan ID anggota.');
      }
      throw new Error('Anggota baru wajib menyertakan ID dan nama anggota.');
    }

    hitungPinjamanAktif(idAnggota) {
      const target = norm(idAnggota);
      if (!target) return 0;
      return this.daftarPeminjaman.filter(
        p => norm(p.idAnggota) === target && p.status === 'Dipinjam'
      ).length;
    }

    _buatIdTransaksi() {
      let kandidat;
      do {
        kandidat = `TRX-${String(this._urutanTransaksi).padStart(3, '0')}`;
        this._urutanTransaksi += 1;
      } while (this.daftarPeminjaman.some(p => norm(p.idTransaksi) === norm(kandidat)));
      return kandidat;
    }

    catatPeminjaman({ idBuku, idAnggota = '', namaAnggota = '' }) {
      const info = this.cekKetersediaan(idBuku);
      if (!info.ditemukan) {
        throw new Error(`Buku dengan ID "${String(idBuku || '').trim()}" tidak ditemukan.`);
      }
      if (!info.tersedia) {
        throw new Error(`Stok buku "${info.buku.judul}" habis, tidak dapat dipinjam.`);
      }

      const anggota = this._selesaikanAnggota({ idAnggota, namaAnggota });
      const aktif = this.hitungPinjamanAktif(anggota.id);
      if (aktif >= this.batasPinjaman) {
        throw new Error(
          `Batas pinjaman tercapai: ${anggota.nama} (${anggota.id}) sudah meminjam ${aktif} dari maksimal ${this.batasPinjaman} buku aktif.`
        );
      }

      info.buku.stok -= 1;
      const transaksi = new Peminjaman({
        idTransaksi: this._buatIdTransaksi(),
        idBuku: info.buku.id,
        judulBuku: info.buku.judul,
        idAnggota: anggota.id,
        namaAnggota: anggota.nama
      });
      this.daftarPeminjaman.unshift(transaksi);
      return transaksi;
    }

    catatPengembalian(idTransaksi) {
      const target = wajibTeks(idTransaksi, 'ID transaksi');
      const transaksi = this.daftarPeminjaman.find(
        p => norm(p.idTransaksi) === norm(target)
      );
      if (!transaksi) {
        throw new Error(`Transaksi "${target}" tidak tercatat. Pengembalian ditolak.`);
      }
      if (transaksi.status === 'Dikembalikan') {
        throw new Error(`Transaksi "${transaksi.idTransaksi}" sudah dikembalikan sebelumnya.`);
      }

      const buku = this.cariBukuById(transaksi.idBuku);
      if (buku) {
        buku.stok += 1;
      }
      transaksi.status = 'Dikembalikan';
      transaksi.tanggalKembali = new Date().toISOString();
      return transaksi;
    }

    daftarPeminjamanAktif() {
      return this.daftarPeminjaman.filter(p => p.status === 'Dipinjam');
    }

    toJSON() {
      return {
        batasPinjaman: this.batasPinjaman,
        urutanTransaksi: this._urutanTransaksi,
        koleksiBuku: this.koleksiBuku.map(b => b.toJSON()),
        daftarAnggota: this.daftarAnggota.map(a => a.toJSON()),
        daftarPeminjaman: this.daftarPeminjaman.map(p => p.toJSON())
      };
    }

    static fromJSON(data) {
      const perpus = new Perpustakaan({
        batasPinjaman: data && data.batasPinjaman ? data.batasPinjaman : 3
      });
      if (!data || typeof data !== 'object') return perpus;
      if (Array.isArray(data.koleksiBuku)) {
        perpus.koleksiBuku = data.koleksiBuku.map(b => new Buku(b));
      }
      if (Array.isArray(data.daftarAnggota)) {
        perpus.daftarAnggota = data.daftarAnggota.map(a => new Anggota(a));
      }
      if (Array.isArray(data.daftarPeminjaman)) {
        perpus.daftarPeminjaman = data.daftarPeminjaman.map(p => new Peminjaman(p));
      }
      const urutan = Number(data.urutanTransaksi);
      perpus._urutanTransaksi =
        Number.isInteger(urutan) && urutan > 0
          ? urutan
          : perpus.daftarPeminjaman.length + 1;
      return perpus;
    }
  }

  const exportsObj = { Buku, Anggota, Peminjaman, Perpustakaan };
  if (typeof module !== 'undefined' && module.exports) {
    module.exports = exportsObj;
  } else {
    root.PerpustakaanDomain = exportsObj;
  }
})(typeof window !== 'undefined' ? window : globalThis);
