#!/bin/bash
# Shell script for installing Java, Jenkins and Maven in Ubuntu 22.0.4 EC2 instance

# Update and insrall Java SDK 11
sudo apt-get update
sudo apt-get install default-jdk -y

# Repository key
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null


# Debian package repo address
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt-get update && sudo apt-get install jenkins -y