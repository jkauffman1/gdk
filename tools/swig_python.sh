#!/bin/bash
set -e

sed_exe=$1
generated_c=$2
outdir=$3
swig_src=$4
swig_extra=$5

echo **** swig_python.sh
echo **** sed_exe = $sed_exe
echo **** generated_c = $generated_c
echo **** outdir = $outdir
echo **** swig_src = $swig_src
echo **** swig_extra = $swig_extra

module_dir="$outdir/greenaddress"
mkdir -p $module_dir

echo **** module_dir = $module_dir

swig -python -py3 -threads -o $generated_c -outdir $outdir -o $generated_c $swig_src
swig_result="$outdir/greenaddress.py"

echo ***** swig_result = $swig_result

# Fix up shared library names
$sed_exe -i 's/_greenaddress/libgreenaddress/g' $generated_c $swig_result

# Merge the extra helper code into greenaddress/__init__.py
mv $swig_result $module_dir/__init__.py
cat $swig_extra >>$module_dir/__init__.py
