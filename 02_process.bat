rem --- 01 prepare point cloud (I) ---
rem only part I

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
opalsImport -inf %F1% %F2% %F3% %F4% %F5% %F6% %F7% %F8% %F9% %F10% %F11% %F12% %F13% %F14% %F15% %F16% %F17% %F18% %F19% %F20% %F21% %F22% %F23% -outf 02_intermediate\ALS_L1B_20180830.odm -iformat iformat_raw_withHeader.xml -tilesize 100.0

rem --- 02 merge point clouds ---
opalsImport -inf 02_intermediate\ALS_L1B_20180830.odm -outf 02_intermediate\ALS_all.odm -tilesize 100.0

rem --- 03 process point cloud ---

rem Add EchoRank
opalsAddInfo -inf 02_intermediate\ALS_all.odm -attribute _EchoRank(unsignedByte)=_EchoCount-EchoNumber

rem --- Export point cloud ---
opalsExport -inf 02_intermediate\ALS_all.odm -outf 02_intermediate\ALS_all_basic.txt -oformat oformat_basic.xml
rem opalsExport -inf 02_intermediate\ALS_all.odm -outf 02_intermediate\ALS1_all_basic.txt -oformat oformat_basic.xml -filter "Region[03_region\P1.shp]"
rem opalsExport -inf 02_intermediate\ALS_all.odm -outf 02_intermediate\ALS2_all_basic.txt -oformat oformat_basic.xml -filter "Region[03_region\P2.shp]"
rem opalsExport -inf 02_intermediate\ALS_all.odm -outf 02_intermediate\ALS3_all_basic.txt -oformat oformat_basic.xml -filter "Region[03_region\P3.shp]"
rem opalsExport -inf 02_intermediate\ALS_all.odm -outf 02_intermediate\ALS4_all_basic.txt -oformat oformat_basic.xml -filter "Region[03_region\P4.shp]"
rem opalsExport -inf 02_intermediate\ALS_all.odm -outf 02_intermediate\ALS5_all_basic.txt -oformat oformat_basic.xml -filter "Region[03_region\P5.shp]"

rem --- 04 classify echo types and drop other columns ---
python classifyEchoType.py
rem python classifyEchoType1.py 
rem python classifyEchoType2.py 
rem python classifyEchoType3.py 
rem python classifyEchoType4.py 
rem python classifyEchoType5.py 

