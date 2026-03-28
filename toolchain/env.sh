#!/bin/sh
# Lab 3 toolchain env — works in both bash and zsh.
# Points at Lab 2's local/ directory where the MIPS cross-compiler lives.

LAB2_TOOLCHAIN=/Users/williamwang/Desktop/spring2026_Projects/Comp_Arch_Lab2/toolchain

export PATH=$LAB2_TOOLCHAIN/local/bin:$LAB2_TOOLCHAIN/local/encap/maven-sys-xcc/bin:$PATH
export LD_LIBRARY_PATH=$LAB2_TOOLCHAIN/local/lib:$LAB2_TOOLCHAIN/local/encap/maven-sys-xcc/lib:${LD_LIBRARY_PATH}
export MANPATH=$LAB2_TOOLCHAIN/local/man:${MANPATH}
export C_INCLUDE_PATH=$LAB2_TOOLCHAIN/local/include
export CPLUS_INCLUDE_PATH=$LAB2_TOOLCHAIN/local/include
export ENCAP_SOURCE=$LAB2_TOOLCHAIN/local/encap/

function urg() { command urg -full64 "$@"; }; export -f urg
function vcs() { command vcs -full64 "$@"; }; export -f vcs
function dve() { command dve -full64 "$@"; }; export -f dve

export PATH=/usr/bin/:$PATH
