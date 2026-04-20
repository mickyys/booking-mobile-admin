import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reservaloya_admin/features/users/presentation/bloc/users_bloc.dart';
import 'package:reservaloya_admin/features/users/presentation/bloc/users_event.dart';
import 'package:reservaloya_admin/features/users/presentation/bloc/users_state.dart';
import 'package:reservaloya_admin/injection_container.dart' as di;
import 'package:reservaloya_admin/core/widgets/app_drawer.dart';
import 'package:reservaloya_admin/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<UsersBloc>()..add(LoadUsers()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: Text(
            'Usuarios',
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
        ),
        body: BlocBuilder<UsersBloc, UsersState>(
          builder: (context, state) {
            if (state is UsersLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            } else if (state is UsersLoaded) {
              if (state.users.isEmpty) {
                return const Center(
                  child: Text('No hay usuarios registrados.'),
                );
              }
              return ListView.builder(
                itemCount: state.users.length,
                itemBuilder: (context, index) {
                  final user = state.users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.picture),
                      onBackgroundImageError: (exception, stackTrace) => const Icon(Icons.person),
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: Text(
                      user.lastLogin.toString().split(' ')[0], // Display only date
                      style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
                    ),
                  );
                },
              );
            } else if (state is UsersError) {
              return Center(
                child: Text(state.message),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
