#!/bin/bash

SETUP=false
TEMPLATES=false

SVGBOB="$PWD/svgbob/target/release/svgbob_cli"

function help () {
    echo "run.sh [--all, -a]: [--setup | -s] [--gen-templates | -g]"
}

function setup () {
    echo "Updating submodules..."
    git submodule init &&
    git submodule update
    check_errors

    exit 0
}

function gen_templates () {
    for template in $(find templates -type f -name "*.txt" -print);
    do
        local out_file=${template#templates/}
        out_file=$PWD/static/content/${out_file/txt/svg}
        check_errors "Malformed template file name: ${template}"

        [[ -d ${out_file%\/*.svg} ]] || mkdir -p ${out_file%\/*.svg}
        $SVGBOB $template > $out_file
        check_errors
    done

    exit 0
}

function check_errors () {
    local exit=$?
    [[ $exit != 0 ]] && echo $1 && exit $exit
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --setup|-s)
            SETUP=true
            shift
        ;;
        --gen-templates|-g)
            TEMPLATES=true
            shift
        ;;
        --all|-a)
            SETUP=true
            TEMPLATES=true
            shift
        ;;
        --help|-h)
            help
            exit 0
        ;;
        *)
            echo "Unknown argument: ${1}"
            exit 1
        ;;
    esac
done

if !($SETUP || $TEMPLATES); then
    echo "No commands found, run --help to view available commands"
    exit 2
fi
if [[ ! -f $SVGBOB ]]; then
    echo "svgbob cli binary not found, exiting..."
    exit 3
fi

if $SETUP; then
    setup
fi

if $TEMPLATES; then
    gen_templates
fi