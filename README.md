# Uni-Chronicle: An Automated Shell Solution for Academic File Management

Uni-Chronicle is a shell-script-based automation tool designed to simplify and streamline file organization and backup management for university students. Built for Ubuntu, this project ensures that students can effortlessly organize their academic files for theory and lab courses, manage backups, and optimize their workflow throughout the semester.

---

## Features

### 1. **Semester Setup**
- Automatically organizes directories for courses (theory and lab) based on semester information.
- Creates structured folders for file types such as:
  - **Theory Courses**: Assignments, Presentations, Mid-Essentials, Final-Essentials, Others.
  - **Lab Courses**: Reports, Projects, Presentations, Lab Tasks, Others.

### 2. **Backup Management**
- **Daily Automatic Backups**: Configurable backup schedules to ensure data safety.
- **Instant Backup**: Create on-demand backups of the semester's files.
- **Restore Backup**: Restore files from a list of available backup files.

### 3. **Resource Sharing**
- Extract and share specific course files (e.g., assignments or presentations) with peers.
- Automatically names extracted files for clarity (e.g., `CourseName_ResourceType`).

### 4. **Schedule Management**
- Check the status of the automatic backup schedule.
- Modify the backup schedule time as needed.

### 5. **Semester Termination**
- Finalizes the semester by:
  - Creating a final backup.
  - Deleting old backups and semester directories.
  - Cleaning up scheduled tasks.

---

## How It Works

### 1. **Configuration**
Run the script and input the necessary details:
- **Semester Name**: The name of the semester (e.g., "Spring_2024").
- **Course Names**: List all courses for the semester.
- **Backup Location**: Directory for storing backups.
- **Backup Time**: Time for automatic backups (in `HH:MM` format).

### 2. **Directory Structure**
- Automatically generates a clean directory layout based on course names.

### 3. **Backups and Logs**
- Stores semester details in `config.txt`.
- Logs all activities with timestamps in `log_file.txt`.

---

## Installation

### Prerequisites
- **Ubuntu** or a Linux-based operating system.
- Shell scripting capabilities (`bash`).

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/garodiaa/uni-chronicle.git
   cd uni-chronicle
   ```
2. Make the script executable:
    ```bash
   chmod +x uni-chronicle.sh
   ```
3. Run the script:
    ```bash
   ./uni-chronicle.sh
   ```


