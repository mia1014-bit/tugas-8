// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../services/local_storage_service.dart';
import 'note_form_page.dart';

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> _notes = [];
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Kuliah',
    'Organisasi',
    'Pribadi',
    'Lain-lain'
  ];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // Load catatan dari SharedPreferences
  Future<void> _loadNotes() async {
    final notes = await LocalStorageService.loadNotes();
    setState(() {
      _notes = notes;
    });
    print('✅ Loaded ${_notes.length} notes');
    for (var note in _notes) {
      print('   - ${note.title} [${note.category}]');
    }
  }

  // Simpan catatan ke SharedPreferences
  Future<void> _saveNotes() async {
    await LocalStorageService.saveNotes(_notes);
    print('💾 Saved ${_notes.length} notes');
  }

  // Filter catatan berdasarkan kategori yang dipilih
  List<Note> get _filteredNotes {
    if (_selectedCategory == 'Semua') {
      print('📂 Showing all ${_notes.length} notes');
      return _notes;
    }
    final filtered = _notes.where((note) => note.category == _selectedCategory).toList();
    print('📂 Showing ${filtered.length} notes in category: $_selectedCategory');
    return filtered;
  }

  // CREATE - Tambah catatan baru
  Future<void> _addNote() async {
    final result = await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (context) => const NoteFormPage(),
      ),
    );

    if (result != null) {
      setState(() {
        _notes.insert(0, result); // Tambah di paling atas
      });
      await _saveNotes();

      print('➕ Added note: ${result.title} [${result.category}]');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Catatan "${result.title}" berhasil ditambahkan ke ${result.category}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // UPDATE - Edit catatan
  Future<void> _editNote(int displayIndex) async {
    // Cari index asli dari catatan di list utama (_notes)
    final filteredList = _filteredNotes;
    final noteToEdit = filteredList[displayIndex];
    final actualIndex = _notes.indexOf(noteToEdit);

    print('✏️ Editing note at index $actualIndex: ${noteToEdit.title} [${noteToEdit.category}]');

    final result = await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (context) => NoteFormPage(existingNote: noteToEdit),
      ),
    );

    if (result != null) {
      setState(() {
        _notes[actualIndex] = result;
      });
      await _saveNotes();

      print('✅ Updated note: ${result.title} [${result.category}]');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Catatan "${result.title}" berhasil diperbarui'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // DELETE - Hapus catatan
  void _deleteNote(int displayIndex) {
    final filteredList = _filteredNotes;
    final noteToDelete = filteredList[displayIndex];
    final actualIndex = _notes.indexOf(noteToDelete);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Konfirmasi Hapus'),
          ],
        ),
        content: Text('Yakin ingin menghapus catatan "${noteToDelete.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              setState(() {
                _notes.removeAt(actualIndex);
              });
              await _saveNotes();

              print('🗑️ Deleted note: ${noteToDelete.title}');

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🗑️ Catatan "${noteToDelete.title}" dihapus'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Helper - Get icon berdasarkan kategori
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

  // Helper - Get warna berdasarkan kategori
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

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _filteredNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '📝 Student Notes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Kategori (Horizontal Chips)
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;

                // Hitung jumlah catatan per kategori
                final count = category == 'Semua'
                    ? _notes.length
                    : _notes.where((n) => n.category == category).length;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(category),
                        if (count > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.3)
                                  : _getCategoryColor(category).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : _getCategoryColor(category),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                      print('🔍 Filter changed to: $category');
                    },
                    avatar: category != 'Semua'
                        ? Icon(
                      _getCategoryIcon(category),
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : _getCategoryColor(category),
                    )
                        : null,
                    selectedColor: category == 'Semua'
                        ? Theme.of(context).colorScheme.primary
                        : _getCategoryColor(category),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          // Statistik
          if (_notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Text(
                    _selectedCategory == 'Semua'
                        ? 'Total ${filteredNotes.length} catatan'
                        : '${filteredNotes.length} catatan di $_selectedCategory',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Daftar Catatan atau Empty State
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _selectedCategory == 'Semua'
                        ? Icons.note_add_rounded
                        : Icons.filter_alt_off_rounded,
                    size: 100,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedCategory == 'Semua'
                        ? 'Belum ada catatan'
                        : 'Tidak ada catatan di $_selectedCategory',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tekan tombol + untuk menambah',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                final categoryColor = _getCategoryColor(note.category);

                return TweenAnimationBuilder<double>(
                  duration: Duration(
                    milliseconds: 300 + (index * 50),
                  ),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _editNote(index),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Icon Kategori
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(note.category),
                                    color: categoryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Title & Date
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        note.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        DateFormat('dd MMM yyyy, HH:mm')
                                            .format(note.createdAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Delete Button
                                IconButton(
                                  icon: const Icon(Icons.delete_rounded),
                                  color: Colors.red,
                                  onPressed: () => _deleteNote(index),
                                  tooltip: 'Hapus catatan',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Content Preview
                            Text(
                              note.content,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),

                            // Category Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                note.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: categoryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNote,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Catatan'),
        elevation: 4,
      ),
    );
  }
}