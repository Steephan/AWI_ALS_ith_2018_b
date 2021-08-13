rem ---
rem --- Processings steps
rem --- by Stephan Lange
rem --- last modified: 2021-04-14

rem --- 01 prepare point cloud (I) ---
set F1=01_pointclouds\repaired\ALS_L1B_20180829T230052_230743_ascii.txt
set F2=01_pointclouds\repaired\ALS_L1B_20180829T230726_231310_ascii.txt
set F3=01_pointclouds\repaired\ALS_L1B_20180829T231248_231917_ascii.txt
set F4=01_pointclouds\repaired\ALS_L1B_20180829T231853_232558_ascii.txt
set F5=01_pointclouds\repaired\ALS_L1B_20180829T232523_233304_ascii.txt
set F6=01_pointclouds\repaired\ALS_L1B_20180829T233240_234248_ascii.txt
set F7=01_pointclouds\repaired\ALS_L1B_20180829T234212_234954_ascii.txt
set F8=01_pointclouds\repaired\ALS_L1B_20180829T234922_235654_ascii.txt
set F9=01_pointclouds\repaired\ALS_L1B_20180829T235626_240257_ascii.txt
set F10=01_pointclouds\repaired\ALS_L1B_20180830T000234_000853_ascii.txt
set F11=01_pointclouds\repaired\ALS_L1B_20180830T000830_001420_ascii.txt
set F12=01_pointclouds\repaired\ALS_L1B_20180830T001406_001925_ascii.txt
set F13=01_pointclouds\repaired\ALS_L1B_20180830T001900_002415_ascii.txt
set F14=01_pointclouds\repaired\ALS_L1B_20180830T002400_002917_ascii.txt
set F15=01_pointclouds\repaired\ALS_L1B_20180830T002853_003454_ascii.txt
set F16=01_pointclouds\repaired\ALS_L1B_20180830T003430_004101_ascii.txt
set F17=01_pointclouds\repaired\ALS_L1B_20180830T004038_004806_ascii.txt
set F18=01_pointclouds\repaired\ALS_L1B_20180830T004729_005445_ascii.txt
set F19=01_pointclouds\repaired\ALS_L1B_20180830T005416_010334_ascii.txt
set F20=01_pointclouds\repaired\ALS_L1B_20180830T010308_011102_ascii.txt
set F21=01_pointclouds\repaired\ALS_L1B_20180830T011032_011657_ascii.txt
set F22=01_pointclouds\repaired\ALS_L1B_20180830T011634_012251_ascii.txt
set F23=01_pointclouds\repaired\ALS_L1B_20180830T012240_013238_ascii.txt

rem Import single ALS strips
opalsImport -inf %F1% %F2% %F3% %F4% %F5% %F6% %F7% %F8% %F9% %F10% %F11% %F12% %F13% %F14% %F15% %F16% %F17% %F18% %F19% %F20% %F21% %F22% %F23%  -outf 02_intermediate\ALS_all.odm -iformat iformat_raw_withHeader.xml -tilesize 150.0

rem --- 02 merge point clouds ---
rem opalsImport -inf 02_intermediate\ALS_L1B_20180822.odm -outf 02_intermediate\ALS_all.odm -tilesize 150.0

rem --- 03 process point cloud ---
rem opalsExport -inf 02_intermediate\ALS_all.odm -outf 04_check\TVC_ALS_2018b_roi_trees_tvc_1.las -limit 561144 7626892 562564 7627008

rem Add EchoRank
opalsAddInfo -inf 02_intermediate\ALS_all.odm -points_in_memory 5000000 -attribute _EchoRank(unsignedByte)=_EchoCount-EchoNumber

rem --- Export point cloud ---
opalsExport -inf 02_intermediate\ALS_all.odm -outf 02_intermediate\ALS_all_basic.txt -oformat oformat_basic.xml

rem --- 04 classify echo types and drop other columns ---
python classifyEchoType.py 

