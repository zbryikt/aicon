jsblad skeleton - jade jquery sass bootstrap ls angular django
===============

This is a very first version of skeleton of django web application. It contains following technologies:

* jade
* jquery
* compass / sass
* bootstrap3
* livescript
* angular JS
* django

There are also several default django plugins:

* userena
* south
* pillow
* pyjade
* userena

Usage
=================

Prepare the working environment by:
    make env
    . vb

Prepare database by:
    make init

Update database schema by:
    make migrate

start dev server by:
    make run

check http://sample.tkirby.org:8000 for a sample instance.

External Dependencies
=================
Following packages are needed:

ruby and gem: for compass
nodejs and npm: for yuglify and livescript

compass: gem install compass
yuglify: npm -g install yuglify
livescript: npm -g install LiveScrip
