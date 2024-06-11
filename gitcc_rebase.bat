@echo off

rem setup
chcp 1252
call conda activate py27
@echo conda activate py27

if not exist .git\ (
  @echo.
  @echo This folder is not a git repository!
  goto :error
)

if [%1]==[] goto :argumentError
if [%2]==[] goto :argumentError
if [%3]==[] goto :argumentError

SET git_branch=%1
SET cc_dir=%2
SET cc_branches=%3

rem Remove quotation marks, but not from cc_branches variable!
SET git_branch=%git_branch:"=%
SET cc_dir=%cc_dir:"=%
SET cc_branches=%cc_branches:|=^|%

rem write gitcc config
SET gitcc_file=./.git/gitcc
>%gitcc_file%  echo [core]
>>%gitcc_file% echo [%git_branch%]
>>%gitcc_file% echo clearcase = %cc_dir%
>>%gitcc_file% echo branches = %cc_branches:"=%
>>%gitcc_file% echo cache = off

rem clear uncommitted git changes(!) and switch to base branch
git reset
git checkout .
git clean -fdx
rem this creates the _cc and _ci branches, if it doesnt exist yet. Ignore the "branch already exists" error.
git switch %git_branch%
git switch -c %git_branch%_cc
git switch -c %git_branch%_ci
git switch %git_branch%

rem run gitcc
@echo.
@echo --------------- Start of gitcc ---------------
if exist ./.git/lshistory.bak (
  
  START /wait /B gitcc rebase --load .git\lshistory.bak
  goto :cleanup
)
START /wait /B gitcc rebase

:cleanup
@echo ---------------- End of gitcc ----------------
@echo.
git branch -D %git_branch%_cc
git branch -D %git_branch%_ci
conda deactivate
@echo.
@echo End of batch script. Exiting now.
exit /B 0

:argumentError
@echo.
@echo Usage: gitcc_rebase.bat [git branch] [CC VOB path] [CC branch(es)]
@echo        [git branch]:    Target git branch name
@echo        [CC VOB branch]: Original (absolute!) ClearCase VOB path
@echo        [CC branch(es)]: String of all ClearCase branches to be rebased,  
@echo                         seperated by "|". Example: "main|syb_3_0|tp_3dff_ble4"
goto :error

:error
@echo.
@echo Exiting with error.
exit /B 1