rem --- 05 SOR filter ---
opalsImport -inf 02_intermediate\ALS_all_echotypes.txt -outf 02_intermediate\ALS_all_echotypes.odm -iformat iformat_echotypes.xml -tilesize 80.0
rem opalsExport -inf 02_intermediate\ALS1_all_echotypes.odm -outf 02_intermediate\ALS1_all_echotypes_part.txt -oformat oformat_echotypes.xml
rem outlier.exe 02_intermediate\ALS1_all_echotypes_part.txt 02_intermediate\ALS1_all_echotypes_part_SOR.txt 12 2.0
rem outlier.exe 02_intermediate\ALS1_all_echotypes_part.txt 02_intermediate\ALS_all_echotypes_part_SOR.txt 6 1.0
rem opalsImport -inf 02_intermediate\ALS1_all_echotypes_part_SOR.txt -outf 02_intermediate\ALS1_all_echotypes_part_SOR.odm -iformat iformat_echotypes.xml -tilesize 80.0
rem opalsImport -inf 02_intermediate\ALS1_all_echotypes_part_SOR.odm -outf 02_intermediate\ALS1_all_echotypes_SOR.odm -tilesize 120.0
rem opalsExport -inf 02_intermediate\ALS1_all_echotypes_SOR.odm -outf 02_intermediate\ALS1_all_echotypes_SOR.txt -oformat oformat_echotypes.xml
rem opalsCell -inf 02_intermediate\ALS1_all_echotypes_SOR.odm -outFile 04_rasters\ALS1_all_echotypes_SOR_pcount.tif -feature pcount -cel 1.0
opalsCell -inf 02_intermediate\ALS_all_echotypes.odm -outFile 04_rasters\ALS_all_echotypes_SOR_pcount.tif -feature pcount -cel 1.0

rem opalsExport -inf 02_intermediate\ALS1_all_echotypes.odm -outf 04_check\TVC_ALS_2018b_roi_trees_tvc_2.las -limit 561144 7626892 562564 7627008
rem opalsExport -inf 02_intermediate\ALS1_all_echotypes_SOR.odm -outf 04_check\TVC_ALS_2018b_roi_trees_tvc_4.las -limit 561144 7626892 562564 7627008

rem --- 06 Clean out the camp tents --- not really necessary SL 26.05.2021
rem opalsImport -inf 02_intermediate\ALS_all_echotypes_SOR.txt -outf 02_intermediate\ALS_all_echotypes_SOR_ToClean.odm -iformat iformat_echotypes.xml -tilesize 120.0

rem export camp and non-camp
rem opalsExport -inf 02_intermediate\ALS_all_echotypes_SOR_ToClean.odm -outf 02_intermediate\ALS_all_echotypes_SOR_camp.txt -oformat oformat_echotypes.xml -filter "Region[03_region\region_ALS2016_camp.shp]"
rem opalsExport -inf 02_intermediate\ALS_all_echotypes_SOR_ToClean.odm -outf 02_intermediate\ALS_all_echotypes_SOR_withoutCamp.txt -oformat oformat_echotypes.xml -filter "Region[03_region\region_ALS2016_withoutCamp.shp]"

rem test
rem opalsExport -inf 02_intermediate\ALS_all_echotypes_SOR_ToClean.odm -outf 02_intermediate\ALS_all_echotypes_SOR_withoutCampTest.txt -oformat oformat_echotypes.xml -filter "Region[region\region_ALS2016_withoutCampTest.shp]"

rem merge point cloud parts
rem opalsImport -inf 02_intermediate\ALS_all_echotypes_SOR_campClean.txt 02_intermediate\ALS_all_echotypes_SOR_withoutCamp.txt -outf 02_intermediate\ALS_all_echotypes_SOR.odm -iformat iformat_echotypes.xml -tilesize 120.0
rem opalsExport -inf 02_intermediate\ALS_all_echotypes_SOR.odm -outf 02_intermediate\ALS_all_echotypes_SOR.txt -oformat oformat_echotypes.xml

rem --- 07 terrain probability ---
rem filter by echo type 
rem single and last with terrainprob python calculation
rem first and middle with constant terrainprob of 0%
opalsExport -inf 02_intermediate\ALS_all_echotypes.odm -outf 02_intermediate\ALS_first_echotypes_SOR.txt -filter "Generic[_EchoType == 1 OR _EchoType == 2]" -oformat oformat_echotypes.xml
opalsImport -inf 02_intermediate\ALS_first_echotypes_SOR.txt -outf 02_intermediate\ALS_first_echotypes_SOR.odm -iformat iformat_echotypes.xml -tilesize 120.0
opalsAddInfo -inf 02_intermediate\ALS_first_echotypes_SOR.odm -attribute "_terrainProb = 0.0"
opalsExport -inf 02_intermediate\ALS_first_echotypes_SOR.odm -outf 02_intermediate\ALS_first_echotypes_SOR_terrainprob.txt -oformat oformat_terrainprob.xml
opalsImport -inf 02_intermediate\ALS_first_echotypes_SOR_terrainprob.txt -outf 02_intermediate\ALS_first_echotypes_SOR_terrainprob_1.odm -iformat iformat_terrainprob_first.xml -tilesize 80.0

