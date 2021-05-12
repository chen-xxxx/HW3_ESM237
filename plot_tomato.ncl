begin

; dir = "/glade/scratch/chenxing/HW3-ESM237/"
dir = "/glade/u/home/chenxing/HW3-ESM237/"

MON = (/3,4,5/)
DAY = (/15,15,15/)

ne = 5 ;ensemble number

ia = 1
mos = MON(ia)
dys = DAY(ia)

fils = systemfunc("ls "+dir+"data/ACCESS-ESM1-5_historical_r*i1p1f1_"+mos+"."+dys+"_gsl.nc")
print(fils)
f   = addfiles(fils, "r")  ;multiple files
ListSetType (f, "join")        ; concatenate (=default)
gsl_acc_h  = f[:]->gsl

fils = systemfunc("ls "+dir+"data/ACCESS-ESM1-5_ssp585_r*i1p1f1_"+mos+"."+dys+"_gsl.nc")
f   = addfiles(fils, "r")  ;multiple files
ListSetType (f, "join")        ; concatenate (=default)
gsl_acc_s  = f[:]->gsl

fils = systemfunc("ls "+dir+"data/MPI-ESM1-2-LR_historical_r*i1p1f1_"+mos+"."+dys+"_gsl.nc")
print(fils)
f   = addfiles(fils, "r")  ;multiple files
ListSetType (f, "join")        ; concatenate (=default)
gsl_mpi_h  = f[:]->gsl

fils = systemfunc("ls "+dir+"data/MPI-ESM1-2-LR_ssp585_r*i1p1f1_"+mos+"."+dys+"_gsl.nc")
f   = addfiles(fils, "r")  ;multiple files
ListSetType (f, "join")        ; concatenate (=default)
gsl_mpi_s  = f[:]->gsl

fils = systemfunc("ls "+dir+"data/MIROC6_historical_r*i1p1f1_"+mos+"."+dys+"_gsl.nc")
print(fils)
f   = addfiles(fils, "r")  ;multiple files
ListSetType (f, "join")        ; concatenate (=default)
gsl_mir_h  = f[:]->gsl

fils = systemfunc("ls "+dir+"data/MIROC6_ssp585_r*i1p1f1_"+mos+"."+dys+"_gsl.nc")
f   = addfiles(fils, "r")  ;multiple files
ListSetType (f, "join")        ; concatenate (=default)
gsl_mir_s  = f[:]->gsl

printVarSummary(gsl_mpi_s)
printVarSummary(gsl_mpi_s)
printVarSummary(gsl_mir_s)

gsl_mpi = array_append_record(gsl_mpi_h(time|:,ncl_join|:,lat|:,lon|:),gsl_mpi_s(time|:,ncl_join|:,lat|:,lon|:),0)
gsl_acc = array_append_record(gsl_acc_h(time|:,ncl_join|:,lat|:,lon|:),gsl_acc_s(time|:,ncl_join|:,lat|:,lon|:),0)
gsl_mir = array_append_record(gsl_mir_h(time|:,ncl_join|:,lat|:,lon|:),gsl_mir_s(time|:,ncl_join|:,lat|:,lon|:),0)
gsl_mpi!1 = "ensemble"
gsl_acc!1 = "ensemble"
gsl_mir!1 = "ensemble"
lat1 = gsl_acc&lat
lat1@units = "degrees_north"
gsl_acc&lat = lat1
lon1 = gsl_acc&lon
lon1@units = "degrees_east"
gsl_acc&lon = lon1
lat2 = gsl_mpi&lat
lat2@units = "degrees_north"
gsl_mpi&lat = lat2
lon2 = gsl_mpi&lon
lon2@units = "degrees_east"
gsl_mpi&lon = lon2
lat3 = gsl_mir&lat
lat3@units = "degrees_north"
gsl_mir&lat = lat3
lon3 = gsl_mir&lon
lon3@units = "degrees_east"
gsl_mir&lon = lon3
printVarSummary(gsl_mpi)
print(lon1)


gsl_acc = where(gsl_acc.eq.0, gsl_acc@_FillValue, gsl_acc)
gsl_mpi = where(gsl_mpi.eq.0, gsl_mpi@_FillValue, gsl_mpi)
gsl_mir = where(gsl_mir.eq.0, gsl_mir@_FillValue, gsl_mir)

;-------evolution of each location----------
; a PLUMAS 39.022118N, 121.558487W
; a: YOLO 38.732967N, 121.807281W
; b: SAN JOAQUIN 37.9176° N, 121.1710° W
; c: MERCED 37.3022° N, 120.4830° W
; d: FRESNO 36.7378° N, 119.7871° W
; e: KINGS 36.0988° N, 119.8815° W
; f: Santa Barbara 34.420830N 119.698189W

