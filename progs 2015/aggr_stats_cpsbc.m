function aggr_stats_cpsbc(setNo)
% Aggregate stats by year

cS = const_cpsbc(setNo);
yearV = cS.yearV;
ny = length(yearV);

% Mean log wage by school group
saveS.meanLogWage_stM = repmat(cS.missVal, [cS.nSchool, ny]);
saveS.medianWage_stM = repmat(cS.missVal, [cS.nSchool, ny]);
saveS.medianWage_tV = repmat(cS.missVal, [ny, 1]);
saveS.meanLogWage_tV = repmat(cS.missVal, [ny, 1]);

% Last year has no wage data
for iy = 1 : (ny - 1)
   % For wages in year 1, must load year 2 variables
   year1 = yearV(iy) + 1;
   
   wtV = var_load_cpsbc(cS.vWeight, year1, setNo);
   % Age at interview
   ageV = var_load_cpsbc(cS.vAge, year1, setNo);
   % sexV = var_load_cpsbc(cS.vSex, year1, setNo);
   schoolClV = var_load_cpsbc(cS.vSchoolGroup, year1, setNo);
   % Wage for year1 - 1
   wageV = var_load_cpsbc(cS.vRealWeeklyWage, year1, setNo);
   logWageV = log_lh(wageV, cS.missVal);

   wtV(ageV < cS.aggrAgeRangeV(1)  |  ageV > cS.aggrAgeRangeV(end)  |  wageV <= 0) = 0;
   totalWt = sum(wtV);

   idxV = find(wtV > 0);
   if ~isempty(idxV)
      % Compute median wage
      clWtV = wtV(idxV) / totalWt;
      saveS.medianWage_tV(iy) = distrib_lh.weighted_median(wageV(idxV), clWtV, cS.dbg);
      % Mean log wage
      saveS.meanLogWage_tV(iy) = sum(logWageV(idxV) .* clWtV);

      for iSchool = 1 : cS.nSchool
         idxV = find(wtV > 0  &  schoolClV == iSchool  &  wageV > 0);
         totalWt = sum(wtV(idxV));
         clWtV = wtV(idxV) / totalWt;

         saveS.meanLogWage_stM(iSchool, iy) = sum(clWtV .* logWageV(idxV));
         saveS.medianWage_stM(iSchool, iy) = distrib_lh.weighted_median(wageV(idxV), clWtV, cS.dbg);
      end
   end
end

vIdxV = find(saveS.medianWage_tV ~= cS.missVal);
validateattributes(saveS.medianWage_tV(vIdxV), {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive'})
validateattributes(saveS.meanLogWage_tV(vIdxV), {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})

var_save_cpsbc(saveS, cS.vAggrStats, [], setNo);


end