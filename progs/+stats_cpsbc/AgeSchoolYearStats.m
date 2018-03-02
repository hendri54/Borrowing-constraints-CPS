classdef AgeSchoolYearStats < handle
   
properties
   % Min obs per cell
   minObs uint16 = 10;
   dbg  uint16 = 111
end
   
properties (SetAccess = private)
   setName  char
   ageV   double
   nObsM  uint16
   massM  double
   meanLogWageM  double
   meanLogEarnM  double
   medianWageM  double
   medianEarnM  double
end

methods
   %% Constructor
   function saveS = AgeSchoolYearStats(setName)
      saveS.setName = setName;
   end
   
   
   %% Compute stats by [age, school, year]
   %{
   Outputs indexed by physical age, cS.yearV

   Account for the fact that earnings refer to past year

   Checked:
   %}
   function compute_stats(saveS)
      cS = const_cpsbc(saveS.setName);
      dmS = import_cpsbc.DataMatrix(saveS.setName);
      m = dmS.load;

      ny = length(cS.yearV);

      % ages retained
      saveS.ageV = cS.fltS.ageMin : cS.fltS.ageMax;
      nAge = length(saveS.ageV);

      % No ob observations
      sizeV = [cS.fltS.ageMax, cS.nSchool, ny];
      saveS.nObsM = zeros(sizeV, 'uint16');
      % Mass
      saveS.massM = zeros(sizeV);
      % Mean log wage (real, weekly), only those with earnings above threshold
      saveS.meanLogWageM = repmat(cS.missVal, sizeV);
      % Mean log annual real earnings, only those with earnings above threshold
      saveS.meanLogEarnM = repmat(cS.missVal, sizeV);
      % Median annual real earnings, all
      saveS.medianEarnM = repmat(cS.missVal, sizeV);
      saveS.medianWageM = repmat(cS.missVal, sizeV);
      % Fraction working (earnings more than threshold)
      % saveS.fracWorkingM = repmat(cS.missVal, sizeV);


      % Start in year 2, which reports wages in year 1
      for iy = 2 : ny
         year1 = cS.yearV(iy);
         yIdxV = find(m.year == year1);

         % Age when wages were earned
         ageV = m.age(yIdxV) - 1;
         wageV = m.wage(yIdxV);
         earnV = m.earnings(yIdxV);
         schoolClV = m.schoolCl(yIdxV);
         wtV = m.weight(yIdxV);

         % Filter
         ageV(wtV <= 0  |  wageV < 0  |  earnV == cS.missVal) = NaN;

         for iAge = 1 : nAge
            age1 = saveS.ageV(iAge);      
            for iSchool = 1 : cS.nSchool
               sIdxV = find(schoolClV == iSchool  &  ageV == age1);
               if length(sIdxV) >= saveS.minObs
                  % All results refer to last year, when wages were earned
                  saveS.nObsM(age1, iSchool, iy-1) = length(sIdxV);
                  saveS.massM(age1, iSchool, iy-1) = sum(wtV(sIdxV));

                  % Fraction working
      %             saveS.fracWorkingM(age1, iSchool, iy-1) = sum((isWorkingV(sIdxV) == 1) .* wtV(sIdxV)) ./ saveS.massM(age1, iSchool, iy-1);

                  % Median (all, including zeros)
                  medianEarn = distribLH.weighted_median(earnV(sIdxV), wtV(sIdxV), cS.dbg);
                  saveS.medianEarnM(age1, iSchool, iy-1) = medianEarn;
                  medianWage = distribLH.weighted_median(wageV(sIdxV), wtV(sIdxV), cS.dbg);
                  saveS.medianWageM(age1, iSchool, iy-1) = medianWage;

                  %if age1 == 70  &&  year1 == 2000  &&  iSchool == 2
                  %   keyboard;
                  %end

                  % Annual earnings
                  idxV = find(earnV(sIdxV) >= cS.fltS.minRealEarn);
                  if length(idxV) >= saveS.minObs
                     idxV = sIdxV(idxV);
                     saveS.meanLogEarnM(age1, iSchool, iy-1) = ...
                        sum(log(earnV(idxV)) .* wtV(idxV)) ./ sum(wtV(idxV));
                  end

                  % Weekly wage
                  %  Enough to restrict wage > 0 b/c very small wages were
                  %  dropped
                  idxV = find(wageV(sIdxV) > 0);
                  if length(idxV) >= saveS.minObs
                     idxV = sIdxV(idxV);
                     saveS.meanLogWageM(age1, iSchool, iy-1) = ...
                        sum(log(wageV(idxV)) .* wtV(idxV)) ./ sum(wtV(idxV));                  
                  end
               end;
            end % iSchool
         end % iAge
      end % iy

      validateattributes(saveS.meanLogWageM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})
      validateattributes(saveS.meanLogEarnM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})
      validateattributes(saveS.medianWageM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})
      validateattributes(saveS.medianEarnM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})
   end

end
   
end