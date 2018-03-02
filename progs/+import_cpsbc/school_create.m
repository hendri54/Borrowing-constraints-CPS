function [schoolClV, schoolV] = school_create(educ99V, higradeV, yearV, cS)
% Create school variables at individual level

% Test this +++++

schoolClV = nan(size(educ99V));
schoolV = nan(size(educ99V));

% After 1992: Have educ99 (degree attained)
educ99S = vars_cpsbc.educ99;
idxV = find(yearV >= 1992);
if ~isempty(idxV)
   schoolClV(idxV) = educ99S.recode_to_degrees(educ99V(idxV));
   schoolV(idxV) = educ99S.recode_to_yrschool(educ99V(idxV));
end

% Before 1992: higrade
idxV  = find(yearV < 1992);
if ~isempty(idxV)
   higradeS = vars_cpsbc.higrade;
   schoolClV(idxV) = higradeS.recode_to_degrees(higradeV(idxV));
   schoolV(idxV) = higradeS.recode_to_yrschool(higradeV(idxV));
end


% if year1 >= 1992
%    
%    schoolClV = educ99_to_degree_cps(educ99V, year1, cS.iHSD, cS.iHSG, cS.iCD, cS.iCG, cS.missVal);
%    schoolV   = educ99_to_yrschool_cps(educ99V, year1, cS.missVal);
% else
%    hiGradeV = var_load_cpsbc(cS.vHigrade, year1, setNo);
%    schoolClV = higrade_to_degree_cps(hiGradeV, year1, cS.iHSD, cS.iHSG, cS.iCD, cS.iCG, cS.missVal);
%    schoolV   = higrade_to_yrschool_cps(hiGradeV, year1, cS.missVal);
% end


end