#!/bin/bash
set -eu

SMALLSIZE=4
MEDIUMSIZE=128
LARGESIZE=132

echo "=== Seek tests ==="
rm -rf blocks
tests/test.py << TEST
    lfs2_format(&lfs2, &cfg) => 0;
    lfs2_mount(&lfs2, &cfg) => 0;
    lfs2_mkdir(&lfs2, "hello") => 0;
    for (int i = 0; i < $LARGESIZE; i++) {
        sprintf((char*)buffer, "hello/kitty%03d", i);
        lfs2_file_open(&lfs2, &file[0], (char*)buffer,
                LFS2_O_WRONLY | LFS2_O_CREAT | LFS2_O_APPEND) => 0;

        size = strlen("kittycatcat");
        memcpy(buffer, "kittycatcat", size);
        for (int j = 0; j < $LARGESIZE; j++) {
            lfs2_file_write(&lfs2, &file[0], buffer, size);
        }

        lfs2_file_close(&lfs2, &file[0]) => 0;
    }
    lfs2_unmount(&lfs2) => 0;
TEST

echo "--- Simple dir seek ---"
tests/test.py << TEST
    lfs2_mount(&lfs2, &cfg) => 0;
    lfs2_dir_open(&lfs2, &dir[0], "hello") => 0;
    lfs2_dir_read(&lfs2, &dir[0], &info) => 1;
    strcmp(info.name, ".") => 0;
    lfs2_dir_read(&lfs2, &dir[0], &info) => 1;
    strcmp(info.name, "..") => 0;

    lfs2_soff_t pos;
    int i;
    for (i = 0; i < $SMALLSIZE; i++) {
        sprintf((char*)buffer, "kitty%03d", i);
        lfs2_dir_read(&lfs2, &dir[0], &info) => 1;
        strcmp(info.name, (char*)buffer) => 0;
        pos = lfs2_dir_tell(&lfs2, &dir[0]);
    }
    pos >= 0 => 1;

    lfs2_dir_seek(&lfs2, &dir[0], pos) => 0;
    sprintf((char*)buffer, "kitty%03d", i);
    lfs2_dir_read(&lfs2, &dir[0], &info) => 1;
    strcmp(info.name, (char*)buffer) => 0;

    lfs2_dir_rewind(&lfs2, &dir[0]) => 0;
    sprintf((char*)buffer, "kitty%03d", 0);
    lfs2_dir_read(&lfs2, &dir[0], &info) => 1;
    strcmp(info.name, ".") => 0;
    lfs2_dir_read(&lfs2, &dir[0], &info) => 1;
    strcmp(info.name, "..") => 0;
    lfs2_dir_read(&lfs2, &dir[0], &info) => 1;
    strcmp(info.name, (char*)buffer) => 0;

    lfs2_dir_seek(&lfs2, &dir[0], pos) => 0;
    sprintf((char*)buffer, "kitty%03d", i);
    lfs2_dir_read(&lfs2, &dir[0], &info) => 1;
    strcmp(info.name, (char*)buffer) => 0;

    lfs2_dir_close(&lfs2, &dir[0]) => 0;
    lfs2_unmount(&lfs2) => 0;
TEST

