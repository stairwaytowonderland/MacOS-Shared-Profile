# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7)  OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  *  command to be executed
# *  *  *  *  *  command --arg1 --arg2 file1 file2 2>&1

# Only removed .DS_Store from /Volumes folder.
0 * * * * find /Volumes -name '.DS_Store' -type f -delete >/dev/null 2>&1
# Follow symlinks and recursiveloy remove all occurrences. Not recommended since folder view attributes will be lost.
# 0 * * * * find -L /Volumes -name '.DS_Store' -type f -delete >/dev/null 2>&1