rem --- 05 SOR filter all ---
opalsImport -inf 02_intermediate\ALS_all_echotypes.txt -outf 02_intermediate\ALS_all_echotypes.odm -iformat iformat_echotypes.xml -tilesize 100.0
opalsExport -inf 02_intermediate\ALS_all_echotypes.odm -outf 02_intermediate\ALS_all_echotypes_part.txt -oformat oformat_echotypes.xml
outlier.exe 02_intermediate\ALS_all_echotypes_part.txt 02_intermediate\ALS_all_echotypes_part_SOR.txt 20 2.0
opalsImport -inf 02_intermediate\ALS_all_echotypes_part_SOR.txt -outf 02_intermediate\ALS_all_echotypes_part_SOR.odm -iformat iformat_echotypes.xml -tilesize 100.0
opalsImport -inf 02_intermediate\ALS_all_echotypes_part_SOR.odm -outf 02_intermediate\ALS_all_echotypes_SOR.odm -tilesize 120.0
opalsExport -inf 02_intermediate\ALS_all_echotypes_SOR.odm -outf 02_intermediate\ALS_all_echotypes_SOR.txt -oformat oformat_echotypes.xml
opalsCell -inf 02_intermediate\ALS_all_echotypes_SOR.odm -outFile 04_rasters\ALS_all_echotypes_SOR_pcount.tif -feature pcount -cel 1.0
rem --- 05 SOR filter tile 1 ---
opalsImport -inf 02_intermediate\ALS1_all_echotypes.txt -outf 02_intermediate\ALS1_all_echotypes.odm -iformat iformat_echotypes.xml -tilesize 100.0
opalsExport -inf 02_intermediate\ALS1_all_echotypes.odm -outf 02_intermediate\ALS1_all_echotypes_part.txt -oformat oformat_echotypes.xml
outlier.exe 02_intermediate\ALS1_all_echotypes_part.txt 02_intermediate\ALS1_all_echotypes_part_SOR.txt 20 2.0
opalsImport -inf 02_intermediate\ALS1_all_echotypes_part_SOR.txt -outf 02_intermediate\ALS1_all_echotypes_part_SOR.odm -iformat iformat_echotypes.xml -tilesize 100.0
opalsImport -inf 02_intermediate\ALS1_all_echotypes_part_SOR.odm -outf 02_intermediate\ALS1_all_echotypes_SOR.odm -tilesize 120.0
opalsExport -inf 02_intermediate\ALS1_all_echotypes_SOR.odm -outf 02_intermediate\ALS1_all_echotypes_SOR.txt -oformat oformat_echotypes.xml
opalsCell -inf 02_intermediate\ALS1_all_echotypes_SOR.odm -outFile 04_rasters\ALS1_all_echotypes_SOR_pcount.tif -feature pcount -cel 1.0
rem --- 05 SOR filter tile 1 ---
opalsImport -inf 02_intermediate\ALS2_all_echotypes.txt -outf 02_intermediate\ALS2_all_echotypes.odm -iformat iformat_echotypes.xml -tilesize 100.0
opalsExport -inf 02_intermediate\ALS2_all_echotypes.odm -outf 02_intermediate\ALS2_all_echotypes_part.txt -oformat oformat_echotypes.xml
outlier.exe 02_intermediate\ALS2_all_echotypes_part.txt 02_intermediate\ALS2_all_echotypes_part_SOR.txt 20 2.0
opalsImport -inf 02_intermediate\ALS2_all_echotypes_part_SOR.txt -outf 02_intermediate\ALS2_all_echotypes_part_SOR.odm -iformat iformat_echotypes.xml -tilesize 100.0
opalsImport -inf 02_intermediate\ALS2_all_echotypes_part_SOR.odm -outf 02_intermediate\ALS2_all_echotypes_SOR.odm -tilesize 120.0
opalsExport -inf 02_intermediate\ALS2_all_echotypes_SOR.odm -outf 02_intermediate\ALS2_all_echotypes_SOR.txt -oformat oformat_echotypes.xml
opalsCell -inf 02_intermediate\ALS2_all_echotypes_SOR.odm -outFile 04_rasters\ALS2_all_echotypes_SOR_pcount.tif -feature pcount -cel 1.0
rem --- 05 SOR filter tile 1 ---
opalsImport -inf 02_intermediate\ALS3_all_echotypes.txt -outf 02_intermediate\ALS3_all_echotypes.odm -iformat iformat_echotypes.xml -tilesize 100.0
opalsExport -inf 02_intermediate\ALS3_all_echotypes.odm -outf 02_intermediate\ALS3_all_echotypes_part.txt -oformat oformat_echotypes.xml
outlier.exe 02_intermediate\ALS3_all_echotypes_part.txt 02_intermediate\ALS3_all_echotypes_part_SOR.txt 20 2.0
opalsImport -inf 02_intermediate\ALS3_all_echotypes_part_SOR.txt -outf 02_intermediate\ALS3_all_echotypes_part_SOR.odm -iformat iformat_echotypes.xml -tilesize 100.0
opalsImport -inf 02_intermediate\ALS3_all_echotypes_part_SOR.odm -outf 02_intermediate\ALS3_all_echotypes_SOR.odm -tilesize 120.0
opalsExport -inf 02_intermediate\ALS3_all_echotypes_SOR.odm -outf 02_intermediate\ALS3_all_echotypes_SOR.txt -oformat oformat_echotypes.xml
opalsCell -inf 02_intermediate\ALS3_all_echotypes_SOR.odm -outFile 04_rasters\ALS3_all_echotypes_SOR_pcount.tif -feature pcount -cel 1.0
rem --- 05 SOR filter tile 1 ---
opalsImport -inf 02_intermediate\ALS4_all_echotypes.txt -outf 02_intermediate\ALS4_all_echotypes.odm -iformat iformat_echotypes.xml -tilesize 100.0
opalsExport -inf 02_intermediate\ALS4_all_echotypes.odm -outf 02_intermediate\ALS4_all_echotypes_part.txt -oformat oformat_echotypes.xml
outlier.exe 02_intermediate\ALS4_all_echotypes_part.txt 02_intermediate\ALS4_all_echotypes_part_SOR.txt 20 2.0
opalsImport -inf 02_intermediate\ALS4_all_echotypes_part_SOR.txt -outf 02_intermediate\ALS4_all_echotypes_part_SOR.odm -iformat iformat_echotypes.xml -tilesize 100.0
opalsImport -inf 02_intermediate\ALS4_all_echotypes_part_SOR.odm -outf 02_intermediate\ALS4_all_echotypes_SOR.odm -tilesize 120.0
opalsExport -inf 02_intermediate\ALS4_all_echotypes_SOR.odm -outf 02_intermediate\ALS4_all_echotypes_SOR.txt -oformat oformat_echotypes.xml
opalsCell -inf 02_intermediate\ALS4_all_echotypes_SOR.odm -outFile 04_rasters\ALS4_all_echotypes_SOR_pcount.tif -feature pcount -cel 1.0
rem --- 05 SOR filter tile 1 ---
opalsImport -inf 02_intermediate\ALS5_all_echotypes.txt -outf 02_intermediate\ALS5_all_echotypes.odm -iformat iformat_echotypes.xml -tilesize 100.0
opalsExport -inf 02_intermediate\ALS5_all_echotypes.odm -outf 02_intermediate\ALS5_all_echotypes_part.txt -oformat oformat_echotypes.xml
outlier.exe 02_intermediate\ALS5_all_echotypes_part.txt 02_intermediate\ALS5_all_echotypes_part_SOR.txt 20 2.0
opalsImport -inf 02_intermediate\ALS5_all_echotypes_part_SOR.txt -outf 02_intermediate\ALS5_all_echotypes_part_SOR.odm -iformat iformat_echotypes.xml -tilesize 100.0
opalsImport -inf 02_intermediate\ALS5_all_echotypes_part_SOR.odm -outf 02_intermediate\ALS5_all_echotypes_SOR.odm -tilesize 120.0
opalsExport -inf 02_intermediate\ALS5_all_echotypes_SOR.odm -outf 02_intermediate\ALS5_all_echotypes_SOR.txt -oformat oformat_echotypes.xml
opalsCell -inf 02_intermediate\ALS5_all_echotypes_SOR.odm -outFile 04_rasters\ALS5_all_echotypes_SOR_pcount.tif -feature pcount -cel 1.0


