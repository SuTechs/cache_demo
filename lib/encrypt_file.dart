import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cache_demo/audio_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:path_provider/path_provider.dart' as path;

class EncryptFile extends StatelessWidget {
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Encrypt'),
      ),
      body: Column(
        children: [
          DownloadFile(
            url: kMusicFileUrl2,
            name: 'Music1',
            audioPlayer: audioPlayer,
          ),
          DownloadFile(
            url: kMusicFileUrl,
            name: 'Music2',
            audioPlayer: audioPlayer,
          ),
          DownloadFile(
            url: kMusicFileUrl,
            name: 'Music3',
            audioPlayer: audioPlayer,
          ),
        ],
      ),
    );
  }
}

class DownloadFile extends StatefulWidget {
  final String url;
  final String name;
  final AudioPlayer audioPlayer;

  const DownloadFile({Key key, this.url, this.name, this.audioPlayer})
      : super(key: key);

  @override
  _DownloadFileState createState() => _DownloadFileState();
}

class _DownloadFileState extends State<DownloadFile> {
  final crypt = AesCrypt('SuMit0055#');
  bool _isLoading = false;
  bool _isDownloaded = false;
  String _errorMessage = '';
  String filePath = '';
  bool _isMusicPlaying = false;
  String decryptedFilePath;

  Future<void> getFilePath() async {
    final loc = await path.getExternalStorageDirectories();
    filePath = loc[0].path + '/' + widget.name + '.su';
    await isDownloaded();
  }

  Future<void> isDownloaded() async {
    final isExist = await File(filePath).exists();

    if (isExist) {
      decryptedFilePath = crypt.decryptFileSync(filePath);
      _errorMessage = 'view downloaded file at $filePath';
    }

    setState(() {
      _isDownloaded = isExist;
    });
  }

  @override
  void initState() {
    super.initState();
    getFilePath();
  }

  @override
  void dispose() {
    if (decryptedFilePath != null) {
      File(decryptedFilePath).deleteSync();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.name),
      subtitle: Text(
        _errorMessage,
        style: TextStyle(color: Colors.red),
      ),
      trailing: _isLoading
          ? CircularProgressIndicator()
          : IconButton(
              icon: Icon(_isDownloaded
                  ? _isMusicPlaying ? Icons.pause : Icons.play_arrow
                  : Icons.file_download),
              onPressed: () async {
                if (_isDownloaded) {
                  if (_isMusicPlaying) {
                    widget.audioPlayer.pause();
                    setState(() {
                      _isMusicPlaying = false;
                    });
                  } else {
                    if (decryptedFilePath == null) {
                      await isDownloaded();
                    }

                    widget.audioPlayer.play(decryptedFilePath, isLocal: true);
                    setState(() {
                      _isMusicPlaying = true;
                    });
                  }
                } else
                  _downloadFile();
              },
            ),
    );
  }

  void _downloadFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      File file = await DefaultCacheManager().getSingleFile(widget.url);
      print('file path = ${file.path}');

      crypt.encryptFileSync(file.path, filePath);

      setState(() {
        _isLoading = false;
        _isDownloaded = true;
        _errorMessage = 'view downloaded file at $filePath';
      });
    } catch (e) {
      setState(() {
        print('error = $e');
        _isLoading = false;
        _errorMessage = 'Some error occurred please try again';
      });
    }
  }
}
