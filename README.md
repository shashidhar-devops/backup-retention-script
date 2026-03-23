# 🗂️ Backup & Retention Script

A Bash script that automates the creation of compressed backups and enforces a retention policy to keep your disk usage in check — no manual cleanup needed.

---

## 📌 What It Does

- Creates a timestamped `.tar.gz` archive of any directory
- Automatically deletes the oldest backups when the count exceeds your retention limit
- Logs every run — what was created, how many were deleted, and how many remain
- Fails loudly and early if something goes wrong (no silent failures)

---

## 🚀 Usage

```bash
bash backup.sh <source_directory> <backup_directory> <retention_count>
```

### Example

```bash
bash backup.sh /var/www/html /backups/html 5
```

This will:
1. Create a backup of `/var/www/html` inside `/backups/html`
2. Keep only the **5 most recent** backups
3. Delete any older ones automatically

---

## ⚙️ How It Works

```
backup_20250615_143022.tar.gz   ← newest, kept
backup_20250614_090011.tar.gz   ← kept
backup_20250613_080500.tar.gz   ← kept
backup_20250612_073200.tar.gz   ← kept
backup_20250611_060100.tar.gz   ← kept
backup_20250610_050000.tar.gz   ← DELETED (exceeds retention limit of 5)
```

The script uses `ls -rt` (oldest-first sort) combined with `head` to identify and remove only the oldest files — the newest backups are always preserved.

---

## 📋 Output Log

After every run, the script writes to `/home/user/answer.txt`:

```
backup_20250615_143022.tar.gz   ← backup created
DELETED:1                        ← number of old backups removed
REMAINING:5                      ← backups currently on disk
```

---

## 🛡️ Error Handling

| Scenario | Behaviour |
|---|---|
| Wrong number of arguments | Prints usage and exits |
| Source directory doesn't exist | Prints error and exits |
| Backup directory doesn't exist | Creates it automatically |
| Retention count is not a number | Prints error and exits |
| Any command fails mid-run | Script stops immediately (`set -euo pipefail`) |

---

## 🔧 Requirements

- Bash 4+
- Standard Unix tools: `tar`, `ls`, `xargs`, `wc`
- No external dependencies

---

## 📁 Project Structure

```
backup-retention-script/
│
├── backup.sh       # Main script
└── README.md       # You are here
```

---

## 💡 Key Concepts Used

- **'tar -czf'** --> Creates a gzip-compressed archive
- **date '+%Y%m%d_%H%M%S'** --> Generates precise timestamps for versioning
- **'ls -rt | head -n'** --> Identifies oldest files for deletion
- **'xargs rm -rf'** --> Safely removes identified files
- **'set -euo pipefail'** --> Ensures the script exits immediately on any failure

---

## 🤝 Contributing

Feel free to open an issue or submit a PR if you have ideas for improvement — things like time-based retention, email alerts on failure, or S3 upload support would be great additions.

---

## 📄 License

MIT License — free to use and modify.
