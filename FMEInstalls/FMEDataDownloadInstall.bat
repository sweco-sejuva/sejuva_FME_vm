	
  aria2c https://bluesky-safe-software.fmecloud.com/fmedatastreaming/FMETraining/CurrentFMEDataDownloadURL.fmw --out=CurrentFMEDataDownloadURL.txt --allow-overwrite=true
	aria2c -i CurrentFMEDataDownloadURL.txt --allow-overwrite=true
	for %%f in (FMEDATA*.zip) do 7z x -oc:\ -aoa %%f