opalsExport -inf 02_intermediate\ALS_all_echotypes.odm -outf 02_intermediate\ALS_last_echotypes_SOR.txt -filter "Generic[_EchoType == 0 OR _EchoType == 3]" -oformat oformat_echotypes.xml
set PYPATH=C:\python_2_opals\python.exe
rem python adaptDecDigits.py ... only if necessary!
python terrainProbability2pi.py 02_intermediate\ALS_last_echotypes_SOR.txt 4 5 10000000
opalsImport -inf 02_intermediate\ALS_last_echotypes_SOR_terrainprob_last.txt -outf 02_intermediate\ALS_last_echotypes_SOR.odm -iformat iformat_terrainProb.xml -tilesize 80.0

rem merge both odms again
opalsImport -inf 02_intermediate\ALS_last_echotypes_SOR.odm 02_intermediate\ALS_first_echotypes_SOR_terrainprob_1.odm -outf 02_intermediate\ALS_last_echotypes_SOR.odm


rem --- 08 DTM generation using OPALS (DTM module) ---
set COORD=-coord_ref_sys EPSG:32608


rem RobFilter
opalsRobFilter -inFile 02_intermediate\ALS_last_echotypes_SOR.odm -debugOutFile 02_intermediate\ALS1_all_echotypes_SOR_terrainprob_grdPts.xyz -points_in_memory 16000000 -filter "Generic[_TerrainProb>0.0]" -sigmaApriori "_TerrainProb>0.5 ? 0.25 : 0.5"
rem opalsGrid -inFile 02_intermediate\ALS_last_echotypes_SOR.odm -outFile 04_rasters\ALS1_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -interpolation robMovingPlanes -gridSize 1.0 -searchRad 7.5 -filter class[ground] %COORD% 
set COORD=-coord_ref_sys EPSG:32608
set LIM1=-limit "(547000.000,7585000.000,586000.000,7617000.000)"
set LIM2=-limit "(547000.000,7617000.000,586000.000,7660000.000)"
set LIM3=-limit "(547000.000,7660000.000,586000.000,7700000.000)"
opalsGrid -inFile 02_intermediate\ALS_last_echotypes_SOR.odm -outFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_1.tif -interpolation robMovingPlanes -gridSize 1.0 -searchRad 7.5 -filter class[ground] %COORD% %LIM1%
opalsGrid -inFile 02_intermediate\ALS_last_echotypes_SOR.odm -outFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_2.tif -interpolation robMovingPlanes -gridSize 1.0 -searchRad 7.5 -filter class[ground] %COORD% %LIM2%
opalsGrid -inFile 02_intermediate\ALS_last_echotypes_SOR.odm -outFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_3.tif -interpolation robMovingPlanes -gridSize 1.0 -searchRad 7.5 -filter class[ground] %COORD% %LIM3%

opalsShade -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_1.tif -outf 04_rasters\shd_ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_1.tif -pixelsize 1.0 %COORD% %LIM1%
opalsShade -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_2.tif -outf 04_rasters\shd_ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_2.tif -pixelsize 1.0 %COORD% %LIM2%
opalsShade -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_3.tif -outf 04_rasters\shd_ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_3.tif -pixelsize 1.0 %COORD% %LIM3%

rem fill DTM
opalsStatFilter -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_1.tif -outFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth_1.tif -feature mean -kernelSize 3 %COORD% %LIM1%
opalsStatFilter -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_2.tif -outFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth_2.tif -feature mean -kernelSize 3 %COORD% %LIM2%
opalsStatFilter -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_3.tif -outFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth_3.tif -feature mean -kernelSize 3 %COORD% %LIM3%

