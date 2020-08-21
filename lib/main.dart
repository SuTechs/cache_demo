import 'package:cache_demo/audio_screen.dart';
import 'package:cache_demo/constatnts.dart';
import 'package:cache_demo/video_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cache Demo',
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cache Demo'),
        actions: [
          IconButton(
            icon: Icon(Icons.video_library),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoScreen(),
                ),
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.music_note),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => AudioScreen())),
      ),
      body: ListView.builder(
          itemCount: kImages.length,
          itemBuilder: (context, index) {
            return MyCachedImage(
              imageUrl: kImages[index],
            );
          }),
    );
  }
}

/// using cached_network_image
class MyCachedImage extends StatelessWidget {
  final String imageUrl;

  const MyCachedImage({Key key, this.imageUrl}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 200),
      padding: EdgeInsets.all(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (context, url) =>
            Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }
}
