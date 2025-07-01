import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../models/news_model.dart';

class CreateNewsScreen extends StatefulWidget {
  final News? news;

  const CreateNewsScreen({super.key, this.news});

  @override
  _CreateNewsScreenState createState() => _CreateNewsScreenState();
}

class _CreateNewsScreenState extends State<CreateNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _categoryController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _publishImmediately = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.news != null) {
      _titleController.text = widget.news!.title;
      _summaryController.text = widget.news!.summary;
      _contentController.text = widget.news!.content;
      _imageUrlController.text = widget.news!.featuredImageUrl ?? '';
      _categoryController.text = widget.news!.category;
      _tagsController.text = widget.news!.tags.join(', ');
      _publishImmediately = widget.news!.isPublished;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.news != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Berita' : 'Buat Berita'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show editing info
              if (isEditing)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue[800]),
                      const SizedBox(width: 8),
                      Text(
                        'Mode Edit - ${widget.news!.isPublished ? "Published" : "Draft"}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ),

              // Show error message if any
              Consumer<NewsProvider>(
                builder: (context, newsProvider, child) {
                  if (newsProvider.error != null) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              newsProvider.error!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red[700]),
                            onPressed: () => newsProvider.clearError(),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Title
              _buildTextField(
                'Judul *',
                _titleController,
                'Masukkan judul berita',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul harus diisi';
                  }
                  if (value.length < 5) {
                    return 'Judul minimal 5 karakter';
                  }
                  return null;
                },
              ),

              // Summary
              _buildTextField(
                'Ringkasan *',
                _summaryController,
                'Masukkan ringkasan berita',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ringkasan harus diisi';
                  }
                  if (value.length < 10) {
                    return 'Ringkasan minimal 10 karakter';
                  }
                  return null;
                },
              ),

              // Content
              _buildTextField(
                'Konten *',
                _contentController,
                'Masukkan konten lengkap berita',
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konten harus diisi';
                  }
                  if (value.length < 20) {
                    return 'Konten minimal 20 karakter';
                  }
                  return null;
                },
              ),

              // Image URL
              _buildTextField(
                'URL Gambar (Opsional)',
                _imageUrlController,
                'Kosongkan jika tidak ada gambar',
              ),

              // Category
              _buildTextField(
                'Kategori *',
                _categoryController,
                'Masukkan kategori',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori harus diisi';
                  }
                  return null;
                },
              ),

              // Tags
              _buildTextField(
                'Tags',
                _tagsController,
                'Masukkan tags dipisah koma',
              ),

              // Publish Switch
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Publikasikan Langsung',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _publishImmediately,
                    onChanged: (value) {
                      setState(() {
                        _publishImmediately = value;
                      });
                    },
                    activeColor: Colors.brown,
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitNews,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(isEditing ? 'Mengupdate...' : 'Membuat...'),
                          ],
                        )
                      : Text(
                          isEditing ? 'Update Berita' : 'Buat Berita',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _submitNews() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final newsProvider = Provider.of<NewsProvider>(context, listen: false);

      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      if (tags.isEmpty) {
        tags.add('general');
      }

      final news = News(
        title: _titleController.text.trim(),
        summary: _summaryController.text.trim(),
        content: _contentController.text.trim(),
        featuredImageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        category: _categoryController.text.trim(),
        tags: tags,
        isPublished: _publishImmediately,
      );

      bool success;
      if (widget.news != null) {
        success = await newsProvider.updateNews(widget.news!.id!, news);
      } else {
        success = await newsProvider.createNews(news);
      }

      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.news != null
                ? 'Berita berhasil diupdate'
                : 'Berita berhasil dibuat'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.of(context).pop();
      }
      // Error akan ditampilkan oleh Consumer di atas
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}