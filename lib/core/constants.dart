// Supabase Configuration - Replace with your actual values
const String supabaseUrl = 'https://adyrowyzxxggcbblndcb.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFkeXJvd3l6eHhnZ2NiYmxuZGNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA5Mzg1NzgsImV4cCI6MjA2NjUxNDU3OH0.QUXk1VzRVsGeEbVdG8WiRzE7OiM9akzU6pdwg0yITT4';

// Storage Buckets
const String chalanImagesBucket = 'images';

// Table Names
const String organizationsTable = 'organizations';
const String chalansTable = 'chalans';
const String organizationUsersTable = 'organization_users';

// App Strings
class AppStrings {
  static const String appName = 'Chalan Book';
  static const String login = 'Login';
  static const String signUp = 'Sign Up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account? Sign Up";
  static const String alreadyHaveAccount = "Already have an account? Login";
  static const String organizations = 'Organizations';
  static const String createOrganization = 'Create Organization';
  static const String organizationName = 'Organization Name';
  static const String chalans = 'Chalans';
  static const String addChalan = 'Add Chalan';
  static const String chalanNumber = 'Chalan Number';
  static const String description = 'Description';
  static const String selectImage = 'Select Image';
  static const String camera = 'Camera';
  static const String gallery = 'Gallery';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String share = 'Share';
  static const String addMember = 'Add Member';
  static const String memberEmail = 'Member Email';
  static const String invite = 'Invite';
  static const String switchOrganization = 'Switch Organization';
  static const String noOrganizations = 'No organizations found';
  static const String noChalans = 'No chalans found';
}