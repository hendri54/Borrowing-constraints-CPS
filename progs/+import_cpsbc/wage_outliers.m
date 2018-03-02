function validV = wage_outliers(wageV, wtV, yearV, cS)
% Loop over years to mark outliers
%{
OUT
   validV  ::  logical
      indicates whether wage is valid or outlier
%}

validV = false(size(wageV));

for iy = 1 : length(cS.wageYearV)
   year1 = cS.wageYearV(iy);
   yIdxV = find(yearV == year1  &  wtV > 0);
   if isempty(yIdxV)
      fprintf('    No positive weights for year %i \n',  year1);
      
   else
      yrWageV = wageV(yIdxV);
      yrWtV = wtV(yIdxV);

      % Compute median weekly wage to drop outliers
      idxV = find(yrWageV > 0);

      if isempty(idxV)
         fprintf('    No wage data for year %i \n',  year1);

      else
         medianWage = distribLH.weighted_median(yrWageV(idxV), yrWtV(idxV), cS.dbg);
         if isempty(medianWage)  ||  isnan(medianWage)  ||  isinf(medianWage)
            keyboard;
         end
         validateattributes(medianWage, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive', 'scalar'})

         % Valid: zero wage or wage in range
         yrValidV = (yrWageV == 0)  |  ((yrWageV >= cS.fltS.wageMinFactor .* medianWage)  &  ...
            (yrWageV <= cS.fltS.wageMaxFactor .* medianWage));

         validV(yIdxV) = yrValidV;
      end
   end
end

end