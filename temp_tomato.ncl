begin
dir = "/glade/scratch/chenxing/HW3-ESM237/"
dir0 = "/glade/u/home/chenxing/HW3-ESM237/"

MODEL = (/"ACCESS-ESM1-5","MPI-ESM1-2-LR" /);"MIROC6",
EXP = (/"historical","ssp585"/)
nm = dimsizes(MODEL)
ne = 5 ;ensemble number
yrs = (/1850,2015/)
yrl = (/2014,2099/)

do iexp = 0,1
do im = 0,nm-1
do ie = 1,ne

f1   = addfile(dir + MODEL(im)+"_tasmax_"+EXP(iexp)+"_r"+ie+"i1p1_California.nc", "r");
f2   = addfile(dir + MODEL(im)+"_tasmin_"+EXP(iexp)+"_r"+ie+"i1p1_California.nc", "r");
print(MODEL(im)+"_tasmax_"+EXP(iexp)+"_r"+ie+"i1p1_California.nc")

f_yrs = yrs(iexp)
f_yrl = yrl(iexp)
nyrs = f_yrl - f_yrs +1 ;number of years

  TIME1=f1->time
  yyyymmdd =cd_calendar(TIME1, -2)
  printMinMax(yyyymmdd , True)

;spacial pattern
tasmax = f1->tasmax
tasmin = f2->tasmin
printVarSummary(tasmax)

;be cautious about the units!! K --> C
tasmax = tasmax - 273.15
tasmin = tasmin - 273.15
tasmax@units = "degC"
tasmin@units = "degC"

;---------Function: TOMATOS accumulated GDDs and Growing Season Length!----------
;parameter setting
MDD = 1214 ;physiological maturity when 1214 degree-days accumulated after planting
Tbase = 10 ;base temperature
Tcutoff = 30 ;cutoff temperature

;specify planting date
;March 15; April 14; May 15
mos = 4
dys = 15

;creat array
cgdd = tasmax(1:nyrs,:,:)
cgdd = 0.
gsl = cgdd ;growing season length

do iyr = 0,nyrs-2;f_yrs,f_yrl
  ydstrt = (iyr+f_yrs)*10000+mos*100+dys

do ix = 0,dimsizes(tasmax&lat)-1
do iy = 0,dimsizes(tasmax&lon)-1
  ymstrt1 = ind(yyyymmdd.eq.ydstrt)
do while(cgdd(iyr,ix,iy).lt.MDD)

  xmax = tasmax(ymstrt1,ix,iy)
  xmin = tasmin(ymstrt1,ix,iy)
  x1 = (xmax + xmin)/2
  if (x1.gt.Tbase.and.x1.lt.Tcutoff) then
    gdd = x1 - Tbase
  else if (x1.ge.Tcutoff) then
    gdd = Tcutoff - Tbase
  else if (x1.le.Tbase) then
    gdd = 0
  end if
  end if
  end if

  cgdd(iyr,ix,iy) = cgdd(iyr,ix,iy) + gdd
  ymstrt1 = ymstrt1 + 1 ;go to the next day
  gsl(iyr,ix,iy) = gsl(iyr,ix,iy)+1.0
  ; print("the date is: "+ydstrt+", and loop num is "+gsl(iyr,ix,iy))

end do
end do
end do

end do
printVarSummary(cgdd)

;-----------output-----------------------------
fon=dir0+"data/"+MODEL(im)+"_"+EXP(iexp)+"_r"+ie+"i1p1f1_"+mos+"."+dys+"_gsl.nc";
system("rm -f "+fon)
fo=addfile(fon,"c")
fo->gsl  = gsl

print(MODEL(im)+" "+EXP(iexp)+" r"+ie+"i1p1f1 is done")
delete([/yyyymmdd,TIME1,tasmax,tasmin,cgdd,gsl,ydstrt,ymstrt1,xmax,xmin/])
end do
end do
end do
end
