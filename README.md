# Tantive IV

A remind-me program written in nim (https://nim-lang.org/)

Works just on linux with systemd and wayland for now

## If you don't use sytemd
You can write an equivalent .service

## If you don't use wayland
You can change the environment in rmd.service to match yours

You'll need to install nim and then run ```sh install.sh```

To use you can ```rmd 3h eat``` or ```rmd i have to eat in 3h and then go to the bathroom```
You can set more persistent notifications with the ```-i``` flag
See ```rmd --help``` for better help and supported formats
