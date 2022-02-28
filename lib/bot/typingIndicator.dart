
import 'package:flutter/material.dart';


class JumpingDots extends StatefulWidget {
  final int numberOfDots;

  const JumpingDots({Key key, this.numberOfDots = 3}) : super(key: key);

  @override
  _JumpingDotsState createState() => _JumpingDotsState();
}

class _JumpingDotsState extends State<JumpingDots>
    with TickerProviderStateMixin {
  List<AnimationController> _animationControllers;

  List<Animation<double>> _animations = List();

  int animationDuration = 150;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

      return Center(
        child: Container(
          height: 40,
          color: Colors.white,

            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.numberOfDots, (index) {
            //AnimatedBuilder widget will rebuild it self when
            //_animationControllers[index] value changes.
            return AnimatedBuilder(
              animation: _animationControllers[index],
              builder: (context, child) {
                return Container(
                  padding: EdgeInsets.all(2.5),
                  //Transform widget's translate constructor will help us to move the dot
                  //in upward direction by changing the offset of the dot.
                  //X-axis position of dot will not change.
                  //Only Y-axis position will change.
                  child: Transform.translate(
                    offset: Offset(0, _animations[index].value),
                    child: DotWidget(),
                  ),
                );
              },
            );
          }).toList(),
        )),
      );
  }

  void _initAnimation() {
    ///initialization of _animationControllers
    ///each _animationController will have same animation duration
    _animationControllers = List.generate(
      widget.numberOfDots,
          (index) {
        return AnimationController(
            vsync: this, duration: Duration(milliseconds: animationDuration));
      },
    ).toList();

    ///initialization of _animations
    ///here end value is -20
    ///end value is amount of jump.
    ///and we want our dot to jump in upward direction
    for (int i = 0; i < widget.numberOfDots; i++) {
      _animations.add(
          Tween<double>(begin: 0, end: -6).animate(_animationControllers[i]));
    }

    for (int i = 0; i < widget.numberOfDots; i++) {
      _animationControllers[i].addStatusListener((status) {
        //On Complete
        if (status == AnimationStatus.completed) {
          //return of original postion
          _animationControllers[i].reverse();
          //if it is not last dot then start the animation of next dot.
          if (i != widget.numberOfDots - 1) {
            _animationControllers[i + 1].forward();
          }
        }
        //if last dot is back to its original postion then start animation of the first dot.
        // now this animation will be repeated infinitely
        if (i == widget.numberOfDots - 1 &&
            status == AnimationStatus.dismissed) {
          _animationControllers[0].forward();
        }
      });
    }

    //trigger animtion of first dot to start the whole animation.
    _animationControllers.first.forward();
  }

}

class DotWidget extends StatelessWidget {
  const DotWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: Theme.of(context).primaryColor),
      height: 10,
      width: 10,
    );
  }
}


/*
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({
    Key? key,
    this.showIndicator = false,
    this.bubbleColor = const Color(0xFF646b7f),
    this.flashingCircleDarkColor = const Color(0xFF333333),
    this.flashingCircleBrightColor = const Color(0xFFaec1dd),
  }) : super(key: key);

  final bool showIndicator;
  final Color bubbleColor;
  final Color flashingCircleDarkColor;
  final Color flashingCircleBrightColor;

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _appearanceController;

  late Animation<double> _indicatorSpaceAnimation;

  late Animation<double> _smallBubbleAnimation;
  late Animation<double> _mediumBubbleAnimation;
  late Animation<double> _largeBubbleAnimation;

  late AnimationController _repeatingController;
  final List<Interval> _dotIntervals = const [
    Interval(0.25, 0.8),
    Interval(0.35, 0.9),
    Interval(0.45, 1.0),
  ];

  @override
  void initState() {
    super.initState();

    _appearanceController = AnimationController(
      vsync: this,
    )..addListener(() {
      setState(() {});
    });

    _indicatorSpaceAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    ).drive(Tween<double>(
      begin: 0.0,
      end: 60.0,
    ));

    _smallBubbleAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      reverseCurve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );
    _mediumBubbleAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      reverseCurve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );
    _largeBubbleAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    _repeatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.showIndicator) {
      _showIndicator();
    }
  }

  @override
  void didUpdateWidget(TypingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showIndicator != oldWidget.showIndicator) {
      if (widget.showIndicator) {
        _showIndicator();
      } else {
        _hideIndicator();
      }
    }
  }

  @override
  void dispose() {
    _appearanceController.dispose();
    _repeatingController.dispose();
    super.dispose();
  }

  void _showIndicator() {
    _appearanceController
      ..duration = const Duration(milliseconds: 750)
      ..forward();
    _repeatingController.repeat();
  }

  void _hideIndicator() {
    _appearanceController
      ..duration = const Duration(milliseconds: 150)
      ..reverse();
    _repeatingController.stop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _indicatorSpaceAnimation,
      builder: (context, child) {
        return SizedBox(
          height: _indicatorSpaceAnimation.value,
          child: child,
        );
      },
      child: Stack(
        children: [
          _buildAnimatedBubble(
            animation: _smallBubbleAnimation,
            left: 8,
            bottom: 8,
            bubble: _buildCircleBubble(8),
          ),
          _buildAnimatedBubble(
            animation: _mediumBubbleAnimation,
            left: 10,
            bottom: 10,
            bubble: _buildCircleBubble(16),
          ),
          _buildAnimatedBubble(
            animation: _largeBubbleAnimation,
            left: 12,
            bottom: 12,
            bubble: _buildStatusBubble(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBubble({
    Animation<double> animation,
    required double left,
    required double bottom,
    required Widget bubble,
  }) {
    return Positioned(
      left: left,
      bottom: bottom,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.scale(
            scale: animation.value,
            alignment: Alignment.bottomLeft,
            child: child,
          );
        },
        child: bubble,
      ),
    );
  }

  Widget _buildCircleBubble(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.bubbleColor,
      ),
    );
  }

  Widget _buildStatusBubble() {
    return Container(
      width: 85,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        color: widget.bubbleColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFlashingCircle(0),
          _buildFlashingCircle(1),
          _buildFlashingCircle(2),
        ],
      ),
    );
  }

  Widget _buildFlashingCircle(int index) {
    return AnimatedBuilder(
      animation: _repeatingController,
      builder: (context, child) {
        final circleFlashPercent =
        _dotIntervals[index].transform(_repeatingController.value);
        final circleColorPercent = sin(pi * circleFlashPercent);

        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.lerp(widget.flashingCircleDarkColor,
                widget.flashingCircleBrightColor, circleColorPercent),
          ),
        );
      },
    );
  }
}
*/