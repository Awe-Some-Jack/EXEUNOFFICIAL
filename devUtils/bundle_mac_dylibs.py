import glob
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


def rpaths(path):
    try:
        out = subprocess.check_output(["otool", "-l", path], text=True, stderr=subprocess.DEVNULL)
    except subprocess.CalledProcessError:
        return []
    result = []
    lines = out.splitlines()
    for i, l in enumerate(lines):
        if l.strip() == "cmd LC_RPATH":
            for m in lines[i + 1:i + 4]:
                m = m.strip()
                if m.startswith("path "):
                    result.append(m[5:].rsplit(" (offset", 1)[0].replace("@loader_path", os.path.dirname(path)))
    return result


def resolve_rpath(name, src):
    dirs = rpaths(src) + ["/opt/homebrew/lib", "/usr/local/lib", "/opt/local/lib"]
    dirs += glob.glob("/opt/homebrew/opt/*/lib") + glob.glob("/usr/local/opt/*/lib")
    for d in dirs:
        c = os.path.join(d, name)
        if os.path.exists(c):
            return c
    return None


def external_deps(path, src):
    result = []
    for d in otool_deps(path):
        if d.startswith(EXTERNAL_PREFIXES):
            result.append((d, d))
        elif d.startswith("@rpath/"):
            r = resolve_rpath(d[len("@rpath/"):], src)
            if r is not None:
                result.append((d, r))
    return result


def main():
    app = os.path.abspath(sys.argv[1])
    macos = os.path.join(app, "Contents", "MacOS")
    lib = os.path.join(macos, "lib")
    if not os.path.isdir(macos):
        sys.exit("bundle_mac_dylibs: %s not found" % macos)
    os.makedirs(lib, exist_ok=True)

    bundled = set()

    def fix(path, src):
        rel = os.path.relpath(lib, os.path.dirname(path))
        for dep, resolved in external_deps(path, src):
            name = os.path.basename(resolved)
            dst = os.path.join(lib, name)
            if name not in bundled:
                bundled.add(name)
                real = os.path.realpath(resolved)
                shutil.copy(real, dst)
                os.chmod(dst, 0o755)
                subprocess.check_call(["install_name_tool", "-id", "@loader_path/" + name, dst], stderr=subprocess.DEVNULL)
                fix(dst, real)
            subprocess.check_call(["install_name_tool", "-change", dep, "@loader_path/%s/%s" % (rel, name), path], stderr=subprocess.DEVNULL)

    for entry in sorted(os.listdir(macos)):
        p = os.path.join(macos, entry)
        if os.path.isfile(p) and (entry.endswith((".ndll", ".dylib")) or os.access(p, os.X_OK)):
            fix(p, p)

    for entry in sorted(os.listdir(lib)):
        p = os.path.join(lib, entry)
        if os.path.isfile(p) and entry.endswith(".dylib"):
            fix(p, os.path.realpath(p))

    print("bundle_mac_dylibs: bundled %d librar%s" % (len(bundled), "y" if len(bundled) == 1 else "ies"))


if __name__ == "__main__":
    main()
