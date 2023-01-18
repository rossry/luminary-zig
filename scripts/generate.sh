#!/bin/bash

# run this from luminary root
make
mkdir -p demo/f3-1a
bin/a.out 500
ffmpeg -r 50 -y -i demo/f3-1a/img0000%04d.png -c:v libx264 -vf fps=50 -pix_fmt yuv420p demo/f3-1a_50hz.mp4
