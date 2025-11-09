#!/bin/bash
# ==============================================================
#   🌟 SYSTEM MAINTENANCE SUITE (Animated + Colored Version)
#   Automates Backups, Updates, Cleanup & Log Monitoring
#   With Colors, Animations, Error Handling & Logging
# ==============================================================

# ---------- COLORS ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[1;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ---------- CONFIGURATION ----------
BACKUP_SRC="/home/$USER/Documents"
BACKUP_DEST="/home/$USER/backup"
BACKUP_LOG="$BACKUP_DEST/backup_log.txt"
UPDATE_LOG="/home/$USER/system_update_log.txt"
MONITOR_LOG="/var/log/syslog"  # Change if your distro uses /var/log/messages
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')

# ---------- LOADING ANIMATION ----------
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# ---------- FUNCTIONS ----------

# 🗂️ BACKUP FUNCTION
backup_system() {
    echo -e "\n${CYAN}${BOLD}🔄 Starting System Backup...${NC}"
    mkdir -p "$BACKUP_DEST"

    if [ ! -d "$BACKUP_SRC" ]; then
        echo -e "${RED}❌ Error: Source directory not found!${NC}"
        echo "[$TIMESTAMP] Source directory missing." >> "$BACKUP_LOG"
        return 1
    fi

    echo -ne "${YELLOW}Compressing files, please wait...${NC}"
    tar -czf "$BACKUP_DEST/backup_$TIMESTAMP.tar.gz" "$BACKUP_SRC" & spinner

    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}✅ Backup completed successfully!${NC}"
        echo "[$TIMESTAMP] Backup successful!" >> "$BACKUP_LOG"
    else
        echo -e "\n${RED}❌ Backup failed! Check log at $BACKUP_LOG${NC}"
        echo "[$TIMESTAMP] Backup failed!" >> "$BACKUP_LOG"
    fi
}

# ⚙️ SYSTEM UPDATE & CLEANUP FUNCTION
update_cleanup() {
    echo -e "\n${CYAN}${BOLD}🔧 Starting System Update & Cleanup...${NC}"
    echo "[$TIMESTAMP] Update started." >> "$UPDATE_LOG"

    echo -ne "${YELLOW}Running system update, please wait...${NC}"
    (sudo apt update -y && sudo apt upgrade -y >> "$UPDATE_LOG" 2>&1) & spinner

    echo -ne "${YELLOW}\nCleaning old packages...${NC}"
    (sudo apt autoremove -y && sudo apt autoclean -y >> "$UPDATE_LOG" 2>&1) & spinner

    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}✅ Update & cleanup completed successfully!${NC}"
        echo "[$TIMESTAMP] System updated successfully!" >> "$UPDATE_LOG"
    else
        echo -e "\n${RED}❌ Update failed! Check log at $UPDATE_LOG${NC}"
        echo "[$TIMESTAMP] Update encountered errors!" >> "$UPDATE_LOG"
    fi
}

# 🔍 LOG MONITOR FUNCTION
monitor_logs() {
    echo -e "\n${MAGENTA}${BOLD}🧾 Real-time Log Monitoring (Ctrl+C to stop)...${NC}"
    FILTER="error|fail|critical|warn"
    echo -e "${YELLOW}Displaying entries matching: ${FILTER}${NC}"
    sudo tail -f "$MONITOR_LOG" | grep --line-buffered -iE "$FILTER"
}

# 🚪 EXIT FUNCTION
exit_suite() {
    echo -e "\n${BLUE}${BOLD}👋 Exiting Maintenance Suite. Have a great day!${NC}"
    exit 0
}

# ---------- MAIN MENU ----------
while true; do
    clear
    echo -e "${BLUE}${BOLD}"
    echo "================================================="
    echo "         🧰 SYSTEM MAINTENANCE SUITE"
    echo "================================================="
    echo -e "${NC}${YELLOW}"
    echo "1️⃣  Run System Backup"
    echo "2️⃣  Run System Update & Cleanup"
    echo "3️⃣  Monitor Logs"
    echo "4️⃣  Exit"
    echo "================================================="
    echo -ne "${NC}${CYAN}Enter your choice [1-4]: ${NC}"
    read choice

    case $choice in
        1) backup_system ;;
        2) update_cleanup ;;
        3) monitor_logs ;;
        4) exit_suite ;;
        *) echo -e "${RED}⚠️ Invalid option! Please try again.${NC}" ;;
    esac

    echo
    read -p "Press Enter to return to the menu..."
done
