#!/bin/sh

function gdb-peda(){
    gdb -q -ex init-peda "$@"
}

function gdb-pwndbg(){
    pwndbg "$@"
}

function gdb-gef(){
    gdb -q -ex init-gef "$@"
}
