#!/bin/bash

SETUP=false
TEMPLATES=false

LAUNCH_DIR="$PWD"
SVGBOB_DIR="$PWD/svgbob"
SVGBOB_CLI="$SVGBOB_DIR/target/release/svgbob_cli"

function help () {
    echo "run.sh [--all, -a]: [--setup | -s] [--gen-templates | -g]"
}

function setup () {
    echo "Updating submodules..."
    git submodule init &&
    git submodule update

    if [[ ! -d $SVGBOB_DIR ]]; then
        echo "svgbob submodule directory not found, exiting..."
        exit 4
    fi

    if ! $(cargo --version 2&>1 &> /dev/null); then
        echo "Installing rust..."
        curl https://sh.rustup.rs -sSf | sh -s -- -y
        check_errors
    fi

    if [[ ! -f $SVGBOB_CLI ]]; then
        echo "Building svgbob..."
        cd svgbob && cargo build
        check_errors
    fi

    cd $LAUNCH_DIR
}

function gen_templates () {
    for template in $(find templates -type f -name "*.txt" -print);
    do
        local out_file=${template#templates/}
        out_file=$PWD/static/content/${out_file/txt/svg}
        check_errors "Malformed template file name: ${template}"

        [[ -d ${out_file%\/*.svg} ]] || mkdir -p ${out_file%\/*.svg}
        echo "Rendering template ${template} to ${out_file}"
        $SVGBOB $template > $out_file
        check_errors
    done
}

function check_errors () {
    local exit=$?
    [[ $exit != 0 ]] && echo $1 && cd $LAUNCH_DIR && exit $exit
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
if [[ ! -f $SVGBOB_CLI ]]; then
    echo "svgbob cli binary not found, exiting..."
    exit 3
fi

if $SETUP; then
    setup
fi

if $TEMPLATES; then
    gen_templates
fi

exit 0