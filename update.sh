git add .
git commit -am "Tag $1"
git tag -a $1 -m "Tagging as $1"
git push origin master tag $1
