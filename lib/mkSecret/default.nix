# Create a secret with standard age.secrets structure
{lib, ...}: {
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
}
