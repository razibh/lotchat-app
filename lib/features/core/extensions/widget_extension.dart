import 'package:flutter/material.dart';

extension WidgetExtension on Widget {
  // Padding extensions
  Widget paddingAll(double value) {
    return Padding(
      padding: EdgeInsets.all(value),
      child: this,
    );
  }

  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
      child: this,
    );
  }

  Widget paddingLTRB(double left, double top, double right, double bottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: this,
    );
  }

  // Margin extensions
  Widget marginAll(double value) {
    return Container(
      margin: EdgeInsets.all(value),
      child: this,
    );
  }

  Widget marginSymmetric({double horizontal = 0, double vertical = 0}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  Widget marginOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Container(
      margin: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
      child: this,
    );
  }

  // Size extensions
  Widget size(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: this,
    );
  }

  Widget width(double width) {
    return SizedBox(
      width: width,
      child: this,
    );
  }

  Widget height(double height) {
    return SizedBox(
      height: height,
      child: this,
    );
  }

  Widget square(double dimension) {
    return SizedBox(
      width: dimension,
      height: dimension,
      child: this,
    );
  }

  Widget constrained({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth ?? 0,
        maxWidth: maxWidth ?? double.infinity,
        minHeight: minHeight ?? 0,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: this,
    );
  }

  // Decoration extensions
  Widget rounded(double radius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: this,
    );
  }

  Widget circular() {
    return ClipOval(child: this);
  }

  Widget border({
    Color color = Colors.grey,
    double width = 1,
    double radius = 0,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: width),
        borderRadius: radius > 0 ? BorderRadius.circular(radius) : null,
      ),
      child: this,
    );
  }

  Widget shadow({
    Color color = Colors.black,
    double blurRadius = 10,
    double spreadRadius = 0,
    Offset offset = Offset.zero,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
            offset: offset,
          ),
        ],
      ),
      child: this,
    );
  }

  Widget gradient({
    required Gradient gradient,
    double? radius,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: radius != null ? BorderRadius.circular(radius) : null,
      ),
      child: this,
    );
  }

  // Interactive extensions
  Widget onTap(VoidCallback callback) {
    return GestureDetector(
      onTap: callback,
      child: this,
    );
  }

  Widget onLongPress(VoidCallback callback) {
    return GestureDetector(
      onLongPress: callback,
      child: this,
    );
  }

  Widget onDoubleTap(VoidCallback callback) {
    return GestureDetector(
      onDoubleTap: callback,
      child: this,
    );
  }

  Widget inkWell({
    VoidCallback? onTap,
    Color splashColor = Colors.transparent,
    Color highlightColor = Colors.transparent,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: splashColor,
      highlightColor: highlightColor,
      child: this,
    );
  }

  // Visibility extensions
  Widget visible(bool condition) {
    return condition ? this : const SizedBox.shrink();
  }

  Widget opacity(double value) {
    return Opacity(
      opacity: value,
      child: this,
    );
  }

  Widget offstage(bool offstage) {
    return Offstage(
      offstage: offstage,
      child: this,
    );
  }

  // Alignment extensions
  Widget centered() {
    return Center(child: this);
  }

  Widget aligned(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: this,
    );
  }

  Widget positioned({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: this,
    );
  }

  Widget expanded({int flex = 1}) {
    return Expanded(
      flex: flex,
      child: this,
    );
  }

  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(
      flex: flex,
      fit: fit,
      child: this,
    );
  }

  // Container extensions
  Widget backgroundColor(Color color) {
    return ColoredBox(
      color: color,
      child: this,
    );
  }

  Widget clip(double radius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: this,
    );
  }

  // Tooltip
  Widget tooltip(String message, {double? waitDuration}) {
    return Tooltip(
      message: message,
      waitDuration: Duration(milliseconds: waitDuration?.toInt() ?? 500),
      child: this,
    );
  }

  // Simple animations without VSync
  Widget fadeIn({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeIn,
  }) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: duration,
      curve: curve,
      child: this,
    );
  }

  Widget slideIn({
    Duration duration = const Duration(milliseconds: 300),
    Offset begin = const Offset(1, 0),
    Curve curve = Curves.easeOut,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: begin, end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, offset, child) {
        return Transform.translate(
          offset: offset * 100, // Convert to pixels
          child: child,
        );
      },
      child: this,
    );
  }

  Widget scaleIn({
    Duration duration = const Duration(milliseconds: 300),
    double begin = 0.8,
    Curve curve = Curves.elasticOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: begin, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: this,
    );
  }

  Widget sizeTransition({
    Duration duration = const Duration(milliseconds: 300),
    Axis axis = Axis.vertical,
    Curve curve = Curves.easeOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, factor, child) {
        if (axis == Axis.vertical) {
          return ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: factor,
              child: child,
            ),
          );
        } else {
          return ClipRect(
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: factor,
              child: child,
            ),
          );
        }
      },
      child: this,
    );
  }

  Widget rotationTransition({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, turns, child) {
        return Transform.rotate(
          angle: turns * 2 * 3.14159, // Full rotation
          child: child,
        );
      },
      child: this,
    );
  }
}

extension ListWidgetExtension on List<Widget> {
  // Add spacing between widgets
  List<Widget> spaced(double space) {
    final result = <Widget>[];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) {
        result.add(SizedBox(width: space, height: space));
      }
    }
    return result;
  }

  // Wrap in row
  Widget toRow({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: this,
    );
  }

  // Wrap in column
  Widget toColumn({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: this,
    );
  }

  // Wrap in stack
  Widget toStack({
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    StackFit fit = StackFit.loose,
    Clip clipBehavior = Clip.hardEdge,
  }) {
    return Stack(
      alignment: alignment,
      fit: fit,
      clipBehavior: clipBehavior,
      children: this,
    );
  }

  // Wrap in list view
  Widget toListView({
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? controller,
    EdgeInsets? padding,
  }) {
    return ListView(
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      padding: padding,
      children: this,
    );
  }

  // Wrap in grid view
  Widget toGridView({
    required int crossAxisCount,
    double crossAxisSpacing = 0,
    double mainAxisSpacing = 0,
    double childAspectRatio = 1,
    EdgeInsets? padding,
  }) {
    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      padding: padding,
      children: this,
    );
  }

  // Wrap in wrap
  Widget toWrap({
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    double spacing = 0,
    double runSpacing = 0,
  }) {
    return Wrap(
      direction: direction,
      alignment: alignment,
      spacing: spacing,
      runSpacing: runSpacing,
      children: this,
    );
  }
}