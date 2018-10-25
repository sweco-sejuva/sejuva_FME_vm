:: Downloads and unzips the current FMEDataXXXX from www.safe.com/fmedata

::Obtain link to FMEData
aria2c https://bluesky-safe-software.fmecloud.com/fmedatastreaming/FMETraining/CurrentFMEDataDownloadURL.fmw --out=CurrentFMEDataDownloadURL.txt --allow-overwrite=true

:Download FMEData
aria2c -i CurrentFMEDataDownloadURL.txt --allow-overwrite=true
aria2c https://s3.amazonaws.com/FMEData/GeoAlbertaWorkshops.zip --out=GeoAlbertaWorkshops.zip --allow-overwrite=true

:Unzip FMEData
for %%f in (FMEDATA*.zip) do 7z x -oc:\ -aoa %%f
7z x -oc:\FMEData2018\Resources\GeoAlbertaWorkshops\ -aoa GeoAlbertaWorkshops.zip
