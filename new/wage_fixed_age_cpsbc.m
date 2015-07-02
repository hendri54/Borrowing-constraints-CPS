function wage_fixed_age_cpsbc(ageLb, ageUb, sexCode, setNo)
% Show stats for fixed age range over time
% ---------------------------------------------

cS = const_cpsbc(setNo);
ny = length(cS.yearV);
% Threshold
wLimit = cS.minRealEarn ./ 50;

% Frac missing
fracMissV = repmat(cS.missVal, [ny, 1]);
% Frac > 0 out of not missing
fracPosV = repmat(cS.missVal, [ny, 1]);
% Frac > threshold (out of not missing)
fracAboveV = repmat(cS.missVal, [ny, 1]);
fracWorkingV = repmat(cS.missVal, [ny, 1]);


% Start in year 2, which records wages for year 1
for iy = 2 : length(cS.yearV)
   year1 = cS.yearV(iy);
   wageV = var_load_cpsbc(cS.vRealWeeklyWage, year1, setNo);         
   wtV = var_load_cpsbc(cS.vWeight, year1, setNo);
   % Age at interview, subtract 1
   ageV = var_load_cpsbc(cS.vAge, year1, setNo) - 1;
   sexV = var_load_cpsbc(cS.vSex, year1, setNo);
   isWorkingV = var_load_cpsbc(cS.vIsWorking, year1, setNo);
   
   vIdxV = find(wtV > 0  &  ageV >= ageLb  &  ageV <= ageUb  &  sexV == sexCode);
   
   totalWt = sum(wtV(vIdxV));
   wtMiss  = sum(wtV(vIdxV) .* (wageV(vIdxV) == cS.missVal));
   
   wtPos   = sum(wtV(vIdxV) .* (wageV(vIdxV) > 0));
   wtAbove = sum(wtV(vIdxV) .* (wageV(vIdxV) > wLimit));
   wtWorking = sum(wtV(vIdxV) .* (isWorkingV(vIdxV) == 1));

   fracMissV(iy-1) = wtMiss ./ totalWt;
   
   fracPosV(iy-1) = wtPos ./ (totalWt - wtMiss);
   fracAboveV(iy-1) = wtAbove ./ (totalWt - wtMiss);
   
   fracWorkingV(iy-1) = wtWorking ./ (totalWt - wtMiss);
   
   %if year1 == 2000
   %   keyboard;
   %end
end


hold on;
idxV = find(fracMissV >= 0);
plot(cS.yearV(idxV), fracMissV(idxV), '-', 'Color', cS.colorM(1,:));

idxV = find(fracPosV >= 0);
plot(cS.yearV(idxV), fracPosV(idxV), '-', 'Color', cS.colorM(2,:));

idxV = find(fracAboveV >= 0);
plot(cS.yearV(idxV), fracAboveV(idxV), '-', 'Color', cS.colorM(3,:));

idxV = find(fracWorkingV >= 0);
plot(cS.yearV(idxV), fracWorkingV(idxV), '-', 'Color', cS.colorM(4,:));

hold off;
grid on;
legend({'Missing', 'Positive', 'Above 2k', 'Working'}, 'Location', 'SouthOutside', 'orientation', 'horizontal');

pause;
close;


end