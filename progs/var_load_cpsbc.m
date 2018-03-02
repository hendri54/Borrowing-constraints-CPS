function [outV, success] = var_load_cpsbc(varName, year1, setName)
% Load a MAT variable

if nargin ~= 3
   error('invalid nargin');
end

fn = var_fn_cpsbc(varName, year1, setName);

if ~exist(fn, 'file')
   outV = [];
   success = false;
else
   outV = load(fn);
   outV = outV.outV;
   success = true;
end

end