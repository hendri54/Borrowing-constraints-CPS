function var_save_cpsbc(outV, varName, year1, setName)
% Save a MAT variable

[fn, ~, fDir] = var_fn_cpsbc(varName, year1, setName);

% Create dir if it does not exist
if ~exist(fDir, 'dir')
   filesLH.mkdir(fDir, 0);
end

save(fn, 'outV');
fprintf('Saved variable %s  for year %i, set %s \n',  varName, year1, setName);

end