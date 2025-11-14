{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  glib,
  pkg-config,
  pcre2,
  libsysprof-capture,
}:
let
  version = "1.5.2";
  PKG_CONFIG_PATH = (
    if stdenv.isDarwin then
      "${pkgs.pcre2}/lib/pkgconfig:${pkgs.libsysprof-capture}/lib/pkgconfig"
    else
      null
  );
in
stdenv.mkDerivation {
  pname = "lcm";
  version = version;

  src = fetchFromGitHub {
    owner = "lcm-proj";
    repo = "lcm";
    rev = "v${version}";
    hash = "sha256-72fytJY+uXEHGdZ7N+0g+JK7ALb2e2ZtJuvhiGIMHiA=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  nativeBuildInputs =
    [
      pkg-config
      cmake
    ]
    ++ (
      if stdenv.isDarwin then
        [
          pcre2
          libsysprof-capture
        ]
      else
        [ ]
    );

  buildInputs = [
    glib
  ];

  inherit PKG_CONFIG_PATH;

  patches = [
    (pkgs.writeText "lcm-darwin-fsync.patch" "--- ./lcm-logger/lcm_logger.c     2025-11-14 09:46:01.000000000 -0600\n+++ ./lcm-logger/lcm_logger.c  2025-11-14 09:47:05.000000000 -0600\n@@ -428,9 +428,13 @@\n         if (needs_flushed) {\n             fflush(logger->log->f);\n #ifndef WIN32\n+#ifdef __APPLE__\n+            fsync(fileno(logger->log->f));\n+#else\n             // Perform a full fsync operation after flush\n             fdatasync(fileno(logger->log->f));\n #endif\n+#endif\n             logger->last_fflush_time = log_event->timestamp;\n         }\n")
  ];

  meta = {
    description = "Lightweight Communications and Marshalling (LCM)";
    homepage = "https://github.com/lcm-proj/lcm";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.kjeremy ];
    platforms = lib.platforms.unix;
  };
}
