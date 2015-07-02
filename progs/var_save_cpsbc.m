function var_save_cpsbc(outV, varNo, year1, setNo)
% Save a MAT variable
% ----------------------------------------------

[fn, ~, fDir] = var_fn_cpsbc(varNo, year1, setNo);

% Create dir if it does not exist
if ~exist(fDir, 'dir')
   files_lh.mkdir_lh(fDir, 0);
end

save(fn, 'outV');
fprintf('Saved variable %i  for year %i, set %i \n',  varNo, year1, setNo);

end