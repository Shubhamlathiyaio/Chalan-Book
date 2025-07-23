import 'package:chalan_book_app/core/extensions/context_extension.dart';
import 'package:chalan_book_app/features/filter/chalan_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/views/splash_page.dart';
import '../../organization/bloc/organization_bloc.dart';
import '../../organization/views/organization_list_page.dart';
import '../../profile/views/profile_page.dart';
import '../../shared/bloc/nav_bar_cubit.dart';
import '../../shared/widgets/app_drawer.dart';
import '../../shared/widgets/organization_selector.dart';
import '../../../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavBarCubit(),
      child: BlocBuilder<OrganizationBloc, OrganizationState>(
        builder: (context, orgState) {
          return BlocBuilder<NavBarCubit, int>(
            builder: (context, currentIndex) {
              final pages = [
                ChalanListPage(
                  organization: orgState.currentOrg,
                ),
                OrganizationListPage(
                  onOrganizationCreated: () {
                    context.read<OrganizationBloc>().add(LoadOrganizations());
                  },
                ),
                const ProfilePage(),
              ];

              return Scaffold(
                appBar: AppBar(
                  title: Text(_getAppBarTitle(currentIndex, orgState)),
                  backgroundColor: context.colors.surface,
                  elevation: 0,
                  scrolledUnderElevation: 1,
                  actions: [
                    if (orgState.organizations.isNotEmpty && currentIndex == 0)
                      OrganizationSelector(
                        organizations: orgState.organizations,
                        currentOrganization: orgState.currentOrg,
                        onOrganizationChanged: (org) {
                          context.read<OrganizationBloc>().add(
                            SelectOrganization(org),
                          );
                        },
                      ),
                    PopupMenuButton(
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          onTap: _logout,
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
                drawer: const AppDrawer(),
                body: IndexedStack(index: currentIndex, children: pages),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (index) {
                    context.read<NavBarCubit>().updateTab(index);
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.receipt_long_outlined),
                      selectedIcon: Icon(Icons.receipt_long),
                      label: 'Chalans',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.business_outlined),
                      selectedIcon: Icon(Icons.business),
                      label: 'Organizations',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getAppBarTitle(int index, OrganizationState orgState) {
    switch (index) {
      case 0:
        return orgState.currentOrg?.name ?? 'Chalan Book';
      case 1:
        return 'Organizations';
      case 2:
        return 'Profile';
      default:
        return 'Chalan Book';
    }
  }

  void _logout() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SplashPage()),
      );
    }
  }
}
