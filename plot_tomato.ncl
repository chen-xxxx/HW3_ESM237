begin

; dir = "/glade/scratch/chenxing/HW3-ESM237/"
dir = "/glade/u/home/chenxing/HW3-ESM237/"

f1 = addfile(dir+"ACCESS-ESM1-5_historical_gsl.nc","r")
gsl = f1->gsl
printVarSummary(gsl)

;-------location----------
; YOLO 38.732967N -121.807281W
; SAN JOAQUIN 37.9176° N, 121.1710° W
; MERCED 37.3022° N, 120.4830° W
; FRESNO 36.7378° N, 119.7871° W
; KINGS 36.0988° N, 119.8815° W

t1 = gsl(:,{38.732967},{(241.807281)})
print(t1)

;--------plot-------------
wks  = gsn_open_wks("png",dir+"test" )
plot = new(10,graphic)

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

x_axis = ispan(1850, 2014, 1)
res@tiYAxisString = ""
res@tiXAxisString = "year"

res@xyMonoLineColor = False
res@xyMonoDashPattern = True

; res@trXMinF              = 1920;yrs0
; res@trXMaxF              = yrl0+1

; res@trYMinF               = -1.2
; res@trYMaxF               =  1.2

res@xyLineThicknessF = 5.0

res@xyLineColors =  "blue"


plot(0) = gsn_csm_xy(wks,x_axis,t1, res)


;----Spatial pattern for the trends-----

draw(plot)
frame(wks)
end
