#!/bin/sh

ln -srfT dist/misc/brachistochrone/demo dist/pt/misc/brachistochrone/demo
rsync -cavurxz --copy-links --delete dist/ goll@goll.cc:/srv/www/webroot/
