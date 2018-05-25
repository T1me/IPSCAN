# IPSCAN
A multiple threads childnet ip scan script in powershell

## Usage
> .\ipscan.ps1 <192.168.1.> [-s silent] [-t=<num> thread]

## Silent Mode
In default, IPSCAN will output simple ping result. Add -s option if you dont want to see it.

## Threads
20 threads in default. Use -t option to change the number of threads. 

## Log
Not full result. Only the most important two lines of every ping result will be written in the log file.

## CMD Version
see cmd branch.
