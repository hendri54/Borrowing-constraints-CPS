function [avgSchoolV, fracM] = school_by_year_cpsbc(setNo)
% Show stats for schooling by year
% ---------------------------------------

cS = const_cpsbc(setNo);
ny = length(cS.yearV);

% Avg years of schooling
avgSchoolV = zeros([ny, 1]);
% Fraction by school group
fracM = zeros([cS.nSchool, ny]);

for iy = 1 : ny
   year1 = cS.yearV(iy);
   
   wtV = var_load_cpsbc(cS.vWeight, year1, setNo);
   ageV = var_load_cpsbc(cS.vAge, year1, setNo);
   schoolClV = var_load_cpsbc(cS.vSchoolGroup, year1, setNo);
   schoolV = var_load_cpsbc(cS.vSchoolYears, year1, setNo);
   
   idxV = find(wtV > 0  &  ageV >= 25  &  ageV <= 50  &  schoolClV > 0  &  schoolV >= 0);
   totalWt = sum(wtV(idxV));
   
   avgSchoolV(iy) = sum(wtV(idxV) .* schoolV(idxV)) ./ totalWt;
   
   for iSchool = 1 : cS.nSchool
      fracM(iSchool, iy) = sum(wtV(idxV) .* (schoolClV(idxV) == iSchool)) ./ totalWt;
   end
end

end