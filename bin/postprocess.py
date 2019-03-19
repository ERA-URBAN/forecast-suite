#!/usr/bin/env python

import argparse
import datetime
import time
import wrfpy.utils as utils
from wrfpy.config import config
import os
import errno

class postprocess(config):
    ''''
    postprocesses forecast output from wrf_run_dir to
    archive_dir as defined in config.json under filesystem
    uses cdo, nc3tonc4 and ncl
    '''
    def __init__(self, datestring, cylc_suite_def_path):
        config.__init__(self)
        dt = utils.convert_cylc_time(datestring)
        wrfout_time = datetime.datetime.strftime(dt, '%Y-%m-%d_%H:%M:%S')
        nml = self.config['options_wrf']['namelist.input']
        max_dom = utils.get_max_dom(nml)
        rundir = self.config['filesystem']['wrf_run_dir']
        archivedir = self.config['filesystem']['archive_dir']
        gis_archive = os.path.join(archivedir, 'gis', wrfout_time)
        utils._create_directory(gis_archive)
        for dom in range(1,max_dom+1):
            wrfout = os.path.join(rundir, 'wrfout_d0' + str(dom) + '_' + wrfout_time)
            archived = os.path.join(archivedir, 'wrfout_d0' + str(dom) + '_' + wrfout_time)
            utils.silentremove(archived)
            os.system('nc3tonc4 ' + wrfout + ' ' + archived)
            try:
              gis_out = os.path.join(gis_archive, 'meteo_gis_d0' + str(dom) + '_' + wrfout_time)
              os.system('cdo -f nc4c -z zip_4 selvar,Q2,T2,U10,V10 ' + wrfout + ' ' + gis_out)
            except Exception:
              pass
            plot_archive = os.path.join(archivedir, 'plot', wrfout_time)
	    utils._create_directory(plot_archive)
            wrfncl = os.path.join(cylc_suite_def_path, 'bin', 'wrf_Surface3.ncl')
	    os.system('ncl ' + wrfncl + ' inputfile=' + r'\"' + archived + r'\" outputfile=\"' + plot_archive + r'/surface_d0' + str(dom) + '.png' + r'\"')
        plot_latest = os.path.join(archivedir, 'plot', 'latest')
        try:
	    os.symlink(plot_archive, plot_latest)
        except OSError, e:
            if e.errno == errno.EEXIST:
                 os.remove(plot_latest)
                 os.symlink(plot_archive, plot_latest)
        gis_latest = os.path.join(archivedir, 'gis', 'latest')
        try:
            os.symlink(gis_archive, gis_latest)
        except OSError, e:
            if e.errno == errno.EEXIST:
                 os.remove(gis_latest)
                 os.symlink(gis_archive, gis_latest)

if __name__=="__main__":
    parser = argparse.ArgumentParser(description='postprocess forecast output')
    parser.add_argument('datestring', metavar='N', type=str,
                        help='Date-time string from cylc suite')
    parser.add_argument('cylcsuitedefpath', metavar='O', type=str,
                        help='Path of cylc suite definition')
    # parse arguments
    args = parser.parse_args()
    # call main
    postprocess(args.datestring, args.cylcsuitedefpath)    
