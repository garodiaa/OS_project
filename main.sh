#!/bin/bash

# Main Menu Function
show_menu() {
    echo "-----------------------------------"
    echo "File Management System"
    echo "-----------------------------------"
    echo "1. Initial Setup"
    echo "2. Exit"
    echo "Enter your choice:"
    read -r choice
    case $choice in
        1) setup ;;
        2) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid choice. Try again." ;;
    esac
}

# Setup Placeholder
setup() {
    echo "Enter the semester name (e.g., Spring_2024):"
    read -r semester
    if [[ -z $semester ]]; then
        echo "Semester name cannot be empty!"
        return
    fi

    echo "Enter course names (comma-separated):"
    read -r course_input
    if [[ -z $course_input ]]; then
        echo "Course list cannot be empty!"
        return
    fi
    IFS=',' read -r -a courses <<< "$course_input"

    echo "Enter the backup time in 24-hour format (HH:MM):"
    read -r backup_time
    if [[ ! $backup_time =~ ^[0-2][0-9]:[0-5][0-9]$ ]]; then
        echo "Invalid time format!"
        return
    fi

    echo "Enter the backup location (full path):"
    read -r backup_location
    mkdir -p "$backup_location"

    # Save configuration
    echo "semester=$semester" > config.txt
    echo "courses=${courses[*]}" >> config.txt
    echo "backup_time=$backup_time" >> config.txt
    echo "backup_location=$backup_location" >> config.txt

    echo "Setup complete!"
    create_folders "$semester" "${courses[@]}"

    echo "Folder creation complete!"
    schedule_backup
}

# Folder Creation at Setup
create_folders() {
    local semester=$1
    shift
    local courses=("$@")
    for course in "${courses[@]}"; do
        mkdir -p "$semester/$course"
        if [[ "$course" =~ [Ll][Aa][Bb] ]]; then
            mkdir -p "$semester/$course"/{report,project,presentation,lab_task,others}
        else
            mkdir -p "$semester/$course"/{mid-essentials,final-essentials,assignment,presentation,others}
        fi
    done
    echo "Folders created successfully for the semester."
}

# Backup Function
backup() {
    log_file="/home/jojo/Documents/GitHub/OS_project/log_file.txt"

    # Read values from config.txt
    config_file="/home/jojo/Documents/GitHub/OS_project/config.txt"
    semester=$(grep "semester=" "$config_file" | cut -d'=' -f2)
    courses_string=$(grep "courses=" "$config_file" | cut -d'=' -f2)
    backup_location=$(grep "backup_location=" "$config_file" | cut -d'=' -f2)

    # Convert the comma-separated courses string into an array
    IFS=',' read -r -a courses <<< "$courses_string"
    # Log the start of the backup function
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting backup for semester $semester" >> "$log_file"

    # Check if the semester directory exists
    semester_dir="/home/jojo/Documents/GitHub/OS_project/$semester"
    if [[ -d $semester_dir ]]; then
        backup_file="$backup_location/${semester}_backup_$(date +%F).zip"
        zip -r "$backup_file" "$semester_dir" >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup successfully created at $backup_file" >> "$log_file"
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Backup failed!" >> "$log_file"
        fi
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Semester folder not found." >> "$log_file"
    fi
}

# Schedule Backup
schedule_backup() {
    log_file="/home/jojo/Documents/GitHub/OS_project/log_file.txt"  # Replace with the path to your desired log file

    # Log the start of the function
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting backup schedule" >> "$log_file"

    # Remove existing cron jobs for this script
    crontab -l 2>/dev/null | grep -v "$(pwd)/main.sh backup" | crontab - 2>> "$log_file"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Removed old cron jobs for backup" >> "$log_file"

    # Schedule backup at user-defined time
    hour=${backup_time%%:*}
    minute=${backup_time##*:}
    (crontab -l 2>/dev/null; echo "$minute $hour * * * bash $(pwd)/main.sh backup >> $log_file 2>&1") | crontab - 2>> "$log_file"

    # Log the scheduling status
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup scheduled at $backup_time daily" >> "$log_file"
    echo "Backup scheduled at $backup_time daily."
}


# Main Loop (only shows menu if no argument is passed)
if [[ "$1" == "backup" ]]; then
    backup
else
    while true; do
        show_menu
    done
fi
