rem --- Generate Bounds
rem by Stephan Lange 2020-04-16


@echo off
FOR %%f IN (01_pointclouds\repaired\*) DO (
echo "processing: %%~nf"
rem opalsImport -inf 01_pointclouds\repaired\%%~nf.txt -outf 02_odm_strips\%%~nf.odm -iformat iformat_raw.xml -tilesize 16.0
opalsImport -inf 01_pointclouds\repaired\%%~nf.txt -outf 02_odm_strips\%%~nf.odm -iformat iformat_raw.xml
opalsBounds -inf 02_odm_strips\%%~nf.odm -outfile 02_strip_extents\%%~nf.shp -boundstype alphaShape -alphaRadius 100.0


rem activate for TVC
rem opalsCell -inf 02_odm_strips\%%~nf.odm -outfile 02_als_strips\%%~nf.tif -feat pcount -cellsize 1.0 -coord_ref_sys EPSG:32608 -limit "(548105.0,7614379.0,566350.0,7630989.0)"
rem activate for ITH
opalsCell -inf 02_odm_strips\%%~nf.odm -outfile 02_als_strips\%%~nf.tif -feat pcount -cellsize 1.0 -coord_ref_sys EPSG:32608 -limit "(537489.0,7574203.0,587730.0,7709040.0)"
rem activate for new and change EPSG and limits
rem opalsCell -inf 02_odm_strips\%%~nf.odm -outfile 02_als_strips\%%~nf.tif -feat pcount -cellsize 1.0 -coord_ref_sys EPSG:32608 -limit "(537489.0,7574203.0,587730.0,7709040.0)"

)
