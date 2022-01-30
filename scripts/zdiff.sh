#/bin/sh

BRANCH=next
REF=rpi/rpi-5.15.y

git checkout $REF
git merge --no-ff --no-edit $BRANCH

git log --oneline HEAD^..HEAD > changes.log
sed -i '1d' changes.log

git checkout $BRANCH
