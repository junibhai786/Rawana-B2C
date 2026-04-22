import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreenFixed extends StatefulWidget {
  @override
  State<HomeScreenFixed> createState() => _HomeScreenFixedState();
}

class _HomeScreenFixedState extends State<HomeScreenFixed> {
  List<dynamic> apiResponse = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Replace with your actual API call
      // final response = await http.get(Uri.parse('your_api_endpoint'));
      // apiResponse = jsonDecode(response.body);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Home')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Rawana')),
      body: ListView.builder(
        itemCount: apiResponse.length,
        itemBuilder: (context, blockIndex) {
          final block = apiResponse[blockIndex];
          final String blockType = block['type'] ?? 'unknown';

          print("BLOCK TYPE => $blockType");

          if (block['model'] == null || block['model']['data'] == null) {
            return SizedBox.shrink();
          }

          final List items = block['model']['data'];

          if (items.isEmpty) {
            return SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  blockType.replaceAll('list_', '').toUpperCase(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, itemIndex) {
                    final item = items[itemIndex];
                    final String? imageUrl = item['image'];
                    final String title = item['title'] ?? 'No Title';

                    print("IMAGE URL => $imageUrl");

                    return Container(
                      width: 180,
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: imageUrl != null && imageUrl.isNotEmpty
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[300],
                                            child: Icon(Icons.broken_image,
                                                size: 50),
                                          );
                                        },
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Container(
                                            color: Colors.grey[300],
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: Icon(Icons.image_not_supported,
                                            size: 50),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
