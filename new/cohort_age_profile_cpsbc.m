function outS = cohort_age_profile_cpsbc(bYear, iSchool, loadS, setNo)
% Return cohort age earnings profile
% Constructed from wage regressions

% IN:
%  loadS
%     output from wage_regr3_cpsbc
%     may be []

% OUT:
%  profileV
%     mean log earnings, by age
%     from age dummies
%  yearEffectV
%     year effects; add to profileV
%     missing out of sample
%  profileCombinedV   
%     combine the 2 to get profile adjusted for frac working
%     set missing year effects to mean
% -------------------------------------------------------

cS = const_cpsbc(setNo);

if isempty(loadS)
   loadS = wage_regr3_cpsbc(setNo);
end

idxCoh = find(bYear == loadS.byV);

% Construct the cohort's "predicted" age profile
%  cohort effect + constant + age dummies
outS.profileV = loadS.ageDummyM(:, iSchool) + loadS.cohDummyM(idxCoh, iSchool) + loadS.betaConstV(iSchool);
outS.profileV(loadS.ageDummyM(:, iSchool) == cS.missVal) = cS.missVal;

% Year effects that apply to this cohort
maxAge = length(outS.profileV);
% Cohort "lives" that these ages
yearV = bYear + (1 : maxAge);
% Ages actually observed
idxV = find(yearV >= cS.yearV(1)  &  yearV <= cS.yearV(end));
outS.yearEffectV = repmat(cS.missVal, size(outS.profileV));
outS.yearEffectV(idxV) = loadS.yearEffectM(:, iSchool);



% ******  Combined profile: mean log earn + year effects

% Fill in missing year effects
idxV = find(loadS.yearEffectM(:, iSchool) ~= cS.missVal);
avgYrEffect = mean(loadS.yearEffectM(idxV, iSchool));
yearEffectV = outS.yearEffectV;
yearEffectV(yearEffectV == cS.missVal) = avgYrEffect;

% Combined profile
outS.profileCombinedV = repmat(cS.missVal, size(outS.profileV));
idxV = find(outS.profileV ~= cS.missVal);
outS.profileCombinedV(idxV) = outS.profileV(idxV) + yearEffectV(idxV);


end