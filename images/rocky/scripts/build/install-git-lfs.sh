#!/bin/bash -e
################################################################################
##  File:  install-git-lfs.sh
##  Desc:  Install Git-lfs
################################################################################

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:${PATH}"
# Load helper functions (if any)
# shellcheck disable=SC1091
source "$HELPER_SCRIPTS"/install.sh

GIT_LFS_REPO="https://packagecloud.io/github/git-lfs/el/9"

# The packagecloud installer does not recognise Rocky Linux natively.
# Download the script, inject os=el and the detected major version before the
# OS-detection logic runs, then execute the patched script.
SETUP_SCRIPT=$(mktemp /tmp/git-lfs-setup-XXXXXX.sh)
curl -fsSL https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh -o "$SETUP_SCRIPT"

ROCKY_MAJOR=$(rpm -q --qf '%{VERSION}' rocky-release 2>/dev/null | cut -d. -f1 || echo "9")
awk -v dist="$ROCKY_MAJOR" \
  'NR==1 { print; print "\n# Rocky Linux: pre-set os/dist to bypass unsupported-distro check\nos=el\ndist=" dist; next } 1' \
  "$SETUP_SCRIPT" > "${SETUP_SCRIPT}.patched"
mv "${SETUP_SCRIPT}.patched" "$SETUP_SCRIPT"

sudo bash "$SETUP_SCRIPT"
rm -f "$SETUP_SCRIPT"

install_dnfpkgs git-lfs

# Remove source repo's
sudo rm -f /etc/yum.repos.d/github_git-lfs.repo

# Document installed Git LFS repo
echo "git-lfs $GIT_LFS_REPO" | sudo tee -a "$HELPER_SCRIPTS"/package-versions.txt
