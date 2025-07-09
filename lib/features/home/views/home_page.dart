import 'package:chalan_book_app/bloc/home/home_bloc.dart';
import 'package:chalan_book_app/bloc/home/home_event.dart';
import 'package:chalan_book_app/bloc/home/home_state.dart';
import 'package:chalan_book_app/bloc/nav_bar_cubit.dart';
import 'package:chalan_book_app/core/constants/strings.dart';
import 'package:chalan_book_app/features/auth/views/splash_page.dart';
import 'package:chalan_book_app/features/organization/views/chalan_list_page.dart';
import 'package:chalan_book_app/features/organization/views/organization_list_page.dart';
import 'package:chalan_book_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    final navBar = context.watch<NavBarCubit>();
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is HomeError) {
          return Scaffold(body: Center(child: Text(state.message)));
        }

        if (state is HomeLoaded) {
          final currentOrganization = state.currentOrganization;

          final pages = [
            ChalanListPage(organization: currentOrganization),
            OrganizationListPage(
              onOrganizationCreated: () {
                context.read<HomeBloc>().add(LoadOrganizations());
              },
            ),
          ];

          return Scaffold(
            appBar: AppBar(
              title: Text(currentOrganization.name),
              actions: [
                // if (organizations.isNotEmpty)
                //   OrganizationSelector(
                //     organizations: organizations,
                //     currentOrganization: currentOrganization,
                //     onOrganizationChanged: (org) {
                //       final selectedOrg = context.read<OrganizationSelectionCubit>().state.selectedOrganization;
                //       context.read<HomeBloc>().add(ChangeOrganization(org));
                //     },
                //   ),
                PopupMenuButton(
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      onTap: () async {
                        await supabase.auth.signOut();
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SplashPage(),
                            ),
                          );
                        }
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            body: IndexedStack(index: navBar.state, children: pages),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: navBar.state,
              onTap: (i) {
                if (i == 1) {
                  context.read<HomeBloc>().add(LoadOrganizations());
                }
                context.read<NavBarCubit>().updateTab(i);
              },

              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: AppStrings.chalans,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business),
                  label: AppStrings.organizations,
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