opalsAlgebra -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_1.tif 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth_1.tif -outFile 04_rasters\ITH_ALS_201808_DTM_1.tif -formula "return r[1] if ( r[0] is None) else r[0]" -gridSize 1.0 %COORD% %LIM1% 
opalsAlgebra -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_2.tif 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth_2.tif -outFile 04_rasters\ITH_ALS_201808_DTM_2.tif -formula "return r[1] if ( r[0] is None) else r[0]" -gridSize 1.0 %COORD% %LIM2%
opalsAlgebra -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_3.tif 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth_3.tif -outFile 04_rasters\ITH_ALS_201808_DTM_3.tif -formula "return r[1] if ( r[0] is None) else r[0]" -gridSize 1.0 %COORD% %LIM3%

opalsShade -inFile 04_rasters\ITH_ALS_201808_DTM_1.tif -outFile 04_rasters\shd_ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled_1.tif -pixelsize 1.0 %COORD% 
opalsShade -inFile 04_rasters\ITH_ALS_201808_DTM_2.tif -outFile 04_rasters\shd_ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled_2.tif -pixelsize 1.0 %COORD% 
opalsShade -inFile 04_rasters\ITH_ALS_201808_DTM_3.tif -outFile 04_rasters\shd_ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled_3.tif -pixelsize 1.0 %COORD% 



rem --- 09 Veg. height generation using OPALS (AddInfo & Cell modules) ---

rem compute vegetation height: Z - DTM
opalsAddInfo -inf 02_intermediate\ALS_last_echotypes_SOR.odm -gridfile 04_rasters\ITH_ALS_201808_DTM_1.tif 04_rasters\ITH_ALS_201808_DTM_2.tif 04_rasters\ITH_ALS_201808_DTM_3.tif -attribute _nZ=Z-r[0]
rem opalsAddInfo -inf 02_intermediate\ALS_last_echotypes_SOR.odm -gridfile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -attribute _nZ=Z-r[0]

opalsAddInfo -inf 02_intermediate\ALS_last_echotypes_SOR.odm -attribute "_nZ_corr = _nZ <0.0 ? 0.0 : _nZ"

rem --- filter point cloud by threshold of 20 m above ground
opalsExport -inf 02_intermediate\ALS_last_echotypes_SOR.odm -outf 02_intermediate\ALS_all_echotypes_SOR_terrain.txt  -filter "Generic[_nZ <= 20]" -oformat oformat_all.xml

set PYPATH=C:\python_2_opals\python.exe
python classifyVegType.py

rem --- 10 Check final point cloud data ---
opalsImport -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.txt -outf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -iformat iformat_all.xml -tilesize 120.0

rem TVC tile
rem opalsExport -inf 02_intermediate\ALS1_all_echotypes_SOR_terrain_classified.odm -outf 04_check\ALS1_all_echotypes_SOR_terrain_classified_tile11.txt -oformat oformat_all.xml -filter "Region[extent_tiles\region_ALS2016_t11.shp]"

rem other tiles
rem opalsExport -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -outf 04_check\ALS_all_echotypes_SOR_terrain_classified_tile3.txt -oformat oformat_all.xml -filter "Region[extent_tiles\region_ALS2016_t3.shp]"
rem opalsExport -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -outf 04_check\ALS_all_echotypes_SOR_terrain_classified_tile1.txt -oformat oformat_all.xml -filter "Region[extent_tiles\region_ALS2016_t1.shp]"
rem opalsExport -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -outf 04_check\ALS_all_echotypes_SOR_terrain_classified_tile2.txt -oformat oformat_all.xml -filter "Region[extent_tiles\region_ALS2016_t2.shp]"
rem opalsExport -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -outf 04_check\ALS_all_echotypes_SOR_terrain_classified_tile4.txt -oformat oformat_all.xml -filter "Region[extent_tiles\region_ALS2016_t4.shp]"
rem opalsExport -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -outf 04_check\ALS_all_echotypes_SOR_terrain_classified_tile5.txt -oformat oformat_all.xml -filter "Region[extent_tiles\region_ALS2016_t5.shp]"

