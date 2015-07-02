function year_effects_cpsbc(saveFigures, setNo)
% Estimate year effects
% Regress mean log wage by [age, year] on year dummies
% for each school group
% ------------------------------------------------

cS = const_cpsbc(setNo);
rAlpha = 0.05;
dbg = 1;
% Min no of obs per [cohort, school] cell
minObs = 50;
ny = length(cS.yearV);

% Load mean log wage by [age, school, year]
% For comparison
loadS = var_load_cpsbc(cS.vAgeSchoolYearStats, [], setNo);


% Year effects (dummy coefficients)
yrEffectM = repmat(cS.missVal, [cS.nSchool, ny]);


for iSchool = 1 : cS.nSchool
   % Age range to use
   if iSchool == cS.iCG  ||  iSchool == cS.iCD
      ageV = 23 : 60;
   else
      ageV = 18 : 60;
   end
   nAge = length(ageV);


   % Range of birth years to keep
   byRangeV = (cS.yearV(1) - 35) : (cS.yearV(end) - 35);
   %nBy = length(byRangeV);
   

   % Mean log wage by [age, year]
   % Only keep selected ages
   meanLogWageM = squeeze(loadS.meanLogWageM(ageV, iSchool, :));
   nObsM = squeeze(loadS.nObsM(ageV, iSchool, :));


   % ***************  Regress on year dummies

   nObs = nAge * ny;
   yrDummyM = zeros([nObs, ny]);
   yV = zeros([nObs, 1]);
   nObsV = zeros([nObs, 1]);
   %byDummyM = zeros([nObs, nBy]);
   %experV = zeros([nObs, 1]); 

   % Highest row populated
   ir = 0;
   for iy = 1 : ny
      year1 = cS.yearV(iy);
      % Birth years that go with each age index
      bYearV = year1 - ageV(:) + 1;

      % Find obs with data and valid birth cohort
      idxV = find(meanLogWageM(:, iy) ~= cS.missVal  &  nObsM(:, iy) >= minObs  &    bYearV >= byRangeV(1)  &  bYearV <= byRangeV(end));

      % Add observations to regressors
      if ~isempty(idxV)
         % Rows to be populated
         rowV = ir + (1 : length(idxV));
         yV(rowV) = meanLogWageM(idxV, iy);
         nObsV(rowV) = nObsM(idxV,iy);
         yrDummyM(rowV, iy) = 1;
         
         % Last row populated so far
         ir = rowV(end);
      end
   end

   % No of rows
   nr = ir;
   yV = yV(1 : nr);
   yrDummyM = yrDummyM(1:nr, :);
   nObsV = nObsV(1:nr);
   
   % Keep only years with data
   % binds for dropouts in 1964
   idxV = find(max(yrDummyM) > 0.5);

   rsS = lsq_weighted_lh(yV, yrDummyM(:, idxV), sqrt(nObsV), rAlpha, dbg);

   % Construct residual wages
   %residV = yV - yrDummyM * rsS.betaV;
   
   %keyboard;
   
   yrEffectM(iSchool, idxV) = rsS.betaV;
end % for iSchool


% ********  Fill in missing years

% Last year effect is always missing
yrEffectM(:, ny) = yrEffectM(:, ny - 1);

%  Should only be 1st 2 years
%  And last year effect - b/c we don't have earnings data 
minV = min(yrEffectM);
if any(minV(3: (ny-1)) == cS.missVal)
   disp('Missing year effects after year 2');
   keyboard;
end

for iSchool = 1 : cS.nSchool
   idxV = find(yrEffectM(iSchool, :) == cS.missVal);
   if ~isempty(idxV)
      yrEffectM(iSchool, idxV) = yrEffectM(iSchool, idxV(end) + 1);
   end
end


% Save
var_save_cpsbc(yrEffectM, cS.vYearEffects, [], setNo);


% Plot year dummies
if saveFigures >= 0
   for iSchool = 1 : cS.nSchool
      subplot(2,2,iSchool);
      
      % Also plot mean log wage in that year
      meanLogWageYearM = wage_by_year_cpsbc(cS.male, cS.yearV, setNo);
      
      idxV = find(yrEffectM(iSchool, 1:(ny-1)) ~= cS.missVal);
      plot(cS.yearV(idxV), yrEffectM(iSchool,idxV)', 'bo',   cS.yearV(1 : (ny-1)), meanLogWageYearM(iSchool,1 : (ny-1)), 'r-');
      xlabel('Year');
      title(['Year dummies  ', cS.schoolLabelV{iSchool}]);
      legend({'Dummy', 'Mean log wage'}, 'Location', 'Best');
      grid on;
   end
   
   figFn = [cS.figDir,  'year_dummies'];
   save_fig_cpsbc(figFn, saveFigures, cS.figOpt4S, setNo)
   
end

end