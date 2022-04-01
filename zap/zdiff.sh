#/bin/sh

BRANCH=stable
REF=rpi/rpi-5.15.y

git checkout $REF
git merge -s ours --no-ff --no-edit $BRANCH

git log --oneline HEAD^..HEAD > zap/changes.log
sed -i '1d' zap/changes.log

git checkout $BRANCH
