# Cylc suite WRF weather forecast

This repo contains the cylc suite for the WRF weather forecast.

## Instructions Cartesius 
In order to get the forecast running on cartesius, follow the steps in this document.

### Install WRFV3 and WPS
WRFV3 v3.7.1 with changes to the urban module in order to have high resolution urban parameters, as well as recycling of urban temperatures from the previous day forecast, should be installed from the
[ERA-URBAN github](https://www.github.com/ERA-URBAN/WRFV3). WPS can be installed from the [ERA-URBAN github](https://www.github.com/ERA-URBAN/WPS) as well.

### Create python virtual environment and install dependencies
To create a python virtual environment on cartesius we first need to load the python module with `module load python`.
After that, create and activate the environment with
```
mkdir ~/venv
virtualenv ~/venv/forecast
source ~/venv/forecast/bin/activate
```
Now we can install the requirements of the forecast suite in the python virtual environment we just created and activated:
```
pip install git+https://github.com/ERA-URBAN/wrfpy
```
Download cylc from [the cylc website](https://cylc.github.io/) and install. Add the directory with the `cylc` executable to the PATH variable in `~/.bashrc`.

With the command `deactivate` you can deactivate the python virtual environment if needed. It is time to logout and login so the changes to `~/.bashrc` take effect.

### Installing the forecast suite
First make sure the vitual environment we created in the previous step is activated. After that, we should be able to install and register 
```
mkdir ~/cylc-suites
cd ~/cylc-suites
git clone https://github.com/ERA-URBAN/forecast-suite.git
cylc register forecast-suite forecast-suite
```

### Configuring the forecast
The forecast suite has two configuration files, `settings.rc` and `config.json`. Both of these need to be adapted (e.g. changing start and end time of the simulation, directories and namelists to be used).

The file `suite.rc` is the workflow definition suite. This file doesn't need changing to run the forecast as is. 

### Running the forecast
If all changing to the configuration files are done, the python virtual environment that we created before is activated, it is time to start the forecast
```
cylc start forecast-suite
```
In order to see the current status of the forecast use
```
cylc monitor forecast-suite
```
If a task failed and needs to be restarted (some tasks are allowed to fail and will be cleaned up at the next time step), we can use the following command
```
cylc trigger forecast-suite TIMESTEP/TASK
```
where both TIMESTEP and TASK should be substituted for the timestep and taskname of the failed task.

### Log files
Cylc workflow engine keeps its log files in `~/cylc-run/forecast-suite`. Log files are ordened by timestep and taskname.

### Cylc manual
For more information on cylc please consult the [cylc website](https://cylc.github.io/index.html). 

## Instruction watertemperatures and plots
The watertemperatures are downloaded and converted to netCDF on maq06. The netCDF file is copied using `scp` to cartisus via a cron job on maq06. Vice versa, the plots for the website are copied to maq06. In order for this to work, the cron jobs on maq06 should have the correct destination path, and being able to passwordless copy the files. The steps to get this working are described [here](http://www.linuxproblem.org/art_9.html).
