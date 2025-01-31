{
  # Dependencies
  lib,
  umu-launcher-unwrapped,
  python3Packages,
  rustPlatform,
  cargo,
  zstd,
  # Public API
  version,
  withTruststore ? true,
  withDeltaUpdates ? true,
}:
umu-launcher-unwrapped.overridePythonAttrs (prev: {
  src = ../../.;
  inherit version;

  # The nixpkgs patches (in `prev.patches`) are not needed anymore
  # - no-umu-version-json.patch was resolved in:
  #   https://github.com/Open-Wine-Components/umu-launcher/pull/289
  # - The other is backporting:
  #   https://github.com/Open-Wine-Components/umu-launcher/pull/343
  patches = [];

  # FIXME:
  # The flake needs submodules in order to build the `umu-vendored` target.
  # Specifying `?submodules=1` should be enough, but in my testing it was ineffective.
  # As a temporary workaround, explicitly specify the supported build targets:
  buildFlags =
    (prev.buildFlags or [])
    ++ [
      "umu-dist"
      "umu-launcher"
    ];

  # Same issue for install targets
  installTargets =
    (prev.installTargets or [])
    ++ [
      "umu-dist"
      "umu-docs"
      "umu-launcher"
      "umu-delta"
    ];

  nativeBuildInputs =
    (prev.nativeBuildInputs or [])
    ++ [
      python3Packages.hatch-vcs
      rustPlatform.cargoSetupHook
      cargo
    ];

  propagatedBuildInputs =
    (prev.propagatedBuildInputs or [])
    ++ lib.optionals withTruststore [
      python3Packages.truststore
    ]
    ++ lib.optionals withDeltaUpdates [
      python3Packages.cbor2
      python3Packages.xxhash
      zstd
    ];

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ../../Cargo.lock;
  };
})
