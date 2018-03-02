function fracM = cohort_school_cpsbc(bYearV, ageV, setNo)
% Compute fraction by [birth year, school level]
% ----------------------------------------------

cS = const_cpsbc(setNo);

byLbV = bYearV(:);
byUbV = bYearV(:);

% Mass by [by, school, phys age]
outS = byear_school_age_stats_cpsbc(byLbV, byUbV, ageV, setNo);

fracM = zeros([length(byUbV), cS.nSchool]);

for iBy = 1 : length(byUbV)
   % Mass by [school, age]
   massM = squeeze(outS.massM(iBy, :, ageV));
   
   % Sum over all ages with data
   massV = zeros([cS.nSchool, 1]);
   for iAge = 1 : length(ageV)
      if min(massM(:, iAge)) > 0
         massV = massV + massM(:, iAge);
      end
   end
   
   % Data for any age?
   if massV(1) > 0
      fracM(iBy, :) = massV ./ sum(massV);
   end
end




end