#define _XOPEN_SOURCE 700

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <ftw.h>
#include <errno.h>

#define UID 4545
#define FILENAME "/home/gateway/.mozilla-iot"

#ifndef USE_FDS
#define USE_FDS 15
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

    /* Invalid directory path? */
    if (dirpath == NULL || *dirpath == '\0')
    {
        perror("chown");
        return errno = EINVAL;
    }

    result = nftw(dirpath, change_ownership, USE_FDS, FTW_PHYS);
    if (result >= 0)
        errno = result;

    if (errno != 0)
        perror("chown");

    return errno;
}
