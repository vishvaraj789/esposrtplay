class Routes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const otp = '/otp';
  static const completeProfile = '/complete-profile'; // NEW: first-time UserForm step

  static const home = '/home';

  static const leaderboard = '/leaderboard';

  static const wallet = '/wallet';
  static const walletTransactions = '/wallet/transactions';
  static const walletWithdraw = '/wallet/withdraw';

  static const notifications = '/notifications';

  static const chat = '/chat';
  static const teamChat = '/team-chat';

  static const adminDashboard = '/admin';

  // ---- Tournaments ----
  // NOTE: static segments (create) must be registered before ':id' in the router.
  static const tournamentCreate = '/tournaments/create';
  static const tournamentDetails = '/tournaments/:id';
  static const tournamentBracket = '/tournaments/:id/bracket';

  // ---- Matches ----
  static const matches = '/matches';
  static const matchDetails = '/matches/:id';
  static const matchRoom = '/matches/:id/room';
  static const matchResult = '/matches/:id/result';

  // ---- Teams ----
  static const teamCreate = '/teams/create';
  static const teamDetails = '/teams/:id';

  // ---- Profile ----
  static const profileEdit = '/profile/edit';
  static const profileAchievements = '/profile/achievements';

  // ---- Admin (all under /admin, so the prefix guard in _redirect covers them) ----
  static const adminTournaments = '/admin/tournaments';
  static const adminTournamentEdit = '/admin/tournaments/:id';
  static const adminTeams = '/admin/teams';
  static const adminMatches = '/admin/matches';
  static const adminMatchCreate = '/admin/matches/create';
  static const adminMatchManage = '/admin/matches/:id';
  static const adminAnnouncements = '/admin/announcements';

  // ---- Path builders (use these instead of string-concatenating ids) ----
  static String tournamentDetailsPath(String id) => '/tournaments/${Uri.encodeComponent(id)}';
  static String tournamentBracketPath(String id) => '/tournaments/${Uri.encodeComponent(id)}/bracket';
  static String matchDetailsPath(String id) => '/matches/${Uri.encodeComponent(id)}';
  static String matchRoomPath(String id) => '/matches/${Uri.encodeComponent(id)}/room';
  static String matchResultPath(String id) => '/matches/${Uri.encodeComponent(id)}/result';
  static String teamDetailsPath(String id) => '/teams/${Uri.encodeComponent(id)}';
  static String adminTournamentEditPath(String id) => '/admin/tournaments/${Uri.encodeComponent(id)}';
  static String adminMatchManagePath(String id) => '/admin/matches/${Uri.encodeComponent(id)}';
}