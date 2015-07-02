function saveS = wage_regr2_cpsbc(setNo)
% Run EARNINGS regression on time dummies and a time
% invariant experience profile
%{
%}

%% Settings

cS = const_cpsbc(setNo);
dbg = cS.dbg;
rAlpha = 0.05;
% Min no of obs per [cohort, school] cell
minObs = 25;
ny = length(cS.yearV);

useCohortEffects = 0;
useYearEffects = 01;
% Use experience (higher order) in 1st stage regression?
%  Produces crazy year / cohort effects, but has almost no effects on
%  experience terms
   % +++++
useExper = 01;

% Load mean log earnings by [age, school, year]
% For comparison
loadS = var_load_cpsbc(cS.vAgeSchoolYearStats, [], setNo);


%% Regression for each school group

nBy = 80;
nx  = 50;

% Save birth years and cohort dummies for each school group
saveS.byM = zeros([nBy, cS.nSchool]);
saveS.cohDummyM = zeros([nBy, cS.nSchool]);
saveS.yearDummyM = zeros([ny, cS.nSchool]);

% Experience profile - net of time / cohort effects
%  by [experience, cohort, school]
saveS.expProfileM = repmat(cS.missVal, [nx, nBy, cS.nSchool]);
% Ages that go with these profiles
saveS.ageRangeM = repmat(cS.missVal,  [2, cS.nSchool]);
% Birth year ranges 
saveS.byRangeM  = repmat(cS.missVal,  [2, cS.nSchool]);

% Predicted experience profile - net of time / cohort effects
saveS.predExperProfileM = repmat(cS.missVal, [nx, cS.nSchool]);


