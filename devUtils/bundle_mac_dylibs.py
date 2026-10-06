import os
import shutil
import subprocess
import sys

EXTERNAL_PREFIXES = ("/opt/local/", "/opt/homebrew/", "/usr/local/")


def otool_deps(path):
    try:
        out = subprocess.check_output(["otool", "-L", path], text=True, stderr=subprocess.DEVNULL)
    except subprocess.CalledProcessError:
        return []
    return [l.split()[0] for l in out.splitlines()[1:] if l.strip()]


def external_deps(path):
    return [d for d in otool_deps(path) if d.startswith(EXTERNAL_PREFIXES)]


def main():
    app = os.path.abspath(sys.argv[1])
    macos = os.path.join(app, "Contents", "MacOS")
    lib = os.path.join(macos, "lib")
    if not os.path.isdir(macos):
        sys.exit("bundle_mac_dylibs: %s not found" % macos)
    os.makedirs(lib, exist_ok=True)

    bundled = set()

    def fix(path):
        rel = os.path.relpath(lib, os.path.dirname(path))
        for dep in external_deps(path):
            name = os.path.basename(dep)
            dst = os.path.join(lib, name)
            if name not in bundled:
                bundled.add(name)
                shutil.copy(os.path.realpath(dep), dst)
                os.chmod(dst, 0o755)
                subprocess.check_call(["install_name_tool", "-id", "@loader_path/" + name, dst], stderr=subprocess.DEVNULL)
                fix(dst)
            subprocess.check_call(["install_name_tool", "-change", dep, "@loader_path/%s/%s" % (rel, name), path], stderr=subprocess.DEVNULL)

    for entry in sorted(os.listdir(macos)):
        p = os.path.join(macos, entry)
        if os.path.isfile(p) and (entry.endswith((".ndll", ".dylib")) or os.access(p, os.X_OK)):
            fix(p)

    for entry in sorted(os.listdir(lib)):
        p = os.path.join(lib, entry)
        if os.path.isfile(p) and entry.endswith(".dylib"):
            fix(p)

    print("bundle_mac_dylibs: bundled %d librar%s" % (len(bundled), "y" if len(bundled) == 1 else "ies"))


if __name__ == "__main__":
    main()
