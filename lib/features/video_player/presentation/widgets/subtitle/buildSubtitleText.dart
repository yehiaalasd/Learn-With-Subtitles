import 'package:flutter/material.dart';
import 'package:mxplayer/features/video_player/domain/viewmodels/video_player_viewmodel.dart';
import 'package:mxplayer/features/video_player/presentation/widgets/subtitle/buildWordButtons.dart';
import 'package:provider/provider.dart';
import 'package:mxplayer/features/known_words/domain/known_words_model.dart';

class SubtitleText extends StatefulWidget {
  final VideoPlayerViewModel model;
  final bool isSecondSub;

  const SubtitleText(
      {super.key, required this.model, required this.isSecondSub});

  @override
  State<SubtitleText> createState() => _SubtitleTextState();
}

class _SubtitleTextState extends State<SubtitleText> {
  late Offset _dragOffset;

  @override
  void initState() {
    super.initState();
    widget.model.loadSubtitles();
    setState(() {});
    _dragOffset = const Offset(0, 0);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KnownWordsModel>(context, listen: false);
    final currentSubtitle = !widget.isSecondSub
        ? widget.model.subtitleViewModel
            .firstWhere(
              (data) => data.indexOfVide == widget.model.currentIndex,
            )
            .subtitleViewDataFirst
        : widget.model.subtitleViewModel
            .firstWhere(
              (data) => data.indexOfVide == widget.model.currentIndex,
            )
            .subtitleViewDataSecond;
    return Positioned(
      left: currentSubtitle.subtitleOffset.dx + _dragOffset.dx,
      right: 0,
      top: MediaQuery.of(context).size.height / 2 +
          currentSubtitle.subtitleOffset.dy +
          _dragOffset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            // Scale the drag sensitivity by a factor (e.g., 0.5)
            _dragOffset += Offset(0, details.delta.dy * 0.09);
          });
          currentSubtitle.onSubtitleDragUpdate(details);
        },
        onPanEnd: (details) {
          // Optional: Reset offset or implement further logic on drag end
          // setState(() {
          //   _dragOffset = Offset(0, 0);
          // });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WordButtons(
              model: widget.model,
              provider: provider,
              isSecondSub: widget.isSecondSub,
            ),
            const SizedBox(height: 10),
            if (!currentSubtitle.isArabic)
              IconButton(
                onPressed: () {
                  if (currentSubtitle.isShowOriginalSubtitle) {
                    currentSubtitle.removeKnownWordsFromSubtitles();
                  }
                  currentSubtitle.showOriginalSubtitle();
                },
                icon: Icon(
                  currentSubtitle.isShowOriginalSubtitle
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
