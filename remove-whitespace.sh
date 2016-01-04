find . -iname '*.swift' | xargs gsed -i 's/[ ]\+$//g'
find . -iname '*.m' | xargs gsed -i 's/[ ]\+$//g'
find . -iname '*.h' | xargs gsed -i 's/[ ]\+$//g'
