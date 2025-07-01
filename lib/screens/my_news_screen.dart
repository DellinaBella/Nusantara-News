import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../models/news_model.dart';
import 'create_news_screen.dart';
import 'news_detail_screen.dart';

class MyNewsScreen extends StatefulWidget {
  const MyNewsScreen({super.key});

  @override
  _MyNewsScreenState createState() => _MyNewsScreenState();
}

class _MyNewsScreenState extends State<MyNewsScreen> {
  final Set<String> _deletingNewsIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsProvider>(context, listen: false).fetchAuthorNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita Saya'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<NewsProvider>(context, listen: false)
                  .fetchAuthorNews();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateNewsScreen()),
              ).then((_) {
                Provider.of<NewsProvider>(context, listen: false)
                    .fetchAuthorNews();
              });
            },
          ),
        ],
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          if (newsProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat berita...'),
                ],
              ),
            );
          }

          if (newsProvider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Error memuat berita',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      newsProvider.error!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        newsProvider.clearError();
                        newsProvider.fetchAuthorNews();
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (newsProvider.authorNews.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.article, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('Belum ada berita',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Text('Mulai buat berita pertama Anda',
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey[500])),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const CreateNewsScreen()))
                            .then((_) => newsProvider.fetchAuthorNews());
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Buat Berita'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Provider.of<NewsProvider>(context, listen: false)
                  .fetchAuthorNews();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: newsProvider.authorNews.length,
              itemBuilder: (context, index) {
                final news = newsProvider.authorNews[index];
                return _buildNewsCard(context, news, newsProvider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewsCard(
      BuildContext context, News news, NewsProvider newsProvider) {
    final isDeleting = _deletingNewsIds.contains(news.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: isDeleting
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewsDetailScreen(news: news)),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: news.isPublished
                          ? Colors.green[100]
                          : Colors.brown[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      news.isPublished ? 'Published' : 'Draft',
                      style: TextStyle(
                        color: news.isPublished
                            ? Colors.green[800]
                            : Colors.brown[800],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editNews(context, news);
                            } else if (value == 'delete') {
                              _showDeleteDialog(context, news, newsProvider);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit,
                                      size: 16, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Edit Berita'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      size: 16, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Hapus Berita'),
                                ],
                              ),
                            ),
                          ],
                          child: const Text(
                            'Aksi',
                            style: TextStyle(
                              color: Colors.brown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: news.featuredImageUrl != null &&
                            news.featuredImageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              news.featuredImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image, color: Colors.grey),
                            ),
                          )
                        : const Icon(Icons.image, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          news.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDeleting ? Colors.grey : Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          news.summary,
                          style: TextStyle(
                            color: isDeleting
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              news.category,
                              style: TextStyle(
                                color: isDeleting ? Colors.grey : Colors.brown,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              news.createdAt != null
                                  ? _formatDate(news.createdAt!)
                                  : 'Baru saja',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (isDeleting)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Menghapus berita...',
                        style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 0), // Hapus tombol EDIT dan HAPUS
            ],
          ),
        ),
      ),
    );
  }

  void _editNews(BuildContext context, News news) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateNewsScreen(news: news)),
    ).then((_) {
      Provider.of<NewsProvider>(context, listen: false).fetchAuthorNews();
    });
  }

  void _showDeleteDialog(
      BuildContext context, News news, NewsProvider newsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Berita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin menghapus berita ini?'),
            const SizedBox(height: 8),
            Text('"${news.title}"',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            const Text('Tindakan ini tidak dapat dibatalkan.',
                style: TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNews(context, news, newsProvider);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNews(
      BuildContext context, News news, NewsProvider newsProvider) async {
    if (news.id == null) return;

    setState(() {
      _deletingNewsIds.add(news.id!);
    });

    try {
      bool success = await newsProvider.deleteNews(news.id!);

      setState(() {
        _deletingNewsIds.remove(news.id!);
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Berita berhasil dihapus'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Provider.of<NewsProvider>(context, listen: false).fetchPublicNews();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Gagal menghapus berita'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _deletingNewsIds.remove(news.id!);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) return '${difference.inDays} hari lalu';
    if (difference.inHours > 0) return '${difference.inHours} jam lalu';
    if (difference.inMinutes > 0) return '${difference.inMinutes} menit lalu';
    return 'Baru saja';
  }
}