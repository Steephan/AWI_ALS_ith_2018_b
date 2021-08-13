rem --- 08 DTM generation using OPALS (DTM module) ---

set COORD=-coord_ref_sys EPSG:32608

rem filter terrain points
opalsImport -inf ALS_all_echotypes_SOR_terrainprob.txt -outf 02_intermediate\ALS_all_echotypes_SOR_terrainprob.odm -iformat iformat_terrainProb.xml -tilesize 100.0

rem RobFilter
opalsRobFilter -inFile 02_intermediate\ALS_all_echotypes_SOR_terrainprob.odm -debugOutFile 02_intermediate\ALS_all_echotypes_SOR_terrainprob_grdPts.xyz -points_in_memory 16000000 -filter "Generic[_TerrainProb>0.0]" -sigmaApriori "_TerrainProb>0.5 ? 0.25 : 0.5"
opalsGrid -inFile 02_intermediate\ALS_all_echotypes_SOR_terrainprob.odm -outFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -interpolation robMovingPlanes -gridSize 1.0 -searchRad 7.5 -filter class[ground] %COORD% 
opalsShade -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -outf 04_rasters\shd_ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -pixelsize 1.0 %COORD% 

rem fill DTM
opalsStatFilter -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif -outFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth.tif -feature mean -kernelSize 3 %COORD% 
opalsAlgebra -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m.tif 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_smooth.tif -outFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -formula "return r[1] if ( r[0] is None) else r[0]" -gridSize 1.0 %COORD% 
opalsShade -inFile 04_rasters\ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -outFile 04_rasters\shd_ALS_all_echotypes_SOR_terrain_RobF_robMovPlanes_1m_filled.tif -pixelsize 1.0 %COORD%