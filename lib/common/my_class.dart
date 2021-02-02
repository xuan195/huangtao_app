import 'package:flutter/material.dart';

abstract class RedditPage extends StatefulWidget {
  RedditPage({this.data});
  final ValueNotifierData data;
  Map<String, dynamic> botdata = {};
  bool active = false;
}

class ValueNotifierData extends ValueNotifier<int> {
  ValueNotifierData(value) : super(value);
}