rem --- 07 terrain probability ---
rem filter by echo type 
rem single and last with terrainprob python calculation
rem first and middle with constant terrainprob of 0%
opalsExport -inf 02_intermediate\ALS_all_echotypes_SOR.odm -outf 02_intermediate\ALS_first_echotypes_SOR.txt -filter "Generic[_EchoType == 1 OR _EchoType == 2]" -oformat oformat_echotypes.xml
opalsImport -inf 02_intermediate\ALS_first_echotypes_SOR.txt -outf 02_intermediate\ALS_first_echotypes_SOR.odm -iformat iformat_echotypes.xml -tilesize 120.0
opalsAddInfo -inf 02_intermediate\ALS_first_echotypes_SOR.odm -attribute "_terrainProb = 0.0"
opalsExport -inf 02_intermediate\ALS_first_echotypes_SOR.odm -outf 02_intermediate\ALS_first_echotypes_SOR_terrainprob.txt -oformat oformat_terrainprob.xml
opalsImport -inf 02_intermediate\ALS_first_echotypes_SOR_terrainprob.txt -outf 02_intermediate\ALS_first_echotypes_SOR_terrainprob_1.odm -iformat iformat_terrainprob_first.xml -tilesize 80.0

opalsExport -inf 02_intermediate\ALS_all_echotypes_SOR.odm -outf 02_intermediate\ALS_last_echotypes_SOR.txt -filter "Generic[_EchoType == 0 OR _EchoType == 3]" -oformat oformat_echotypes.xml
set PYPATH=C:\python_2_opals\python.exe
rem python adaptDecDigits.py ... only if necessary!
python terrainProbability2pi.py 02_intermediate\ALS_last_echotypes_SOR.txt 4 5 10000000
opalsImport -inf 02_intermediate\ALS_last_echotypes_SOR_terrainprob_last.txt -outf 02_intermediate\ALS_last_echotypes_SOR.odm -iformat iformat_terrainProb.xml -tilesize 80.0



