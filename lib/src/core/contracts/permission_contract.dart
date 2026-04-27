/// Identity of the currently authenticated user.
class UserIdentity {
  final String userId;
  final String? email;
  final String persona; // e.g. 'manager', 'operator', 'admin'
  final String? tenantId;
  final Set<String> featureFlags;

  const UserIdentity({
    required this.userId,
    required this.persona,
    this.email,
    this.tenantId,
    this.featureFlags = const {},
  });
}

/// Context passed to every permission evaluation.
class PermissionContext {
  final UserIdentity user;
  final String moduleId;
  final String? routePath;

  const PermissionContext({
    required this.user,
    required this.moduleId,
    this.routePath,
  });
}

/// Result of a permission evaluation.
class PermissionResult {
  final bool granted;
  final String? reason;

  const PermissionResult.granted() : granted = true, reason = null;
  const PermissionResult.denied(this.reason) : granted = false;
}

/// A callable that evaluates whether a given context has permission.
/// Implement this in the consuming app to encode your RBAC logic.
abstract class PermissionPolicy {
  PermissionResult evaluate(PermissionContext context);
}

/// Default open policy — grants everything. Use only in development.
class OpenPermissionPolicy implements PermissionPolicy {
  const OpenPermissionPolicy();

  @override
  PermissionResult evaluate(PermissionContext context) =>
      const PermissionResult.granted();
}

/// Restricts access to users whose persona is in the [allowedPersonas] set.
class PersonaPermissionPolicy implements PermissionPolicy {
  final Set<String> allowedPersonas;
  final String? denyReason;

  const PersonaPermissionPolicy(
    this.allowedPersonas, {
    this.denyReason,
  });

  @override
  PermissionResult evaluate(PermissionContext context) {
    if (allowedPersonas.contains(context.user.persona)) {
      return const PermissionResult.granted();
    }
    return PermissionResult.denied(
      denyReason ?? 'Role ${context.user.persona} cannot access ${context.moduleId}',
    );
  }
}
