begin
diri = "/glade/scratch/chenxing/HW3-ESM237/"
diri2 =  "/glade/scratch/chenxing/HW3-ESM237/"

model = (/"ACCESS-ESM1-5","CESM2","GFDL-ESM4","MIROC6", "MPI-ESM1-2-LR"/)

nm = dimsizes(model)
ne = 5; ensemble number

VAR_A = (/"tasmax","tasmin" /) ;variables
EXP_A = (/"historical","ssp585"/) ;experiment

do iv = 0,dimsizes(VAR_A)-1
    VAR = VAR_A(iv)
    do ix = 0,dimsizes(EXP_A)-1
        EXP = EXP_A(ix)
do i=0,nm-1
    do ie = 1,ne
            ;tasmin_day_MPI-ESM1-2-LR_ssp585_r1i1p1f1_gn_20350101-20541231.nc
        files = systemfunc(" ls -1 "+diri2+VAR+"*"+model(i)+"_"+EXP+"_r"+ie+"i1p1f1*.nc")
        print(files)
        nf = dimsizes(.not.ismissing(files))
        print(nf)
            if(.not.ismissing(files(0)))then
                system("cdo cat "+diri2+VAR+"*"+model(i)+"_"+EXP+"_r"+ie+"i1p1*.nc "+diri+"a2.nc")
                system("cdo sellonlatbox,-125,-113,30,43 "+diri+"a2.nc "+diri+model(i)+"_"+VAR+"_"+EXP+"_r"+ie+"i1p1_California.nc")
                print(model(i)+" "+ie)
        end if
    delete(files)
    system(" rm -rf "+diri+"a2.nc" )
    system(" mv "+diri2+VAR+"*"+model(i)+"_"+EXP+"_r"+ie+"i1p1*.nc "+diri2+"trash/" )
    end do
end do
end do
end do
end
