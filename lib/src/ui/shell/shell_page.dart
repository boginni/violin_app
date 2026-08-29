import 'package:flutter/material.dart';
import 'package:violin_app/src/ui/tuner/pages/tuner_page.dart';

import '../home/pages/home_page.dart';
import 'controller/shell_controller.dart';
import 'controller/shell_store.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({
    required this.controller,
    super.key,
  });

  final ShellController controller;

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  ShellController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        init();
      },
    );
  }

  Future<void> init() async {
    await Future.delayed(
      const .new(milliseconds: 250),
    );

    widget.controller.store.state = const ShellSuccessState();
  }

  @override
  Widget build(BuildContext context) {
    return TunerPage(
      controller: controller.tunerController,
    );
  }
}
