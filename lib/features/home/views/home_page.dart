import 'package:chalan_book_app/core/constants/app_colors.dart';
import 'package:chalan_book_app/core/extensions/context_extension.dart';
import 'package:chalan_book_app/features/chalan/views/chalan_list_page.dart';
import 'package:chalan_book_app/features/organization/widgets/organization_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../organization/bloc/organization_bloc.dart';
import '../../organization/views/organization_list_page.dart';
import '../../profile/views/profile_page.dart';
import '../../shared/bloc/nav_bar_cubit.dart';
import '../../shared/widgets/app_drawer.dart';

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
                ChalanListPage(),
                OrganizationListPage(),
                const ProfilePage(),
                // const ImageSetupPage(),
                // const ChalanUploadPage(),
                //  OrganizationSelector(currentOrganization: orgState.currentOrg, organizations: orgState.organizations, onOrganizationChanged: (org) {
                //   context.read<OrganizationBloc>().add(SelectOrganization(org));
                // }),
              ];

              return PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) {
                  if (!didPop) {
                    if (currentIndex != 0) {
                      context.read<NavBarCubit>().updateTab(0);
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  }
                },
                child: Scaffold(
                  appBar: AppBar(
                    title: Text(_getAppBarTitle(currentIndex, orgState)),
                    backgroundColor: context.colors.surface,
                    elevation: 0,
                    scrolledUnderElevation: 1,
                    actions: (currentIndex == 0)
                        ? [
                            OrganizationSelector(
                              currentOrganization: orgState.currentOrg,
                              organizations: orgState.organizations,
                              onOrganizationChanged: (org) {
                                context.read<OrganizationBloc>().add(
                                  SelectOrganization(org),
                                );
                              },
                            ),
                          ]
                        : null,
                  ),
                  drawer: const AppDrawer(),
                  body: IndexedStack(index: currentIndex, children: pages),
                  bottomNavigationBar: NavigationBar(
                    indicatorColor: AppColors.primaryAlpha30,
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
                      // NavigationDestination(
                      //   icon: Icon(Icons.settings_outlined),
                      //   selectedIcon: Icon(Icons.settings),
                      //   label: 'Settings',
                      // )
                    ],
                  ),
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
      case 3:
        return 'Settings';
      default:
        return 'Chalan Book';
    }
  }
}