for iSchool = 1 : cS.nSchool
   % Age range to use
   if iSchool == cS.iCG  ||  iSchool == cS.iCD
      ageV = 23 : 64;
   else
      ageV = 19 : 64;
   end
   nAge = length(ageV);
   saveS.ageRangeM(1, iSchool) = ageV(1);
   saveS.ageRangeM(2, iSchool) = ageV(end);


   % Range of birth years to keep
   byRangeV = (cS.yearV(1) - 35) : (cS.yearV(end) - 35);
   nBy = length(byRangeV);
   saveS.byRangeM(:, iSchool) = [byRangeV(1); byRangeV(end)];
   

   % Mean log EARNINGS by [age, year]
   % Only keep selected ages
   meanLogWageM = squeeze(loadS.meanLogEarnM(ageV, iSchool, :));
   nObsM = squeeze(loadS.nObsM(ageV, iSchool, :));


   % ***************  Construct regressors

   nObs = nAge * ny;
   yrDummyM = zeros([nObs, ny]);
   % Mean log wage 
   yV = zeros([nObs, 1]);
   nObsV = zeros([nObs, 1]);
   byDummyM = zeros([nObs, nBy]);
   experV = zeros([nObs, 1]); 

   % Highest row populated
   ir = 0;
   for iy = 1 : ny
      year1 = cS.yearV(iy);
      
      for iAge = 1 : nAge
         age1 = ageV(iAge);
         % Birth year
         bYear = year1 - age1;
         wage = meanLogWageM(iAge, iy);
         
         if wage ~= cS.missVal  &&  nObsM(iAge, iy) >= minObs  &&  bYear >= byRangeV(1)  &&  bYear <= byRangeV(end)
            % Add an observation
            ir = ir + 1;
            yV(ir) = wage;
            nObsV(ir) = nObsM(iAge,iy);
            yrDummyM(ir, iy) = 1;

            % Birth year dummies
            byIdx = find(bYear == byRangeV);
            if length(byIdx) == 1
               byDummyM(ir, byIdx) = 1;
            else
               disp('Unexpected birth year');
               keyboard;
            end


            % Experience, relative to first age in range
            % Start at 1, so we don't have trouble with matrix indexing
            experV(ir) = (age1 - ageV(1) + 1) .* 0.1;
         end
      end
   end % for iy

   % No of rows
   nr = ir;
   yV = yV(1 : nr);
   yrDummyM = yrDummyM(1:nr, :);
   nObsV = nObsV(1:nr);
   experV = experV(1 : nr);
   byDummyM = byDummyM(1 : nr, :);

   
   % Find used year dummies
   ydIdxV = find(max(yrDummyM) > 0.5);
   bdIdxV = find(max(byDummyM) > 0.5);
   
   
   % ***********  Regression
   
   iConst = 1;
   xM = ones([nr, 1]);
   
   if useCohortEffects == 1
      iByDummyV = cols(xM) + (1 : length(bdIdxV) - 1);
      xM  = [xM, byDummyM(:, bdIdxV(2 : end))];
   end
   if useYearEffects == 1
      iYrDummyV = cols(xM) + (1 : length(ydIdxV) - 1);
      xM = [xM, yrDummyM(:, ydIdxV(2 : end))];
   end
   if useExper == 1
      iExperV = cols(xM) + (1 : 3);
      xM = [xM, experV .^ 2, experV .^ 3, experV .^ 4];
   end
   
   rsS = regress_lh.lsq_weighted_lh(yV, xM, sqrt(nObsV), rAlpha, dbg);

   % Construct residual wages
   %     net of year / cohort effects
   if useExper == 1
      rIdxV = 1 : cols(xM);
      rIdxV(iExperV) = [];
      residV = yV - xM(:, rIdxV) * rsS.betaV(rIdxV);
   else
      residV = yV - xM * rsS.betaV;
   end
   
   % Unravel coefficients
   if useYearEffects
      yrDummyV = repmat(cS.missVal, [ny, 1]);
      yrDummyV(ydIdxV(2:end)) = rsS.betaV(iYrDummyV);
      yrDummyV(ydIdxV(1)) = 0;
      saveS.yearDummyM(:, iSchool) = yrDummyV;
   end
   
   byDummyV = repmat(cS.missVal, [nBy, 1]);
   byDummyV(bdIdxV(2:end)) = rsS.betaV(iByDummyV);
   byDummyV(bdIdxV(1)) = 0;

   % Save birth years and dummies
   saveS.byM(1 : nBy, iSchool) = byRangeV;
   saveS.cohDummyM(1 : nBy, iSchool) = byDummyV;
   
   
   

   
   % ***********  Construct experience profile by cohort
   % net of year / cohort effects

   
   for i1 = 1 : nBy
      % Find obs for this cohort
      cIdxV = find(byDummyM(:, i1) == 1);
      if length(cIdxV) > 5
         %profileV = hpfilter(resid2V(cIdxV), 10);
         saveS.expProfileM(round(10 .* experV(cIdxV)), i1, iSchool) = residV(cIdxV);
      end
   end


   % **********  Regress on experience

   x3M = [ones([nr, 1]), experV, experV .^ 2, experV .^ 3, experV .^ 4];
   rsS = lsq_weighted_lh(residV, x3M, sqrt(nObsV), rAlpha, dbg);
   
   disp('Experience coefficients:');
   fprintf('%8.3f ',  rsS.betaV(2 : end));
   fprintf('\n');
   fprintf('(%7.3f)',  rsS.seBetaV(2:end));
   fprintf('\n')
   

   % These are residuals after taking out everything
   pred3V = x3M * rsS.betaV;
   resid3V = residV - pred3V;

   % Predicted exper profile
   nr4 = rows(saveS.predExperProfileM);
   experValueV = linspace(min(experV), max(experV), nr4)';
   x4M = [ones([nr4, 1]),  experValueV, experValueV .^ 2, experValueV .^ 3, experValueV .^ 4];
   predExperV = x4M * rsS.betaV;
   
   saveS.predExperProfileM(:, iSchool) = predExperV;
   
   
   % ***********  How well does the model fit?
   if 0
      optS.plot45 = 1;
      optS.Regress = 1;
      optS.plotRegr = 1;
      optS.weighted = 1;
      optS.wtV = sqrt(nObsV);
      optS.showRegr = 1;

      if saveFigures >= 0
         rsS = plot_xy_lh(yV, yV - resid3V, cS.missVal, optS, dbg);

         grid on;
         xlabel('Mean log earnings');
         title('Fitted mean log earnings');
         figFn = [cS.figDir,  'exp_profile_fit_', cS.schoolLabelV{iSchool}];
         save_fig_cpsbc(figFn, saveFigures, [], setNo)
      end
   end
end % iSchool


%%  Save


% Show cohort dummies college - HS
if saveFigures >= 0  &&  0
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
   if 01
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