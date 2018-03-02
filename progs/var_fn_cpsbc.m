function [fPath, fn, fDir] = var_fn_cpsbc(varName, year1, setName)
% File name for a variable file
%{
Variables that have year dimension are written into year specfic dirs
Checked 
%}

if nargin ~= 3
   error('Invalid nargin');
end
assert(ischar(varName));
assert(ischar(setName));
dirS = helper_cpsbc.directories(setName);


% Directory for variable files
if isempty(year1)
   % No year dim
   fDir = fullfile(dirS.matDir, 'mat');
else
   if year1 < 1900  ||  year1 > 2020
      error('Invalid year1');
   end
   fDir = fullfile(dirS.matDir, sprintf('cps%i', year1));
end

fn = [varName, '.mat'];

fPath = fullfile(fDir, fn);


end
