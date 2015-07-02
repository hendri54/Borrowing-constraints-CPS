function saveS = wage_regr3_cpsbc(setNo)
% Run EARNINGS regression on cohort dummies, age dummies, and unempl rate
%{
% OUT
%  age dummies, by [age, school]

% A cohort's "predicted" profile is given by
%  betaConstV(iSchool) + cohDummyM(iCoh, iSchool) + ageDummyM(ageV,
%  iSchool)
%  + yearEffectM(yrIdxV, iSchool)
   where year effects are beta * unemployment rate(t)

% Checked: 2013-sep-17
%}
% -------------------------------------------------------

cS = const_cpsbc(setNo);

rAlpha = 0.05;
% Min no of obs per [cohort, school, year] cell
minObs = 50;
ny = length(cS.yearV);
% Work start age by school group (incl HSD)
startAgeV = [cS.workStartAgeV(1), cS.workStartAgeV];

%useYearEffects = 01;

% Load mean log earnings by [age, school, year]
% For comparison
loadS = var_load_cpsbc(cS.vAgeSchoolYearStats, [], setNo);

% Load unemployment rate
ueS = var_load_cpsbc(cS.vUnemplRate, [], setNo);


% Save birth years and cohort dummies for each school group
saveS.byV = cS.wageRegrCohortV;
nBy = length(saveS.byV);
saveS.cohDummyM = repmat(cS.missVal, [nBy, cS.nSchool]);
% Age dummies, indexed by [age, school]
saveS.ageDummyM = repmat(cS.missVal, [100, cS.nSchool]);

% Year effects = unempl rate * beta
saveS.yearEffectM = repmat(cS.missVal, [ny, cS.nSchool]);

% Regression coefficients
saveS.betaConstV = zeros([cS.nSchool, 1]);
saveS.betaUnemplV = zeros([cS.nSchool, 1]);



for iSchool = 1 : cS.nSchool
   % Age range to use
   ageV = startAgeV(iSchool) : min(75, cS.fltAgeMax);

   nAge = length(ageV);
   

   % Mean log EARNINGS by [age, year]
   % Only keep selected ages
   meanLogEarnM = squeeze(loadS.meanLogEarnM(ageV, iSchool, :));
   nObsM = squeeze(loadS.nObsM(ageV, iSchool, :));


   % ***************  Construct regressors

   nObs = nAge * ny;
   % Mean log earnings
   yV = zeros([nObs, 1]);
   nObsV = zeros([nObs, 1]);
   byDummyM = zeros([nObs, nBy]);
   ageDummyM = zeros([nObs, ageV(end)]);
   ueRateV = zeros([nObs, 1]);
   %experV = zeros([nObs, 1]); 

   % Highest row populated
   ir = 0;
   for iy = 1 : ny
      year1 = cS.yearV(iy);
      
      for iAge = 1 : nAge
         age1 = ageV(iAge);
         % Birth year
         bYear = year1 - age1;
         wage = meanLogEarnM(iAge, iy);
         
         if wage ~= cS.missVal  &&  nObsM(iAge, iy) >= minObs  &&  bYear >= saveS.byV(1)  &&  bYear <= saveS.byV(nBy)
            % Add an observation
            ir = ir + 1;
            yV(ir) = wage;
            nObsV(ir) = nObsM(iAge,iy);
            % yrDummyM(ir, iy) = 1;

            % Birth year dummies
            byIdx = find(bYear == saveS.byV);
            if length(byIdx) == 1
               byDummyM(ir, byIdx) = 1;
            else
               disp('Unexpected birth year');
               keyboard;
            end
            
            % Age dummy
            ageDummyM(ir, age1) = 1;
            
            % Uemployment rate
            ueRateV(ir) = ueS.unemplV(ueS.yearV == year1);


            % Experience, relative to first age in range
            % Start at 1, so we don't have trouble with matrix indexing
            % experV(ir) = (age1 - ageV(1) + 1) .* 0.1;
            
            %if age1 == 60  &&  iy > 10
            %   keyboard;
            %end
         end
      end
   end % for iy

   % No of rows
   nr = ir;
   yV = yV(1 : nr);
   %yrDummyM = yrDummyM(1:nr, :);
   nObsV = nObsV(1:nr);
   %experV = experV(1 : nr);
   byDummyM = byDummyM(1 : nr, :);
   ageDummyM = ageDummyM(1 : nr, :);
   ueRateV = ueRateV(1 : nr);
   fprintf('No of obs: %i \n', nr);
   
   if any(ueRateV <= 0)  ||  any(ueRateV > 20)
      disp('Invalid unempl rates');
      keyboard;
   end

   
   % Find used year dummies
   %ydIdxV = find(max(yrDummyM) > 0.5);
   bdIdxV = find(max(byDummyM) > 0.5);
   adIdxV = find(max(ageDummyM) > 0.5);
   
   % Drop default category
   bdDefault = bdIdxV(10);
   bdIdxV(10) = [];
   adDefault = adIdxV(10);
   adIdxV(10) = [];
   
   
   % ***********  Regression
   
   iConst = 1;
   xM = ones([nr, 1]);
   
   iUnempl = cols(xM) + 1;
   xM = [xM, ueRateV];
   
   if 1
      iByDummyV = cols(xM) + (1 : length(bdIdxV));
      xM  = [xM, byDummyM(:, bdIdxV)];
   end
   if 1
      iAgeDummyV = cols(xM) + (1 : length(adIdxV));
      xM  = [xM, ageDummyM(:, adIdxV)];
   end
   %if useYearEffects == 1
   %   iYrDummyV = cols(xM) + (1 : length(ydIdxV) - 1);
   %   xM = [xM, yrDummyM(:, ydIdxV(2 : end))];
   %end
   %if useExper
   %   iExperV = cols(xM) + (1 : 3);
   %   xM = [xM, experV .^ 2, experV .^ 3, experV .^ 4];
   %end
   
   rsS = lsq_weighted_lh(yV, xM, sqrt(nObsV), rAlpha, cS.dbg);

   % Construct residual wages
   %     net of year / cohort effects
   %residV = yV - xM * rsS.betaV;
   
   % Unravel coefficients
   %if useYearEffects
   %   yrDummyV = repmat(cS.missVal, [ny, 1]);
   %   yrDummyV(ydIdxV(2:end)) = rsS.betaV(iYrDummyV);
   %   yrDummyV(ydIdxV(1)) = 0;
   %   saveS.yearDummyM(:, iSchool) = yrDummyV;
   %end
   
   % Save birth years and dummies
   saveS.cohDummyM(bdIdxV, iSchool) = rsS.betaV(iByDummyV);
   saveS.cohDummyM(bdDefault, iSchool) = 0;

   saveS.ageDummyM(adIdxV, iSchool) = rsS.betaV(iAgeDummyV);
   saveS.ageDummyM(adDefault, iSchool) = 0;
   

   % Save regr coefficients
   saveS.betaConstV(iSchool) = rsS.betaV(iConst);
   saveS.betaUnemplV(iSchool) = rsS.betaV(iUnempl);

   % Construct year effects
   yrIdxV = find(ueS.yearV == cS.yearV(1)) : find(ueS.yearV == cS.yearV(end));
   saveS.yearEffectM(:, iSchool) = rsS.betaV(iUnempl) .* ueS.unemplV(yrIdxV);
   
end % iSchool



end