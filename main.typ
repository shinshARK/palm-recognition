#import "@preview/typslides:1.2.6": *

// Konfigurasi Proyek
#show: typslides.with(
  ratio: "16-9",
  theme: "bluey",
  font: "Fira Sans",
  link-style: "color",
)

// Slide Judul
#front-slide(
  title: "Pengenalan Telapak Tangan Menggunakan Jaringan Siamese",
  subtitle: [Pendekatan Deep Learning untuk Identifikasi Biometrik],
  authors: "Jidan Abdurahman Aufan, 2205422\nJason Suryoatmojo, 2204524",
  info: [Financial Technology, 22 September 2025],
)

// Daftar Isi
#table-of-contents()

// Slide pemisah untuk memulai bagian baru
#title-slide[
  Pendahuluan & Tujuan Proyek
]

#slide(title: "Latar Belakang: Identifikasi yang Aman")[
  - Pengenalan biometrik adalah landasan keamanan modern, mulai dari membuka kunci ponsel hingga otorisasi transaksi finansial.
  - Sidik telapak tangan menawarkan sumber fitur unik yang kaya, menjadikannya kandidat yang sangat baik untuk identifikasi yang kuat.
  - *Tujuan Proyek:* Membangun dan melatih model machine learning yang mampu mengenali individu secara akurat dari gambar telapak tangan mereka, yang diambil menggunakan kamera ponsel.
]

#slide(title: "Dataset yang Digunakan")[
  #cols(columns: (1fr, 1fr))[
    - Dua dataset utama digunakan untuk melatih dan mengevaluasi model:
      - *Sapienza University Mobile Palmprint Database (SMPD)*
      - *Birjand University Mobile Palmprint Database (BMPD)*
    - Kedua dataset ini menyediakan ribuan gambar dari lebih dari 100 subjek, yang menjadi data utama untuk proyek ini.
  ][
#figure(
  image("images/Screenshot 2025-09-21 205427.png", width: 80%, height: 200pt),
  caption: [Contoh gambar telapak tangan dari dataset SMPD.]
)
  ]
]

#title-slide[
  Metodologi & Alur Kerja
]

#slide(title: "Ekstraksi ROI: Pendekatan Awal (Valley Points)")[
  - Pendekatan awal untuk ekstraksi ROI adalah dengan metode _valley-point_. Tujuannya adalah untuk menemukan titik-titik kunci (sela-sela jari) sebagai patokan.
  - *Proses Kerja:*
    - Membuat _silhouette_ tangan dari image.
    - Mendeteksi _contour_ terbesar untuk mengambil bentuk tangan.
    - Mendeteksi _defect_ berdasarkan sudut dan posisi untuk memilih kandidat _valley_ yang relevan (sela jari).
    - Menetapkan ROI berdasarkan sela jari Kelingking-Manis dan sela jari Telunjuk-Tengah
  - *Kelemahan:* Metode ini terbukti #reddy("tidak stabil dan sering gagal") (_unreliable_) pada dataset yang digunakan, karena adanya variasi posisi tangan, pencahayaan, juga beberapa tidak menyebarkan jari nya sehingga sela jari sulit dideteksi.
]

#slide(title: "Visualisasi Proses: Pendekatan Key Points")[
 
  #v(1em) // Memberi sedikit spasi vertikal
#figure(
  image("image.png", width: 100%, height: 150pt),
  caption: [Contoh visualisasi Pendekatan Valley-point.]
)
  #align(center)[
    Visualisasi langkah-langkah pemrosesan: dari *silhouette*, *contour*, deteksi *key points*, *baseline*, hingga ekstraksi *ROI* akhir.
  ]
]

#slide(title: "Ekstraksi ROI: Pendekatan Final (Centroid)")[
  - Karena metode _valley-point_ tidak stabil, pendekatan yang lebih robust dan konsisten digunakan.
  - Metode ini berfokus pada titik pusat (centroid) dari kontur telapak tangan untuk ekstraksi langsung.
  - *Proses Kerja:*
    - Menemukan kontur tangan yang bersih.
    - Menghitung titik pusat geometris (centroid) dari kontur.
    - Memotong area besar (misalnya, 1000x1000 piksel) yang berpusat pada centroid.
    - Menormalisasi ukuran ROI ke dimensi standar yang dibutuhkan model (150x150).
]

#slide(title: "Visualisasi Proses: Pendekatan Centroid")[
  // Mengganti placeholder dengan grid 5 kolom untuk setiap langkah
 #figure(
  image("images/Screenshot 2025-09-21 215427.png", width: 100%, height: 150pt),
  caption: [Contoh visualisasi pendekatan centroid]
)

  #v(1em) // Memberi sedikit spasi vertikal

  #align(center)[
    Visualisasi untuk metode berbasis *centroid*, yang terbukti lebih stabil dalam menemukan area telapak tangan.
  ]
]

#slide(title: "Arsitektur Jaringan Siamese")[
    - *Jaringan Siamese* digunakan karena ideal untuk tugas pengenalan.
    - Arsitektur ini menggunakan dua "jaringan dasar" yang identik dan berbagi bobot (_weights_).
    - Setiap jaringan mengubah gambar menjadi sebuah *vektor fitur* (embedding) numerik.
    - Tujuan model adalah untuk mempelajari ruang fitur di mana vektor dari #greeny("orang yang sama") menjadi berdekatan, dan vektor dari #reddy("orang yang berbeda") menjadi berjauhan.
]

