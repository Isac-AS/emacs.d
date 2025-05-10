#!/bin/bash

cd "$(dirname "$0")"
stow --target="$HOME/.emacs.d" .emacs.d