rem output vegHeight rasters 1
opalsCell -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -outf 04_rasters\ALS_all_echotypes_SOR_nZ_max_1m_1.tif -cellsize 1.0 -attribute _nZ_corr -feature max %COORD% %LIM1% -filter "Generic[_nZ_corr> 0.0]"
opalsCell -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -outf 04_rasters\ALS_all_echotypes_SOR_nZ_mean_1m_1.tif -cellsize 1.0 -attribute _nZ_corr -feature mean %COORD% %LIM1% -filter "Generic[_nZ_corr> 0.0]"
opalsCell -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -outf 04_rasters\ALS_all_echotypes_SOR_nZ_q99_1m_1.tif -cellsize 1.0 -attribute _nZ_corr -feature quantile:0.99 %COORD% %LIM1% -filter "Generic[_nZ_corr> 0.0]"
opalsCell -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -outf 04_rasters\ALS_all_echotypes_SOR_nZ_q95_1m_1.tif -cellsize 1.0 -attribute _nZ_corr -feature quantile:0.95 %COORD% %LIM1% -filter "Generic[_nZ_corr> 0.0]"
rem output vegHeight rasters 2
opalsCell -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -outf 04_rasters\ALS_all_echotypes_SOR_nZ_max_1m_2.tif -cellsize 1.0 -attribute _nZ_corr -feature max %COORD% %LIM2% -filter "Generic[_nZ_corr> 0.0]"
opalsCell -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -outf 04_rasters\ALS_all_echotypes_SOR_nZ_mean_1m_2.tif -cellsize 1.0 -attribute _nZ_corr -feature mean %COORD% %LIM2% -filter "Generic[_nZ_corr> 0.0]"
opalsCell -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -outf 04_rasters\ALS_all_echotypes_SOR_nZ_q99_1m_2.tif -cellsize 1.0 -attribute _nZ_corr -feature quantile:0.99 %COORD% %LIM2% -filter "Generic[_nZ_corr> 0.0]"
opalsCell -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -outf 04_rasters\ALS_all_echotypes_SOR_nZ_q95_1m_2.tif -cellsize 1.0 -attribute _nZ_corr -feature quantile:0.95 %COORD% %LIM2% -filter "Generic[_nZ_corr> 0.0]"
rem output vegHeight rasters 3
opalsCell -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -outf 04_rasters\ALS_all_echotypes_SOR_nZ_max_1m_3.tif -cellsize 1.0 -attribute _nZ_corr -feature max %COORD% %LIM3% -filter "Generic[_nZ_corr> 0.0]"
opalsCell -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -outf 04_rasters\ALS_all_echotypes_SOR_nZ_mean_1m_3.tif -cellsize 1.0 -attribute _nZ_corr -feature mean %COORD% %LIM3% -filter "Generic[_nZ_corr> 0.0]"
opalsCell -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -outf 04_rasters\ALS_all_echotypes_SOR_nZ_q99_1m_3.tif -cellsize 1.0 -attribute _nZ_corr -feature quantile:0.99 %COORD% %LIM3% -filter "Generic[_nZ_corr> 0.0]"
opalsCell -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -outf 04_rasters\ALS_all_echotypes_SOR_nZ_q95_1m_3.tif -cellsize 1.0 -attribute _nZ_corr -feature quantile:0.95 %COORD% %LIM3% -filter "Generic[_nZ_corr> 0.0]"

rem fill vegHeight rasters
rem mean 1
opalsStatFilter -inFile 04_rasters\ALS_all_echotypes_SOR_nZ_mean_1m_1.tif -outFile 04_rasters\ALS_all_echotypes_SOR_nZ_mean_1m_smooth_1.tif -feature mean -kernelSize 3 %COORD% %LIM1%
opalsAlgebra -inFile 04_rasters\ALS_all_echotypes_SOR_nZ_mean_1m_1.tif 04_rasters\ALS_all_echotypes_SOR_nZ_mean_1m_smooth_1.tif -outFile 04_rasters\ITH_ALS_201808_VegetationHeight_Mean_1.tif -formula "return r[1] if ( r[0] is None) else r[0]" -gridSize 1.0 %COORD% %LIM1%
rem mean 2
opalsStatFilter -inFile 04_rasters\ALS_all_echotypes_SOR_nZ_mean_1m_2.tif -outFile 04_rasters\ALS_all_echotypes_SOR_nZ_mean_1m_smooth_2.tif -feature mean -kernelSize 3 %COORD% %LIM2%
opalsAlgebra -inFile 04_rasters\ALS_all_echotypes_SOR_nZ_mean_1m_2.tif 04_rasters\ALS_all_echotypes_SOR_nZ_mean_1m_smooth_2.tif -outFile 04_rasters\ITH_ALS_201808_VegetationHeight_Mean_2.tif -formula "return r[1] if ( r[0] is None) else r[0]" -gridSize 1.0 %COORD% %LIM2%
rem mean 3
opalsStatFilter -inFile 04_rasters\ALS_all_echotypes_SOR_nZ_mean_1m_3.tif -outFile 04_rasters\ALS_all_echotypes_SOR_nZ_mean_1m_smooth_3.tif -feature mean -kernelSize 3 %COORD% %LIM3%
opalsAlgebra -inFile 04_rasters\ALS_all_echotypes_SOR_nZ_mean_1m_3.tif 04_rasters\ALS_all_echotypes_SOR_nZ_mean_1m_smooth_3.tif -outFile 04_rasters\ITH_ALS_201808_VegetationHeight_Mean_3.tif -formula "return r[1] if ( r[0] is None) else r[0]" -gridSize 1.0 %COORD% %LIM3%

