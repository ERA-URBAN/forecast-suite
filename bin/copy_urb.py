#!/usr/bin/env python

import argparse
import datetime
import time
import wrfpy.utils as utils
from wrfpy.config import config
import os
#from urb import urb

class copy_urb(config):
    ''''
    Main function to initialize WPS timestep:
      - converts cylc timestring to datetime object
      - calls wps_init()
    '''
    def __init__(self, datestring, cylc_suite_def_path, interval, index):
        config.__init__(self)
        dt = utils.convert_cylc_time(datestring)
        prevtime = dt - datetime.timedelta(hours=interval)
        wrfout_time = datetime.datetime.strftime(prevtime, '%Y-%m-%d_%H:%M:%S')
        nml = self.config['options_wrf']['namelist.input']
        max_dom = utils.get_max_dom(nml)
        rundir = self.config['filesystem']['wrf_run_dir']
	if not len(index)==max_dom:
	  print 'index should be given for each domain'
          exit()
        for dom in range(1,max_dom+1):
            outfile = os.path.join(rundir, 'wrfout_d0' + str(dom) + '_' + wrfout_time)
            infile = os.path.join(rundir, 'wrfinput_d0' + str(dom))
            copyurb = os.path.join(cylc_suite_def_path, 'bin', 'copy_urb_init.sh')
            os.system(copyurb + ' ' + outfile + ' ' + infile + ' ' + str(index[dom-1]))

if __name__=="__main__":
    parser = argparse.ArgumentParser(description='Initialize obsproc.')
    parser.add_argument('datestring', metavar='N', type=str,
                        help='Date-time string from cylc suite')
    parser.add_argument('interval', metavar='I', type=int,
                        help='interval between runs')
    parser.add_argument('cylcsuitedefpath', metavar='O', type=str,
                        help='Path of cylc suite definition')
    parser.add_argument('-i', '--index', help='delimited list index', type=lambda s: [int(item) for item in s.split(',')])
    # parse arguments
    args = parser.parse_args()
    # call main
    copy_urb(args.datestring, args.cylcsuitedefpath, args.interval, args.index)    
