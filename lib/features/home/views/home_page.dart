import 'package:chalan_book_app/core/constants.dart';
import 'package:chalan_book_app/core/models/organization.dart';
import 'package:chalan_book_app/features/auth/views/splash_page.dart';
import 'package:chalan_book_app/features/organization/views/chalan_list_page.dart';
import 'package:chalan_book_app/features/organization/views/organization_list_page.dart';
import 'package:chalan_book_app/main.dart';
import 'package:chalan_book_app/shared/widgets/organization_selector.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  Organization? _currentOrganization;
  List<Organization> _organizations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  Future<void> _loadOrganizations() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from(organizationUsersTable)
          .select('organization_id, organizations:organization_id(*)')
          .eq('user_id', user.id);

      final orgs = response
          .where((row) => row['organizations'] != null)
          .map<Organization>((row) => Organization.fromJson(row['organizations']))
          .toList();

      setState(() {
        _organizations = orgs;
        if (orgs.isNotEmpty && _currentOrganization == null) {
          _currentOrganization = orgs.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        context.showSnackBar('Error loading organizations: $e', isError: true);
      }
    }
  }

  void _onOrganizationChanged(Organization org) {
    setState(() => _currentOrganization = org);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = [
      ChalanListPage(organization: _currentOrganization),
      OrganizationListPage(onOrganizationCreated: _loadOrganizations),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentOrganization?.name ?? AppStrings.appName),
        actions: [
          if (_organizations.isNotEmpty)
            OrganizationSelector(
              organizations: _organizations,
              currentOrganization: _currentOrganization,
              onOrganizationChanged: _onOrganizationChanged,
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
        onTap: (i) async {
          if (i == 1) {
            await _loadOrganizations();
          }
          setState(() => _currentIndex = i);
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
}