# Create a secret with standard age.secrets structure
# Usage: lib.mkSecret { name = "mysecret"; file = "../../secrets/mysecret.age"; }
{lib, ...}: {
  # Create a secret with a specific file path
  mkSecret = {
    name,
    file,
    owner ? "root",
    mode ? "0400",
    group ? null,
  }:
    {
      file = file;
      owner = owner;
      mode = mode;
    }
    // lib.optionalAttrs (group != null) {inherit group;};

  # Create a secret with automatic path resolution
  mkSecretPath = {
    name,
    secretFile,
    owner ? "root",
    mode ? "0400",
    group ? null,
  }:
    {
      file = ../../secrets/${secretFile};
      owner = owner;
      mode = mode;
    }
    // lib.optionalAttrs (group != null) {inherit group;};

  # Create multiple secrets from a list
  mkSecrets = secrets:
    lib.listToAttrs (
      map (secret: lib.nameValuePair secret.name (lib.mkSecret secret)) secrets
    );
}