echo "--- Large dir seek ---"
tests/test.py << TEST
    lfs2_mount(&lfs2, &cfg) => 0;
    lfs2_dir_open(&lfs2, &dir[0], "hello") => 0;
    lfs2_dir_read(&lfs2, &dir[0], &info) => 1;
    strcmp(info.name, ".") => 0;
    lfs2_dir_read(&lfs2, &dir[0], &info) => 1;
    strcmp(info.name, "..") => 0;

    lfs2_soff_t pos;
    int i;
    for (i = 0; i < $MEDIUMSIZE; i++) {
        sprintf((char*)buffer, "kitty%03d", i);
        lfs2_dir_read(&lfs2, &dir[0], &info) => 1;
        strcmp(info.name, (char*)buffer) => 0;
        pos = lfs2_dir_tell(&lfs2, &dir[0]);
    }
    pos >= 0 => 1;

    lfs2_dir_seek(&lfs2, &dir[0], pos) => 0;
    sprintf((char*)buffer, "kitty%03d", i);
    lfs2_dir_read(&lfs2, &dir[0], &info) => 1;
    strcmp(info.name, (char*)buffer) => 0;

    lfs2_dir_rewind(&lfs2, &dir[0]) => 0;
    sprintf((char*)buffer, "kitty%03d", 0);
    lfs2_dir_read(&lfs2, &dir[0], &info) => 1;
    strcmp(info.name, ".") => 0;
    lfs2_dir_read(&lfs2, &dir[0], &info) => 1;
    strcmp(info.name, "..") => 0;
    lfs2_dir_read(&lfs2, &dir[0], &info) => 1;
    strcmp(info.name, (char*)buffer) => 0;

    lfs2_dir_seek(&lfs2, &dir[0], pos) => 0;
    sprintf((char*)buffer, "kitty%03d", i);
    lfs2_dir_read(&lfs2, &dir[0], &info) => 1;
    strcmp(info.name, (char*)buffer) => 0;

    lfs2_dir_close(&lfs2, &dir[0]) => 0;
    lfs2_unmount(&lfs2) => 0;
TEST

echo "--- Simple file seek ---"
tests/test.py << TEST
    lfs2_mount(&lfs2, &cfg) => 0;
    lfs2_file_open(&lfs2, &file[0], "hello/kitty042", LFS2_O_RDONLY) => 0;

    lfs2_soff_t pos;
    size = strlen("kittycatcat");
    for (int i = 0; i < $SMALLSIZE; i++) {
        lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
        memcmp(buffer, "kittycatcat", size) => 0;
        pos = lfs2_file_tell(&lfs2, &file[0]);
    }
    pos >= 0 => 1;

    lfs2_file_seek(&lfs2, &file[0], pos, LFS2_SEEK_SET) => pos;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "kittycatcat", size) => 0;

    lfs2_file_rewind(&lfs2, &file[0]) => 0;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "kittycatcat", size) => 0;

    lfs2_file_seek(&lfs2, &file[0], 0, LFS2_SEEK_CUR) => size;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "kittycatcat", size) => 0;

    lfs2_file_seek(&lfs2, &file[0], size, LFS2_SEEK_CUR) => 3*size;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "kittycatcat", size) => 0;

    lfs2_file_seek(&lfs2, &file[0], pos, LFS2_SEEK_SET) => pos;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "kittycatcat", size) => 0;

    lfs2_file_seek(&lfs2, &file[0], -size, LFS2_SEEK_CUR) => pos;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "kittycatcat", size) => 0;

    lfs2_file_seek(&lfs2, &file[0], -size, LFS2_SEEK_END) >= 0 => 1;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "kittycatcat", size) => 0;

    size = lfs2_file_size(&lfs2, &file[0]);
    lfs2_file_seek(&lfs2, &file[0], 0, LFS2_SEEK_CUR) => size;

    lfs2_file_close(&lfs2, &file[0]) => 0;
    lfs2_unmount(&lfs2) => 0;
TEST

