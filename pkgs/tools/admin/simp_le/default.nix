{ stdenv, fetchFromGitHub, fetchpatch, pythonPackages, bash }:

pythonPackages.buildPythonApplication rec {
  pname = "simp_le-client";
  version = "0.6.1";
  name = "${pname}-${version}";

  src = pythonPackages.fetchPypi {
    inherit pname version;
    sha256 = "0x4fky9jizs3xi55cdy217cvm3ikpghiabysan71b07ackkdfj6k";
  };

  postPatch = ''
    substituteInPlace simp_le.py \
      --replace "/bin/sh" "${bash}/bin/sh"
  '';

  checkPhase = ''
    $out/bin/simp_le --test
  '';

  propagatedBuildInputs = with pythonPackages; [ acme setuptools_scm ];

  meta = with stdenv.lib; {
    homepage = https://github.com/zenhack/simp_le;
    description = "Simple Let's Encrypt client";
    license = licenses.gpl3;
    maintainers = with maintainers; [ gebner ];
    platforms = platforms.all;
  };
}