rem max 1
opalsStatFilter -inFile 04_rasters\ALS_all_echotypes_SOR_nZ_max_1m_1.tif -outFile 04_rasters\ALS_all_echotypes_SOR_nZ_max_1m_smooth_1.tif -feature mean -kernelSize 3 %COORD% %LIM1%
opalsAlgebra -inFile 04_rasters\ALS_all_echotypes_SOR_nZ_max_1m_1.tif 04_rasters\ALS_all_echotypes_SOR_nZ_max_1m_smooth_1.tif -outFile 04_rasters\ITH_ALS_201808_VegetationHeight_Max_1.tif -formula "return r[1] if ( r[0] is None) else r[0]" -gridSize 1.0 %COORD% %LIM1%
rem max 2
opalsStatFilter -inFile 04_rasters\ALS_all_echotypes_SOR_nZ_max_1m_2.tif -outFile 04_rasters\ALS_all_echotypes_SOR_nZ_max_1m_smooth_2.tif -feature mean -kernelSize 3 %COORD% %LIM2%
opalsAlgebra -inFile 04_rasters\ALS_all_echotypes_SOR_nZ_max_1m_2.tif 04_rasters\ALS_all_echotypes_SOR_nZ_max_1m_smooth_2.tif -outFile 04_rasters\ITH_ALS_201808_VegetationHeight_Max_2.tif -formula "return r[1] if ( r[0] is None) else r[0]" -gridSize 1.0 %COORD% %LIM2%
rem max 3
opalsStatFilter -inFile 04_rasters\ALS_all_echotypes_SOR_nZ_max_1m_3.tif -outFile 04_rasters\ALS_all_echotypes_SOR_nZ_max_1m_smooth_3.tif -feature mean -kernelSize 3 %COORD% %LIM3%
opalsAlgebra -inFile 04_rasters\ALS_all_echotypes_SOR_nZ_max_1m_3.tif 04_rasters\ALS_all_echotypes_SOR_nZ_max_1m_smooth_3.tif -outFile 04_rasters\ITH_ALS_201808_VegetationHeight_Max_3.tif -formula "return r[1] if ( r[0] is None) else r[0]" -gridSize 1.0 %COORD% %LIM3%




rem rem calculate VegRatio: Number of points with vegetation heights> 1.5 m / number of all points
opalsCell -inf 02_intermediate\ALS1_all_echotypes_SOR_terrain_classified.odm -outf 04_rasters\ALS_all_echotypes_SOR_pcount_gt150_1m.tif -cellsize 1.0 -feature pcount -filter "Generic[_nZ_corr>= 1.5]" %COORD% %LIM%
opalsCell -inf 02_intermediate\ALS1_all_echotypes_SOR_terrain_classified.odm -outf 04_rasters\ALS_all_echotypes_SOR_pcount_1m.tif -cellsize 1.0 -feature pcount %COORD% %LIM%
rem opalsAlgebra -inf 04_rasters\ALS_all_echotypes_SOR_pcount_gt150_1m.tif 04_rasters\ALS_all_echotypes_SOR_pcount_1m.tif -outf 04_rasters\ALS_all_echotypes_SOR_vegratio150cm_1m.tif -formula "float(r[0]) / float(r[1])" -gridsize 1.0 %COORD% %LIM%
opalsAlgebra -inf 04_rasters\ALS_all_echotypes_SOR_pcount_gt150_1m.tif 04_rasters\ALS_all_echotypes_SOR_pcount_1m.tif -outf 04_rasters\ALS_all_echotypes_SOR_vegratio150cm_1m.tif -formula "return float(r[0]) / float(r[1]) if r[1]>0 else None" -gridsize 1.0 %COORD% %LIM%

