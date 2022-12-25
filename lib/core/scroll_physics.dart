//custom page changing speed because by default on swiping _tabController.addListener(() { is fired later than on tap
import 'package:flutter/material.dart';

class TabBarScrollPhysics extends ScrollPhysics {
  const TabBarScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  TabBarScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return TabBarScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 200,
        stiffness: 100,
        damping: 0.4,
      );
}

class PageNewsScrollPhysics extends ScrollPhysics {
  const PageNewsScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  PageNewsScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PageNewsScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 100,
        stiffness: 100,
        damping: 0.4,
      );
}
