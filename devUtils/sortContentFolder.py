import os
import shutil

CONTENTS = "contents_file"
EMBEDDED = "embedded_contents_file"

EMBEDDED_EXTS = {".lua", ".hx", ".txt"}

FORCE_EMBEDDED_DIRS = {"SONICHU"}


def is_force_embedded(path, root):
    rel = os.path.relpath(path, root)
    parts = rel.split(os.sep)

    return any(
        part.upper() in {folder.upper() for folder in FORCE_EMBEDDED_DIRS}
        for part in parts[:-1]
    )


def move_correct_files(source_root, target_root, move_embedded):

    for root, dirs, files in os.walk(source_root):
        for file in files:
            src = os.path.join(root, file)

            ext = os.path.splitext(file)[1].lower()
            forced = is_force_embedded(src, source_root)

            if move_embedded:
                # contents -> embedded
                should_move = ext in EMBEDDED_EXTS or forced
            else:
                # embedded -> contents
                should_move = ext not in EMBEDDED_EXTS and not forced

            if not should_move:
                continue

            rel = os.path.relpath(src, source_root)
            dst = os.path.join(target_root, rel)

            os.makedirs(os.path.dirname(dst), exist_ok=True)

            print(f"{src} -> {dst}")
            shutil.move(src, dst)

def remove_empty_dirs(root):
    for current, dirs, files in os.walk(root, topdown=False):
        try:
            if not os.listdir(current):
                os.rmdir(current)
        except OSError:
            pass


move_correct_files(CONTENTS, EMBEDDED, True)

move_correct_files(EMBEDDED, CONTENTS, False)

remove_empty_dirs(CONTENTS)
remove_empty_dirs(EMBEDDED)

print("Done!")