# Written by Mikhail Patricio Ortiz-Lunyov
#
# This script is intended to be called from the main Update_Full-UNIX script.
# Running this script manually is optional and possibe, but not the intended use case

# Checks for ROOT user
case $USER in
    "root")
    printf "Continuing to check checksums\n"
        ;;
    *)
        printf "Using this script without ROOT priviledges is forbidden\n"
        exit 1
        ;;
esac
# Check for existence of Update_Full-UNIX file in local directory
if [ ! -f "./update_full-unix.sh" ] ; then
    # If missing, print Error message and quit
    printf "update_full-unix.sh script NOT FOUND!\n"
    exit 1
fi
# Decides which tool to use to extract checksums
case $2 in
    "CURL")
        case $3 in
            "true")
                echo "CURL INSECURE!!!"
                curl --insecure --remote-name --silent https://raw.githubusercontent.com/mportizlunyov/uf-CHECKSUM_STORAGE/main/Update_Full-UNIX/latest/update_full-unix-$1.sha256sum
                curl --insecure --remote-name --silent https://raw.githubusercontent.com/mportizlunyov/uf-CHECKSUM_STORAGE/main/Update_Full-UNIX/latest/update_full-unix-$1.sha512sum
                ;;
            "false")
                echo "NORMAL CURL"
                curl --remote-name --silent https://raw.githubusercontent.com/mportizlunyov/uf-CHECKSUM_STORAGE/main/Update_Full-UNIX/latest/update_full-unix-$1.sha256sum
                curl --remote-name --silent https://raw.githubusercontent.com/mportizlunyov/uf-CHECKSUM_STORAGE/main/Update_Full-UNIX/latest/update_full-unix-$1.sha512sum
                ;;
            *)
                printf "Check program!\n"
                exit 1
                ;;
        esac
        ;;
    "WGET")
        echo "WGET"
        wget --quiet https://raw.githubusercontent.com/mportizlunyov/uf-CHECKSUM_STORAGE/main/Update_Full-UNIX/latest/update_full-unix-$1.sha256sum
        wget --quiet https://raw.githubusercontent.com/mportizlunyov/uf-CHECKSUM_STORAGE/main/Update_Full-UNIX/latest/update_full-unix-$1.sha512sum
        ;;
    *)
        printf "Neither CURL nor WGET exists, cannot continue!\n"
        exit 1
        ;;
esac
# If checksum files are not rpesent
if [ ! -f "./update_full-unix-$1.sha256sum" ] && [ ! -f "update_full-unix-$1.sha512sum" ] ; then
    printf "Checksums failed to download using $2, check connection\n"
    rm ./update_full-unix-$1.sha256sum > /dev/null 2>&1
    rm ./update_full-unix-$1.sha512sum > /dev/null 2>&1
    exit 1
fi
# Format downloaded checksums
echo "$(cat ./update_full-unix-$1.sha256sum | cut -d ' ' -f 1)" > ./update_full-unix-$1.sha256sum
echo "$(cat ./update_full-unix-$1.sha512sum | cut -d ' ' -f 1)" > ./update_full-unix-$1.sha512sum
# Format actual checksums
echo "$(sha256sum ./update_full-unix.sh | cut -d ' ' -f 1)" > ./tempfile_ACTUAL256
echo "$(sha512sum ./update_full-unix.sh | cut -d ' ' -f 1)" > ./tempfile_ACTUAL512
# Compare and Contrast checksums, and take action based on similarity
if [ "$(cat ./update_full-unix-$1.sha256sum)" = "$(cat ./tempfile_ACTUAL256)" ] && [ "$(cat ./update_full-unix-$1.sha512sum)" = "$(cat ./tempfile_ACTUAL512)" ] ; then
    printf "MATCHING [up-to-date and secure to use]!\n"
else
    printf " !!!CHECKSUM MIS-MATCH !!!\nCheck for NEWER VERSION or check for TAMPERING\n"
    printf "Currently running v$1\n"
    rm ./update_full-unix-$1.sha256sum > /dev/null 2>&1
    rm ./update_full-unix-$1.sha512sum > /dev/null 2>&1
    rm ./tempfile_ACTUAL256 > /dev/null 2>&1
    rm ./tempfile_ACTUAL512 > /dev/null 2>&1
    exit 1
fi

rm ./update_full-unix-$1.sha256sum > /dev/null 2>&1
rm ./update_full-unix-$1.sha512sum > /dev/null 2>&1
rm ./tempfile_ACTUAL256 > /dev/null 2>&1
rm ./tempfile_ACTUAL512 > /dev/null 2>&1
exit 0
