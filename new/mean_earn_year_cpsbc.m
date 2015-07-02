function meanV = mean_earn_year_cpsbc(byValueV, iSchoolV, setNo)
% Compute by year
%  mean real earnings, dropping top / bottom 5%
%  pool birth years and school groups

% IN:
%  iSchoolV
%     school groups to keep
%     can be []; then even keep people with unknown schooling

% ----------------------------------------------------

cS = const_cpsbc(setNo);
% Drop top / bottom x pct
dropPct = 0.05;
nBy = length(byValueV);
ny = length(cS.yearV);




% *******  Loop over years

meanV = repmat(cS.missVal, [ny, 1]);

for iy = 1 : ny
   year1 = cS.yearV(iy);
   schoolClV = var_load_cpsbc(cS.vSchoolGroup, year1, setNo);
   wtV = var_load_cpsbc(cS.vWeight, year1, setNo);
   earnV = var_load_cpsbc(cS.vRealAnnualEarn, year1, setNo);
   ageV = var_load_cpsbc(cS.vAge, year1, setNo);
   nInd = length(ageV);
   
   % Mark as invalid unless match one birth year
   validV = zeros([nInd, 1]);
   % Ages for each birth year
   ageValueV = year1 - byValueV;
   for iBy = 1 : length(ageValueV)
      validV(ageV == ageValueV(iBy)) = 1;
   end   
   
   % Mark as invalid unless match one school class
   if ~isempty(iSchoolV)
      sValidV = zeros([nInd, 1]);
      for i1 = 1 : length(iSchoolV)
         sValidV(schoolClV == iSchoolV(i1)) = 1;
      end
      validV(sValidV < 0.5) = 0;
   end
   
   vIdxV = find(validV > 0.5  &  earnV(:) ~= cS.missVal  &  wtV > 0);
   if length(vIdxV) > 10
      meanV(iy) = trunc_mean_lh(earnV(vIdxV), wtV(vIdxV), [dropPct, 1-dropPct]);
   end
end




end