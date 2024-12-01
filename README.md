
# Restic Backup Scripts for SFTP with Retention Policies

This repository contains two Bash scripts to manage backups using `restic` for SFTP storage. The scripts are designed to automate the process of initializing a `restic` repository and performing backup operations, with a configurable retention policy.

### Table of Contents

1. [Installation](#installation)
2. [Configuration](#configuration)
3. [Scripts Overview](#scripts-overview)
    - [sftp-init.sh](#sftp-initsh)
    - [sftp-backup.sh](#sftp-backupsh)
4. [Usage](#usage)

---

### Installation

1. Ensure `restic` and `jq` are installed on your system. You can install them using the package manager for your Linux distribution.

   For Ubuntu/Debian:

   ```bash
   sudo apt update
   sudo apt install restic jq
   ```

2. Make sure you have access to the SFTP server where backups will be stored.

3. Make the scripts executable:

   ```bash
   chmod +x sftp-init.sh sftp-backup.sh
   ```

---

### Configuration

The configuration for the backup process is defined in a JSON file. Below is a template for the configuration file:

```json
{
    "name": "backupName",
    "backup_source": "/backup/folder/path",
    "restic": {
        "password": "restic_password",
        "repo": "sftp://user@sftserver:/backups/",
        "RetentionPolicy": {
            "KeepLast": 5,
            "KeepDaily": 7,
            "KeepWeekly": 4,
            "KeepMonthly": 6,
            "KeepYearly": 2
        }
    }
}
```

### Configuration Parameters

- **name**: The name used for logging and status files.
- **backup_source**: The directory or files you want to back up.
- **restic.password**: The password for your `restic` repository.
- **restic.repo**: The location of the `restic` repository, e.g., SFTP storage URL.
- **RetentionPolicy**: Defines how long to keep backups:
  - **KeepLast**: The number of last snapshots to keep.
  - **KeepDaily**: The number of daily snapshots to keep.
  - **KeepWeekly**: The number of weekly snapshots to keep.
  - **KeepMonthly**: The number of monthly snapshots to keep.
  - **KeepYearly**: The number of yearly snapshots to keep.

---

### Scripts Overview

#### `sftp-init.sh`

This script initializes a `restic` repository if it doesn't already exist.

- **Usage**:

  ```bash
  ./sftp-init.sh --config /path/to/config.json
  ```

- **Functionality**:
  - Reads configuration from the provided JSON file.
  - Initializes a new `restic` repository if it doesn't exist.
  - Logs all actions to a file named after the `name` in the configuration file.

#### `sftp-backup.sh`

This script performs the actual backup of files and directories and applies the retention policy.

- **Usage**:

  ```bash
  ./sftp-backup.sh --config /path/to/config.json
  ```

- **Functionality**:
  - Reads configuration from the provided JSON file.
  - Backs up the specified source directory or files to the `restic` repository.
  - Applies the defined retention policy (keep last, daily, weekly, monthly, yearly backups).
  - Verifies the integrity of the repository after backup.
  - Logs all actions to a file named after the `name` in the configuration file.
  - Generates a status file indicating the result of the backup (`OK` for success, `Bad` for failure).

---

### Usage

1. **Initialize the Repository**:

   Run the `sftp-init.sh` script with the path to your configuration file:

   ```bash
   ./sftp-init.sh --config /path/to/config.json
   ```

   This script will initialize the `restic` repository on the specified SFTP server if it doesn't already exist.

2. **Perform a Backup**:

   Run the `sftp-backup.sh` script with the path to your configuration file:

   ```bash
   ./sftp-backup.sh --config /path/to/config.json
   ```

   This will back up the specified source directory to the `restic` repository, apply the retention policy, and check the integrity of the repository.

---

### Conclusion

This setup allows for automated backups with a configurable retention policy using `restic` on SFTP storage. The scripts ensure efficient backup management and log every operation for transparency.
