function wage_create_cpsbc(yearV, setNo)
% Create weekly wage, real
%{
Including business income share
Including zeros, but not negatives

Checked: 2015-july1
%}

cS = const_cpsbc(setNo);

% CPI last year, when wages were earned
bcS = const_bc1([]);
cpiV = data_bc1.cpi(yearV - 1, bcS);
clear bcS;

for iy = 1 : length(yearV)
   year1 = yearV(iy);

   % Load ind variables
   % classWkrV = var_load_cpsbc(cS.vClassWkr,  year1, setNo);
   incWageV  = var_load_cpsbc(cS.vIncWage,   year1, setNo);
   % Business income - can be negative
   incBusV   = var_load_cpsbc(cS.vIncBus,    year1, setNo);
   weeksV    = var_load_cpsbc(cS.vWeeksYear, year1, setNo);
   wtV       = var_load_cpsbc(cS.vWeight, year1, setNo);
   
   % Earnings = wage income + fraction of business income
   earnV = (max(0, incWageV) + cS.fracBusInc .* max(0, incBusV)) ./ cpiV(iy);
   
   earnV(incWageV < 0) = cS.missVal;
   earnV(earnV < 0) = cS.missVal;
   earnV(weeksV <= 0) = cS.missVal;
   % We keep those truly earning 0 (if filter permits this)
   earnV(earnV == 0   &   weeksV == 0) = 0;

   
   % weekly real wage
   wageV = earnV ./ max(1, weeksV);
   wageV(wageV < 0) = cS.missVal;
   

   % Compute median weekly wage to drop outliers
   idxV = find(wageV > 0);
   medianWage = distrib_lh.weighted_median(wageV(idxV), wtV(idxV), 1);
   
   wageV(wageV > 0  &  (wageV < cS.wageMinFactor .* medianWage  |  wageV > cS.wageMaxFactor .* medianWage)) = cS.missVal;   
   var_save_cpsbc(wageV, cS.vRealWeeklyWage, year1, setNo);

   earnV(wageV == cS.missVal) = cS.missVal;
   var_save_cpsbc(earnV, cS.vRealAnnualEarn, year1, setNo);
        
%    % Does person earn enough to be counted as working
%    isWorkingV = repmat(cS.missVal, size(weeksV));
%    isWorkingV(idxV) = (earnV(idxV) >= cS.minRealEarn);
%    var_save_cpsbc(isWorkingV, cS.vIsWorking, year1, setNo);
  
end

%keyboard;
   
end