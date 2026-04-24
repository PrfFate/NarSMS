String normalizeRole(String? role) {
  return role?.toLowerCase().trim() ?? '';
}

bool isFielderRole(String? role) {
  return normalizeRole(role) == 'fielder';
}

bool isAdminRole(String? role) {
  final normalized = normalizeRole(role);
  return normalized == 'admin' || normalized == 'administrator';
}
