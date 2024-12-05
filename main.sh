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
    echo "Setup functionality will be implemented here."
}

# Main Loop
while true; do
    show_menu
done

