function cohort_earn_profiles(setNo)
% Make, save, show cohort earnings profiles
%{
For log median wages and mean log wages
For cohorts used in model and for all cohorts
%}

cS = const_cpsbc(setNo);
saveFigures = 1;

bYearV = cS.bYearV;
bYearV = cS.bYearV(1) : cS.bYearV(end);

for wageConcept = [cS.iLogMedian, cS.iMeanLog]
   if wageConcept == cS.iLogMedian
      % Regression results: log wage on [age, school, year]
      saveVarNo = cS.vCohortEarnProfilesMedian;
   elseif wageConcept == cS.iMeanLog
      % Regression results
      saveVarNo = cS.vCohortEarnProfilesMeanLog;
   else
      error('Invalid');
   end
   
   % Make profiles
   saveS = aggregates_cpsbc.cohort_earn_profiles_make(bYearV, wageConcept, setNo);
   if isequal(bYearV, cS.bYearV)
      % Save them
      var_save_cpsbc(saveS, saveVarNo, [], setNo);
      % Show them
      aggregates_cpsbc.cohort_earn_profiles_show(saveS, wageConcept, saveFigures, setNo);
   else
      % Show time path of present values of lifetime earnings
      aggregates_cpsbc.cohort_pvearn_show(saveS, wageConcept, saveFigures, setNo);
   end
end


end