rem --- 11 Extraction of individual trees from DSM ---

rem generate DSM and fill
opalsCell -inf 02_intermediate\ALS1_all_echotypes_SOR_terrain_classified.odm -outf 04_rasters\ALS_all_echotypes_SOR_Z_max_1m.tif -cellsize 1.0 -feature max %COORD% %LIM%
opalsStatFilter -inFile 04_rasters\ALS_all_echotypes_SOR_Z_max_1m.tif -outFile 04_rasters\ALS_all_echotypes_SOR_Z_max_1m_smooth.tif -feature mean -kernelSize 3 %COORD% %LIM%
opalsAlgebra -inFile 04_rasters\ALS_all_echotypes_SOR_Z_max_1m.tif 04_rasters\ALS_all_echotypes_SOR_Z_max_1m_smooth.tif -outFile 04_rasters\ALS_all_echotypes_SOR_Z_max_1m_filled.tif -formula "return r[1] if ( r[0] is None) else r[0]" -gridSize 1.0 %COORD% %LIM%

rem Position of trees/shrubs with height> 1.5 m. Positions were extracted based on local height maxima with kernel size = 3 m
opalsStatFilter -inFile 04_rasters\ALS_all_echotypes_SOR_nZ_max_1m_filled.tif -outFile 04_rasters\ALS_all_echotypes_SOR_nZ_max_1m_ptstats_max_k3.tif -feature max -kernelSize 3 %COORD% %LIM%

rem local maxima to point shapefile done in ArcGIS: Con("ALS_all_echotypes_SOR_nZ_max_1m_filled.tif" ==  "ALS_all_echotypes_SOR_nZ_max_1m_ptstats_max_k3.tif",Con("ALS_all_echotypes_SOR_nZ_max_1m_filled.tif">= 1.5,1))
rem export roi pointclouds
opalsImport -inf 02_intermediate\ALS1_all_echotypes_SOR_terrain_classified.txt -outf 02_intermediate\ALS1_all_echotypes_SOR_terrain_classified.odm -iformat iformat_all.xml -tilesize 120.0
rem opalsExport -inf 02_intermediate\ALS1_all_echotypes_SOR_terrain_classified.odm -outf 04_check\TVC_ALS_2018b_roi_bridge_tvc.txt -oformat oformat_all.xml -filter "Region[03_region\roi_bridge_tvc.shp]"
rem opalsExport -inf 02_intermediate\ALS1_all_echotypes_SOR_terrain_classified.odm -outf 04_check\TVC_ALS_2018b_roi_south_trees.txt -oformat oformat_all.xml -filter "Region[03_region\roi_south_trees.shp]"

rem test las opals format
rem opalsExport -inf 02_intermediate\ALS1_all_echotypes_SOR_terrain_classified.odm -outf 04_check\TVC_ALS_2018b_roi_bridge_tvc.las -oformat oformat_pangaea_las.xml -filter "Region[03_region\roi_bridge_tvc.shp]"
rem opalsExport -inf 02_intermediate\ALS1_all_echotypes_SOR_terrain_classified.odm -outf 04_check\TVC_ALS_2018b_roi_bridge_tvc.las -oformat oformat_pangaea_las.xml -limit 550000 7620000 550100 7620100

opalsExport -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -outf 04_check\ITH_ALS_2018_1.laz -oformat oformat_pangaea_las.xml -limit 547000 7585000 586000 7617000
opalsExport -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -outf 04_check\ITH_ALS_2018_2.laz -oformat oformat_pangaea_las.xml -limit 547000 7617000 586000 7660000
opalsExport -inf 02_intermediate\ALS_all_echotypes_SOR_terrain_classified.odm -outf 04_check\ITH_ALS_2018_3.laz -oformat oformat_pangaea_las.xml -limit 547000 7660000 586000 7700000
rem opalsExport -inf 02_intermediate\ALS1_all_echotypes_SOR_terrain_classified.odm -outf 04_check\TVC_ALS_2018b_roi_trees_tvc_2.las -oformat oformat_pangaea_las.xml -limit 561144 7626892 562564 7627008



