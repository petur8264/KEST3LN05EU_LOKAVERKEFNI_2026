#!/usr/bin/env bash
# Usage: sudo bash setup_domain_users.sh /path/to/Linux_Users.csv

set -euo pipefail

[[ $EUID -ne 0 ]] && { echo "Run as root."; exit 1; }
[[ -f "${1:-}" ]] || { echo "Usage: sudo bash $0 /path/to/Linux_Users.csv"; exit 1; }

CSV_FILE="$1"
DEFAULT_PASSWORD="mrpeter123"

# Skip header and read CSV
tail -n +2 "$CSV_FILE" | while IFS=',' read -r \
    fullname firstname lastname username email department employeeid
do
    # Trim whitespace
    username=$(echo "$username" | xargs)
    firstname=$(echo "$firstname" | xargs)
    lastname=$(echo "$lastname" | xargs)
    email=$(echo "$email" | xargs)
    department=$(echo "$department" | xargs)
    employeeid=$(echo "$employeeid" | xargs)

    # Create group if missing
    if ! getent group "$department" >/dev/null; then
        groupadd "$department"
        echo "Group created: $department"
    fi

    # Skip existing users
    if id "$username" &>/dev/null; then
        echo "Skipped (exists): $username"
        continue
    fi

    # Create user
    useradd --create-home \
            --shell /bin/bash \
            --comment "${firstname} ${lastname},${employeeid},${email}" \
            --gid "$department" \
            "$username"

    # Set password
    echo "${username}:${DEFAULT_PASSWORD}${employeeid}" | chpasswd

    # Force password change on first login
    chage -d 0 "$username"

    echo "Created: $username → $department"

done

echo "Done."
