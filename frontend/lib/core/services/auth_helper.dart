// iFridge — Auth Helper
// =====================
// Centralized user ID resolution. Returns the current authenticated
// user's ID, or the legacy demo UUID as a fallback for guest sessions.

import 'package:supabase_flutter/supabase_flutter.dart';

/// The legacy demo user UUID from seed_data.sql.
const _fallbackDemoId = '00000000-0000-4000-8000-000000000001';

/// Returns the current authenticated user's ID.
/// Falls back to the demo UUID for unauthenticated/guest users.
String currentUserId() {
  final user = Supabase.instance.client.auth.currentUser;
  return user?.id ?? _fallbackDemoId;
}

/// Returns true if a user is currently signed in (not anonymous guest).
bool isAuthenticated() {
  final session = Supabase.instance.client.auth.currentSession;
  return session != null;
}

/// Returns the display name from Supabase auth metadata, or 'Chef'.
String currentUserName() {
  final user = Supabase.instance.client.auth.currentUser;
  return user?.userMetadata?['full_name'] as String? ??
      user?.userMetadata?['name'] as String? ??
      user?.email?.split('@').first ??
      'Chef';
}

/// Returns the avatar URL from Supabase auth metadata, or null.
String? currentUserAvatar() {
  final user = Supabase.instance.client.auth.currentUser;
  return user?.userMetadata?['avatar_url'] as String? ??
      user?.userMetadata?['picture'] as String?;
}