set COORD=-coord_ref_sys EPSG:32608

rem RobFilter test
opalsRobFilter -inFile 02_intermediate\ALS_all_echotypes_SOR_terrainprob.odm -debugOutFile 02_intermediate\ALS_all_echotypes_SOR_terrainprob_grdPts.xyz -points_in_memory 16000000 -filter "Generic[_TerrainProb>0.0]" -sigmaApriori "_TerrainProb>0.5 ? 0.25 : 0.5"
opalsGrid -inFile 02_intermediate\ALS_all_echotypes_SOR_terrainprob.odm -outFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -interpolation robMovingPlanes -gridSize 1.0 -searchRad 7.5 -filter class[ground] %COORD% 
opalsShade -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -outf 04_rasters\shd_ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -pixelsize 1.0 %COORD% 

opalsStatFilter -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -outFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth.tif -feature mean -kernelSize 3 %COORD% 
opalsAlgebra -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth.tif -outFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -formula "return r[1] if ( r[0] is None) else r[0]" -gridSize 1.0 %COORD% 
opalsShade -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -outFile 04_rasters\shd_ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -pixelsize 1.0 %COORD% 


rem RobFilter test
opalsRobFilter -inFile 02_intermediate\ALS_all_echotypes_SOR_terrainprob_1.odm -debugOutFile 02_intermediate\ALS_all_echotypes_SOR_terrainprob_grdPts_1.xyz -points_in_memory 16000000 -filter "Generic[_TerrainProb>0.0]" -sigmaApriori "_TerrainProb>0.5 ? 0.25 : 0.5"
opalsGrid -inFile 02_intermediate\ALS_all_echotypes_SOR_terrainprob_1.odm -outFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_1.tif -interpolation robMovingPlanes -gridSize 1.0 -searchRad 7.5 -filter class[ground] %COORD% 
opalsShade -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_1.tif -outf 04_rasters\shd_ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_1.tif -pixelsize 1.0 %COORD% 

opalsStatFilter -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_1.tif -outFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth_1.tif -feature mean -kernelSize 3 %COORD% 
opalsAlgebra -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_1.tif 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth_1.tif -outFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled_1.tif -formula "return r[1] if ( r[0] is None) else r[0]" -gridSize 1.0 %COORD% 
opalsShade -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled_1.tif -outFile 04_rasters\shd_ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled_1.tif -pixelsize 1.0 %COORD% 

opalsRobFilter -inFile 02_intermediate\ALS_all_echotypes_SOR_terrainprob_2.odm -debugOutFile 02_intermediate\ALS_all_echotypes_SOR_terrainprob_grdPts_2.xyz -points_in_memory 16000000 -filter "Generic[_TerrainProb>0.0]" -sigmaApriori "_TerrainProb>0.5 ? 0.25 : 0.5"
opalsGrid -inFile 02_intermediate\ALS_all_echotypes_SOR_terrainprob_2.odm -outFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_2.tif -interpolation robMovingPlanes -gridSize 1.0 -searchRad 7.5 -filter class[ground] %COORD% 
opalsShade -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_2.tif -outf 04_rasters\shd_ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_2.tif -pixelsize 1.0 %COORD% 

