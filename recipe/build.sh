#!/bin/bash

set -ex

# helpful while developing from local sources that may be partially built
for s in lunar jpl_eph sat_code find_orb; do
	(cd sources/$s && make clean)
done

# makefile in jpl_eph uses CPP for the C++ compiler.  This collides with the
# C preprocessor on Unix-y OS-es. Let's replace it with CXX
sed -i.bak 's/CPP/CXX/g' sources/lunar/makefile && rm -f sources/lunar/makefile.bak
cat sources/lunar/makefile

# build all
( cd sources/lunar    && make                          && make install )
( cd sources/jpl_eph  && make libjpl.a                 && make install )
( cd sources/lunar    && make integrat                 && make install ) # must be a separate step as it depends on jpl_eph
( cd sources/sat_code && make sat_id                   && make install )
( cd sources/find_orb && make CURSES_LIB="-lncursesw"  && make install )

# clean up the libraries and headers we won't distribute
rm -f $PREFIX/lib/{libjpl,liblunar,libsatell}.a
rm -f $PREFIX/include/{afuncs,brentmin,cgi_func,comets,date,get_bin,jpleph,lunar,mpc_func,norad,showelem,vislimit,watdefs}.h
