# adbfs-rootless was removed from nixpkgs (needs fuse2). Build it against fuse3.
{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "adbfs-rootless";
  version = "unstable-2026";
  src = pkgs.fetchFromGitHub {
    owner = "spion";
    repo = "adbfs-rootless";
    rev = "277c08840da9d0a540983a704741f2660296d492";
    hash = "sha256-U0/u5OZYOzga5XDrrqBir6W8DVZlGiIjk7x7Y19vcB4=";
  };
  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [ pkgs.fuse3 ];
  postPatch = ''
    sed -i 's/FUSE_USE_VERSION 26/FUSE_USE_VERSION 31/' adbfs.cpp
    sed -i 's/pkg-config fuse /pkg-config fuse3 /' Makefile
    sed -i 's/adb_getattr(const char \*path, struct stat \*stbuf)/adb_getattr(const char *path, struct stat *stbuf, struct fuse_file_info *fi)/' adbfs.cpp
    sed -i 's/off_t offset, struct fuse_file_info \*fi)$/off_t offset, struct fuse_file_info *fi, enum fuse_readdir_flags rflags)/' adbfs.cpp
    sed -i 's/\(filler(buf, [a-z_.()]*, NULL, 0\))/\1, (fuse_fill_dir_flags)0)/' adbfs.cpp
    sed -i 's/adb_utimens(const char \*path, const struct timespec ts\[2\])/adb_utimens(const char *path, const struct timespec ts[2], struct fuse_file_info *fi)/' adbfs.cpp
    sed -i 's/adb_truncate(const char \*path, off_t size)/adb_truncate(const char *path, off_t size, struct fuse_file_info *fi)/' adbfs.cpp
    sed -i 's/return adb_utimens(path, ts);/return adb_utimens(path, ts, NULL);/' adbfs.cpp
    sed -i 's/adb_rename(const char \*from, const char \*to)/adb_rename(const char *from, const char *to, unsigned int flags)/' adbfs.cpp
  '';
  makeFlags = [ "DESTDIR=$(out)" "INSTALL_DIR=$(out)" ];
  preInstall = "mkdir -p $out";
  installPhase = "install -Dm755 adbfs $out/bin/adbfs";
}
