aclocal -Wnone -I m4 -I .
libtoolize
automake --gnu --add-missing
autoconf
./configure --enable-static