opalsStatFilter -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_2.tif -outFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth_2.tif -feature mean -kernelSize 3 %COORD% 
opalsAlgebra -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_2.tif 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth_2.tif -outFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled_2.tif -formula "return r[1] if ( r[0] is None) else r[0]" -gridSize 1.0 %COORD% 
opalsShade -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled_2.tif -outFile 04_rasters\shd_ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled_2.tif -pixelsize 1.0 %COORD% 


rem RobFilter
opalsRobFilter -inFile 02_intermediate\ALS1_all_echotypes_SOR_terrainprob.odm -debugOutFile 02_intermediate\ALS1_all_echotypes_SOR_terrainprob_grdPts.xyz -points_in_memory 16000000 -filter "Generic[_TerrainProb>0.0]" -sigmaApriori "_TerrainProb>0.5 ? 0.25 : 0.5"
opalsGrid -inFile 02_intermediate\ALS1_all_echotypes_SOR_terrainprob.odm -outFile 04_rasters\ALS1_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -interpolation robMovingPlanes -gridSize 1.0 -searchRad 7.5 -filter class[ground] %COORD% 
opalsShade -inFile 04_rasters\ALS1_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -outf 04_rasters\shd_ALS1_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -pixelsize 1.0 %COORD% 

opalsRobFilter -inFile 02_intermediate\ALS2_all_echotypes_SOR_terrainprob.odm -debugOutFile 02_intermediate\ALS2_all_echotypes_SOR_terrainprob_grdPts.xyz -points_in_memory 16000000 -filter "Generic[_TerrainProb>0.0]" -sigmaApriori "_TerrainProb>0.5 ? 0.25 : 0.5"
opalsGrid -inFile 02_intermediate\ALS2_all_echotypes_SOR_terrainprob.odm -outFile 04_rasters\ALS2_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -interpolation robMovingPlanes -gridSize 1.0 -searchRad 7.5 -filter class[ground] %COORD% 
opalsShade -inFile 04_rasters\ALS2_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -outf 04_rasters\shd_ALS2_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -pixelsize 1.0 %COORD% 

opalsRobFilter -inFile 02_intermediate\ALS3_all_echotypes_SOR_terrainprob.odm -debugOutFile 02_intermediate\ALS3_all_echotypes_SOR_terrainprob_grdPts.xyz -points_in_memory 16000000 -filter "Generic[_TerrainProb>0.0]" -sigmaApriori "_TerrainProb>0.5 ? 0.25 : 0.5"
opalsGrid -inFile 02_intermediate\ALS3_all_echotypes_SOR_terrainprob.odm -outFile 04_rasters\ALS3_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -interpolation robMovingPlanes -gridSize 1.0 -searchRad 7.5 -filter class[ground] %COORD% 
opalsShade -inFile 04_rasters\ALS3_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -outf 04_rasters\shd_ALS3_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -pixelsize 1.0 %COORD% 

opalsRobFilter -inFile 02_intermediate\ALS4_all_echotypes_SOR_terrainprob.odm -debugOutFile 02_intermediate\ALS4_all_echotypes_SOR_terrainprob_grdPts.xyz -points_in_memory 16000000 -filter "Generic[_TerrainProb>0.0]" -sigmaApriori "_TerrainProb>0.5 ? 0.25 : 0.5"
opalsGrid -inFile 02_intermediate\ALS4_all_echotypes_SOR_terrainprob.odm -outFile 04_rasters\ALS4_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -interpolation robMovingPlanes -gridSize 1.0 -searchRad 7.5 -filter class[ground] %COORD% 
opalsShade -inFile 04_rasters\ALS4_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -outf 04_rasters\shd_ALS4_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -pixelsize 1.0 %COORD% 

