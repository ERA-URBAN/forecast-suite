
;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  a = addfile(inputfile,"r")

; We generate plots, but what kind do we prefer?
; type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
  type = "png"
  wks = gsn_open_wks(type,outputfile)

; Set some basic resources
  res = True
  res@MainTitle                   = "REAL-TIME WRF"

  pltres = True
  mpres = True

  ; Set country outlines if high resolution borders are available
  rangs_dir  = ncargpath("rangs")
  rangs_file = "gshhs(0).rim"
  ;if(fileexists(rangs_dir + "/" + rangs_file)) then   
    mpres@mpFillOn                    = False        ; turn off gray fill
    mpres@mpOutlineBoundarySets       = "National"   ; turn on country boundaries
    mpres@mpDataSetName               = "RANGS_GSHHS"   ; set high resolution border
    mpres@mpDataBaseVersion           = "HighRes"  ; set high resolution border
    mpres@mpGeophysicalLineColor      = "Black"      ; color of cont. outlines
    mpres@mpGeophysicalLineThicknessF = 2            ; thickness of outlines
  ;end if
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; What times and how many time steps are in the data set?
  times = wrf_user_getvar(a,"times",-1)  ; get all times in the file
  ntimes = dimsizes(times)         ; number of times in the file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  do it = 0,ntimes-1,2             ; TIME LOOP

    print("Working on time: " + times(it) )
    res@TimeLabel = times(it)   ; Set Valid time to use on plots


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   tc_all = wrf_user_getvar(a, "T2", -1)
      dmin    = min(tc_all) - 273.15
      dmax    = max(tc_all) - 273.15
      maxlev  = 40
      mnmxint = nice_mnmxintvl( dmin, dmax, maxlev, False)

; First get the variables we will need        

    slp = wrf_user_getvar(a,"slp",it)    ; slp
      wrf_smooth_2d( slp, 3 )            ; smooth slp
    tc = wrf_user_getvar(a,"tc",it)      ; 3D tc 
    u  = wrf_user_getvar(a,"ua",it)      ; 3D U at mass points
    v  = wrf_user_getvar(a,"va",it)      ; 3D V at mass points
    tc2 = wrf_user_getvar(a,"T2",it)     ; T2 in Kelvin
       tc2 = tc2-273.16                  ; T2 in C
       tc2@units = "C"

    tc2canyon = wrf_user_getvar(a,"TC2M_URB",it)    ; 2m temperature in canyon from SLUCM
       tc2canyon = tc2canyon -273.16                 ; in C
       tc2canyon@units = "C"

    u10 = wrf_user_getvar(a,"U10",it)    ; u at 10 m, mass point
    v10 = wrf_user_getvar(a,"V10",it)    ; v at 10 m, mass point

    u10 = u10*1.94386                    ; Turn wind into knots
    v10 = v10*1.94386
      u10@units = "kts"
      v10@units = "kts"

    if (it .eq. 0) then
      tc2merged = tc2
    else
      ; merge tc2 and tc2canyon
      utype = wrf_user_getvar(a,"UTYPE_URB",it)           ; urban type 1-4: SLUCM, 0: non-urban
      tc2merged = where( utype.eq.0, tc2, tc2canyon )
    end if
    tc2merged@units = "C"
    tc2merged@description = tc2@description

    tavg = avg( tc2merged )
    tdiff = tc2merged - tavg
       tdiff@units = "C"
       tdiff@description = "T - Tavg"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Plotting options for T                
   ;   dmin    = min(tc_all)
    ;  dmax    = max(tc_all)
    ;  maxlev  = 40
    ;  mnmxint = nice_mnmxintvl( dmin, dmax, maxlev, False)
      opts = res                         
      opts@cnFillOn = True  
      ;opts@ContourParameters = (/  20., 27., 0.25/)
      opts@ContourParameters = mnmxint
      opts@gsnSpreadColorEnd = -3  ; End third from the last color in color map
      contour_tc = wrf_contour(a,wks,tc2merged,opts)
      delete(opts)

    ; Plotting options for Tdiff                
      opts = res                         
      opts@cnFillOn = True  
      opts@ContourParameters = (/  -5., 5., 0.5/)
      opts@gsnSpreadColorEnd = -3  ; End third from the last color in color map
      contour_tdiff = wrf_contour(a,wks,tdiff,opts)
      delete(opts)


    ; Plotting options for SLP                     
      opts = res         
      opts@cnLineColor = "Blue"
      opts@cnHighLabelsOn = True
      opts@cnLowLabelsOn = True
      opts@ContourParameters = (/ 900., 1100., 4. /)
      opts@cnLineLabelBackgroundColor = -1
      opts@gsnContourLineThicknessesScale = 2.0
      contour_psl = wrf_contour(a,wks,slp,opts)
      delete(opts)

    ; Plotting options for Wind Vectors                 
      opts = res         
      opts@FieldTitle = "Wind"       ; overwrite Field Title
      opts@NumVectors = 47           ; density of wind barbs
      vector = wrf_vector(a,wks,u10,v10,opts)
      delete(opts)
  

    ; MAKE PLOTS                                       
      plot = wrf_map_overlays(a,wks,(/contour_tdiff,contour_psl,vector/),pltres,mpres)
      plot = wrf_map_overlays(a,wks,(/contour_tc,contour_psl,vector/),pltres,mpres)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  end do        ; END OF TIME LOOP

end
