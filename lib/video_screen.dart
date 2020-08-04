import 'package:cache_demo/constatnts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Cache'),
      ),
      body: ListView.builder(
          itemCount: kVideos.length,
          itemBuilder: (context, index) {
            return VideoTile(videoUrl: kVideos[index]);
          }),
    );
  }
}

class VideoTile extends StatefulWidget {
  final String videoUrl;

  const VideoTile({Key key, this.videoUrl}) : super(key: key);
  @override
  _VideoTileState createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  VideoPlayerController _controller;
  bool _showControl = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl, useCache: true)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      }, onError: (e) {
        print('Hello Error $e');
        setState(() {
          _isError = true;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 200),
      padding: EdgeInsets.only(bottom: 10),
      child: _controller.value.initialized
          ? GestureDetector(
              onTap: () {
                setState(() {
                  _showControl = !_showControl;
                });
              },
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  children: [
                    VideoPlayer(_controller),
                    Visibility(
                      visible: _showControl,
                      child: Center(
                        child: IconButton(
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.red,
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: _isError ? Icon(Icons.error) : CircularProgressIndicator(),
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
