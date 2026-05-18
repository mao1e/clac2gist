#!/bin/bash
set -e

# --- Step 1: Create a new secret Gist and get its SSH URL ---
echo "Creating new Gist..."

# Create a temp placeholder file (gist needs at least one file to be created)
tmp_file=$(mktemp /tmp/init_XXXXXX.txt)
echo "init" > "$tmp_file"

# Create the gist and capture its URL
gist_url=$(gh gist create "$tmp_file" --desc "c2cpp submission" 2>/dev/null | tail -n1)
rm "$tmp_file"

# Convert the browser URL to an SSH URL
# e.g. https://gist.github.com/user/abc123 -> git@gist.github.com:abc123.git
gist_id=$(echo "$gist_url" | grep -oE '[a-f0-9]+$')
ssh_link="git@gist.github.com:${gist_id}.git"
echo "Created Gist: $gist_url"
echo "SSH URL: $ssh_link"

# --- Step 2: Clone it (your original logic) ---
echo "Cloning repository..."
git clone "$ssh_link"

if [[ $ssh_link =~ :([^/]+)\.git$ ]]; then
    folder_name="${BASH_REMATCH[1]}"
    echo "Parsed folder name: $folder_name"
else
    echo "Error: Could not parse the folder name from the SSH URL."
    exit 1
fi


cd "$folder_name"
find . -mindepth 1 -maxdepth 1 ! -name ".git" -exec rm -rf {} +

# --- Step 3: Sync from CLAC (your original logic) ---
read -p "Enter your Columbia UNI: " uni
echo "Syncing c2cpp directory from CLAC..."
rsync -avz "${uni}@clac.cs.columbia.edu:~/c2cpp" .

echo "Running 'make clean' in subdirectories..."
find c2cpp -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
    if [ -f "$dir/Makefile" ] || [ -f "$dir/makefile" ]; then
        echo "Cleaning $dir..."
        make -C "$dir" clean
    fi
done

# Remove any .git directories from synced content before flattening
echo "Removing .git directories from synced content..."
find c2cpp -name ".git" -type d -exec rm -rf {} +

echo "Flattening directory structure..."
find c2cpp -mindepth 2 -type f | while read -r file; do
    newname=$(echo "$file" | sed 's/\//_/g' | sed 's/^c2cpp_//')
    mv "$file" "./$newname"
done

rm -rf c2cpp

# --- Step 4: Push back to Gist ---
echo "Pushing changes to remote..."
git add .
git commit -m "code from clac's c2cpp directory"
git push

echo ""
echo "Done! View your Gist at: $gist_url"
