function filter_cpsbc(year1, setNo)
% Filter
%{
constructs a variable that contains indices for persons passing filter

do not filter on earnings (that messes up schooling and fraction working)

Checked: 2015-07-01
%}


cS = const_cpsbc(setNo);
dbg = cS.dbg;

disp(' ');
fprintf('Filter for %i \n',  year1);


% This loads a CPS variable by name.
% Last argument controls whether a generic recoding is applied
sexV = var_load_cps('sex', year1, 1);
disp(['N before filter:     ',  separatethousands(length(sexV), ',', 0)]);
validV = ones(size(sexV));

if ~isempty(cS.fltSex)
   % Sex filter
   if cS.fltSex == cS.male
      sexCode = 1;
   elseif cS.fltSex == cS.female
      sexCode = 2;
   else
      error('Invalid');
   end
   validV = (sexV == sexCode);
   disp(['N after sex filter:  ',  separatethousands(sum(validV), ',', 0)]);
end
clear sexV;


if ~isempty(cS.fltRace)
   if cS.fltRace == cS.raceWhite
      raceV = var_load_cps('race', year1, 1);
      validV(raceV ~= 100) = 0;
      disp(['N after race filter:  ',  separatethousands(sum(validV), ',', 0)]);
      clear raceV;
   end
end


% Age  -  keep in mind that we want age last year when earnings were
% observed
ageV = var_load_cps('age', year1, 1);
validV(ageV < (cS.fltAgeMin + 1) | ageV > (cS.fltAgeMax + 1)) = 0;
disp(['N after age filter:  ',  separatethousands(sum(validV), ',', 0)]);
clear ageV;


% No in gq
[gqV, success] = var_load_cps('gq', year1, 1);
if success == 1
   validV(gqV ~= 1) = 0;
   disp(['N after gq filter:  ',  separatethousands(sum(validV), ',', 0)]);
   clear gqV;
end


% Positive weight
validV = filter_one(validV, 'wtsupp', year1, 0, 1e-8, [], [], dbg);


% Positive earnings
% lb = 1: keep only positive
validV = filter_one(validV, 'incwage', year1, 0, 1, [], [], dbg);


% Wage and salary workers only (not armed forces [26])
valueV = 20 : 28;
valueV(valueV == 26) = [];
validV = filter_one(validV, 'classwkr', year1, 0, [], [], valueV, dbg);


% Hours worked
validV = filter_one(validV, 'hrswork', year1, 0, cS.fltHoursMin, [], [], dbg);


% Weeks worked
[loadV, success] = var_load_cps('wkswork2', year1, 1);
if success ~= 1
   error('Variable not found');
end
loadV = recode_wkswork2_cpsbc(loadV, year1, setNo);
validV(loadV < cS.fltWeeksMin) = 0;
disp(['N after weeks filter:  ',  separatethousands(sum(validV), ',', 0)]);
clear loadV;


% Schooling
if year1 < 1992
   validV = filter_one(validV, 'higrade', year1, 0,  10, 210, [], dbg);
else
   validV = filter_one(validV, 'educ99', year1, 0,   1, 18, [], dbg);
end


% Save
vIdxV = find(validV == 1);
var_save_cpsbc(vIdxV,  cS.vFilter, year1, setNo);


end


%% Filter by a variable
%{
Can provide 
   lb: lower bound
   ub: upper bound
   valueV: specific values that are to be kept
%}
function validV = filter_one(validV, varNameStr, year1, doRecode, lb, ub, valueV, dbg)
   [xV, success] = var_load_cps(varNameStr, year1, doRecode);
   if success ~= 1
      error(['Cannot load ',  varNameStr]);
   end
   if ~isempty(lb)
      validV(xV < lb) = 0;
   end
   if ~isempty(ub)
      validV(xV > ub) = 0;
   end
   if ~isempty(valueV)
      valueMatchV = zeros(size(xV));
      for i1 = 1 : length(valueV)
         valueMatchV(xV == valueV(i1)) = 1;
      end
      validV(valueMatchV == 0) = 0;
   end
   disp(['N after ', varNameStr, ' filter:  ',  separatethousands(sum(validV), ',', 0)]);
end
