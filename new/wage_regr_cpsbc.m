function [byRangeV, wGrowthV] = wage_regr_cpsbc(saveFigures, setNo)
% Run a wage regression on time dummies and a time
% invariant experience profile

% OUT
%  wage growth for college grads, by cohort

% change
%  separate computation from plotting
% Checked: 2011-
% -------------------------------------------------------

cS = const_cpsbc(setNo);
rAlpha = 0.05;
dbg = 1;
% Min no of obs per [cohort, school] cell
minObs = 50;
ny = length(cS.yearV);

% Load mean log wage by [age, school, year]
% For comparison
loadS = var_load_cpsbc(cS.vAgeSchoolYearStats, [], setNo);

% Load year effects, by [school, year]
%  no missing values
yrEffectM = var_load_cpsbc(cS.vYearEffects, [], setNo);


% Save birth years and cohort dummies for each school group
byM = zeros([80, cS.nSchool]);
cohDummyM = zeros([80, cS.nSchool]);


% Omitting CD, which has trouble with incomplete dummies that I would have
% to work around
for iSchool = 1 : cS.nSchool
   % Age range to use
   if iSchool == cS.iCG  ||  iSchool == cS.iCD
      ageV = 23 : 64;
   else
      ageV = 18 : 64;
   end
   nAge = length(ageV);


   % Range of birth years to keep
   byRangeV = (cS.yearV(1) - 35) : (cS.yearV(end) - 35);
   nBy = length(byRangeV);
   

   % Mean log wage by [age, year]
   % Only keep selected ages
   meanLogWageM = squeeze(loadS.meanLogWageM(ageV, iSchool, :));
   nObsM = squeeze(loadS.nObsM(ageV, iSchool, :));


   % ***************  Construct regressors

   nObs = nAge * ny;
   %yrDummyM = zeros([nObs, ny]);
   % Mean log wage net of year effects
   yV = zeros([nObs, 1]);
   nObsV = zeros([nObs, 1]);
   byDummyM = zeros([nObs, nBy]);
   experV = zeros([nObs, 1]); 

   % Highest row populated
   ir = 0;
   for iy = 1 : ny
      year1 = cS.yearV(iy);
      % Birth years that go with each age index
      bYearV = year1 - ageV(:) + 1;

      % Find obs with data and valid birth cohort
      idxV = find(meanLogWageM(:, iy) ~= cS.missVal  &  nObsM(:, iy) >= minObs  &  bYearV >= byRangeV(1)  &  bYearV <= byRangeV(end));

      % Add observations to regressors
      if ~isempty(idxV)
         % Rows to be populated
         rowV = ir + (1 : length(idxV));
         yV(rowV) = meanLogWageM(idxV, iy) - yrEffectM(iSchool, iy);
         nObsV(rowV) = nObsM(idxV,iy);
         %yrDummyM(rowV, iy) = 1;

         % Birth year dummies
         bYearV = year1 - ageV(idxV) + 1;
         for i1 = 1 : length(bYearV)
            byIdx = find(bYearV(i1) == byRangeV);
            if length(byIdx) == 1
               byDummyM(rowV(i1), byIdx) = 1;
            else
               disp('Unexpected birth year');
               keyboard;
            end
         end

         % Experience, relative to first age in range
         experV(rowV) = (ageV(idxV) - ageV(1) + 1) .* 0.1;
         
         % Last row populated so far
         ir = rowV(end);
      end
   end

   % No of rows
   nr = ir;
   yV = yV(1 : nr);
   %yrDummyM = yrDummyM(1:nr, :);
   nObsV = nObsV(1:nr);
   experV = experV(1 : nr);
   byDummyM = byDummyM(1 : nr, :);

   %rsS = lsq_weighted_lh(yV, yrDummyM, sqrt(nObsV), rAlpha, dbg);

   % Construct residual wages
   %residV = yV - yrDummyM * rsS.betaV;