echo "--- Large file seek ---"
tests/test.py << TEST
    lfs2_mount(&lfs2, &cfg) => 0;
    lfs2_file_open(&lfs2, &file[0], "hello/kitty042", LFS2_O_RDONLY) => 0;

    lfs2_soff_t pos;
    size = strlen("kittycatcat");
    for (int i = 0; i < $MEDIUMSIZE; i++) {
        lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
        memcmp(buffer, "kittycatcat", size) => 0;
        pos = lfs2_file_tell(&lfs2, &file[0]);
    }
    pos >= 0 => 1;

    lfs2_file_seek(&lfs2, &file[0], pos, LFS2_SEEK_SET) => pos;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "kittycatcat", size) => 0;

    lfs2_file_rewind(&lfs2, &file[0]) => 0;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "kittycatcat", size) => 0;

    lfs2_file_seek(&lfs2, &file[0], 0, LFS2_SEEK_CUR) => size;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "kittycatcat", size) => 0;

    lfs2_file_seek(&lfs2, &file[0], size, LFS2_SEEK_CUR) => 3*size;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "kittycatcat", size) => 0;

    lfs2_file_seek(&lfs2, &file[0], pos, LFS2_SEEK_SET) => pos;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "kittycatcat", size) => 0;

    lfs2_file_seek(&lfs2, &file[0], -size, LFS2_SEEK_CUR) => pos;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "kittycatcat", size) => 0;

    lfs2_file_seek(&lfs2, &file[0], -size, LFS2_SEEK_END) >= 0 => 1;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "kittycatcat", size) => 0;

    size = lfs2_file_size(&lfs2, &file[0]);
    lfs2_file_seek(&lfs2, &file[0], 0, LFS2_SEEK_CUR) => size;

    lfs2_file_close(&lfs2, &file[0]) => 0;
    lfs2_unmount(&lfs2) => 0;
TEST

echo "--- Simple file seek and write ---"
tests/test.py << TEST
    lfs2_mount(&lfs2, &cfg) => 0;
    lfs2_file_open(&lfs2, &file[0], "hello/kitty042", LFS2_O_RDWR) => 0;

    lfs2_soff_t pos;
    size = strlen("kittycatcat");
    for (int i = 0; i < $SMALLSIZE; i++) {
        lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
        memcmp(buffer, "kittycatcat", size) => 0;
        pos = lfs2_file_tell(&lfs2, &file[0]);
    }
    pos >= 0 => 1;

    memcpy(buffer, "doggodogdog", size);
    lfs2_file_seek(&lfs2, &file[0], pos, LFS2_SEEK_SET) => pos;
    lfs2_file_write(&lfs2, &file[0], buffer, size) => size;

    lfs2_file_seek(&lfs2, &file[0], pos, LFS2_SEEK_SET) => pos;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "doggodogdog", size) => 0;

    lfs2_file_rewind(&lfs2, &file[0]) => 0;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "kittycatcat", size) => 0;

    lfs2_file_seek(&lfs2, &file[0], pos, LFS2_SEEK_SET) => pos;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "doggodogdog", size) => 0;

    lfs2_file_seek(&lfs2, &file[0], -size, LFS2_SEEK_END) >= 0 => 1;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "kittycatcat", size) => 0;

    size = lfs2_file_size(&lfs2, &file[0]);
    lfs2_file_seek(&lfs2, &file[0], 0, LFS2_SEEK_CUR) => size;

    lfs2_file_close(&lfs2, &file[0]) => 0;
    lfs2_unmount(&lfs2) => 0;
TEST

echo "--- Large file seek and write ---"
tests/test.py << TEST
    lfs2_mount(&lfs2, &cfg) => 0;
    lfs2_file_open(&lfs2, &file[0], "hello/kitty042", LFS2_O_RDWR) => 0;

    lfs2_soff_t pos;
    size = strlen("kittycatcat");
    for (int i = 0; i < $MEDIUMSIZE; i++) {
        lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
        if (i != $SMALLSIZE) {
            memcmp(buffer, "kittycatcat", size) => 0;
        }
        pos = lfs2_file_tell(&lfs2, &file[0]);
    }
    pos >= 0 => 1;

    memcpy(buffer, "doggodogdog", size);
    lfs2_file_seek(&lfs2, &file[0], pos, LFS2_SEEK_SET) => pos;
    lfs2_file_write(&lfs2, &file[0], buffer, size) => size;

    lfs2_file_seek(&lfs2, &file[0], pos, LFS2_SEEK_SET) => pos;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "doggodogdog", size) => 0;

    lfs2_file_rewind(&lfs2, &file[0]) => 0;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "kittycatcat", size) => 0;

    lfs2_file_seek(&lfs2, &file[0], pos, LFS2_SEEK_SET) => pos;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "doggodogdog", size) => 0;

    lfs2_file_seek(&lfs2, &file[0], -size, LFS2_SEEK_END) >= 0 => 1;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "kittycatcat", size) => 0;

    size = lfs2_file_size(&lfs2, &file[0]);
    lfs2_file_seek(&lfs2, &file[0], 0, LFS2_SEEK_CUR) => size;

    lfs2_file_close(&lfs2, &file[0]) => 0;
    lfs2_unmount(&lfs2) => 0;
