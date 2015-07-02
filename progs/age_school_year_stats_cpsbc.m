function age_school_year_stats_cpsbc(setNo)
% Compute stats by [age, school, year]
%{
Outputs indexed by physical age, cS.yearV

Account for the fact that earnings refer to past year

Checked: 2015-Jul-1
%}
% --------------------------------------------

cS = const_cpsbc(setNo);

% Min obs per cell
minObs = 10;

ny = length(cS.yearV);


% ages retained
saveS.ageV = cS.fltAgeMin : cS.fltAgeMax;
nAge = length(saveS.ageV);

% No ob observations
saveS.nObsM = zeros([cS.fltAgeMax, cS.nSchool, ny]);
% Mass
saveS.massM = zeros([cS.fltAgeMax, cS.nSchool, ny]);
% Mean log wage (real, weekly), only those with earnings above threshold
saveS.meanLogWageM = repmat(cS.missVal, [cS.fltAgeMax, cS.nSchool, ny]);
% Mean log annual real earnings, only those with earnings above threshold
saveS.meanLogEarnM = repmat(cS.missVal, [cS.fltAgeMax, cS.nSchool, ny]);
% Median annual real earnings, all
saveS.medianEarnM = repmat(cS.missVal, [cS.fltAgeMax, cS.nSchool, ny]);
saveS.medianWageM = repmat(cS.missVal, [cS.fltAgeMax, cS.nSchool, ny]);
% Fraction working (earnings more than threshold)
% saveS.fracWorkingM = repmat(cS.missVal, [cS.fltAgeMax, cS.nSchool, ny]);


% Start in year 2, which reports wages in year 1
for iy = 2 : ny
   year1 = cS.yearV(iy);
   
   % Load ind variables
   wageV = var_load_cpsbc(cS.vRealWeeklyWage, year1, setNo);
   earnV = var_load_cpsbc(cS.vRealAnnualEarn, year1, setNo);
   % isWorkingV = var_load_cpsbc(cS.vIsWorking, year1, setNo);
   schoolClV = var_load_cpsbc(cS.vSchoolGroup, year1, setNo);
   wtV = var_load_cpsbc(cS.vWeight, year1, setNo);
   % Age when wages were earned
   ageV = var_load_cpsbc(cS.vAge, year1, setNo) - 1;
   
   % Filter
   ageV(wtV <= 0  |  wageV < 0  |  earnV == cS.missVal) = cS.missVal;
   
   for iAge = 1 : nAge
      age1 = saveS.ageV(iAge);      
      for iSchool = 1 : cS.nSchool
         sIdxV = find(schoolClV == iSchool  &  ageV == age1);
         if length(sIdxV) >= minObs
            % All results refer to last year, when wages were earned
            saveS.nObsM(age1, iSchool, iy-1) = length(sIdxV);
            saveS.massM(age1, iSchool, iy-1) = sum(wtV(sIdxV));

            % Fraction working
%             saveS.fracWorkingM(age1, iSchool, iy-1) = sum((isWorkingV(sIdxV) == 1) .* wtV(sIdxV)) ./ saveS.massM(age1, iSchool, iy-1);

            % Median (all, including zeros)
            medianEarn = distrib_lh.weighted_median(earnV(sIdxV), wtV(sIdxV), cS.dbg);
            saveS.medianEarnM(age1, iSchool, iy-1) = medianEarn;
            medianWage = distrib_lh.weighted_median(wageV(sIdxV), wtV(sIdxV), cS.dbg);
            saveS.medianWageM(age1, iSchool, iy-1) = medianWage;

            %if age1 == 70  &&  year1 == 2000  &&  iSchool == 2
            %   keyboard;
            %end

            % Annual earnings
            idxV = find(earnV(sIdxV) >= cS.minRealEarn);
            if length(idxV) >= minObs
               idxV = sIdxV(idxV);
               saveS.meanLogEarnM(age1, iSchool, iy-1) = sum(log(earnV(idxV)) .* wtV(idxV)) ./ sum(wtV(idxV));
            end

            % Weekly wage
            %  Enough to restrict wage > 0 b/c very small wages were
            %  dropped
            idxV = find(wageV(sIdxV) > 0);
            if length(idxV) >= minObs
               idxV = sIdxV(idxV);
               saveS.meanLogWageM(age1, iSchool, iy-1) = sum(log(wageV(idxV)) .* wtV(idxV)) ./ sum(wtV(idxV));                  
            end
         end

         %keyboard;
      end % iSchool
   end
   
end


% save
var_save_cpsbc(saveS, cS.vAgeSchoolYearStats, [], setNo);


validateattributes(saveS.meanLogWageM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})
validateattributes(saveS.meanLogEarnM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})
validateattributes(saveS.medianWageM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})
validateattributes(saveS.medianEarnM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})


end