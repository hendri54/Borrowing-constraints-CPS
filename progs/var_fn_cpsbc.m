function [fPath, fn, fDir] = var_fn_cpsbc(varNo, year1, setNo)
% File name for a variable file

% Checked 
% --------------------------------------------------------

cS = const_cpsbc(setNo);
if nargin ~= 3
   error('Invalid nargin');
end


% Directory for variable files
if varNo >= 201  &&  varNo <= 300
   % No year dim
   fDir = fullfile(cS.matDir, 'mat');
   if ~isempty(year1)
      disp('Should not have a year dimension');
      keyboard;
   end
else
   if year1 < 1900  ||  year1 > 2020
      error('Invalid year1');
   end
   fDir = fullfile(cS.matDir, sprintf('cps%i', year1));
end

fn = sprintf('v%03i.mat', varNo);

fPath = fullfile(fDir, fn);


end