%    % Plot year dummies
%    if saveFigures >= 0
%       % Also plot mean log wage in that year
%       meanLogWageYearM = wage_by_year_cpsbc(cS.male, cS.yearV, setNo);
%       plot(cS.yearV, rsS.betaV, 'bo',   cS.yearV, meanLogWageYearM(iSchool,:), 'r-');
%       xlabel('Year');
%       title('Year dummies');
%       legend({'Dummy', 'Mean log wage'}, 'Location', 'Best');
%       
%       figFn = [cS.figDir,  'year_dummies_', cS.schoolLabelV{iSchool}];
%       save_fig_cpsbc(figFn, saveFigures, [], setNo)
%    end


   % *************  Regress on cohort

   residV = yV;
   x2M = byDummyM;

   rsS = lsq_weighted_lh(residV, x2M, sqrt(nObsV), rAlpha, dbg);

   % Residual is the implied experience profile
   resid2V = residV - x2M * rsS.betaV;

   % Save birth years and dummies
   byM(1 : nBy, iSchool) = byRangeV;
   cohDummyM(1 : nBy, iSchool) = rsS.betaV;

   
   % Plot cohort dummies
   if saveFigures >= 0
      plot(byRangeV, rsS.betaV, 'bo');
      xlabel('Year');
      title('Cohort dummies');
      
      figFn = [cS.figDir,  'cohort_dummies_', cS.schoolLabelV{iSchool}];
      save_fig_cpsbc(figFn, saveFigures, [], setNo)
   end

   

   % ***********  Construct experience profile by cohort

   expProfileM = zeros([nBy, nAge]);
   for i1 = 1 : nBy
      % Find obs for this cohort
      cIdxV = find(byDummyM(:, i1) == 1);
      if length(cIdxV) > 5
         %profileV = hpfilter(resid2V(cIdxV), 10);
         expProfileM(i1,  round(10 .* experV(cIdxV))) = resid2V(cIdxV);
      end
   end


   % **********  Regress on experience

   x3M = [ones([nr, 1]), experV, experV .^ 2, experV .^ 3, experV .^ 4];
   rsS = lsq_weighted_lh(resid2V, x3M, sqrt(nObsV), rAlpha, dbg);

   % These are residuals after taking out everything
   pred3V = x3M * rsS.betaV;
   resid3V = resid2V - pred3V;

   % Predicted exper profile
   nr4 = 50;
   experValueV = linspace(min(experV), max(experV), nr4)';
   x4M = [ones([nr4, 1]),  experValueV, experValueV .^ 2, experValueV .^ 3, experValueV .^ 4];
   predExperV = x4M * rsS.betaV;

   if saveFigures >= 0
      plot(10 .* experValueV,  predExperV, 'bo');
      xlabel('Experience');
      title('Predicted experience profile');
      figFn = [cS.figDir,  'exp_profile_', cS.schoolLabelV{iSchool}];
      save_fig_cpsbc(figFn, saveFigures, [], setNo)
   end


   % ***********  How well does the model fit?
   
   optS.plot45 = 1;
   optS.Regress = 1;
   optS.plotRegr = 1;
   optS.weighted = 1;
   optS.wtV = sqrt(nObsV);
   optS.showRegr = 1;

   if saveFigures >= 0
      rsS = plot_xy_lh(yV, yV - resid3V, cS.missVal, optS, dbg);

      grid on;
      xlabel('Mean log wage');
      title('Fitted mean log wage');
      figFn = [cS.figDir,  'exp_profile_fit_', cS.schoolLabelV{iSchool}];
      save_fig_cpsbc(figFn, saveFigures, [], setNo)
   end



   % **********  Show selected cohort profiles
   if saveFigures >= 0
      byShowV = 1935 : 5 : 1970;
      hold on;
      for i1 = 1 : length(byShowV)
         % Index into birth year dummies
         byIdx = find(byShowV(i1) == byRangeV);
         % Find obs for this cohort
         cIdxV = find(expProfileM(byIdx,:) ~= 0);
         if length(cIdxV) > 5
            profileV = hpfilter(expProfileM(byIdx,cIdxV), 10);
            plot(cIdxV,  profileV, 'Color', cS.colorM(i1,:));
         end
      end

      % Fitted profile
      plot(10 .* experValueV,  predExperV, 'ro-');
      hold off;
      xlabel('Experience');
      title('Profiles for selected cohorts');
      
      figFn = [cS.figDir,  'cohort_profiles_', cS.schoolLabelV{iSchool}];
      save_fig_cpsbc(figFn, saveFigures, [], setNo)
   end


   % ************  Show wage growth over lifecycle against birth year
   if 01
      % Store the wage growth numbers here
      wGrowthV = zeros(size(byRangeV));
      
      
      exp1 = 5;
      exp2 = 25;
      if saveFigures >= 0
         hold on;
      end
      for i1 = 1 : nBy
         cIdxV = find(expProfileM(i1,:) ~= 0);
         if cIdxV(1) <= exp1  &&  cIdxV(end) >= exp2
            profileV = hpfilter(expProfileM(i1,cIdxV), 10);
            wGrowthV(i1) = profileV(exp2) - profileV(exp1);
            if saveFigures >= 0
               plot(byRangeV(i1),  wGrowthV(i1), 'bo');
            end
         end
      end

      if saveFigures >= 0
         xlabel('Birth year');
         title(sprintf('Wage growth between ages %i and %i',  ageV(1) + exp1, ageV(1) + exp2));

         figFn = [cS.figDir,  'exper_wage_growth_', cS.schoolLabelV{iSchool}];
         save_fig_cpsbc(figFn, saveFigures, [], setNo)
      end
   end
end % iSchool


% Show cohort dummies college - HS
if saveFigures >= 0
   hold on;
   % Birth range range present in both cases
   by1 = max(byM(1, cS.iHSG), byM(1, cS.iCG));
   by2 = max(max(byM(:, cS.iHSG)), max(byM(:, cS.iCG)));
   
   for bYear = by1 : by2
      idxHS = find(byM(:, cS.iHSG) == bYear);
      idxCG = find(byM(:, cS.iCG) == bYear);
      plot(bYear,  cohDummyM(idxCG, cS.iCG) - cohDummyM(idxHS, cS.iHSG), 'o');
   end
   
   % Also show GRE scores
   if 0
      [yearV, ~, ~, greV] = sat_cpsbc(setNo);
      idxV = find(greV > 0);
      greV = greV(idxV) ./ 500;
      greV = greV - greV(1);
      plot(yearV(idxV) - 24,  greV, '-');
   end
   
   hold off;
   grid on;
   title('Cohort effect CG - HS');
   xlabel('Birth year');

   figFn = [cS.figDir,  'coh_effect_cg_hs'];
   save_fig_cpsbc(figFn, saveFigures, [], setNo)
end


end