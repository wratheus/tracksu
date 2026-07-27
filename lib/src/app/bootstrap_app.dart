import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_container.dart';
import 'package:tracksu/src/_core/dependencies/register_dependencies.dart';
import 'package:tracksu/src/app/app_main.dart';

final class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

final class _BootstrapAppState extends State<BootstrapApp> {
  late Future<DepsContainer> _dependenciesFuture;
  var _isBootstrapping = true;

  @override
  void initState() {
    super.initState();
    _dependenciesFuture = _registerDependencies();
  }

  Future<DepsContainer> _registerDependencies() async {
    try {
      return await registerDependencies();
    } finally {
      if (mounted) {
        setState(() {
          _isBootstrapping = false;
        });
      }
    }
  }

  void _retry() {
    if (_isBootstrapping) {
      return;
    }

    setState(() {
      _isBootstrapping = true;
      _dependenciesFuture = _registerDependencies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DepsContainer>(
      future: _dependenciesFuture,
      builder: (BuildContext context, AsyncSnapshot<DepsContainer> snapshot) {
        if (snapshot.hasData) {
          return AppMain(dependencies: snapshot.requireData);
        }

        if (snapshot.hasError) {
          return _BootstrapFailure(
            isRetrying: _isBootstrapping,
            onRetry: _retry,
          );
        }

        return const _BootstrapLoading();
      },
    );
  }
}

final class _BootstrapLoading extends StatelessWidget {
  const _BootstrapLoading();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

final class _BootstrapFailure extends StatelessWidget {
  const _BootstrapFailure({required this.isRetrying, required this.onRetry});

  final bool isRetrying;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: isRetrying ? null : onRetry,
            child: const Text('Retry startup'),
          ),
        ),
      ),
    );
  }
}
