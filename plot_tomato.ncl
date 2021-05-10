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

printVarSummary(gsl_mpi_s)
printVarSummary(gsl_mpi_s)

gsl_mpi = array_append_record(gsl_mpi_h(time|:,ncl_join|:,lat|:,lon|:),gsl_mpi_s(time|:,ncl_join|:,lat|:,lon|:),0)
gsl_acc = array_append_record(gsl_acc_h(time|:,ncl_join|:,lat|:,lon|:),gsl_acc_s(time|:,ncl_join|:,lat|:,lon|:),0)
gsl_mpi!1 = "ensemble"
gsl_acc!1 = "ensemble"
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
printVarSummary(gsl_mpi)


gsl_acc = where(gsl_acc.eq.0, gsl_acc@_FillValue, gsl_acc)
gsl_mpi = where(gsl_mpi.eq.0, gsl_mpi@_FillValue, gsl_mpi)

;-------evolution of each location----------
; a: YOLO 38.732967N, 121.807281W
; b: SAN JOAQUIN 37.9176° N, 121.1710° W
; c: MERCED 37.3022° N, 120.4830° W
; d: FRESNO 36.7378° N, 119.7871° W
; e: KINGS 36.0988° N, 119.8815° W
; f: Santa Barbara 34.420830N 119.698189W

SPOT = (/"YOLO","SAN JOAQUIN","MERCED","FRESNO","KINGS","Santa Barbara" /)
nspot = 6 ;spot number
tacc = new((/nspot,2100-1850,ne/),"float")
tmpi = new((/nspot,2100-1850,ne/),"float")

tacc(0,:,:) = gsl_acc(:,:,{38.7329},{(360-121.807281)})
tacc(1,:,:) = gsl_acc(:,:,{37.9176},{(360-121.1710)})
tacc(2,:,:) = gsl_acc(:,:,{37.3022},{(360-120.4830)})
tacc(3,:,:) = gsl_acc(:,:,{36.7378},{(360-119.7871)})
tacc(4,:,:) = gsl_acc(:,:,{36.0988},{(360-119.8815)})
tacc(5,:,:) = gsl_acc(:,:,{34.4208},{(360-119.6981)})

tmpi(0,:,:) = gsl_mpi(:,:,{38.7329},{(360-121.807281)})
tmpi(1,:,:) = gsl_mpi(:,:,{37.9176},{(360-121.1710)})
tmpi(2,:,:) = gsl_mpi(:,:,{37.3022},{(360-120.4830)})
tmpi(3,:,:) = gsl_mpi(:,:,{36.7378},{(360-119.7871)})
tmpi(4,:,:) = gsl_mpi(:,:,{36.0988},{(360-119.8815)})
tmpi(5,:,:) = gsl_mpi(:,:,{34.4208},{(360-119.6981)})
tacc!0 = "spot"
tmpi!0 = "spot"
printVarSummary(tmpi)

;-------trend----------
time    = ispan(1850,2099,1)            ; days since 1850-01-01
printVarSummary(time)
rc_mpi = gsl_mpi(0,:,:,:)
rc_acc = gsl_acc(0,:,:,:)
do is = 0,ne-1
  rc_mpi(is,:,:)      = regCoef_n(time,dim_avg_n_Wrap(gsl_mpi,1),0,0)        ;(:,is,:,:)
  rc_acc(is,:,:)      = regCoef_n(time,dim_avg_n_Wrap(gsl_acc,1),0,0)
end do
copy_VarCoords(gsl_mpi(0,:,:,:),rc_mpi)
copy_VarCoords(gsl_acc(0,:,:,:),rc_acc)
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

res@trYMinF               = 80
res@trYMaxF               = 230

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
  res2@xyLineColor =  "blue"
  plota = gsn_csm_xy(wks,x_axis,dim_avg_n_Wrap(tacc(spot|is,ensemble|:,time|:),0), res2)
  overlay(plot(is),plota)
  res2@xyLineColor =  "red"
  plota = gsn_csm_xy(wks,x_axis,dim_avg_n_Wrap(tmpi(spot|is,ensemble|:,time|:),0), res2)
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
res@cnMaxLevelValF        =   0.6           ; set max contour level
res@cnLevelSpacingF       =   0.2           ; set contour interval


rc_acc@units = "day/year"

res@gsnLeftString = "ACCESS-ESM1-5"
res@gsnRightString = rc_acc@units
plot2(0) = gsn_csm_contour_map_ce(wks2,dim_avg_n_Wrap(rc_acc,0),res)
res@gsnLeftString = "MPI-ESM1-2-LR"
plot2(1) = gsn_csm_contour_map_ce(wks2,dim_avg_n_Wrap(rc_mpi,0),res)

resk = True
resk@txFontHeightF = 0.02
resk@gsnMaximize = True
resk@gsnPaperOrientation = "portrait"   ; force portrait

resk@txString  = mos+"."+dys+" planting date"
gsn_panel(wks,plot,(/3,2/),resk);
gsn_panel(wks2,plot2,(/1,2/),resk);
end
