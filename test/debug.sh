dir=`pwd`
cd $dir
cat <<EOF | ruby -r debug main.rb -D
\$DIR = "$dir"
b "#{\$DIR}/compile.rb":texify
EOF
