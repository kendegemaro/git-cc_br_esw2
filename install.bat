@echo off

call conda activate py27
python setup.py install
call conda deactivate