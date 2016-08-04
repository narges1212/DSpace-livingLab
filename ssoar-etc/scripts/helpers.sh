#!/bin/sh

function get_property
{
    PROP_FILE=$1
    PROP_KEY=$2
    PROP_VALUE=`cat $PROP_FILE | grep "$PROP_KEY" | cut -d'=' -f2`

    echo $PROP_VALUE
}

function convert_win_path_to_cygwin_path
{
    WIN_PATH=$1
    CYGWIN_PATH=/cygdrive/c"$WIN_PATH"
    echo $CYGWIN_PATH
}