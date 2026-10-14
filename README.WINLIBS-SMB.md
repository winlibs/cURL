# Winlibs SMB compatibility patch

This downstream patch restores the SMB and SMBS implementation removed by
upstream commit `7bbaf2fffd947a1b7d1b96993caf00b9452200bd` on top of curl
8.23.0 (`3163ec065643ba20709f190111f42c3e1fe95273`).

Enable it with `CURL_ENABLE_SMB=ON` and `CURL_ENABLE_NTLM=ON`. The existing
Winlibs CMake build already selects these options. Keep the corresponding
NTLM crypto backend available. SMB stays disabled by default.

This retains the previous SMB1 / NTLMv1 implementation and SMB over TLS;
it does not add SMB2 or SMB3. Upstream no longer maintains this protocol
implementation. Future changes to NTLM, crypto, connection management, and
transfer callbacks require downstream compatibility and security review.

Only the SMB removal is restored. The 8.23.0 security fixes remain in place.
In particular, preserve the current `lib/urldata.h` and append its SMB
include; do not replace whole shared files with an older release.

Authentication hash failures now abort setup before an incomplete hash can
be used. The removed SMB implementation ignored these return values.

The original basic SMB test 1451 is restored as test 3990 because upstream
reused 1451 for a Windows mprintf test. Tests 1850 and 1627 are also restored.
The test server requires the packages in `tests/requirements.txt`.

This patch targets the CMake build used by Winlibs. Autotools users must
regenerate `configure` and `Makefile.in` files from the amended sources.
The original release notes describe upstream curl; this file documents the
additional downstream protocol support.
