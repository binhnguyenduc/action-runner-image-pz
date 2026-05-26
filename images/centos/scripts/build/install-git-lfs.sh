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

# Install git-lfs
# packagecloud does not natively support Rocky Linux; the same download-patch-execute
# approach is used here for consistency on all RHEL-family systems.
SETUP_SCRIPT=$(mktemp /tmp/git-lfs-setup-XXXXXX.sh)
curl -fsSL https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh -o "$SETUP_SCRIPT"

OS_MAJOR=$(rpm -q --qf '%{VERSION}' centos-release rocky-release redhat-release 2>/dev/null | grep -v 'not installed' | head -1 | cut -d. -f1 || echo "9")
awk -v dist="$OS_MAJOR" \
  'NR==1 { print; print "\n# RHEL-family override: pre-set os/dist to bypass unsupported-distro check\nos=el\ndist=" dist; next } 1' \
  "$SETUP_SCRIPT" > "${SETUP_SCRIPT}.patched"
mv "${SETUP_SCRIPT}.patched" "$SETUP_SCRIPT"

sudo env PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH" bash "$SETUP_SCRIPT"
rm -f "$SETUP_SCRIPT"
install_dnfpkgs git-lfs

# Remove source repo's
sudo rm -f /etc/yum.repos.d/github_git-lfs.repo

# Document installed Git LFS repo
echo "git-lfs $GIT_LFS_REPO" | sudo tee -a "$HELPER_SCRIPTS"/package-versions.txt
