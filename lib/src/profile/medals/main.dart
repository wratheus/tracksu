import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:tracksu/src/profile/medals/bloc/bloc.dart';
import 'package:tracksu/src/profile/medals/data/remote_source.dart';
import 'package:tracksu/src/profile/medals/data/repository.dart';
import 'package:tracksu/src/profile/medals/widgets/screen.dart';
import 'package:tracksu_network/tracksu_network.dart';

/// Owns a public web client, deliberately without API auth or cookie interceptors.
final class MedalsMain extends StatefulWidget {
  const MedalsMain({required this.userId, super.key});
  final int userId;
  @override
  State<MedalsMain> createState() => _MedalsMainState();
}

final class _MedalsMainState extends State<MedalsMain> {
  late final RestClient _client;
  @override
  void initState() {
    super.initState();
    _client = HttpRestClient(
      client: http.Client(),
      baseUri: Uri.https('osu.ppy.sh'),
    );
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider<MedalsBloc>(
    key: ValueKey<int>(widget.userId),
    create: (_) => MedalsBloc(
      repository: MedalsRepositoryImpl(MedalsRemoteSource(_client)),
      userId: widget.userId,
    )..add(const MedalsLoadRequested()),
    child: MedalsScreen(userId: widget.userId),
  );
}