opalsRobFilter -inFile 02_intermediate\ALS5_all_echotypes_SOR_terrainprob.odm -debugOutFile 02_intermediate\ALS5_all_echotypes_SOR_terrainprob_grdPts.xyz -points_in_memory 16000000 -filter "Generic[_TerrainProb>0.0]" -sigmaApriori "_TerrainProb>0.5 ? 0.25 : 0.5"
opalsGrid -inFile 02_intermediate\ALS5_all_echotypes_SOR_terrainprob.odm -outFile 04_rasters\ALS5_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -interpolation robMovingPlanes -gridSize 1.0 -searchRad 7.5 -filter class[ground] %COORD% 
opalsShade -inFile 04_rasters\ALS5_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -outf 04_rasters\shd_ALS5_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -pixelsize 1.0 %COORD% 

rem fill DTM
opalsStatFilter -inFile 04_rasters\ALS1_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -outFile 04_rasters\ALS1_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth.tif -feature mean -kernelSize 3 %COORD% 
opalsAlgebra -inFile 04_rasters\ALS1_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif 04_rasters\ALS1_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth.tif -outFile 04_rasters\ALS1_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -formula "return r[1] if ( r[0] is None) else r[0]" -gridSize 1.0 %COORD% 
opalsShade -inFile 04_rasters\ALS1_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -outFile 04_rasters\shd_ALS1_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -pixelsize 1.0 %COORD% 

opalsStatFilter -inFile 04_rasters\ALS2_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -outFile 04_rasters\ALS2_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth.tif -feature mean -kernelSize 3 %COORD% 
opalsAlgebra -inFile 04_rasters\ALS2_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif 04_rasters\ALS2_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth.tif -outFile 04_rasters\ALS2_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -formula "return r[1] if ( r[0] is None) else r[0]" -gridSize 1.0 %COORD% 
opalsShade -inFile 04_rasters\ALS2_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -outFile 04_rasters\shd_ALS2_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -pixelsize 1.0 %COORD% 

opalsStatFilter -inFile 04_rasters\ALS3_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -outFile 04_rasters\ALS3_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth.tif -feature mean -kernelSize 3 %COORD% 
opalsAlgebra -inFile 04_rasters\ALS3_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif 04_rasters\ALS3_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth.tif -outFile 04_rasters\ALS3_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -formula "return r[1] if ( r[0] is None) else r[0]" -gridSize 1.0 %COORD% 
opalsShade -inFile 04_rasters\ALS3_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -outFile 04_rasters\shd_ALS3_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -pixelsize 1.0 %COORD% 

opalsStatFilter -inFile 04_rasters\ALS4_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -outFile 04_rasters\ALS4_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth.tif -feature mean -kernelSize 3 %COORD% 
opalsAlgebra -inFile 04_rasters\ALS4_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif 04_rasters\ALS4_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth.tif -outFile 04_rasters\ALS4_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -formula "return r[1] if ( r[0] is None) else r[0]" -gridSize 1.0 %COORD% 
opalsShade -inFile 04_rasters\ALS4_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -outFile 04_rasters\shd_ALS4_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -pixelsize 1.0 %COORD% 

opalsStatFilter -inFile 04_rasters\ALS5_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -outFile 04_rasters\ALS5_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth.tif -feature mean -kernelSize 3 %COORD% 
opalsAlgebra -inFile 04_rasters\ALS5_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif 04_rasters\ALS5_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth.tif -outFile 04_rasters\ALS5_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -formula "return r[1] if ( r[0] is None) else r[0]" -gridSize 1.0 %COORD% 
opalsShade -inFile 04_rasters\ALS5_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -outFile 04_rasters\shd_ALS5_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -pixelsize 1.0 %COORD% 

