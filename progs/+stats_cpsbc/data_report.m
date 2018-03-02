function data_report(yearV, setName)
% Show basic sample stats as a diagnostic, by year

cS = const_cpsbc(setName);
if isempty(yearV)
   % All years, but last one has no wage data
   yearV = cS.yearV(1 : (end-1));
end
ny = length(yearV);

% Load filtered data
dmS = import_cpsbc.DataMatrix(setName);
m = dmS.load;


%% Compute stats

% wtMeanFct = @(x) statsLH.mean_weighted(x, m.weight, cS.dbg);
% 
% statsS = grpstats(m, 'year', wtMeanFct,  'DataVars', {'earnings', 'wage'});
% 
% keyboard;

nObsV = zeros(ny,1);
ageMeanV = zeros(ny, 1);
hoursMeanV = zeros(ny, 1);
weeksMeanV = zeros(ny, 1);
schoolMeanV = zeros(ny, 1);
cgFracV = zeros(ny, 1);
wageMedianV = zeros(ny, 1);
incWageFracTopCodedV = zeros(ny, 1);
incWageTopCodeV = zeros(ny, 1);

for iy = 1 : ny
   year1 = yearV(iy);
   yIdxV = find(m.year == year1);
   if isempty(yIdxV)
      warning('No data for year %i', year1);
      break;
   end
   
   % Normalized weights
   wtV = m.weight(yIdxV) ./ sum(m.weight(yIdxV));
   wageV = m.wage(yIdxV);
   
   if any(wtV <= 0)
      error('Unexpected');
   end
   validateattributes(m.yrSchool(yIdxV), {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>=', 0, ...
      '<', 35})
   
   nObsV(iy) = length(wtV);
   ageMeanV(iy) = sum(m.age(yIdxV) .* wtV);
   hoursMeanV(iy) = sum(m.ahrsworkt(yIdxV) .* wtV);
   weeksMeanV(iy) = sum(m.weeksWorked(yIdxV) .* wtV);
   schoolMeanV(iy) = sum(m.yrSchool(yIdxV) .* wtV);
   cgFracV(iy) = sum((m.schoolCl(yIdxV) == cS.iCG) .* wtV);
   
   idxV = find(wageV > 0);
   wageMedianV(iy) = distribLH.weighted_median(wageV(idxV), wtV(idxV), cS.dbg);
   % Top coded incWage
   incWageTopCodeV(iy) = max(m.earnings(yIdxV));
   incWageFracTopCodedV(iy) = sum((abs(m.earnings(yIdxV) - incWageTopCodeV(iy)) < 100) .* wtV);
end


%% Checks

validateattributes(nObsV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>', 5000})
validateattributes(ageMeanV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>', 30, '<', 50})
validateattributes(hoursMeanV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>', 30, '<', 50})
validateattributes(weeksMeanV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>', 30, '<' 51})
validateattributes(schoolMeanV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>', 10, '<', 15})
validateattributes(incWageTopCodeV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', '>', 9000})



%% Table setup
% Each row is a year

nr = ny;
nc = 10;

tbM = cell([nr, nc]);
colHeaderV = cell([1, nc]);
rowHeaderV = cell([1, nr]);


%% Fill table

for iy = 1 : ny
   ir = iy;
   year1 = yearV(iy);
   rowHeaderV{ir} = sprintf('%i', year1);
   ic = 0;
   
   row_add('N (k)', sprintf('%.0f', nObsV(iy) ./ 1e3));
   row_add('Age', sprintf('%.1f', ageMeanV(iy)));
   row_add('Hours', sprintf('%.1f', hoursMeanV(iy)));
   row_add('Weeks', sprintf('%.1f', weeksMeanV(iy)));
   row_add('School', sprintf('%.1f', schoolMeanV(iy)));
   row_add('CgFrac', sprintf('%.2f', cgFracV(iy)));
   row_add('Wage', sprintf('%.1f', wageMedianV(iy)));
   row_add('TopCode', sprintf('%.0f', incWageTopCodeV(iy)));
   row_add('FracTop', sprintf('%.3f', incWageFracTopCodedV(iy)));
end

nc = ic;


%% Save table

dirS = helper_cpsbc.directories(setName);
tbFn = fullfile(dirS.tbDir,  'sample_report');

tbS = LatexTableLH(nr, nc,  'filePath', tbFn,  'colHeaderV', colHeaderV(1:nc),  'rowHeaderV', rowHeaderV);
tbS.tbM = tbM(:, 1:nc);
tbS.write_text_table;



%% Nested: Add a row
   function row_add(descrStr, valueStr)
      ic = ic + 1;
      tbM{ir, ic} = valueStr;
      if ir == 2
         %tbM{1, ic} = descrStr;
         colHeaderV{ic} = descrStr;
      end
   end


end