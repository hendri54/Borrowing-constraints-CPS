function outS = byear_school_age_stats_cpsbc(byLbV, byUbV, ageV, setNo)
% Construct stats by birth year, school, age
% from stats by [physical age, school, year]
%{
IN:
 bYear1
    First cohort to keep
 byUbV
    Upper bounds of birth cohorts, integer!
 ageV
    Ages to keep

OUT:
    meanLogWageM(birth year, school, phys age)
    wageExYearEffectsM
       same net of year effects

Checked: 2015-Jul-1
%}

if nargin ~= 4
   error('Invalid nargin');
end

cS = const_cpsbc(setNo);

byUbV = byUbV(:);
byLbV = byLbV(:);

% Lower bounds of birth cohorts
% byLbV = [bYear1; byUbV(1 : end-1) + 1];

% Load stats by [age, school, year]
loadS = var_load_cpsbc(cS.vAgeSchoolYearStats, [], setNo);

% Output matrices
nBy = length(byUbV);
nAge = length(ageV);
sizeV = [nBy, cS.nSchool, ageV(end)];
outS.nObsM = zeros(sizeV);
outS.massM = zeros(sizeV);
outS.meanLogWageM = repmat(cS.missVal, sizeV);
% outS.wageExYearEffectsM = outS.meanLogWageM;
outS.meanLogEarnM = repmat(cS.missVal, sizeV);
% outS.fracWorkingM = repmat(cS.missVal, sizeV);
% Median earnings, all, real
outS.medianEarnM = repmat(cS.missVal, sizeV);

% Load year effects, by [school, year]
% yrEffectM = var_load_cpsbc(cS.vYearEffects, [], setNo);

% Loop over multi-year birth cohorts
for iBy = 1 : nBy
   % Loop over birth years in that cohort
   bYearV = byLbV(iBy) : byUbV(iBy);
   for i1 = 1 : length(bYearV)
      bYear = bYearV(i1);
      % Loop over ages
      for iAge = 1 : nAge
         age1 = ageV(iAge);
         
         % Index of this age in loadS - just to check that entry exists
         ageIdx = find(loadS.ageV == age1);
         if length(ageIdx) ~= 1
            error('Age not found');
         end
         
         % Year for this birth year / age combination
         year1 = bYear + age1;
         yrIdx = find(cS.yearV == year1);
         if ~isempty(yrIdx)  &&  ~isempty(ageIdx)
            outS.nObsM(iBy, :, age1) = loadS.nObsM(age1, :, yrIdx);
            outS.massM(iBy, :, age1) = loadS.massM(age1, :, yrIdx);
            outS.meanLogWageM(iBy, :, age1) = loadS.meanLogWageM(age1, :, yrIdx);
            outS.meanLogEarnM(iBy, :, age1) = loadS.meanLogEarnM(age1, :, yrIdx);
            outS.medianEarnM(iBy, :, age1)  = loadS.medianEarnM(age1, :, yrIdx);
%             outS.fracWorkingM(iBy, :, age1) = loadS.fracWorkingM(age1, :, yrIdx);
%             idxV = find(yrEffectM(:, yrIdx) ~= cS.missVal);
%             if ~isempty(idxV)
%                outS.wageExYearEffectsM(iBy, idxV, age1) = squeeze(outS.meanLogWageM(iBy, idxV, age1))' - yrEffectM(idxV, yrIdx);
%             end
         end
      end
   end
end


end