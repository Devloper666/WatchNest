import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionLabel extends StatefulWidget {
  const VersionLabel({super.key});

  @override
  State<VersionLabel> createState() => _VersionLabelState();
}

class _VersionLabelState extends State<VersionLabel> {
  String _version = '—';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) {
      return;
    }
    setState(() => _version = packageInfo.version);
  }

  @override
  Widget build(BuildContext context) {
    return Text(_version);
  }
}
