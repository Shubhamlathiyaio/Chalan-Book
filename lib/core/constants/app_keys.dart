class AppKeys {
  // Supabase Configuration
  static const String newSupabaseUrl =
      'https://jzhrtmwaqezmrmyoqeka.supabase.co';
  static const String newSupabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp6aHJ0bXdhcWV6bXJteW9xZWthIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQxMDMxMTEsImV4cCI6MjA2OTY3OTExMX0.yQnJtrR3XD5gtwYR_ZrZy9Ab3Td9nL2p9rINPYRFDJs';

  static const String oldSupabaseUrl =
      'https://adyrowyzxxggcbblndcb.supabase.co';
  static const String oldSupabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFkeXJvd3l6eHhnZ2NiYmxuZGNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA5Mzg1NzgsImV4cCI6MjA2NjUxNDU3OH0.QUXk1VzRVsGeEbVdG8WiRzE7OiM9akzU6pdwg0yITT4';

  // Mega Configuration
  static const String megaEmail = 'supershubham1121@gmail.com';
  static const String megaPassword = r'Super$hubham1';

  // Edge Function URLs
  static const String uploadToMegaUrl =
      '${newSupabaseUrl}/functions/v1/upload-to-mega';
  static const String getMegaImageUrl =
      '${newSupabaseUrl}/functions/v1/get-mega-image';
  static const String removeImageUrl =
      '${newSupabaseUrl}/functions/v1/remove-image';
  static const String addMemberToOrgUrl =
      '${newSupabaseUrl}/functions/v1/add-member-in-organization';

  // Storage Buckets
  static const String chalanImagesBucket = 'images';

  // Table Names
  static const String organizationsTable = 'organizations';
  static const String chalansTable = 'chalans';
  static const String organizationUsersTable = 'organization_users';
  static const String profilesTable = 'profiles';

  // Local Storage Keys
  static const String selectedOrgId = 'selected_org_id';
}
