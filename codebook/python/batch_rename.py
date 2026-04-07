def rename_files(files):
    for old_name, new_name in files:
        print(f"RENAME: {old_name} -> {new_name}")

if __name__ == "__main__":
    demo = [("a.txt", "A.txt"), ("b.txt", "B.txt")]
    rename_files(demo)
