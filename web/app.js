(function () {
  'use strict';

  const STORAGE_THEME = 'arsip_pustaka_theme_v1';
  const API_URL =
    window.location.protocol === 'file:'
      ? 'http://localhost/manajemen_perpustakaan/api.php'
      : 'api.php';
  const { Perpustakaan } = window.PerpustakaanDomain;

  const $ = id => document.getElementById(id);

  let perpus = new Perpustakaan({ batasPinjaman: 3 });
  let sedangSinkron = false;

  const el = {
    html: document.documentElement,
    menuToggle: $('menu-toggle'),
    navUtama: $('nav-utama'),
    themeToggle: $('theme-toggle'),
    themeLabel: $('theme-label'),
    statJudul: $('stat-judul'),
    statStok: $('stat-stok'),
    statPinjam: $('stat-pinjam'),
    statBatas: $('stat-batas'),
    statusBanner: $('status-banner'),
    errorBanner: $('error-banner'),
    errorBannerText: $('error-banner-text'),
    btnMuatUlang: $('btn-muat-ulang'),
    loadingState: $('loading-state'),
    cariBuku: $('cari-buku'),
    filterStok: $('filter-stok'),
    katalogKosong: $('katalog-kosong'),
    katalogKosongPesan: $('katalog-kosong-pesan'),
    katalogKosongDetail: $('katalog-kosong-detail'),
    btnKeTambah: $('btn-ke-tambah'),
    btnMuatContoh: $('btn-muat-contoh'),
    btnResetCari: $('btn-reset-cari'),
    tabelKatalogWrap: $('tabel-katalog-wrap'),
    tbodyKatalog: $('tbody-katalog'),
    tabs: Array.from(document.querySelectorAll('[role="tab"]')),
    tabPanels: Array.from(document.querySelectorAll('[role="tabpanel"]')),
    formPinjam: $('form-pinjam'),
    pinjamIdBuku: $('pinjam-id-buku'),
    pinjamIdAnggota: $('pinjam-id-anggota'),
    pinjamNamaAnggota: $('pinjam-nama-anggota'),
    cekStokInfo: $('cek-stok-info'),
    cekKuotaInfo: $('cek-kuota-info'),
    pinjamError: $('pinjam-error'),
    formKembali: $('form-kembali'),
    kembaliIdTransaksi: $('kembali-id-transaksi'),
    kembaliError: $('kembali-error'),
    formTambah: $('form-tambah'),
    bukuId: $('buku-id'),
    bukuJudul: $('buku-judul'),
    bukuPenulis: $('buku-penulis'),
    bukuStok: $('buku-stok'),
    tambahError: $('tambah-error'),
    datalistBuku: $('datalist-buku'),
    datalistAnggota: $('datalist-anggota'),
    datalistTransaksi: $('datalist-transaksi'),
    filterTransaksi: $('filter-transaksi'),
    transaksiKosong: $('transaksi-kosong'),
    tabelTransaksiWrap: $('tabel-transaksi-wrap'),
    tbodyTransaksi: $('tbody-transaksi'),
    anggotaKosong: $('anggota-kosong'),
    tabelAnggotaWrap: $('tabel-anggota-wrap'),
    tbodyAnggota: $('tbody-anggota'),
    btnBukaReset: $('btn-buka-reset'),
    dialogReset: $('dialog-reset'),
    btnBatalReset: $('btn-batal-reset'),
    btnKonfirmasiReset: $('btn-konfirmasi-reset')
  };

  async function panggilApi(aksi, payload = null) {
    const opsi = payload === null
      ? { method: 'GET', cache: 'no-store' }
      : {
          method: 'POST',
          cache: 'no-store',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        };

    let res;
    try {
      res = await fetch(`${API_URL}?aksi=${encodeURIComponent(aksi)}`, opsi);
    } catch (_) {
      throw new Error(
        'Tidak dapat terhubung ke server XAMPP (Apache/MySQL). Jalankan Apache & MySQL, lalu buka http://localhost/manajemen_perpustakaan/.'
      );
    }

    let body;
    try {
      body = await res.json();
    } catch (_) {
      throw new Error('Respons server PHP tidak valid. Periksa konfigurasi XAMPP.');
    }

    if (!res.ok || !body.status) {
      throw new Error(body.pesan || 'Permintaan ke database gagal diproses.');
    }
    return body;
  }

  async function muatDariServer() {
    el.loadingState.hidden = false;
    el.errorBanner.hidden = true;
    try {
      const hasil = await panggilApi('state');
      perpus = Perpustakaan.fromJSON(hasil.data);
      renderSemua();
    } catch (err) {
      tampilErrorGlobal(err.message);
      renderSemua();
    } finally {
      el.loadingState.hidden = true;
    }
  }

  function tampilStatus(pesan) {
    el.errorBanner.hidden = true;
    el.statusBanner.textContent = '';
    requestAnimationFrame(() => {
      el.statusBanner.textContent = pesan;
      el.statusBanner.hidden = false;
    });
  }

  function tampilErrorGlobal(pesan) {
    el.errorBannerText.textContent = pesan;
    el.errorBanner.hidden = false;
  }

  function aturTema(tema) {
    const mode = tema === 'dark' ? 'dark' : 'light';
    el.html.setAttribute('data-theme', mode);
    el.themeToggle.setAttribute('aria-pressed', String(mode === 'dark'));
    el.themeLabel.textContent = mode === 'dark' ? 'Mode Terang' : 'Mode Gelap';
    try {
      localStorage.setItem(STORAGE_THEME, mode);
    } catch (_) {
      // Ignore storage failure for non-critical theme preference.
    }
  }

  function aktifkanTab(tabId, fokusKontrol) {
    el.tabs.forEach(tab => {
      const aktif = tab.id === tabId;
      tab.setAttribute('aria-selected', String(aktif));
      tab.tabIndex = aktif ? 0 : -1;
    });
    el.tabPanels.forEach(panel => {
      const aktif = panel.getAttribute('aria-labelledby') === tabId;
      panel.hidden = !aktif;
    });
    if (fokusKontrol) {
      const target = $(fokusKontrol);
      if (target) target.focus();
    }
  }

  function formatTanggal(iso) {
    try {
      const normalized = String(iso).includes(' ') && !String(iso).includes('T')
        ? String(iso).replace(' ', 'T')
        : iso;
      return new Date(normalized).toLocaleString('id-ID', {
        day: '2-digit',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch (_) {
      return iso;
    }
  }

  function perbaruiRingkasan() {
    const semua = perpus.daftarBuku();
    const totalStok = semua.reduce((acc, b) => acc + b.stok, 0);
    el.statJudul.textContent = String(semua.length);
    el.statStok.textContent = String(totalStok);
    el.statPinjam.textContent = String(perpus.daftarPeminjamanAktif().length);
    el.statBatas.textContent = `${perpus.batasPinjaman} buku / anggota`;
  }

  function perbaruiDatalist() {
    el.datalistBuku.replaceChildren(
      ...perpus.daftarBuku().map(b => {
        const opt = document.createElement('option');
        opt.value = b.id;
        opt.label = `${b.judul} (Stok: ${b.stok})`;
        return opt;
      })
    );
    el.datalistAnggota.replaceChildren(
      ...perpus.daftarAnggota.map(a => {
        const opt = document.createElement('option');
        opt.value = a.id;
        opt.label = a.nama;
        return opt;
      })
    );
    el.datalistTransaksi.replaceChildren(
      ...perpus.daftarPeminjamanAktif().map(p => {
        const opt = document.createElement('option');
        opt.value = p.idTransaksi;
        opt.label = `${p.judulBuku} - ${p.namaAnggota}`;
        return opt;
      })
    );
  }

  function perbaruiInfoStok() {
    const idBuku = el.pinjamIdBuku.value.trim();
    el.cekStokInfo.className = 'check-readout';
    if (!idBuku) {
      el.cekStokInfo.textContent = 'Masukkan ID buku untuk memeriksa ketersediaan stok.';
      return;
    }
    const hasil = perpus.cekKetersediaan(idBuku);
    if (!hasil.ditemukan) {
      el.cekStokInfo.classList.add('is-err');
      el.cekStokInfo.textContent = `Buku dengan ID "${idBuku}" tidak ditemukan di katalog.`;
      return;
    }
    if (hasil.tersedia) {
      el.cekStokInfo.classList.add('is-ok');
      el.cekStokInfo.textContent = `Tersedia: ${hasil.stok} eksemplar (${hasil.buku.judul}).`;
    } else {
      el.cekStokInfo.classList.add('is-err');
      el.cekStokInfo.textContent = `Stok habis: 0 eksemplar (${hasil.buku.judul}). Peminjaman ditolak.`;
    }
  }

  function perbaruiInfoKuota() {
    const idAnggota = el.pinjamIdAnggota.value.trim();
    const namaInput = el.pinjamNamaAnggota.value.trim();
    el.cekKuotaInfo.className = 'check-readout';

    let anggota = null;
    if (idAnggota) {
      anggota = perpus.daftarAnggota.find(
        a => a.id.toLowerCase() === idAnggota.toLowerCase()
      );
      if (anggota && !namaInput) {
        el.pinjamNamaAnggota.value = anggota.nama;
      }
    } else if (namaInput) {
      const cocok = perpus.daftarAnggota.filter(
        a => a.nama.toLowerCase() === namaInput.toLowerCase()
      );
      if (cocok.length === 1) anggota = cocok[0];
    }

    if (!anggota) {
      el.cekKuotaInfo.textContent = `Maksimal ${perpus.batasPinjaman} buku aktif per anggota.`;
      return;
    }

    const aktif = perpus.hitungPinjamanAktif(anggota.id);
    if (aktif >= perpus.batasPinjaman) {
      el.cekKuotaInfo.classList.add('is-err');
      el.cekKuotaInfo.textContent = `Kuota penuh: ${anggota.nama} (${anggota.id}) meminjam ${aktif} dari ${perpus.batasPinjaman} buku.`;
    } else {
      el.cekKuotaInfo.classList.add('is-warn');
      el.cekKuotaInfo.textContent = `Pinjaman aktif ${anggota.nama} (${anggota.id}): ${aktif} dari ${perpus.batasPinjaman} buku.`;
    }
  }

  function renderKatalog() {
    const kataKunci = el.cariBuku.value.trim();
    const filter = el.filterStok.value;
    const semua = perpus.daftarBuku();
    const hasil = perpus.cariBuku(kataKunci).filter(b => {
      if (filter === 'tersedia') return b.tersedia;
      if (filter === 'habis') return !b.tersedia;
      return true;
    });

    if (hasil.length === 0) {
      el.tabelKatalogWrap.hidden = true;
      el.katalogKosong.hidden = false;

      if (semua.length === 0) {
        el.katalogKosongPesan.textContent = 'Belum ada buku di katalog.';
        el.katalogKosongDetail.textContent =
          'Tambahkan buku melalui formulir Tambah Buku, atau muat contoh data uji untuk langsung mencoba alur peminjaman.';
        el.btnKeTambah.hidden = false;
        el.btnMuatContoh.hidden = false;
        el.btnResetCari.hidden = true;
      } else {
        el.katalogKosongPesan.textContent = 'Tidak ada buku yang cocok dengan pencarian.';
        el.katalogKosongDetail.textContent =
          'Periksa ejaan ID atau judul buku, atau reset filter untuk menampilkan seluruh koleksi.';
        el.btnKeTambah.hidden = true;
        el.btnMuatContoh.hidden = true;
        el.btnResetCari.hidden = false;
      }
      return;
    }

    el.katalogKosong.hidden = true;
    el.tabelKatalogWrap.hidden = false;

    const baris = hasil.map(buku => {
      const tr = document.createElement('tr');

      const tdId = document.createElement('td');
      tdId.dataset.label = 'ID';
      const spanId = document.createElement('span');
      spanId.className = 'code-id';
      spanId.textContent = buku.id;
      tdId.appendChild(spanId);

      const tdInfo = document.createElement('td');
      tdInfo.dataset.label = 'Judul dan Penulis';
      const spanJudul = document.createElement('span');
      spanJudul.className = 'book-title';
      spanJudul.textContent = buku.judul;
      const spanPenulis = document.createElement('span');
      spanPenulis.className = 'book-author';
      spanPenulis.textContent = buku.penulis;
      tdInfo.append(spanJudul, spanPenulis);

      const tdStok = document.createElement('td');
      tdStok.dataset.label = 'Stok';
      tdStok.textContent = `${buku.stok} eks.`;

      const tdStatus = document.createElement('td');
      tdStatus.dataset.label = 'Status';
      const badge = document.createElement('span');
      badge.className = `status-tag ${buku.tersedia ? 'status-ok' : 'status-habis'}`;
      badge.textContent = buku.statusKetersediaan;
      tdStatus.appendChild(badge);

      const tdAksi = document.createElement('td');
      tdAksi.dataset.label = 'Aksi';
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'btn btn-secondary btn-sm';
      btn.textContent = buku.tersedia ? 'Pinjam' : 'Stok Habis';
      btn.disabled = !buku.tersedia;
      btn.addEventListener('click', () => {
        aktifkanTab('tab-pinjam', 'pinjam-id-anggota');
        el.pinjamIdBuku.value = buku.id;
        perbaruiInfoStok();
        const sirkulasiPanel = $('sirkulasi');
        if (window.innerWidth <= 980 && sirkulasiPanel) {
          sirkulasiPanel.scrollIntoView({ behavior: 'auto', block: 'start' });
        }
      });
      tdAksi.appendChild(btn);

      tr.append(tdId, tdInfo, tdStok, tdStatus, tdAksi);
      return tr;
    });

    el.tbodyKatalog.replaceChildren(...baris);
  }

  function renderTransaksi() {
    const filter = el.filterTransaksi.value;
    const daftar = perpus.daftarPeminjaman.filter(
      p => filter === 'semua' || p.status === filter
    );

    if (daftar.length === 0) {
      el.tabelTransaksiWrap.hidden = true;
      el.transaksiKosong.hidden = false;
      return;
    }

    el.transaksiKosong.hidden = true;
    el.tabelTransaksiWrap.hidden = false;

    const baris = daftar.map(trx => {
      const tr = document.createElement('tr');

      const tdId = document.createElement('td');
      tdId.dataset.label = 'ID Transaksi';
      const spanId = document.createElement('span');
      spanId.className = 'code-id';
      spanId.textContent = trx.idTransaksi;
      tdId.appendChild(spanId);

      const tdBuku = document.createElement('td');
      tdBuku.dataset.label = 'Buku';
      const spanJudul = document.createElement('span');
      spanJudul.className = 'book-title';
      spanJudul.textContent = trx.judulBuku;
      const spanKode = document.createElement('span');
      spanKode.className = 'sub-meta code-id';
      spanKode.textContent = trx.idBuku;
      tdBuku.append(spanJudul, spanKode);

      const tdAnggota = document.createElement('td');
      tdAnggota.dataset.label = 'Anggota';
      const spanNama = document.createElement('span');
      spanNama.className = 'book-title';
      spanNama.textContent = trx.namaAnggota;
      const spanAid = document.createElement('span');
      spanAid.className = 'sub-meta code-id';
      spanAid.textContent = trx.idAnggota;
      tdAnggota.append(spanNama, spanAid);

      const tdWaktu = document.createElement('td');
      tdWaktu.dataset.label = 'Waktu';
      const spanPinjam = document.createElement('span');
      spanPinjam.textContent = `Pinjam: ${formatTanggal(trx.tanggalPinjam)}`;
      tdWaktu.appendChild(spanPinjam);
      if (trx.tanggalKembali) {
        const spanKembali = document.createElement('span');
        spanKembali.className = 'sub-meta';
        spanKembali.textContent = `Kembali: ${formatTanggal(trx.tanggalKembali)}`;
        tdWaktu.appendChild(spanKembali);
      }

      const tdStatus = document.createElement('td');
      tdStatus.dataset.label = 'Status';
      const badge = document.createElement('span');
      badge.className = `status-tag ${trx.status === 'Dipinjam' ? 'status-pinjam' : 'status-ok'}`;
      badge.textContent = trx.status;
      tdStatus.appendChild(badge);

      const tdAksi = document.createElement('td');
      tdAksi.dataset.label = 'Aksi';
      if (trx.status === 'Dipinjam') {
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'btn btn-primary btn-sm';
        btn.textContent = 'Kembalikan';
        btn.addEventListener('click', () => prosesPengembalian(trx.idTransaksi));
        tdAksi.appendChild(btn);
      } else {
        const spanSelesai = document.createElement('span');
        spanSelesai.className = 'sub-meta';
        spanSelesai.textContent = 'Selesai';
        tdAksi.appendChild(spanSelesai);
      }

      tr.append(tdId, tdBuku, tdAnggota, tdWaktu, tdStatus, tdAksi);
      return tr;
    });

    el.tbodyTransaksi.replaceChildren(...baris);
  }

  function renderAnggota() {
    if (perpus.daftarAnggota.length === 0) {
      el.tabelAnggotaWrap.hidden = true;
      el.anggotaKosong.hidden = false;
      return;
    }

    el.anggotaKosong.hidden = true;
    el.tabelAnggotaWrap.hidden = false;

    const baris = perpus.daftarAnggota.map(a => {
      const tr = document.createElement('tr');
      const aktif = perpus.hitungPinjamanAktif(a.id);

      const tdId = document.createElement('td');
      tdId.dataset.label = 'ID Anggota';
      const spanId = document.createElement('span');
      spanId.className = 'code-id';
      spanId.textContent = a.id;
      tdId.appendChild(spanId);

      const tdNama = document.createElement('td');
      tdNama.dataset.label = 'Nama';
      tdNama.textContent = a.nama;

      const tdKuota = document.createElement('td');
      tdKuota.dataset.label = 'Pinjaman Aktif';
      const badge = document.createElement('span');
      badge.className = `status-tag ${aktif >= perpus.batasPinjaman ? 'status-habis' : 'status-ok'}`;
      badge.textContent = `${aktif} / ${perpus.batasPinjaman} buku`;
      tdKuota.appendChild(badge);

      tr.append(tdId, tdNama, tdKuota);
      return tr;
    });

    el.tbodyAnggota.replaceChildren(...baris);
  }

  function renderSemua() {
    perbaruiRingkasan();
    perbaruiDatalist();
    renderKatalog();
    renderTransaksi();
    renderAnggota();
    perbaruiInfoStok();
    perbaruiInfoKuota();
  }

  function tampilErrorForm(elemen, inputUtama, pesan) {
    elemen.textContent = pesan;
    elemen.hidden = false;
    if (inputUtama) {
      inputUtama.setAttribute('aria-invalid', 'true');
      inputUtama.focus();
    }
  }

  function bersihkanErrorForm(elemen, inputs) {
    elemen.hidden = true;
    elemen.textContent = '';
    inputs.forEach(inp => inp.removeAttribute('aria-invalid'));
  }

  async function prosesPengembalian(idTransaksi) {
    bersihkanErrorForm(el.kembaliError, [el.kembaliIdTransaksi]);
    try {
      const hasil = await panggilApi('kembali', { idTransaksi });
      perpus = Perpustakaan.fromJSON(hasil.data);
      el.formKembali.reset();
      renderSemua();
      tampilStatus(hasil.pesan);
    } catch (err) {
      tampilErrorForm(el.kembaliError, el.kembaliIdTransaksi, err.message);
    }
  }

  async function muatContohKatalog() {
    try {
      const hasil = await panggilApi('muat_contoh', {});
      perpus = Perpustakaan.fromJSON(hasil.data);
      renderSemua();
      tampilStatus(hasil.pesan);
    } catch (err) {
      tampilErrorGlobal(err.message);
    }
  }

  function bindEvents() {
    el.themeToggle.addEventListener('click', () => {
      const sekarang = el.html.getAttribute('data-theme');
      aturTema(sekarang === 'dark' ? 'light' : 'dark');
    });

    el.btnMuatUlang.addEventListener('click', muatDariServer);

    el.menuToggle.addEventListener('click', () => {
      const terbuka = el.navUtama.classList.toggle('is-open');
      el.menuToggle.setAttribute('aria-expanded', String(terbuka));
    });

    el.navUtama.querySelectorAll('a').forEach(link => {
      link.addEventListener('click', () => {
        if (el.navUtama.classList.contains('is-open')) {
          el.navUtama.classList.remove('is-open');
          el.menuToggle.setAttribute('aria-expanded', 'false');
        }
      });
    });

    document.addEventListener('keydown', e => {
      if (e.key === 'Escape' && el.navUtama.classList.contains('is-open')) {
        el.navUtama.classList.remove('is-open');
        el.menuToggle.setAttribute('aria-expanded', 'false');
        el.menuToggle.focus();
      }
    });

    el.tabs.forEach((tab, idx) => {
      tab.addEventListener('click', () => aktifkanTab(tab.id));
      tab.addEventListener('keydown', e => {
        let targetIdx = idx;
        if (e.key === 'ArrowRight') targetIdx = (idx + 1) % el.tabs.length;
        else if (e.key === 'ArrowLeft') targetIdx = (idx - 1 + el.tabs.length) % el.tabs.length;
        else if (e.key === 'Home') targetIdx = 0;
        else if (e.key === 'End') targetIdx = el.tabs.length - 1;
        else return;
        e.preventDefault();
        aktifkanTab(el.tabs[targetIdx].id, el.tabs[targetIdx].id);
      });
    });

    el.cariBuku.addEventListener('input', renderKatalog);
    el.filterStok.addEventListener('change', renderKatalog);
    el.filterTransaksi.addEventListener('change', renderTransaksi);

    el.btnKeTambah.addEventListener('click', () => {
      aktifkanTab('tab-tambah', 'buku-id');
      const sirkulasiPanel = $('sirkulasi');
      if (window.innerWidth <= 980 && sirkulasiPanel) {
        sirkulasiPanel.scrollIntoView({ behavior: 'auto', block: 'start' });
      }
    });
    el.btnMuatContoh.addEventListener('click', muatContohKatalog);
    el.btnResetCari.addEventListener('click', () => {
      el.cariBuku.value = '';
      el.filterStok.value = 'semua';
      renderKatalog();
      el.cariBuku.focus();
    });

    el.pinjamIdBuku.addEventListener('input', perbaruiInfoStok);
    el.pinjamIdAnggota.addEventListener('input', perbaruiInfoKuota);
    el.pinjamNamaAnggota.addEventListener('input', perbaruiInfoKuota);

    el.formPinjam.addEventListener('submit', async e => {
      e.preventDefault();
      bersihkanErrorForm(el.pinjamError, [el.pinjamIdBuku, el.pinjamIdAnggota, el.pinjamNamaAnggota]);
      try {
        // Run domain check locally first to give immediate validation before the HTTP request.
        const salinan = Perpustakaan.fromJSON(perpus.toJSON());
        salinan.catatPeminjaman({
          idBuku: el.pinjamIdBuku.value,
          idAnggota: el.pinjamIdAnggota.value,
          namaAnggota: el.pinjamNamaAnggota.value
        });

        const hasil = await panggilApi('pinjam', {
          idBuku: el.pinjamIdBuku.value,
          idAnggota: el.pinjamIdAnggota.value,
          namaAnggota: el.pinjamNamaAnggota.value
        });
        perpus = Perpustakaan.fromJSON(hasil.data);
        el.formPinjam.reset();
        renderSemua();
        tampilStatus(hasil.pesan);
      } catch (err) {
        let target = el.pinjamIdAnggota;
        if (!el.pinjamIdBuku.value.trim() || /buku|stok/i.test(err.message)) {
          target = el.pinjamIdBuku;
        } else if (el.pinjamIdAnggota.value.trim() && !el.pinjamNamaAnggota.value.trim()) {
          target = el.pinjamNamaAnggota;
        }
        tampilErrorForm(el.pinjamError, target, err.message);
      }
    });

    el.formKembali.addEventListener('submit', e => {
      e.preventDefault();
      prosesPengembalian(el.kembaliIdTransaksi.value);
    });

    el.formTambah.addEventListener('submit', async e => {
      e.preventDefault();
      bersihkanErrorForm(el.tambahError, [el.bukuId, el.bukuJudul, el.bukuPenulis, el.bukuStok]);
      try {
        const stokVal = el.bukuStok.value === '' ? -1 : Number(el.bukuStok.value);
        const salinan = Perpustakaan.fromJSON(perpus.toJSON());
        salinan.tambahBuku({
          id: el.bukuId.value,
          judul: el.bukuJudul.value,
          penulis: el.bukuPenulis.value,
          stok: stokVal
        });

        const hasil = await panggilApi('tambah_buku', {
          id: el.bukuId.value,
          judul: el.bukuJudul.value,
          penulis: el.bukuPenulis.value,
          stok: stokVal
        });
        perpus = Perpustakaan.fromJSON(hasil.data);
        el.formTambah.reset();
        renderSemua();
        tampilStatus(hasil.pesan);
      } catch (err) {
        let target = el.bukuId;
        if (el.bukuId.value.trim() && !el.bukuJudul.value.trim()) target = el.bukuJudul;
        else if (el.bukuJudul.value.trim() && !el.bukuPenulis.value.trim()) target = el.bukuPenulis;
        else if (/stok/i.test(err.message)) target = el.bukuStok;
        tampilErrorForm(el.tambahError, target, err.message);
      }
    });

    el.btnBukaReset.addEventListener('click', () => {
      if (typeof el.dialogReset.showModal === 'function') {
        el.dialogReset.showModal();
      }
    });

    el.btnBatalReset.addEventListener('click', () => el.dialogReset.close());
    el.btnKonfirmasiReset.addEventListener('click', async () => {
      try {
        const hasil = await panggilApi('reset', {});
        perpus = Perpustakaan.fromJSON(hasil.data);
        el.dialogReset.close();
        renderSemua();
        tampilStatus(hasil.pesan);
      } catch (err) {
        el.dialogReset.close();
        tampilErrorGlobal(err.message);
      }
    });
  }

  function ringkasState(p) {
    return JSON.stringify({
      b: p.koleksiBuku.map(x => [x.id, x.judul, x.penulis, x.stok]),
      a: p.daftarAnggota.map(x => [x.id, x.nama]),
      p: p.daftarPeminjaman.map(x => [x.idTransaksi, x.status, x.tanggalKembali])
    });
  }

  async function sinkronDiam() {
    if (sedangSinkron || document.visibilityState !== 'visible' || el.dialogReset.open) {
      return;
    }
    sedangSinkron = true;
    try {
      const hasil = await panggilApi('state');
      const baru = Perpustakaan.fromJSON(hasil.data);
      if (ringkasState(perpus) !== ringkasState(baru) || !el.errorBanner.hidden) {
        perpus = baru;
        el.errorBanner.hidden = true;
        renderSemua();
      }
    } catch (_) {
      // Skip noisy error banner updates during silent background sync.
    } finally {
      sedangSinkron = false;
    }
  }

  function init() {
    let temaAwal = 'light';
    try {
      const simpanTema = localStorage.getItem(STORAGE_THEME);
      if (simpanTema === 'dark' || simpanTema === 'light') {
        temaAwal = simpanTema;
      }
    } catch (_) {
      // Fall back to light paper theme when storage is blocked.
    }
    aturTema(temaAwal);
    bindEvents();
    muatDariServer();
    window.addEventListener('focus', sinkronDiam);
    document.addEventListener('visibilitychange', () => {
      if (document.visibilityState === 'visible') sinkronDiam();
    });
    setInterval(sinkronDiam, 5000);
  }

  init();
})();
