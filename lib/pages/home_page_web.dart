import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'home_page_desktop.dart';
import 'home_page_mobile.dart';



class HomePageWeb extends StatelessWidget {
  final int tabIndex;

  const HomePageWeb({
    Key key,
    @required this.tabIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ResponsiveBuilder(
    builder: (context, sizingInfo) => sizingInfo.isDesktop
        ? HomePageDesktop()
        : HomePageMobile(tabIndex: tabIndex),
  );
}