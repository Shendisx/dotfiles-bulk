#!/bin/bash

# Check if a package name is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <package-name>"
    exit 1
fi

package_name="$1"

# Step 1: Check if the specified package is installed and grab its version
local_version=$(pacman -Q "$package_name" 2>/dev/null | awk '{print $2}')
if [ -z "$local_version" ]; then
    echo "Package '$package_name' is not installed."
    exit 1
fi

echo "Local version of $package_name: $local_version"

# Step 2: Define the remote repository URL
remote_repo="https://mirror.cachyos.org/repo/x86_64/cachyos"

# Step 3: Fetch the list of packages from the remote repository, following redirects
echo "Fetching package list from $remote_repo..."
package_list=$(curl -Ls "$remote_repo")

# Check if the package list was fetched successfully
if [ $? -ne 0 ]; then
    echo "Failed to fetch package list from $remote_repo."
    exit 1
fi

# Step 4: Extract only relevant package names and versions without duplicates
echo "Searching for '$package_name' in the package list..."
package_list_filtered=$(echo "$package_list" | grep -oP "${package_name}-[0-9]+(\.[0-9]+)*(\.r[0-9]+)?(\.[a-zA-Z0-9]+)?(-[a-zA-Z0-9\.]*)*-x86_64\.pkg\.tar\.zst" | sort -u)

# Debug output for filtered package list
echo "Filtered package list:"
echo "$package_list_filtered"

# Check if we found any remote versions
if [ -z "$package_list_filtered" ]; then
    echo "No remote version found for '$package_name'. Available packages:"
    # Print all available packages for manual inspection, excluding HTML tags
    echo "$package_list" | grep -oP "[^<]+(?=\.pkg\.tar\.zst)" | grep "\.pkg\.tar\.zst"
    exit 1
fi

# Extract remote version from filtered results (correctly capture full version)
remote_version=$(echo "$package_list_filtered" | grep -oP "${package_name}-\K[0-9]+(\.[0-9]+)*(\.r[0-9]+)?(\.[a-zA-Z0-9]+)?(-[a-zA-Z0-9\.]*)")

if [ -z "$remote_version" ]; then
    echo "No remote version found for '$package_name'."
    exit 1
fi

echo "Remote version of $package_name: $remote_version"

# Step 5: Compare local and remote versions to avoid unnecessary reinstallation
if [ "$local_version" == "$remote_version" ]; then
    echo "The local package '$package_name' is up-to-date."
    exit 0 # Exit if versions match, no update needed.
else
    echo "Versions do not match. Updating..."
    
    # Construct the full package name for downloading (ensure correct architecture)
    full_package_name="${package_name}-${remote_version}-x86_64.pkg.tar.zst"
    download_url="$remote_repo/$full_package_name"

    # Debug output for download URL
    echo "Constructed download URL: $download_url"

    # Check if the package exists at the constructed URL
    if curl --output /dev/null --silent --head --fail "$download_url"; then
        # Step 6: Download and install the new package
        wget "$download_url" -O "/tmp/$full_package_name"
        
        # Ensure wget succeeded before proceeding to install
        if [ $? -eq 0 ]; then
            sudo pacman -U "/tmp/$full_package_name" --noconfirm
            echo "Package '$package_name' updated to version $remote_version."
        else
            echo "Failed to download '$download_url'."
            exit 1
        fi
        
    else
        echo "No downloadable version found for '$package_name' at '$download_url'."
        exit 1
    fi 
fi
