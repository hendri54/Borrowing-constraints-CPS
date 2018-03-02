% Regress log wage or earnings on [age, year] dummies
%{
For one school groups
%}
classdef RegrEarnAgeYear < handle
   
properties (SetAccess = private)
   setName  char
   wageConcept  char
   iSchool  uint16
   
   minObs  uint16 = 25
   
   ageValueV  double
   ageDummyV  double
   yearValueV double
   yearDummyV double
end

methods
   %% Constructor
   function regrS = RegrEarnAgeYear(wageConcept, iSchool, setName)
      regrS.setName = setName;
      regrS.iSchool = iSchool;
      regrS.wageConcept = wageConcept;
   end
   
   
   %% Run regression
   function regress(regrS)
      cS = const_cpsbc(regrS.setName);
      ny = length(cS.yearV);
      % Age range to use (add some years b/c the last dummies turn out NaN -- why?)
      ageV = (cS.ageWorkStart_sV(regrS.iSchool)-1) : (cS.ageWorkLast + 2);
      nAge = length(ageV);

      loadS = var_load_cpsbc('AgeSchoolYearStats', [], regrS.setName);
      
      switch regrS.wageConcept
         case 'logMedian'
            logEarn_astM = log(loadS.medianEarnM);
         case 'meanLog'
            logEarn_astM = loadS.meanLogEarnM;
         otherwise
            error('invalid');
      end


      % *** Construct regressors

      % Mean log or median earnings
      logEarn_atM = squeeze(logEarn_astM(ageV, regrS.iSchool, :));
      nObs_atM = squeeze(loadS.nObsM(ageV, regrS.iSchool, :));

      age_atM = ageV(:) * ones([1, ny]);
      if ~isequal(size(age_atM), size(logEarn_atM))
         error('Invalid');
      end

      year_atM = ones([nAge,1]) * cS.yearV(:)';
      if ~isequal(size(age_atM), size(year_atM))
         error('Invalid');
      end

      % Valid observations
      valid_atM = ~isnan(logEarn_atM)  &  (nObs_atM >= regrS.minObs);

      vIdxV = find(valid_atM == 1);
      fprintf('  No of observations: %i \n',  length(vIdxV));
      if length(vIdxV) < 50
         error('Too few obs');
      end

      % **** Linear model

      mdl = fitlm([age_atM(vIdxV), year_atM(vIdxV)], logEarn_atM(vIdxV), ...
         'CategoricalVars', [1 2], 'Weights', sqrt(double(nObs_atM(vIdxV))));

      % Extract age and year coefficients
      %  Meaningless scales
      regrS.ageValueV = ageV(:);
      regrS.ageDummyV = feval(mdl, [regrS.ageValueV(:), 2000 .* ones([nAge,1])]);
      regrS.yearValueV = cS.yearV(:);
      regrS.yearDummyV = feval(mdl, [50 .* ones([ny,1]), regrS.yearValueV]);
   end
end

end