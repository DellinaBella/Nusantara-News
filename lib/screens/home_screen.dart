import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../providers/favorite_provider.dart';
import '../models/news_model.dart';
import 'news_detail_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'favorites_screen.dart';
import 'my_news_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<News> _filteredNews = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      newsProvider.fetchPublicNews().then((_) {
        setState(() {
          _filteredNews = newsProvider.publicNews;
        });
      });
      Provider.of<FavoriteProvider>(context, listen: false).loadFavorites();
    });
  }

  void _filterNews(String query) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    if (query.isEmpty) {
      setState(() {
        _filteredNews = newsProvider.publicNews;
      });
    } else {
      final filtered = newsProvider.publicNews.where((news) {
        return news.title.toLowerCase().contains(query.toLowerCase()) ||
            news.summary.toLowerCase().contains(query.toLowerCase());
      }).toList();
      setState(() {
        _filteredNews = filtered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    if (_currentIndex == 0 || _currentIndex == 2) {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.brown,
                shape: BoxShape.circle,
              ),
              child: Center(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/image1.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
            const SizedBox(width: 10),
            Text(
              _currentIndex == 0 ? 'Nusantara News' : 'BERITA SAYA',
              style: const TextStyle(
                color: Colors.brown,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      );
    }
    return null;
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeBody();
      case 1:
        return const FavoritesScreen();
      case 2:
        return const MyNewsScreen();
      case 3:
        return const SettingsScreen();
      case 4:
        return const ProfileScreen();
      default:
        return _buildHomeBody();
    }
  }

  Widget _buildHomeBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterNews,
              decoration: const InputDecoration(
                hintText: 'search',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Popular Tags
          const Text(
            'Popular Tags',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              _buildTag('#Budaya'),
              _buildTag('#IKN'),
              _buildTag('#Teknologi'),
              _buildTag('#Ekonomi'),
            ],
          ),
          const SizedBox(height: 20),

          // Latest News
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  final newsProvider =
                      Provider.of<NewsProvider>(context, listen: false);
                  newsProvider.fetchPublicNews().then((_) {
                    _filterNews(_searchController.text);
                  });
                },
                child: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // News List
          Consumer<NewsProvider>(
            builder: (context, newsProvider, child) {
              if (newsProvider.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (_filteredNews.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(50),
                    child: Column(
                      children: [
                        const Icon(Icons.article, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Berita tidak ditemukan',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            newsProvider.fetchPublicNews().then((_) {
                              _filterNews(_searchController.text);
                            });
                          },
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredNews.length,
                itemBuilder: (context, index) {
                  final news = _filteredNews[index];
                  return _buildNewsCard(news);
                },
              );
            },
          ),
          const SizedBox(height: 20),

          // Recommended Topics
          const Text(
            'Rekomendasi Topik',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildRecommendedTopics(),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: Colors.orange[800],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildNewsCard(News news) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        final isFavorite = favoriteProvider.isFavorite(news.id ?? '');

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetailScreen(news: news),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: news.featuredImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              news.featuredImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image,
                                    color: Colors.grey);
                              },
                            ),
                          )
                        : const Icon(Icons.image, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                news.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey,
                                size: 20,
                              ),
                              onPressed: () {
                                favoriteProvider.toggleFavorite(news);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isFavorite
                                        ? 'Dihapus dari favorit'
                                        : 'Ditambahkan ke favorit'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Text(
                          news.summary,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 81, 139, 150),
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
                              style: const TextStyle(
                                color: Colors.brown,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              news.createdAt != null
                                  ? _formatDate(news.createdAt!)
                                  : '',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendedTopics() {
    return Column(
      children: [
        _buildRecommendedCard(
          'Lewat MBG hingga Kopdes Merah Putih, 3,6 Juta Lebih Lowongan Kerja Baru Bakal Tersedia',
          'Liputan6.com',
          '5 day ago',
        ),
        _buildRecommendedCard(
          'Dasar Pemikiran Wawasan Nusantara di Pembukaan UUD NRI 1945',
          'Kompas.com',
          '22 day ago',
        ),
      ],
    );
  }

  Widget _buildRecommendedCard(String title, String source, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        source,
                        style: const TextStyle(
                          color: Colors.brown,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.brown,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Bookmark',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.article),
          label: 'Berita Saya',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Setting',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else {
      return '${difference.inMinutes} menit lalu';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
