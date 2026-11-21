import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/core/widgets/mobile_frame.dart';
import 'package:mobile_app/features/agenda/viewmodels/agenda_viewmodel.dart';

class PengajuanLokakaryaView extends StatefulWidget {
  final AgendaViewModel? viewModel;

  const PengajuanLokakaryaView({super.key, this.viewModel});

  @override
  State<PengajuanLokakaryaView> createState() => _PengajuanLokakaryaViewState();
}

class _PengajuanLokakaryaViewState extends State<PengajuanLokakaryaView> {
  final _formKey = GlobalKey<FormState>();
  late final AgendaViewModel _viewModel;

  // Controllers
  final _titleController = TextEditingController();
  final _organizerNameController = TextEditingController();
  final _organizerContactController = TextEditingController();
  final _organizerEmailController = TextEditingController();
  final _timeController = TextEditingController(text: '14:00 - 17:00 WIB');
  final _priceController = TextEditingController(text: '0');
  final _quotaController = TextEditingController(text: '25');
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  String _selectedCategory = 'Lokakarya Seni';
  String _selectedLocation = 'Studio Kriya Lt. 1, Rumah Budaya Ratna';
  bool _isSubmitting = false;

  final List<String> _categoryOptions = [
    'Lokakarya Seni',
    'Workshop Kriya',
    'Kelas Membatik',
    'Kelas Tari & Karawitan',
    'Wicara Budaya',
    'Diskusi Komunitas',
  ];

  final List<String> _locationOptions = [
    'Studio Kriya Lt. 1, Rumah Budaya Ratna',
    'Pendopo Utama Rumah Budaya Ratna',
    'Ruang Komunal Lt. 2, Rumah Budaya Ratna',
    'Galeri Seni RBR',
    'Pelataran RBR',
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? AgendaViewModel();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _organizerNameController.dispose();
    _organizerContactController.dispose();
    _organizerEmailController.dispose();
    _timeController.dispose();
    _priceController.dispose();
    _quotaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: now,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.maroon,
              onPrimary: Colors.white,
              onSurface: AppColors.textMain,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
    });

    final formattedDate =
        DateFormat('yyyy-MM-dd').format(_selectedDate);
    final rawPrice = int.tryParse(
            _priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
    final rawQuota = int.tryParse(_quotaController.text.trim()) ?? 25;

    try {
      final res = await _viewModel.submitWorkshopProposal(
        title: _titleController.text.trim(),
        organizerName: _organizerNameController.text.trim(),
        organizerContact: _organizerContactController.text.trim(),
        organizerEmail: _organizerEmailController.text.trim(),
        category: _selectedCategory,
        date: formattedDate,
        time: _timeController.text.trim(),
        location: _selectedLocation,
        price: rawPrice,
        quota: rawQuota,
        description: _descriptionController.text.trim(),
      );

      setState(() {
        _isSubmitting = false;
      });

      if (!mounted) return;
      _showSuccessDialog(_titleController.text.trim(), res);
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Gagal mengirim pengajuan: $e',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12),
          ),
        ),
      );
    }
  }

  void _showSuccessDialog(String workshopTitle, Map<String, dynamic> res) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pending_actions_rounded,
                  color: Color(0xFFD97706),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                ),
                child: Text(
                  'STATUS: MENUNGGU PERSETUJUAN',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Pengajuan Terkirim!',
                style: GoogleFonts.lora(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lokakarya "$workshopTitle" berhasil didaftarkan. Pengajuan ini akan ditinjau oleh kurator Rumah Budaya Ratna dan baru akan tayang di agenda publik setelah disetujui.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(context); // Back to AgendaView
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.maroon,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'KEMBALI KE AGENDA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MobileFrame(
      child: Scaffold(
        backgroundColor: AppColors.bgCanvas,
        appBar: AppBar(
          backgroundColor: AppColors.bgCanvas,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textMain),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Pengajuan Lokakarya',
            style: GoogleFonts.lora(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Banner Alur Persetujuan
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFFD97706),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alur Pengajuan Lokakarya',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF92400E),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Setiap lokakarya yang diajukan akan berstatus "Menunggu Persetujuan" (Pending). Acara baru akan aktif dan tayang di kalender publik setelah disetujui oleh kurator/admin RBR.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                color: const Color(0xFFB45309),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Bagian 1: Data Lokakarya
                _buildCardSection(
                  title: 'DETAIL LOKAKARYA',
                  icon: Icons.event_note_rounded,
                  children: [
                    _buildTextField(
                      controller: _titleController,
                      label: 'Nama / Judul Lokakarya',
                      hint: 'Contoh: Workshop Membatik Tulis Sutra',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Nama lokakarya wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Kategori
                    _buildDropdownField(
                      label: 'Kategori Acara',
                      value: _selectedCategory,
                      items: _categoryOptions,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Tanggal Pelaksanaan
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal Pelaksanaan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.bgCanvas,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month_outlined,
                                    size: 16, color: AppColors.maroon),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('EEEE, dd MMMM yyyy')
                                      .format(_selectedDate),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMain,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Ubah',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.maroon,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Waktu Pelaksanaan
                    _buildTextField(
                      controller: _timeController,
                      label: 'Waktu / Jam Pelaksanaan',
                      hint: 'Contoh: 14:00 - 17:00 WIB',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Waktu pelaksanaan wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Lokasi
                    _buildDropdownField(
                      label: 'Lokasi di Rumah Budaya Ratna',
                      value: _selectedLocation,
                      items: _locationOptions,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedLocation = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Baris Kuota & Biaya
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _quotaController,
                            label: 'Kuota Peserta',
                            hint: '25',
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Wajib diisi'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _priceController,
                            label: 'Biaya Partisipasi (Rp)',
                            hint: '0 (Gratis)',
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Wajib diisi'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Deskripsi
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Deskripsi & Silabus Singkat',
                      hint: 'Jelaskan materi yang akan dipelajari dan target peserta lokakarya...',
                      maxLines: 3,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Bagian 2: Data Fasilitator / Pemohon
                _buildCardSection(
                  title: 'DATA FASILITATOR / PENYELENGGARA',
                  icon: Icons.person_outline_rounded,
                  children: [
                    _buildTextField(
                      controller: _organizerNameController,
                      label: 'Nama Lengkap Fasilitator / Lembaga',
                      hint: 'Contoh: Siti Rahmawati / Sanggar Sekar',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Nama fasilitator wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _organizerContactController,
                      label: 'Nomor WhatsApp Aktif',
                      hint: 'Contoh: 081234567890',
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.trim().length < 8
                          ? 'Nomor WhatsApp valid wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _organizerEmailController,
                      label: 'Email Konfirmasi (Opsional)',
                      hint: 'Contoh: fasilitator@gmail.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tombol Submit
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.maroon,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'KIRIM PENGAJUAN LOKAKARYA',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.maroon),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textMain,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textMuted.withValues(alpha: 0.6),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            filled: true,
            fillColor: AppColors.bgCanvas,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.maroon, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.bgCanvas,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.maroon),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textMain,
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
