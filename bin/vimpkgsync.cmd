@echo off
set CURR_DIR=%~dp0
set SCIRPT_PATH=%CURR_DIR:~0,-4%pkgsync_cmdline.vim
vim -NEsS "%SCIRPT_PATH%" %1 %2 %3 %4 %5 %6 %7 %8 %9
