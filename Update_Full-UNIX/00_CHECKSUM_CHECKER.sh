# Written by Mikhail P. Ortiz-Lunyov (mportizlunyov)
#
# This script is intended to be called from the main Update_Full-UNIX script.
# Running this script manually is optional and possibe, but not the intended use case


# Checks for ROOT user
case $USER in
    "root") printf "USER: $USER\n" ;;
    *)
        printf "Using this script without ROOT priviledges is forbidden\n"
        exit 1
        ;;
esac
# Check if old sha256 and sha512 checksums exist
if [ -f "./update_full-unix-$1.sha256sum" ] ; then
    rm ./update_full-unix-$1.sha256sum
fi
if [ -f "./update_full-unix-$1.sha512sum" ] ; then
    rm ./update_full-unix-$1.sha512sum
fi
# Check for existence of Update_Full-UNIX file in local directory
if [ ! -f "$4/update_full-unix.sh" ] ; then
    # If missing, print Error message and quit
    printf "update_full-unix.sh script NOT FOUND!\n"
    printf "Current Directory: [\n$(ls)\n]\n"
    exit 1
fi
# Decides which tool to use to extract checksums
case $2 in
    "curl")
        case $3 in
            "true")
                echo "* DOWNLOADING using CURL [--insecure !!!]"
                curl --insecure --remote-name --silent https://raw.githubusercontent.com/mportizlunyov/uf-CHECKSUM_STORAGE/main/Update_Full-UNIX/latest/update_full-unix-$1.sha256sum
                curl --insecure --remote-name --silent https://raw.githubusercontent.com/mportizlunyov/uf-CHECKSUM_STORAGE/main/Update_Full-UNIX/latest/update_full-unix-$1.sha512sum
                ;;
            "false")
                echo "* DOWNLOADING using CURL"
                curl --remote-name --silent https://raw.githubusercontent.com/mportizlunyov/uf-CHECKSUM_STORAGE/main/Update_Full-UNIX/latest/update_full-unix-$1.sha256sum
                curl --remote-name --silent https://raw.githubusercontent.com/mportizlunyov/uf-CHECKSUM_STORAGE/main/Update_Full-UNIX/latest/update_full-unix-$1.sha512sum
                ;;
            *)
                printf "\t!!! INTERNAL PROGRAM ERROR !!!\n"
                exit 1
                ;;
        esac
        ;;
    "wget")
        echo "* DOWNLOADING using WGET"
        wget --quiet https://raw.githubusercontent.com/mportizlunyov/uf-CHECKSUM_STORAGE/main/Update_Full-UNIX/latest/update_full-unix-$1.sha256sum
        wget --quiet https://raw.githubusercontent.com/mportizlunyov/uf-CHECKSUM_STORAGE/main/Update_Full-UNIX/latest/update_full-unix-$1.sha512sum
        ;;
    *)
        printf "\n\t^ Neither CURL nor WGET exists, cannot continue!!!\n"
        exit 1
        ;;
esac
# If checksum files are not rpesent
if [ ! -f "./update_full-unix-$1.sha256sum" ] && [ ! -f "./update_full-unix-$1.sha512sum" ] ; then
    printf "\n\t ^ Checksums FAILED to download using $2, check connection!!\n"
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
if [ "$(cat ./tempfile_ACTUAL256)" = "" ] || [ "$( cat ./tempfile_ACTUAL512)" = "" ] ; then
    echo "$(cksum -a sha256 -q ./update_full-unix.sh)" > ./tempfile_ACTUAL256
    echo "$(cksum -a sha512 -q ./update_full-unix.sh)" > ./tempfile_ACTUAL512
fi
# Compare and Contrast checksums, and take action based on similarity
if [ "$(cat ./update_full-unix-$1.sha256sum)" = "$(cat ./tempfile_ACTUAL256)" ] && [ "$(cat ./update_full-unix-$1.sha512sum)" = "$(cat ./tempfile_ACTUAL512)" ] ; then
    printf "\t \e[1m< MATCHING [up-to-date and secure to use]! >\e[0m\n"
else
    printf "\t^ !!!CHECKSUM MIS-MATCH !!!\n\t ^ Check for NEWER VERSION or check for TAMPERING\n"
    printf "* Currently running v$1\n"
    exit 1
fi
# If everything runs as normal
rm ./update_full-unix-$1.sha256sum > /dev/null 2>&1
rm ./update_full-unix-$1.sha512sum > /dev/null 2>&1
rm ./tempfile_ACTUAL256 > /dev/null 2>&1
rm ./tempfile_ACTUAL512 > /dev/null 2>&1
exit 0
