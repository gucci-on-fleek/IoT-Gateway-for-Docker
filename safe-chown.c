/* safe-chown.c
 * https://github.com/gucci-on-fleek/IoT-Gateway-for-Docker
 * Allow non-root users to change the ownership of a directory
 * specified at compile-time.
 */

#define UID 4545                              // UID to assign ownership to
#define FILENAME "/home/gateway/.mozilla-iot" // Directory to change ownership recursively

// All changes made below this point are AT YOUR OWN RISK!

#define _XOPEN_SOURCE 700 // Needed for some of the FTW flags

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <ftw.h>
#include <errno.h>

#ifndef USE_FDS
#define USE_FDS 15 // The number of file descriptors to open at once
#endif

uid_t uid;
uid_t uid = UID;

int change_ownership(const char *filepath, const struct stat *info,
                     const int typeflag, struct FTW *pathinfo)
{
    if (chown(filepath, uid, -1) == -1)
    {
        perror("chown");
    }
    return 0;
}

int main(int argc, char *argv[])
{
    int result;
    char *dirpath = FILENAME;

    // Invalid directory path
    if (dirpath == NULL || *dirpath == '\0')
    {
        perror("chown");
        return errno = EINVAL;
    }

    result = nftw(dirpath, change_ownership, USE_FDS, FTW_PHYS); // Filetree walk
    if (result >= 0)
        errno = result;

    if (errno != 0)
        perror("chown");

    return errno;
}
