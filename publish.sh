git checkout gh-pages
cp -R _site docs
git commit --all -m "Pusblish"
git push origin gh-pages -f
git checkout master
