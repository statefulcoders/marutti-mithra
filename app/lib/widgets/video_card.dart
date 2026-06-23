import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/configs/design/marutti_colors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoCard extends StatelessWidget {
  final String url;

  const VideoCard({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final videoId = YoutubePlayer.convertUrlToId(url) ?? url;
    final String thumbnailUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoId: videoId)),
        );
      },
      child: Card(
        color: Colors.grey.shade300,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: Get.width * 0.6,
          height: Get.width * 0.4,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: thumbnailUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const Icon(
                Icons.play_circle_fill,
                size: 64,
                color: Colors.white,

              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;

  const VideoPlayerScreen({super.key, required this.videoId});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final _controller = YoutubePlayerController(
    initialVideoId: widget.videoId,
    flags: YoutubePlayerFlags(
      autoPlay: true,
      mute: false,
      loop: true
    ),
  );

  @override
  void initState() {
    super.initState();
    // Allow both portrait and landscape
    SystemChrome.setPreferredOrientations([
      // DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Restore to portrait-only (or any default your app uses)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Replace this with actual video player logic using a package like video_player
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: MaruttiColors.primaryColor,
              progressColors: ProgressBarColors(
                playedColor: MaruttiColors.primaryColor,
                handleColor: Colors.blue,
              ),
              onReady: (){}
            ),
          ),
        ),
      ),
    );
  }
}
