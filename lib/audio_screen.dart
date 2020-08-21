import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AudioScreen extends StatefulWidget {
  @override
  _AudioScreenState createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();
  Set<String> musicsUrl = {kMusicFileUrl, kMusicFileUrl1, kMusicFileUrl2};
  String errorMessage = '';
  bool isLoading = false;

  @override
  void dispose() {
    audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                  hintText: 'Enter music url',
                  suffixIcon: Visibility(
                    visible: isLoading,
                    child: CircularProgressIndicator(),
                  )),
              onFieldSubmitted: (value) {
                print(value);
                addMusicUrl(value);
              },
            ),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(
              height: 30,
            ),
            Expanded(
              child: ListView(
                children: [
                  for (String url in musicsUrl)
                    MusicTile(
                      musicUrl: url,
                      audioPlayer: audioPlayer,
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void addMusicUrl(String url) {
    setState(() {
      isLoading = true;
    });

    DefaultCacheManager().getSingleFile(url).then((value) {
      print(value.path);
      setState(() {
        musicsUrl.add(url);
        errorMessage = '';
        isLoading = false;
      });
    }).catchError((e) {
      print('errror = $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Invalid Url';
      });
    });
  }
}

class MusicTile extends StatefulWidget {
  final String musicUrl;
  final AudioPlayer audioPlayer;

  const MusicTile({Key key, this.musicUrl, this.audioPlayer}) : super(key: key);

  @override
  _MusicTileState createState() => _MusicTileState();
}

class _MusicTileState extends State<MusicTile> {
  bool _isMusicPlaying = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.musicUrl),
      subtitle: Text(
        _errorMessage,
        style: TextStyle(color: Colors.red),
      ),
      trailing: _isLoading
          ? CircularProgressIndicator()
          : IconButton(
              icon: Icon(_isMusicPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () => _playMusic(),
            ),
    );
  }

  void _playMusic() async {
    if (_isMusicPlaying) {
      widget.audioPlayer.pause();
      setState(() {
        _isMusicPlaying = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      var file = await DefaultCacheManager().getSingleFile(widget.musicUrl);
      widget.audioPlayer.play(file.path, isLocal: true);
      setState(() {
        _isMusicPlaying = !_isMusicPlaying;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Some error occurred please try again';
      });
    }
  }
}

const kMusicFileUrl =
    'https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_1MG.mp3';

const kMusicFileUrl1 =
    'https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_5MG.mp3';

const kMusicFileUrl2 =
    'https://sampleswap.org/samples-ghost/MELODIC%20LOOPS/SAMPLED%20MUSIC%20LOOPS/1494[kb]055_slow-ballad-guitar-strings.wav.mp3';
