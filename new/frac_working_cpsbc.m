function fracWorkM = frac_working_cpsbc(setNo)
% Construct fraction working by [age, school]
% Simply averaging over years
% -------------------------------------------

cS = const_cpsbc(setNo);

% Stats by [age, school, year]
loadS = var_load_cpsbc(cS.vAgeSchoolYearStats, [], setNo);
ageMax = loadS.ageV(end);

fracWorkM = repmat(cS.missVal, [ageMax, cS.nSchool]);

for age1 = 1 : ageMax
   for iSchool = 1 : cS.nSchool
      % Fraction working by year
      fracV = squeeze(loadS.fracWorkingM(age1, iSchool, :));
      massV = squeeze(loadS.massM(age1, iSchool, :));
      idxV = find(fracV > 0  &  massV > 0);
      if ~isempty(idxV)
         fracWorkM(age1, iSchool) = sum(fracV(idxV) .* massV(idxV)) ./ sum(massV(idxV));
      end
   end
end


end