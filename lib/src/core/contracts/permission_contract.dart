/// Identity of the currently authenticated user [PermissionMiddleware] and [PluginRegistry].
class UserIdentity {
  final String userId;
  final String? email;
  final String persona;

  const UserIdentity({required this.userId, required this.persona, this.email});
}

/// Create instance where need permission evaluation like visibility, route access, etc.[PermissionMiddleware] [PluginRegistry].
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

/// Implement this in the consuming app to encode your Role-Based Access Control logic.[DefaultPluginDescription] and [AppBootstrap].
abstract interface class PermissionPolicyAgreement {
  //method Definition
  PermissionResult evaluate(PermissionContext context);
}

/// Default open policy — grants everything. Use only in development.
class OpenDefaultDevelopmentPolicy implements PermissionPolicyAgreement {
  const OpenDefaultDevelopmentPolicy();

  @override
  PermissionResult evaluate(PermissionContext context) =>
      const PermissionResult.granted();
}

/// Restricts access to users whose persona is in the [allowedPersonas] set.
class PersonaPermissionPolicy implements PermissionPolicyAgreement {
  final Set<String> allowedPersonas;
  final String? denyReason;

  const PersonaPermissionPolicy(this.allowedPersonas, {this.denyReason});

  @override
  PermissionResult evaluate(PermissionContext context) {
    final normalizedPersona = context.user.persona.trim().toLowerCase();
    final normalizedAllowedPersonas = allowedPersonas
        .map((persona) => persona.trim().toLowerCase())
        .toSet();

    if (normalizedAllowedPersonas.contains(normalizedPersona)) {
      return const PermissionResult.granted();
    }
    return PermissionResult.denied(
      denyReason ??
          'Role ${context.user.persona} cannot access ${context.moduleId}',
    );
  }
}
