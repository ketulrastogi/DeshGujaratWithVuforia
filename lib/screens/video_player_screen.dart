import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String youtubeVideoId;

  const VideoPlayerScreen({Key key, this.youtubeVideoId = 'mXgG8k5tTFM'})
      : super(key: key);
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: YoutubePlayer(
          controller: YoutubePlayerController(
            initialVideoId: widget.youtubeVideoId,
            flags: YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
            ),
          ),
          showVideoProgressIndicator: true,
          progressIndicatorColor: Theme.of(context).accentColor,
          progressColors: ProgressBarColors(
            playedColor: Theme.of(context).accentColor,
            handleColor: Theme.of(context).accentColor,
          ),
          onReady: () {
            // _controller.addListener(listener);
          },
        ),
      ),
    );
  }
}
