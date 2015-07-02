function [outV, success] = var_load_cpsbc(varNo, year1, setNo)
% Load a MAT variable
% ----------------------------------------------

if nargin ~= 3
   error('invalid nargin');
end

fn = var_fn_cpsbc(varNo, year1, setNo);

if ~exist(fn, 'file')
   outV = [];
   success = 0;
else
   outV = load(fn);
   outV = outV.outV;
   success = 1;
end

end