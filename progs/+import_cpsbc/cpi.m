function cpiS = cpi(cS)

dirS = helper_cpsbc.directories(cS.setName);
cpiS = econLH.Cpi(cS.cpiBaseYear, fullfile(dirS.baseDir, 'cpi_all_urban.txt'));

end