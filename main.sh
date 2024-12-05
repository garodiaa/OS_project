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

    echo "Enter course names (comma-separated):"
    read -r course_input
    IFS=',' read -r -a courses <<< "$course_input"

    echo "Enter the backup time in 24-hour format (HH:MM):"
    read -r backup_time

    echo "Enter the backup location (full path):"
    read -r backup_location
    mkdir -p "$backup_location"

    # Save configuration
    echo "semester=$semester" > config.txt
    echo "courses=${courses[*]}" >> config.txt
    echo "backup_time=$backup_time" >> config.txt
    echo "backup_location=$backup_location" >> config.txt

    echo "Setup complete!"
    create_folders

    echo "Folder Creation Complete!"
}

#Folder Creation at Setup
create_folders() {
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

# Main Loop
while true; do
    show_menu
done

