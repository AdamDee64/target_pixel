@echo off
if not exist bin (
mkdir bin
)
odin run . -out:./bin/target_pixel.exe
