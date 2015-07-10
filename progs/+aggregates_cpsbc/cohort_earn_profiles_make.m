function saveS = cohort_earn_profiles_make(bYearV, wageConcept, setNo)
% Construct cohort log earnings profiles
%{
Start with means by [age, school, cohort]
Fit a quartic to each
Extend using the common age profile estimated for all cohorts (given s)

Compute present value of lifetime earnings by [s, c]
%}

cS = const_cpsbc(setNo);
nCohorts = length(bYearV);

%% Load

% Raw earnings
byAgeV = cS.fltAgeMin : cS.fltAgeMax;
byS = byear_school_age_stats_cpsbc(bYearV, bYearV, byAgeV, setNo);

if wageConcept == cS.iLogMedian
   % Regression results: log wage on [age, school, year]
   loadV = var_load_cpsbc(cS.vEarnRegrAgeYearMedian, [], setNo);
   rawEarn_csaM = log_lh(byS.medianEarnM, cS.missVal);  
   %saveVarNo = cS.vCohortEarnProfilesMedian;
elseif wageConcept == cS.iMeanLog
   % Regression results
   loadV = var_load_cpsbc(cS.vEarnRegrAgeYearMeanLog, [], setNo);
   rawEarn_csaM = byS.meanLogEarnM;
   %saveVarNo = cS.vCohortEarnProfilesMeanLog;
else
   error('Invalid');
end


%% Make cohort profiles

saveS.bYearV = bYearV;
saveS.logEarn_ascM = repmat(cS.missVal, [cS.ageWorkLast, cS.nSchool, nCohorts]);
% Raw data; no smoothing or interpolation
saveS.logRawEarn_ascM = repmat(cS.missVal, [cS.ageWorkLast, cS.nSchool, nCohorts]);

for iSchool = 1 : cS.nSchool
   regrS = loadV{iSchool};
   % Ages to fill for this school group
   sAgeV = (cS.ageWorkStart_sV(iSchool) : cS.ageWorkLast)';
   
   % Regression profile by sAgeV
   idxV = sAgeV - regrS.ageValueV(1) + 1;
   if ~isequal(sAgeV, regrS.ageValueV(idxV))
      error('Invalid');
   end
   regrEarnV = regrS.ageDummyV(idxV);
   %  Values can be NaN towards the end
   %  In that case: set to last non-nan value
   regrEarnV = vector_lh.extrapolate(regrEarnV, cS.dbg);
   validateattributes(regrEarnV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real'})
   
   for iCohort = 1 : nCohorts
      % Raw earnings data (by sAgeV)
      rawEarnV = rawEarn_csaM(iCohort, iSchool, sAgeV);
      rawEarnV = rawEarnV(:);
      saveS.logRawEarn_ascM(sAgeV, iSchool, iCohort) = rawEarnV;
      
      % Which ages have data?
      rawIdxV = find(rawEarnV ~= cS.missVal);
      
      % Smooth ages with data
      smoothEarnV = smooth(rawIdxV, rawEarnV(rawIdxV), 'lowess');
      validateattributes(smoothEarnV(:), {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
         'size', [length(rawIdxV), 1]})
      
      % Interpolate missing values that are interior, if needed
      if ~isequal(rawIdxV(:), (rawIdxV(1) : rawIdxV(end))')
         smoothEarnV = interp1(rawIdxV, smoothEarnV, (rawIdxV(1) : rawIdxV(end)), 'linear');
         rawIdxV = rawIdxV(1) : rawIdxV(end);
      end
         
      logEarnV = nan(size(sAgeV));
      logEarnV(rawIdxV) = smoothEarnV;
      
      % Extrapolate
      logEarnV = vector_lh.splice(logEarnV, regrEarnV, 5, cS.dbg);
%       if rawIdxV(1) > 1
%          % Fill in at the start
%          idx1 = rawIdxV(1);
%          logEarnV(1 : idx1) = regrEarnV(1 : idx1) - regrEarnV(idx1) + logEarnV(idx1);
%       end
%       
%       if rawIdxV(end) < length(sAgeV)
%          % Fill in at the start
%          idx1 = rawIdxV(end);
%          T = length(sAgeV);
%          logEarnV(idx1 : T) = regrEarnV(idx1 : T) - regrEarnV(idx1) + logEarnV(idx1);
%       end
      
      if cS.dbg > 10
         validateattributes(logEarnV, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
            'size', size(sAgeV)})
      end
      
      % Save the smoothed actual data
      saveS.logEarn_ascM(sAgeV,iSchool,iCohort) = logEarnV;
   end
end

validateattributes(saveS.logEarn_ascM, {'double'}, {'finite', 'nonnan', 'nonempty', 'real', ...
   'size', [cS.ageWorkLast, cS.nSchool, nCohorts]})


%% Present value of lifetime earnings
% Discounted to age 1

saveS.pvEarn_scM = nan([cS.nSchool, nCohorts]);
% Discount to this age
age1 = cS.ageWorkStart_sV(1);
% Interest rate
R = 1.04;   % hard coded +++
discFactorV = (1/R) .^ (0 : (cS.ageWorkLast - age1))';

for iCohort = 1 : nCohorts
   for iSchool = 1 : cS.nSchool
      % Earnings by phys age
      earnV = zeros([cS.ageWorkLast, 1]);
      workAgeV = cS.ageWorkStart_sV(iSchool) : cS.ageWorkLast;
      earnV(workAgeV) = exp(saveS.logEarn_ascM(workAgeV, iSchool, iCohort));
      validateattributes(earnV(workAgeV), {'double'}, {'finite', 'nonnan', 'nonempty', 'real', 'positive'})
      % Present value, discounted to age1
      saveS.pvEarn_scM(iSchool, iCohort) = sum(earnV(age1 : cS.ageWorkLast) .* discFactorV);
   end
end


%% Save

% var_save_cpsbc(saveS, saveVarNo, [], setNo);


end