TEST

echo "--- Boundary seek and write ---"
tests/test.py << TEST
    lfs2_mount(&lfs2, &cfg) => 0;
    lfs2_file_open(&lfs2, &file[0], "hello/kitty042", LFS2_O_RDWR) => 0;

    size = strlen("hedgehoghog");
    const lfs2_soff_t offsets[] = {512, 1020, 513, 1021, 511, 1019};

    for (unsigned i = 0; i < sizeof(offsets) / sizeof(offsets[0]); i++) {
        lfs2_soff_t off = offsets[i];
        memcpy(buffer, "hedgehoghog", size);
        lfs2_file_seek(&lfs2, &file[0], off, LFS2_SEEK_SET) => off;
        lfs2_file_write(&lfs2, &file[0], buffer, size) => size;
        lfs2_file_seek(&lfs2, &file[0], off, LFS2_SEEK_SET) => off;
        lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
        memcmp(buffer, "hedgehoghog", size) => 0;

        lfs2_file_seek(&lfs2, &file[0], 0, LFS2_SEEK_SET) => 0;
        lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
        memcmp(buffer, "kittycatcat", size) => 0;

        lfs2_file_sync(&lfs2, &file[0]) => 0;
    }

    lfs2_file_close(&lfs2, &file[0]) => 0;
    lfs2_unmount(&lfs2) => 0;
TEST

echo "--- Out-of-bounds seek ---"
tests/test.py << TEST
    lfs2_mount(&lfs2, &cfg) => 0;
    lfs2_file_open(&lfs2, &file[0], "hello/kitty042", LFS2_O_RDWR) => 0;

    size = strlen("kittycatcat");
    lfs2_file_size(&lfs2, &file[0]) => $LARGESIZE*size;
    lfs2_file_seek(&lfs2, &file[0], ($LARGESIZE+$SMALLSIZE)*size,
            LFS2_SEEK_SET) => ($LARGESIZE+$SMALLSIZE)*size;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => 0;

    memcpy(buffer, "porcupineee", size);
    lfs2_file_write(&lfs2, &file[0], buffer, size) => size;

    lfs2_file_seek(&lfs2, &file[0], ($LARGESIZE+$SMALLSIZE)*size,
            LFS2_SEEK_SET) => ($LARGESIZE+$SMALLSIZE)*size;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "porcupineee", size) => 0;

    lfs2_file_seek(&lfs2, &file[0], $LARGESIZE*size,
            LFS2_SEEK_SET) => $LARGESIZE*size;
    lfs2_file_read(&lfs2, &file[0], buffer, size) => size;
    memcmp(buffer, "\0\0\0\0\0\0\0\0\0\0\0", size) => 0;

    lfs2_file_seek(&lfs2, &file[0], -(($LARGESIZE+$SMALLSIZE)*size),
            LFS2_SEEK_CUR) => LFS2_ERR_INVAL;
    lfs2_file_tell(&lfs2, &file[0]) => ($LARGESIZE+1)*size;

    lfs2_file_seek(&lfs2, &file[0], -(($LARGESIZE+2*$SMALLSIZE)*size),
            LFS2_SEEK_END) => LFS2_ERR_INVAL;
    lfs2_file_tell(&lfs2, &file[0]) => ($LARGESIZE+1)*size;

    lfs2_file_close(&lfs2, &file[0]) => 0;
    lfs2_unmount(&lfs2) => 0;
TEST

echo "--- Results ---"
tests/stats.py
