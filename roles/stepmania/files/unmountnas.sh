#!/bin/bash
# unmount first, if there have been changes to the mount paths since the last run
echo "Unmountataan NAS"
sudo umount /home/mckyla/stepmania-content/Songs
sudo umount /home/mckyla/.itgmania/Save/LocalProfiles
sudo umount /home/mckyla/stepmania-content/Courses
sudo umount /home/mckyla/.itgmania/NoteSkins
sudo umount /home/mckyla/stepmania-content/Themes/simplylove/Graphics/_judgments
sudo umount /home/mckyla/stepmania-content/Themes/simplylove/Graphics/_HoldJudgments
