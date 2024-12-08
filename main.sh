#!/bin/bash

# Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color (Reset)

#BG Colors
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_BLUE='\033[44m'

# Bold colors
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_BLUE='\033[1;34m'

# Configuration file path
config_file="/home/jojo/Documents/GitHub/OS_project/config.txt"
# Log file path
log_file="/home/jojo/Documents/GitHub/OS_project/log_file.txt"

# Main Menu Function
# Show Menu
show_menu() {
    echo "-----------------------------------"
    echo -e "           ${BOLD_BLUE}Uni-Chronicle${NC}"
    echo "-----------------------------------"
    echo "1. Setup Environment"
    echo "2. Create Backup Now"
    echo "3. Restore Backup"
    echo "4. Check Schedule Backup Status"
    echo "5. Update Schedule Backup Time"
    echo "6. Extract Course Resources"
    echo "7. Terminate Semester"
    echo "8. Exit"
    echo "-----------------------------------"
    echo -e "${GRAY}Enter your choice:${NC}"
    read -r choice
    case $choice in
        1) setup ;;
        2) backup_now ;;
        3) restore_backup ;;
        4) check_schedule_backup_status ;;
        5) update_schedule_backup_time ;;
        6) extract_resources ;;
        7) terminate_semester ;;
        8) echo "Exiting..."; exit 0 ;;
        *) echo -e "${RED}Invalid choice. Try again.${NC}" ;;
    esac
}

# Setup Placeholder
setup() {
    echo -e "${GRAY}Enter the semester name (e.g., Fall_2024):${NC}"
    read -r semester
    if [[ -z $semester ]]; then
        echo "Semester name cannot be empty!"
        return
    fi

    echo -e "${GRAY}Enter course names (comma-separated):${NC}"
    read -r course_input
    if [[ -z $course_input ]]; then
        echo "Course list cannot be empty!"
        return
    fi
    IFS=',' read -r -a courses <<< "$course_input"

    echo -e "${GRAY}Enter the backup time in 24-hour format (HH:MM):${NC}"
    read -r backup_time
    if [[ ! $backup_time =~ ^[0-2][0-9]:[0-5][0-9]$ ]]; then
        echo "Invalid time format!"
        return
    fi

    echo -e "${GRAY}Enter the backup location (full path):${NC}"
    read -r backup_location
    mkdir -p "$backup_location"

    # Save configuration
    echo "semester=$semester" > config.txt
    echo "courses=${courses[*]}" >> config.txt
    echo "backup_time=$backup_time" >> config.txt
    echo "backup_location=$backup_location" >> config.txt

    echo -e "${GREEN}Setup complete!${NC}"

    create_folders "$semester" "${courses[@]}"
    # echo -e "${GREEN}Folder creation complete!${NC}"

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
    echo -e "${GREEN}Folders created successfully for the semester $semester.${NC}"
}

# Backup Function
backup() {
    
    # Read values from config.txt
    config_file="/home/jojo/Documents/GitHub/OS_project/config.txt"
    semester=$(grep "semester=" "$config_file" | cut -d'=' -f2)
    courses_string=$(grep "courses=" "$config_file" | cut -d'=' -f2)
    backup_location=$(grep "backup_location=" "$config_file" | cut -d'=' -f2)

    # Convert the comma-separated courses string into an array
    IFS=',' read -r -a courses <<< "$courses_string"
    # Log the start of the backup function
    echo "-----------------------------------" >> "$log_file"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting backup for semester $semester" >> "$log_file"

    # Check if the semester directory exists
    semester_dir="/home/jojo/Documents/GitHub/OS_project/$semester"
    if [[ -d $semester_dir ]]; then
        backup_file="$backup_location/${semester}_backup_$(date +%F_%H-%M).zip"
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
    # log_file is already defined at the top of the script

    # Log the start of the function
    echo "-----------------------------------" >> "$log_file"
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
    echo -e "${GREEN}Backup scheduled at $backup_time daily.${NC}"
}

# Backup Now Function (Instant Backup)
backup_now() {
    # log_file="/home/jojo/Documents/GitHub/OS_project/log_file.txt"

    # Log the start of the Backup Now function
    echo "-----------------------------------" >> "$log_file"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting immediate backup" >> "$log_file"

    # Call the backup function to perform an instant backup
    backup

    # Log the completion of the Backup Now function
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Immediate backup completed" >> "$log_file"
    echo -e "${GREEN}Backup now completed succesfully.${NC}"
}

