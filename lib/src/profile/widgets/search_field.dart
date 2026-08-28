import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/bloc/bloc.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';

final class ProfileSearchField extends StatefulWidget {
  const ProfileSearchField({super.key});

  @override
  State<ProfileSearchField> createState() => _ProfileSearchFieldState();
}

final class _ProfileSearchFieldState extends State<ProfileSearchField> {
  final TextEditingController _controller = TextEditingController();
  bool _invalid = false;

  void _submit() {
    final String query = _controller.text.trim();
    final ProfileUserReference user;
    try {
      final int? id = int.tryParse(query);
      user = id == null ? ProfileUsername(query) : ProfileUserId(id);
    } on ArgumentError {
      setState(() => _invalid = true);
      return;
    }
    setState(() => _invalid = false);
    FocusScope.of(context).unfocus();
    context.read<ProfileBloc>().add(ProfileLookupRequested(user));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        keyboardType: TextInputType.text,
        maxLines: 1,
        autocorrect: false,
        onSubmitted: (_) => _submit(),
        onChanged: (_) {
          if (_invalid) {
            setState(() => _invalid = false);
          }
        },
        decoration: InputDecoration(
          labelText: context.t.profileSearchHint,
          helperText: context.t.profileSearchHelp,
          errorText: _invalid ? context.t.profileSearchInvalid : null,
          errorMaxLines: 2,
          suffixIcon: IconButton(
            tooltip: context.t.profileSearch,
            icon: const Icon(Icons.search),
            onPressed: _submit,
          ),
        ),
      ),
    );
  }
}
