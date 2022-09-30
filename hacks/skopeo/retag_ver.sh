#!/bin/sh

for VER in 4.{6..9}
do
  skopeo sync -a --src yaml --dest docker ocp_${VER}_sync.yml git.tigerlab.io:6666/ocp/${VER}
done
