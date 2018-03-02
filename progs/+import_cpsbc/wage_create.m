function wageV = wage_create(m, cS)
% Create weekly wage, REAL
%{
Including business income share
Including zeros, but not negatives
NaN when wage cannot be computed (zero hours; no earnings; etc)

IN
   m  ::  table
      with variables 'earnings', 'weeksWorked', 'year', 'incbus'

Checked: 
%}


% Nominal earnings
earnV = (max(0, m.earnings) + cS.fltS.fracBusInc .* max(0, m.incbus));
% Drop negative earnings (and NaNs)
earnV(~(m.earnings >= 0)) = NaN;
earnV(m.weeksWorked <= 0) = NaN;
% We keep those truly earning 0 (if filter permits this)
earnV(m.earnings == 0   &   m.weeksWorked == 0) = 0;

% CPI object
cpiS = import_cpsbc.cpi(cS);
% CPI for last year when wages were earned
cpiV = cpiS.retrieve(m.year - 1);
validateattributes(cpiV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive'})

realEarnV = earnV ./ cpiV;

% Weekly real wage
wageV = realEarnV ./ m.weeksWorked;


end