function regr_earn_age_year_cpsbc(setNo)
% Regress log earnings on age and year dummies
%{
Dummies can be NaN when not enough observations
Especially for older workers
%}


%% Settings

fprintf('\nRegressing (log or median) earnings on age and year dummies\n\n');

cS = const_cpsbc(setNo);
% Min no of obs per [cohort, school] cell
minObs = 25;
ny = length(cS.yearV);

% Load mean log earnings by [age, school, year]
loadS = var_load_cpsbc(cS.vAgeSchoolYearStats, [], setNo);


%% Regressions
% Median and mean log earnings

for wageConcept = [cS.iLogMedian, cS.iMeanLog]
   if wageConcept == cS.iLogMedian
      logEarn_astM = log_lh(loadS.medianEarnM, cS.missVal);
      saveVarNo = cS.vEarnRegrAgeYearMedian;
   elseif wageConcept == cS.iMeanLog;
      logEarn_astM = loadS.meanLogEarnM;
      saveVarNo = cS.vEarnRegrAgeYearMeanLog;
   else
      error('Invalid');
   end

   outV = cell([cS.nSchool, 1]);

   for iSchool = 1 : cS.nSchool
      fprintf('\nSchool level %s \n', cS.sLabelV{iSchool});
      regrS.iSchool = iSchool;

      % Age range to use (add some years b/c the last dummies turn out NaN -- why?)
      ageV = (cS.ageWorkStart_sV(iSchool)-1) : (cS.ageWorkLast + 2);
      nAge = length(ageV);


      % *** Construct regressors

      % Mean log or median earnings
      logEarn_atM = squeeze(logEarn_astM(ageV, iSchool, :));
      nObs_atM = squeeze(loadS.nObsM(ageV, iSchool, :));

      age_atM = ageV(:) * ones([1, ny]);
      if ~isequal(size(age_atM), size(logEarn_atM))
         error('Invalid');
      end

      year_atM = ones([nAge,1]) * cS.yearV(:)';
      if ~isequal(size(age_atM), size(year_atM))
         error('Invalid');
      end

      % Valid observations
      valid_atM = (logEarn_atM ~= cS.missVal)  &  (nObs_atM >= minObs);

      vIdxV = find(valid_atM == 1);
      fprintf('  No of observations: %i \n',  length(vIdxV));
      if length(vIdxV) < 50
         error('Too few obs');
      end

      % **** Linear model

      mdl = fitlm([age_atM(vIdxV), year_atM(vIdxV)], logEarn_atM(vIdxV), ...
         'CategoricalVars', [1 2], 'Weights', sqrt(nObs_atM(vIdxV)));

      % Extract age and year coefficients
      %  Meaningless scales
      regrS.ageValueV = ageV(:);
      regrS.ageDummyV = feval(mdl, [regrS.ageValueV(:), 2000 .* ones([nAge,1])]);
      regrS.yearValueV = cS.yearV(:);
      regrS.yearDummyV = feval(mdl, [50 .* ones([ny,1]), regrS.yearValueV]);

      outV{iSchool} = regrS;
   end


   var_save_cpsbc(outV, saveVarNo, [], setNo);
end

end