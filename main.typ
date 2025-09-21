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
  subtitle: [Pendekatan Machine Learning untuk Identifikasi Biometrik],
  authors: "Jidan Abdurahman Aufan, 2205422\nJason Suryoatmojo, 2204524\nKelompok 1",
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
      caption: [Contoh gambar telapak tangan dari dataset SMPD.],
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
    caption: [Contoh visualisasi Pendekatan Valley-point.],
  )
  #align(center)[
    Visualisasi langkah-langkah pemrosesan: dari *silhouette*, *contour*, deteksi *key points*, *baseline*, hingga ekstraksi *ROI* akhir.
  ]
]

#slide(title: "Visualisasi Proses: Pendekatan Key Points Gagal")[

  #v(1em) // Memberi sedikit spasi vertikal
  #figure(
    image("images/fail.png", width: 100%, height: 150pt),
    caption: [Contoh visualisasi Pendekatan Valley-point gagal.],
  )
  #align(center)[
    Karena memilih pasangan point yang jarak nya terjauh, salah memakai point sela ibu jari.
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
    caption: [Contoh visualisasi pendekatan centroid],
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

#slide(title: "Pelatihan Model Dasar")[
  #cols(columns: (1.2fr, 1fr))[
    - Pelatihan model dasar menunjukkan tren pembelajaran yang sangat baik, di mana #bluey("training loss") dan #reddy("validation loss") sama-sama menurun secara konsisten.
    - Namun, seiring berjalannya epoch, mulai terlihat celah (_gap_) di antara kedua kurva. #reddy("Validation loss") mulai stagnan sementara #bluey("training loss") terus anjlok.
    - Ini adalah indikasi klasik dari #stress[overfitting]: model mulai terlalu menghafal data latih dan kehilangan kemampuan untuk generalisasi pada data baru.
    - Hasil ini mendorong perlunya perbaikan untuk meningkatkan regularisasi dan kemampuan generalisasi model.
  ][
    #figure(
      // Ganti dengan gambar plot training loss model dasar Anda
      image("images/training1.png", width: 100%, height: 200pt),
      caption: [Riwayat Pelatihan Model Dasar],
    )
  ]
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
      caption: [Contoh Prediksi Berhasil],
    ),

    figure(
      image("images/image copy.png", width: 90%),
      caption: [Contoh Prediksi Gagal],
    ),
  )
]

#slide(title: "Upaya Peningkatan Model")[
  Beberapa eksperimen dilakukan untuk meningkatkan kinerja:

  1. #stress[Generator Data Dinamis]: Mengganti daftar pasangan statis dengan generator data yang membuat pasangan baru secara acak dan _on-the-fly_ untuk setiap _batch_.

  2. #stress[Arsitektur yang Ditingkatkan]: Memperkenalkan model V2 yang lebih dalam dengan `BatchNormalization` untuk stabilitas dan `Dropout` untuk regularisasi.

  3. #stress[Augmentasi Data]: Menambahkan transformasi acak seperti _flip_ dan rotasi pada gambar pelatihan untuk menciptakan lebih banyak variasi data.
]

#slide(title: "Hasil: Model V2")[
  #v(2em) // Memberi spasi vertikal
  - Model V2 dilatih menggunakan arsitektur CNN yang lebih dalam, augmentasi data, dan generator data dinamis.
  - Hasil menunjukkan model dapat belajar dari data latih, namun kinerja generalisasinya secara keseluruhan masih rendah.
  - #block(inset: (top: 1em, bottom: 1em))[
      #align(center)[
        *Akurasi Keseluruhan: 32%* \
        *Weighted F1-Score: 0.31*
      ]
    ]
  - Laporan klasifikasi menunjukkan varians yang sangat tinggi: beberapa subjek dikenali dengan baik (F1 > 0.7), sementara banyak subjek lainnya gagal dikenali sama sekali (F1 = 0.00).
]