# Restore Backup Function
restore_backup() {
    # log_file="/home/jojo/Documents/GitHub/OS_project/log_file.txt"

    echo "-----------------------------------" >> "$log_file"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting restore backup" >> "$log_file"

    # # Prompt user to select backup file to restore
    # echo "Enter the path of the backup file to restore:"
    # read -r backup_file
    backup_location=$(grep "backup_location=" "$config_file" | cut -d'=' -f2)

    # List available backup files
    echo "Available backup files:"
    if [[ ! -d $backup_location ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Backup location not found." >> "$log_file"
    echo -e "${RED}Error: Backup location not found.${NC}"
    return
    fi

    backup_files=("$backup_location"/*.zip) # Fetch all zip files

    if [[ ${#backup_files[@]} -eq 0 ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: No backup folders found." >> "$log_file"
    echo -e "${RED}Error: No backup folders found.${NC}"
    return
    fi

    for i in "${!backup_files[@]}"; do
    echo "$((i + 1)). ${backup_files[i]##*/}" # Print folder names only
    done

    # for i in "${!backup_files[@]}"; do
    #     echo "$((i + 1)). ${backup_files[i]}"
    # done

    # Prompt user to select a backup file to restore
    echo -e "${GRAY}Enter the number of the backup file to restore:${NC}"
    read -r backup_choice
    if [[ ! "$backup_choice" =~ ^[0-9]+$ ]] || [[ $backup_choice -lt 1 || $backup_choice -gt ${#backup_files[@]} ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Invalid choice." >> "$log_file"
        echo -e "${RED}Error: Invalid choice.${NC}"
        return
    fi

    backup_file="${backup_files[$((backup_choice - 1))]}"

    if [[ ! -f $backup_file ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Backup file not found." >> "$log_file"
        echo -e "${RED}Error: Backup file not found.${NC}"
        return
    fi

    # Extract backup file to the semester folder
    semester=$(grep "semester=" config.txt | cut -d'=' -f2)
    mkdir -p "$semester"
    # Extract only the contents of the backup file without recreating the full path
    unzip -j "$backup_file" -d "$semester" >/dev/null 2>&1

    if [[ $? -eq 0 ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Restore completed successfully." >> "$log_file"
        echo -e "${GREEN}Restore completed successfully.${NC}"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Restore failed." >> "$log_file"
        echo -e "${RED}Restore failed.${NC}"
    fi
}

# Check Schedule Backup Status Function
check_schedule_backup_status() {
    # log_file="/home/jojo/Documents/GitHub/OS_project/log_file.txt"

    # Log the start of the function
    echo "-----------------------------------" >> "$log_file"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Checking backup schedule status" >> "$log_file"

    # Check if the backup job is scheduled in crontab
    if crontab -l 2>/dev/null | grep -q "$(pwd)/main.sh backup"; then
        backup_time=$(grep "backup_time=" config.txt | cut -d'=' -f2)
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup is scheduled." >> "$log_file"
        echo -e "${GREEN}Backup is scheduled daily at $backup_time.${NC}"
    else
        echo -e "${RED}No backup schedule found.${NC}"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - No backup schedule found." >> "$log_file"
    fi
}

# update schedule backup time
update_schedule_backup_time() {
    # log_file="/home/jojo/Documents/GitHub/OS_project/log_file.txt"

    # Log the start of the function
    echo "-----------------------------------" >> "$log_file"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Updating backup schedule time" >> "$log_file"

    # Read the current backup time from the configuration
    # config_file="/home/jojo/Documents/GitHub/OS_project/config.txt"
    backup_time=$(grep "backup_time=" "$config_file" | cut -d'=' -f2)

    # Prompt the user to enter the new backup time
    echo -e "${GRAY}Enter the new backup time in 24-hour format (HH:MM):${NC}"
    read -r new_backup_time
    if [[ ! $new_backup_time =~ ^[0-2][0-9]:[0-5][0-9]$ ]]; then
        echo -e "${RED}Invalid time format.${NC}"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Invalid time format." >> "$log_file"
        return
    fi

    # Update the backup_time variable
    backup_time=$new_backup_time
    sed -i "s/^backup_time=.*/backup_time=$new_backup_time/" "$config_file"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup time updated to $new_backup_time" >> "$log_file"
    echo -e "${GREEN}Backup time updated to $new_backup_time.${NC}"

    # Reschedule the backup job with the new time
    schedule_backup

}

# Extract Resources Function
extract_resources() {
    local semester=$(grep "semester=" config.txt | cut -d'=' -f2)  # Automatically fetch semester from config
    local semester_dir="/home/jojo/Documents/GitHub/OS_project/$semester"
    local courses_string=$(grep "courses=" config.txt | cut -d'=' -f2)
    IIFS=' ' read -r -a courses <<< "$courses_string"  # Automatically fetch courses from config.txt
    local chosen_course
    local chosen_resource
    local output_dir="extracted_resources"
    local zip_file="resources_$(date +%Y-%m-%d_%H-%M-%S).zip"
    local selected_course_name=""

    echo "-----------------------------------" >> "$log_file"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting extract resources process" >> "$log_file"

    # Verify if semester directory exists
    if [[ ! -d $semester_dir ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Semester directory not found." >> "$log_file"
        echo -e "${RED}Error: Semester directory not found.${NC}"
        return 1
    fi

    # Display available courses
    echo "Available courses:"
    for i in "${!courses[@]}"; do
        echo "$((i + 1)). ${courses[i]}"
    done

    # Prompt user to choose courses
    echo -e "${GRAY}Enter the number(s) of the course(s) you want to extract resources from (comma-separated):${NC}"
    read -r course_choice
    if [[ -z $course_choice ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: No course selected." >> "$log_file"
        echo -e "${RED}Error: No course selected.${NC}"
        return 1
    fi

    # Convert course choices into an array
    IFS=',' read -r -a selected_courses_indices <<< "$course_choice"

    # Validate course selection
    for index in "${selected_courses_indices[@]}"; do
        if [[ ! "$index" =~ ^[0-9]+$ ]] || [[ $index -lt 1 || $index -gt ${#courses[@]} ]]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Invalid course selection: $index." >> "$log_file"
            echo -e "${RED}Error: Invalid course selection: $index.${NC}"
            return 1
        fi
    done

    # Create the output directory
    mkdir -p "$output_dir"

    # Prompt user to choose the type of resource to extract
    echo -e "${GRAY}Enter the type of resource you want to extract\n(e.g., assignment, presentation, mid-essentials, etc.):${NC}"
    read -r chosen_resource
    if [[ -z $chosen_resource ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: No resource type selected." >> "$log_file"
        echo -e "${RED}Error: No resource type selected.${NC}"
        return 1
    fi

    # Process each selected course
    for index in "${selected_courses_indices[@]}"; do
        chosen_course="${courses[$((index - 1))]}"
        selected_course_name="${selected_course_name}${chosen_course}_"
        course_dir="$semester_dir/$chosen_course"
        echo "Selected course: $chosen_course"

        # Check if the chosen resource exists in the course directory
        if [[ -d "$course_dir/$chosen_resource" ]]; then
            # Concatenate the course and resource name to create a unique folder name for rsync
            rsync -a "$course_dir/$chosen_resource" "$output_dir/${chosen_course}_${chosen_resource}/"
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Added $chosen_resource from $chosen_course to $output_dir." >> "$log_file"
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Resource $chosen_resource not found in $chosen_course." >> "$log_file"
            echo -e "${RED}Resource $chosen_resource not found in $chosen_course.${NC}"
            return 1
        fi
    done

    # Zip the extracted files
    mkdir -p "extracted_files"
    zip_file="extracted_files/resources_${selected_course_name}_${chosen_resource}_$(date +%Y-%m-%d).zip"
    zip -r "$zip_file" "$output_dir" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Resources successfully extracted and zipped: $zip_file" >> "$log_file"
        echo -e "${GREEN}Resources successfully extracted and zipped: $zip_file${NC}"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Failed to zip the resources." >> "$log_file"
        echo -e "${RED}Error: Failed to zip the resources.${NC}"
    fi

    # Clean up the temporary output directory
    rm -rf "$output_dir"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Temporary directory $output_dir deleted." >> "$log_file"
}



# Terminate semester function
terminate_semester() {
    # log_file="/home/jojo/Documents/GitHub/OS_project/log_file.txt"

    # Read the semester name from the configuration
    # config_file="/home/jojo/Documents/GitHub/OS_project/config.txt"
    if [[ ! -f $config_file ]]; then
        echo -e "\n$(date '+%Y-%m-%d %H:%M:%S') - Error: Configuration file not found. Please run setup first." >> "$log_file"
        echo -e "${RED}Error: Configuration file not found. Please run setup first.${NC}"
        return
    fi

    semester=$(grep "semester=" "$config_file" | cut -d'=' -f2)
    backup_location=$(grep "backup_location=" "$config_file" | cut -d'=' -f2)
    semester_dir="/home/jojo/Documents/GitHub/OS_project/$semester"

    echo -e "\n$(date '+%Y-%m-%d %H:%M:%S') - Initiating terminate semester process for $semester" >> "$log_file"
    
    # Confirm with the user before proceeding
    echo -e "${GRAY}Are you sure you want to terminate the semester '$semester'?\nThis will create a final backup, delete older backups, and remove the semester folder. (yes/no)${NC}"
    read -r confirm
    if [[ "$confirm" != "yes" ]]; then
        echo -e "\n$(date '+%Y-%m-%d %H:%M:%S') - Terminate semester process aborted by user." >> "$log_file"
        echo -e "${RED}Terminate semester process aborted.${NC}"
        return
    fi

    # Delete all existing backups for this semester
    echo "Deleting old backups for the semester..."
    find "$backup_location" -name "${semester}_backup_*.zip" -delete
    if [[ $? -eq 0 ]]; then
        echo -e "\n$(date '+%Y-%m-%d %H:%M:%S') - Old backups deleted successfully." >> "$log_file"
        echo -e "${GREEN}Old backups deleted successfully.${NC}"
    else
        echo -e "\n$(date '+%Y-%m-%d %H:%M:%S') - Error: Failed to delete old backups." >> "$log_file"
        echo -e "${RED}Error: Failed to delete old backups.${NC}"
        return
    fi

    # Create a final backup
    echo "Creating final backup for the semester..."
    final_backup_file="$backup_location/${semester}_final_backup_$(date +%F_%H-%M).zip"
    zip -r "$final_backup_file" "$semester_dir" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        echo -e "\n$(date '+%Y-%m-%d %H:%M:%S') - Final backup successfully created at $final_backup_file" >> "$log_file"
        echo -e "${GREEN}Final backup successfully created at $final_backup_file.${NC}"
    else
        echo -e "\n$(date '+%Y-%m-%d %H:%M:%S') - Error: Final backup failed!" >> "$log_file"
        echo -e "${RED}Error: Final backup failed. Aborting end semester process.${NC}"
        return
    fi

    # Delete the semester folder
    if [[ -d $semester_dir ]]; then
        rm -rf "$semester_dir"
        echo -e "\n$(date '+%Y-%m-%d %H:%M:%S') - Semester folder '$semester_dir' deleted successfully." >> "$log_file"
        echo -e "${GREEN}Semester folder '$semester_dir' deleted successfully.${NC}"
    else
        echo -e "\n$(date '+%Y-%m-%d %H:%M:%S') - Error: Semester folder not found. Skipping deletion." >> "$log_file"
        echo -e "${RED}Error: Semester folder not found. Skipping deletion.${NC}"
    fi

    # Clear the configuration file
    rm -f "$config_file"
    echo -e "\n$(date '+%Y-%m-%d %H:%M:%S') - Configuration file deleted successfully." >> "$log_file"
    echo -e "${GREEN}Configuration file deleted successfully.${NC}" 

    # Clear the cron jobs
    crontab -l 2>/dev/null | grep -v "$(pwd)/main.sh backup" | crontab - 2>> "$log_file"

    echo -e "${GREEN}End of semester $semester process completed.${NC}"
}

# Main Loop (only shows menu if no argument is passed)
if [[ "$1" == "backup" ]]; then
    backup
else
    while true; do
        show_menu
    done
fi