; SPOT = (/"YOLO","SAN JOAQUIN","MERCED","FRESNO","KINGS","Santa Barbara" /)
SPOT = (/"PLUMAS","SAN JOAQUIN","MERCED","SANTA BARBARA" /)
LATS = (/39.0221,37.9176,37.3022,34.4208 /)
LONS = (/121.5584,121.1710,120.4830,119.6981 /)

nspot = dimsizes(SPOT) ;spot number
tacc = new((/nspot,2100-1850,ne/),"float")
tmpi = new((/nspot,2100-1850,ne/),"float")
tmir = new((/nspot,2100-1850,ne/),"float")

tacc(0,:,:) = gsl_acc(:,:,{LATS(0)},{(360-LONS(0))})
tacc(1,:,:) = gsl_acc(:,:,{LATS(1)},{(360-LONS(1))})
tacc(2,:,:) = gsl_acc(:,:,{LATS(2)},{(360-LONS(2))})
tacc(3,:,:) = gsl_acc(:,:,{LATS(3)},{(360-LONS(3))})

tmpi(0,:,:) = gsl_mpi(:,:,{LATS(0)},{(360-LONS(0))})
tmpi(1,:,:) = gsl_mpi(:,:,{LATS(1)},{(360-LONS(1))})
tmpi(2,:,:) = gsl_mpi(:,:,{LATS(2)},{(360-LONS(2))})
tmpi(3,:,:) = gsl_mpi(:,:,{LATS(3)},{(360-LONS(3))})

tmir(0,:,:) = gsl_mir(:,:,{LATS(0)},{(360-LONS(0))})
tmir(1,:,:) = gsl_mir(:,:,{LATS(1)},{(360-LONS(1))})
tmir(2,:,:) = gsl_mir(:,:,{LATS(2)},{(360-LONS(2))})
tmir(3,:,:) = gsl_mir(:,:,{LATS(3)},{(360-LONS(3))})

tacc!0 = "spot"
tmpi!0 = "spot"
tmir!0 = "spot"
printVarSummary(tmpi)

;-------trend----------
time    = ispan(2016,2099,1)            ; days since 1850-01-01
printVarSummary(time)
rc_mpi = gsl_mpi(0,:,:,:)
rc_acc = gsl_acc(0,:,:,:)
rc_mir = gsl_mir(0,:,:,:)
do is = 0,ne-1
  rc_mpi(is,:,:)      = regCoef_n(time,dim_avg_n_Wrap(gsl_mpi(2016-1850:,:,:,:),1),0,0)        ;(:,is,:,:)
  rc_acc(is,:,:)      = regCoef_n(time,dim_avg_n_Wrap(gsl_acc(2016-1850:,:,:,:),1),0,0)
  rc_mir(is,:,:)      = regCoef_n(time,dim_avg_n_Wrap(gsl_mir(2016-1850:,:,:,:),1),0,0)        ;(:,is,:,:)
end do
copy_VarCoords(gsl_mpi(0,:,:,:),rc_mpi)
copy_VarCoords(gsl_acc(0,:,:,:),rc_acc)
copy_VarCoords(gsl_mir(0,:,:,:),rc_mir)
printVarSummary(rc_acc)

; ;significant
; df   = rc_mpi@nptxy-2   ; degrees of freedom
; tval = rc_mpi@tval      ; t-statistic
; b    = 0.5          ; b must be same size as tval (and df)
; prob = (1 - betainc(df/(df+tval^2),df/2.0,b) )
; sig_pra1 = rc_mpi
; sig_pra1 = where(prob.ge.95., abs(rc_mpi), rc_mpi@_FillValue)

;--------plot-------------
wks  = gsn_open_wks("png",dir+"timeseries" )
wks2  = gsn_open_wks("png",dir+"trend_spatial" )
plot = new(10,graphic)
plot2 = new(10,graphic)

;----Time Series------

res = True
res@gsnDraw = False        ;dont draw
res@gsnFrame = False        ;dont advance frame
res@gsnLeftString = ""
res@gsnRightString = ""
res@vpHeightF = 0.3
res@vpWidthF  = 0.7

res@tmXTOn    = False
res@tmYROn    = False

; res@gsnYRefLine           = 0.0             ; reference line

x_axis = ispan(1850, 2099, 1)
res@tiYAxisString = ""
res@tiXAxisString = "year"

