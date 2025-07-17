import 'package:chalan_book_app/bloc/chalan/chalan_bloc.dart';
import 'package:chalan_book_app/bloc/organization/organization_bloc.dart';
import 'package:chalan_book_app/bloc/organization/organization_event.dart';
import 'package:chalan_book_app/bloc/organization/organization_state.dart';
import 'package:chalan_book_app/features/filter/advanced-chalan_list-page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../organization/views/organization_list_page.dart';
import '../../../shared/widgets/organization_selector.dart';
import '../../auth/views/splash_page.dart';
import '../../../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ✅ Provide OrganizationBloc first
        BlocProvider(
          create: (context) => OrganizationBloc()..add(LoadOrganizationsRequested()),
        ),
        // ✅ Then provide ChalanBloc that depends on OrganizationBloc
        BlocProvider(
          create: (context) => ChalanBloc(
            organizationBloc: context.read<OrganizationBloc>(),
          ),
        ),
      ],
      child: BlocBuilder<OrganizationBloc, OrganizationState>(
        builder: (context, orgState) {
          final pages = [
            AdvancedChalanListPage(organization: orgState.currentOrg),
            OrganizationListPage(
              onOrganizationCreated: () {
                context.read<OrganizationBloc>().add(LoadOrganizationsRequested());
              },
            ),
          ];

          return Scaffold(
            appBar: AppBar(
              title: Text(orgState.currentOrg?.name ?? 'Chalan Book'),
              actions: [
                if (orgState.organizations.isNotEmpty)
                  OrganizationSelector(
                    organizations: orgState.organizations,
                    currentOrganization: orgState.currentOrg,
                    onOrganizationChanged: (org) {
                      context.read<OrganizationBloc>().add(SelectOrganization(org));
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
                          Text('Logout')
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            body: IndexedStack(index: _currentIndex, children: pages),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: 'Chalans',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business),
                  label: 'Organizations',
                ),
              ],
            ),
          );
        },
      ),
    );
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