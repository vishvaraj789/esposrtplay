import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../constants/admin_config.dart';

Future<bool> userHasAdminClaim(User user, {bool forceRefresh = false}) async {
  try {
    final result = await user.getIdTokenResult(forceRefresh);
    debugPrint('[admin] email=${user.email} verified=${user.emailVerified} claims=${result.claims}');
    return result.claims?[kAdminClaim] == true;
  } catch (e) {
    debugPrint('[admin] claim check failed: $e');
    return false;
  }
}