#slide(title: "Hasil Model V2: Generalisasi")[
  #cols(columns: (1.2fr, 1fr))[
    - Untuk mengatasi #stress[overfitting] pada model dasar, model V2 dilatih dengan tugas yang jauh lebih sulit, menggunakan augmentasi dan generator data dinamis.
    - Pelatihan berjalan #greeny[stabil] dan tidak mengalami _loss_ yang meledak. Nilai _loss_ secara umum lebih tinggi, yang wajar terjadi karena variasi data latih yang jauh lebih besar.
    - Meskipun kinerja sedikit meningkat, #reddy("validation loss") yang stagnan menunjukkan bahwa tantangan utama tetap pada kualitas dan konsistensi data ROI itu sendiri.
  ][
    #figure(
      // Gunakan gambar plot training V2 Anda di sini
      image("images/training2.png", width: 100%, height: 200pt),
      caption: [Riwayat Pelatihan Model V2 (Stabil)],
    )
  ]
]

#slide(title: "Tantangan Utama: Kualitas Data & Preprocessing")[
  #v(1em)
  - Meskipun arsitektur model selalu dapat dioptimalkan, hasil pelatihan menyoroti sebuah tantangan yang jelas: kinerja model apapun sangat bergantung pada kualitas data training. Kemungkinan besar, kinerja model kini lebih dibatasi oleh kualitas dan konsistensi data dan Region of Interest (ROI) yang diekstrak.

  - Beberapa tantangan utama dalam tahap _preprocessing_ teridentifikasi:
    - #stress[Kontur yang Tidak Sempurna]: Pencahayaan yang tidak konsisten pada dataset menghasilkan siluet dengan pinggiran yang tajam, terutama di area pergelangan tangan. Hal ini menciptakan _convexity defects_ palsu yang sering keliru dideteksi sebagai lembah jari oleh algoritma.

    - #stress[Kesulitan Identifikasi Lembah Jari]: Sangat sulit untuk merancang aturan geometris yang dapat secara konsisten membedakan empat lembah jari utama dari lembah ibu jari yang dalam, terutama pada gambar di mana jari-jari tidak terentang sempurna. Hal ini sering menyebabkan pemilihan titik acuan ROI yang salah.

    - #stress[Keterbatasan Aturan Geometris]: Solusi yang lebih andal memerlukan peralihan dari aturan geometris ke metode yang lebih cerdas seperti #bluey[deteksi _landmark_]. Dengan melatih model untuk mengenali setiap lembah secara spesifik (misalnya, "lembah telunjuk-tengah"), kita dapat menerapkan strategi ekstraksi ROI yang berbeda dan lebih akurat, sesuai dengan pasangan titik acuan yang berhasil diidentifikasi.
]

#title-slide[
  Kesimpulan
]

#slide(title: "Kesimpulan & Saran Pengembangan")[
  *Kesimpulan:*
  - Alur kerja _end-to-end_ untuk pengenalan telapak tangan berhasil dibangun, mulai dari pra-pemrosesan data hingga pelatihan dan evaluasi Jaringan Siamese.
  - Metode ekstraksi ROI berbasis #bluey[centroid] terbukti #greeny[andal dan konsisten] untuk data yang bervariasi, meskipun metode berbasis #reddy[valley-point] secara teoretis lebih presisi secara anatomis.
  - Peningkatan arsitektur ke model V2 berhasil mengatasi #stress[overfitting], namun kinerja akhir tetap terbatas (akurasi ~32%), yang mengindikasikan bahwa #stress[kualitas ROI] adalah faktor pembatas utama saat ini.

]

#slide(title: "Kesimpulan & Saran Pengembangan")[

  *Saran Pengembangan:*
  - #stress[Membangun Dataset Baru]: Membuat dataset baru dengan kondisi yang terkontrol (pencahayaan seragam, pose tangan konsisten) untuk memastikan data cocok dan andal bagi metode ekstraksi ROI yang lebih presisi seperti _valley-point_.
  - Fokus utama adalah mengembangkan metode ekstraksi ROI hibrida yang menggabungkan #greeny[keandalan pendekatan centroid] dengan #bluey[presisi anatomis pendekatan valley-point].
  - Mengimplementasikan model #stress[deteksi _landmark_] untuk mengenali setiap lembah jari secara spesifik adalah langkah paling menjanjikan untuk mencapai tujuan tersebut dan meningkatkan kualitas ROI secara signifikan.
  - Melakukan _hyperparameter tuning_ lebih lanjut pada arsitektur V2, termasuk optimasi `learning rate` dan `recognition_threshold` untuk memaksimalkan potensi model dengan data ROI yang lebih baik.
]

#focus-slide[
  Terima Kasih \ Ada Pertanyaan?
]
