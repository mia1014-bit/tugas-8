// lib/pages/note_form_page.dart

import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteFormPage extends StatefulWidget {
  final Note? existingNote;

  const NoteFormPage({super.key, this.existingNote});

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedCategory;

  final List<String> _categories = [
    'Kuliah',
    'Organisasi',
    'Pribadi',
    'Lain-lain'
  ];

  bool get isEditMode => widget.existingNote != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingNote?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.existingNote?.content ?? '',
    );
    _selectedCategory = widget.existingNote?.category ?? 'Kuliah';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Kuliah':
        return Icons.school_rounded;
      case 'Organisasi':
        return Icons.groups_rounded;
      case 'Pribadi':
        return Icons.person_rounded;
      default:
        return Icons.note_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Kuliah':
        return Colors.blue;
      case 'Organisasi':
        return Colors.purple;
      case 'Pribadi':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  void _saveNote() {
    if (!_formKey.currentState!.validate()) return;

    final newNote = Note(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: widget.existingNote?.createdAt ?? DateTime.now(),
      category: _selectedCategory,
    );

    Navigator.pop(context, newNote);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? '✏️ Edit Catatan' : '➕ Catatan Baru',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kategori Selector
              Text(
                'Kategori',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  final categoryColor = _getCategoryColor(category);

                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          size: 18,
                          color: isSelected ? Colors.white : categoryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(category),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                    selectedColor: categoryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    showCheckmark: false,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Judul
              Text(
                'Judul',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Masukkan judul catatan...',
                  prefixIcon: const Icon(Icons.title_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withOpacity(0.3),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                validator: (value) =>
                value == null || value.trim().isEmpty
                    ? 'Judul wajib diisi'
                    : null,
              ),

              const SizedBox(height: 20),

              // Isi Catatan
              Text(
                'Isi Catatan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'Tulis catatan Anda di sini...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withOpacity(0.3),
                  alignLabelWithHint: true,
                ),
                maxLines: 12,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
                validator: (value) =>
                value == null || value.trim().isEmpty
                    ? 'Isi catatan tidak boleh kosong'
                    : null,
              ),

              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _saveNote,
                  icon: const Icon(Icons.save_rounded, size: 22),
                  label: Text(
                    isEditMode ? 'Simpan Perubahan' : 'Simpan Catatan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tombol Batal
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 22),
                  label: const Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}