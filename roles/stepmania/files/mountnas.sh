#!/bin/bash
# mount additional content from NAS
echo "Mountataan NAS"
sudo mount -t nfs 192.168.11.3:/volume1/Songs /home/mckyla/stepmania-content/Songs
sudo mount -t nfs 192.168.11.3:/volume1/LocalProfiles /home/mckyla/.itgmania/Save/LocalProfiles/
sudo mount -t nfs 192.168.11.3:/volume1/Courses /home/mckyla/stepmania-content/Courses
sudo mount -t nfs 192.168.11.3:/volume1/NoteSkins /home/mckyla/.itgmania/NoteSkins
sudo mount -t nfs 192.168.11.3:/volume1/Judgments /home/mckyla/stepmania-content/Themes/simplylove/Graphics/_judgments
sudo mount -t nfs 192.168.11.3:/volume1/HoldJudgments /home/mckyla/stepmania-content/Themes/simplylove/Graphics/_HoldJudgments && echo "Mountattu onnistuneesti" && exit 0
