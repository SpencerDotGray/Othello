#! /bin/bash

if which python3
then
	versionSuffix=3
else
	versionSuffix=""
fi

python${versionSuffix} --version
python${versionSuffix} -m venv othello_env
source ./othello_env/bin/activate venv & pip${versionSuffix} install -r requirements.txt 
clear & python${versionSuffix} main.py
