{ stdenv, fetchFromGitHub, perl }:

stdenv.mkDerivation rec {
  name = "mbedtls-2.7.3";

  src = fetchFromGitHub {
    owner = "ARMmbed";
    repo = "mbedtls";
    rev = name;
    sha256 = "1bnvfvbf0i0yp6h428rhhvlmda67lc4rl8sdpa9zlm4kvg1c1n38";
  };

  nativeBuildInputs = [ perl ];

  patches = stdenv.lib.optionals stdenv.isDarwin [ ./darwin_dylib.patch ];

  postPatch = ''
    patchShebangs .
  '' + stdenv.lib.optionalString stdenv.isDarwin ''
    substituteInPlace library/Makefile --replace "-soname" "-install_name"
    substituteInPlace tests/scripts/run-test-suites.pl --replace "LD_LIBRARY_PATH" "DYLD_LIBRARY_PATH"
    # Necessary for install_name_tool below
    echo "LOCAL_LDFLAGS += -headerpad_max_install_names" >> programs/Makefile
  '';

  makeFlags = [
    "SHARED=1"
  ] ++ stdenv.lib.optionals stdenv.isDarwin [
    "DLEXT=dylib"
  ];

  installFlags = [
    "DESTDIR=\${out}"
  ];

  postInstall = stdenv.lib.optionalString stdenv.isDarwin ''
      install_name_tool -change libmbedcrypto.dylib $out/lib/libmbedcrypto.dylib $out/lib/libmbedtls.dylib
      install_name_tool -change libmbedcrypto.dylib $out/lib/libmbedcrypto.dylib $out/lib/libmbedx509.dylib
      install_name_tool -change libmbedx509.dylib $out/lib/libmbedx509.dylib $out/lib/libmbedtls.dylib

      for exe in $out/bin/*; do
          install_name_tool -change libmbedtls.dylib $out/lib/libmbedtls.dylib $exe
          install_name_tool -change libmbedx509.dylib $out/lib/libmbedx509.dylib $exe
          install_name_tool -change libmbedcrypto.dylib $out/lib/libmbedcrypto.dylib $exe
      done
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    homepage = https://tls.mbed.org/;
    description = "Portable cryptographic and SSL/TLS library, aka polarssl";
    license = licenses.gpl3;
    platforms = platforms.all;
    maintainers = with maintainers; [ wkennington fpletz ];
  };
}