#slide(title: "Proses Pelatihan")[
  - *Fungsi Loss:* Model dilatih menggunakan *Loss Kontrastif* (_Contrastive Loss_). Fungsi ini "memaksa" model untuk:
    - #greeny("Meminimalkan") jarak Euclidean untuk pasangan positif (orang yang sama).
    - #reddy("Memaksimalkan") jarak untuk pasangan negatif (orang yang berbeda).
  - *Persiapan Data:* Set pelatihan diubah menjadi ribuan pasangan positif dan negatif yang dibuat secara acak.
  - *Evaluasi:* Kinerja model diukur dari kemampuannya mengidentifikasi gambar "probe" dengan mencari padanan terdekat dalam "galeri" pengguna yang sudah terdaftar.
]

#title-slide[
  Hasil & Eksperimen
]

#slide(title: "Hasil: Model Dasar")[
  #v(2em) // Memberi spasi vertikal
  - Sebuah model dasar dilatih menggunakan arsitektur CNN sederhana dan set pasangan data yang dibuat di awal (_pre-generated_).
  - Hasil menunjukkan bahwa model dapat belajar, namun kinerjanya masih rendah.
  - #block(inset: (top: 1em, bottom: 1em))[
      #align(center)[
        *Akurasi Keseluruhan: 32%* \
        *Weighted F1-Score: 0.30*
      ]
    ]
  - Laporan menunjukkan varians yang tinggi: beberapa subjek dikenali dengan sempurna, sementara banyak subjek lainnya gagal dikenali sama sekali.
]

#slide(title: "Contoh Hasil Prediksi")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 12pt,
    align: center,

    figure(
      image("images/image.png", width: 90%),
      caption: [Contoh Prediksi Berhasil]
    ),

    figure(
      image("images/image copy.png", width: 90%),
      caption: [Contoh Prediksi Gagal]
    ),
  )
]

#slide(title: "Upaya Peningkatan Model")[
  Beberapa eksperimen dilakukan untuk meningkatkan kinerja:

  1. #stress[Generator Data Dinamis]: Mengganti daftar pasangan statis dengan generator data yang membuat pasangan baru secara acak dan _on-the-fly_ untuk setiap _batch_.

  2. #stress[Arsitektur yang Ditingkatkan]: Memperkenalkan model V2 yang lebih dalam dengan `BatchNormalization` untuk stabilitas dan `Dropout` untuk regularisasi.

  3. #stress[Augmentasi Data]: Menambahkan transformasi acak seperti _flip_ dan rotasi pada gambar pelatihan untuk menciptakan lebih banyak variasi data.
]

#slide(title: "Tantangan: Pelatihan yang Tidak Stabil")[
  #cols(columns: (1.2fr, 1fr))[
    - Uji coba awal dari model V2 yang ditingkatkan menunjukkan tanda-tanda *pelatihan yang tidak stabil*.
    - #bluey("Training loss") menurun, namun #reddy("validation loss") meledak ke nilai yang sangat tinggi.
    - Masalah klasik ini biasanya disebabkan oleh nilai vektor fitur keluaran yang menjadi tidak terbatas.
    - Solusinya adalah dengan menambahkan lapisan *L2 Normalization* pada akhir jaringan dasar untuk membatasi nilai vektor dan menstabilkan pelatihan.
  ][
     #figure(
  image("images/Untitled.png", width: 100%, height: 200pt),
  caption: [Contoh gambar telapak tangan dari dataset SMPD.]
)
  ]
]

#title-slide[
  Kesimpulan
]

#slide(title: "Kesimpulan & Saran Pengembangan")[
  *Kesimpulan:*
  - Alur kerja _end-to-end_ untuk pengenalan telapak tangan berhasil dibangun dan diuji.
  - Metode ekstraksi ROI berbasis centroid terbukti menjadi langkah pra-pemrosesan yang kuat dan konsisten.
  - Model dasar berhasil membuktikan konsep dengan akurasi 32%, menunjukkan bahwa pendekatan Jaringan Siamese dapat diterapkan untuk tugas ini.

  *Saran Pengembangan:*
  - Mengimplementasikan L2 Normalization untuk menstabilkan model V2 dan mengevaluasi kinerjanya secara penuh.
  - Melakukan _tuning_ pada `recognition_threshold` secara sistematis untuk mengoptimalkan kinerja.
  - #stress[Peningkatan Kualitas Data & Metode Ekstraksi]:
    - Metode ekstraksi ROI berbasis *valley-point* sangat sensitif terhadap kualitas data. Dengan data yang lebih konsisten (misalnya, pencahayaan studio atau menggunakan pemindai khusus), metode *valley-point* #greeny[*berpotensi memberikan hasil yang lebih unggul*] karena didasarkan pada titik referensi anatomis yang lebih presisi.
]

#focus-slide[
  Terima Kasih \ Ada Pertanyaan?
]