res@xyMonoLineColor = False
res@xyMonoDashPattern = True

res@trXMinF              = 1850
res@trXMaxF              = 2100

res@trYMinF               = 70
res@trYMaxF               = 210

res2 = res

res@xyLineThicknessF = 2.0
res2@xyLineThicknessF = 5.0

do is = 0,nspot-1
  res@gsnLeftString = SPOT(is)
  ; res@gsnRightString = "ACCESS-ESM1-5"
  res@xyLineColor =  "lightblue"
  plot(is) = gsn_csm_xy(wks,x_axis,tacc(spot|is,ensemble|:,time|:), res)
  res@xyLineColor =  "pink"
  plotb = gsn_csm_xy(wks,x_axis,tmpi(spot|is,ensemble|:,time|:), res)
  overlay(plot(is),plotb)
  res@xyLineColor =  "darkgreen"
  plotb = gsn_csm_xy(wks,x_axis,tmir(spot|is,ensemble|:,time|:), res)
  overlay(plot(is),plotb)
  res2@xyLineColor =  "blue"
  plota = gsn_csm_xy(wks,x_axis,dim_avg_n_Wrap(tacc(spot|is,ensemble|:,time|:),0), res2)
  overlay(plot(is),plota)
  res2@xyLineColor =  "red"
  plota = gsn_csm_xy(wks,x_axis,dim_avg_n_Wrap(tmpi(spot|is,ensemble|:,time|:),0), res2)
  overlay(plot(is),plota)
  res2@xyLineColor =  "darkolivegreen1"
  plota = gsn_csm_xy(wks,x_axis,dim_avg_n_Wrap(tmir(spot|is,ensemble|:,time|:),0), res2)
  overlay(plot(is),plota)
end do

delete(res)
;----Spatial pattern for the trends-----

res                       = True
res@gsnDraw = False        ;dont draw
res@gsnFrame = False        ;dont advance frame
res@gsnMaximize           = True             ; make large
res@gsnAddCyclic = False
res@mpMaxLatF                   = 43         ; choose subregion
res@mpMinLatF                   = 30
res@mpMaxLonF                   = 360-113
res@mpMinLonF                   = 360-125
res@mpFillOn = False
res@mpOutlineOn           = True                ; turn on map outline
res@mpOutlineBoundarySets = "AllBoundaries"
res@mpDataBaseVersion     = "MediumRes"
res@mpDataSetName         = "Earth..4"

res@cnFillOn              = True             ; turn on color
; res@cnFillPalette         = "ViBlGrWhYeOrRe" ; set color map
res@cnLinesOn             = False            ; turn off contour lines
res@cnLineLabelsOn        = False            ; turn off contour line labels
;;res@cnFillMode            = "RasterFill"

res@cnLevelSelectionMode  = "ManualLevels"   ; set manual contour levels
res@cnMinLevelValF        =  -1.6           ; set min contour level
res@cnMaxLevelValF        =   0.0           ; set max contour level
res@cnLevelSpacingF       =   0.1           ; set contour interval


rc_acc@units = "day/year"

res@gsnLeftString = "ACCESS-ESM1-5"
res@gsnRightString = rc_acc@units
plot2(0) = gsn_csm_contour_map_ce(wks2,dim_avg_n_Wrap(rc_acc,0),res)
res@gsnLeftString = "MPI-ESM1-2-LR"
plot2(1) = gsn_csm_contour_map_ce(wks2,dim_avg_n_Wrap(rc_mpi,0),res)
res@gsnLeftString = "MIROC6"
plot2(2) = gsn_csm_contour_map_ce(wks2,dim_avg_n_Wrap(rc_mir,0),res)

; ;add text
; txres               = True                     ; text mods desired
; txres@txFontHeightF = 0.015                     ; font smaller. default big
; txres@txFontColor = "black"
; sn = ispan(1,nspot,1)
; text0  = gsn_add_text(wks,plot(0),sn,lon1({LONS}),lat1({LATS}),txres)
; text1  = gsn_add_text(wks,plot(1),sn,lon2({LONS}),lat2({LATS}),txres)
; text2  = gsn_add_text(wks,plot(2),sn,lon3({LONS}),lat3({LATS}),txres)


resk = True
resk@txFontHeightF = 0.02
resk@gsnMaximize = True
resk@gsnPaperOrientation = "portrait"   ; force portrait

resk@txString  = mos+"."+dys+" planting date"
gsn_panel(wks,plot,(/2,2/),resk);
gsn_panel(wks2,plot2,(/1,3/),resk);
end
