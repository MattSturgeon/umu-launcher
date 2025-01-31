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
  patches = [
    # Remove `umu-vendored` from the `all` target
    # This causes an error when building vendored dependencies:
    # python3 -m pip install urllib3 -t builddir
    # => No module named pip
    ./0-Makefile-no-vendor.patch
  ];

  nativeBuildInputs =
    (prev.nativeBuildInputs or [])
    ++ [
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
