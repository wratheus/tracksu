import 'package:flutter/widgets.dart';
import 'package:tracksu/src/about/data/read_build_info.dart';
import 'package:tracksu/src/about/domain/build_info.dart';
import 'package:tracksu/src/about/widgets/screen.dart';

final class AboutMain extends StatefulWidget {
  const AboutMain({super.key});
  @override
  State<AboutMain> createState() => _AboutMainState();
}

final class _AboutMainState extends State<AboutMain> {
  late Future<AppBuildInfo> _info;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _info = _load();
  }

  Future<AppBuildInfo> _load() async {
    _loading = true;
    try {
      return await readBuildInfo();
    } finally {
      _loading = false;
    }
  }

  void _retry() {
    if (_loading) return;
    setState(() => _info = _load());
  }

  @override
  Widget build(BuildContext context) =>
      AboutScreen(info: _info, onRetry: _retry);
}
