#!/bin/bash
set -e

echo "Kustomize Version:" 
kustomize version
echo ""

find -type f -iname "kustomization.y*ml" | while read file
do
    dir=$(dirname "$file")
    echo "# Testing ${dir}"
    kustomize build "${dir}"
    echo "# ---------------------------"
done
