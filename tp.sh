if ! test -d bin; then mkdir bin; fi
odin run . -debug -out:./bin/target_pixel
