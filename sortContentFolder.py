import os
import shutil

CONTENTS = "contents_file"
EMBEDDED = "embedded_contents_file"

EMBEDDED_EXTS = {".lua", ".hx", ".txt"}

def move_correct_files(source_root, target_root, move_embedded):

    for root, dirs, files in os.walk(source_root):
        for file in files:
            ext = os.path.splitext(file)[1].lower()

            should_move = ext in EMBEDDED_EXTS if move_embedded else ext not in EMBEDDED_EXTS

            if not should_move:
                continue

            src = os.path.join(root, file)

            rel = os.path.relpath(src, source_root)
            dst = os.path.join(target_root, rel)

            os.makedirs(os.path.dirname(dst), exist_ok=True)

            print(f"{src} -> {dst}")
            shutil.move(src, dst)

def remove_empty_dirs(root):
    for current, dirs, files in os.walk(root, topdown=False):
        if not dirs and not files:
            try:
                os.rmdir(current)
            except OSError:
                pass

move_correct_files(CONTENTS, EMBEDDED, True)

move_correct_files(EMBEDDED, CONTENTS, False)

remove_empty_dirs(CONTENTS)
remove_empty_dirs(EMBEDDED)

print("Done!")