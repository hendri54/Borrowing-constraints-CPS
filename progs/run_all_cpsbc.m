function run_all_cpsbc(setNo)
% run everything in sequence
% ----------------------------------

cS = const_cpsbc(setNo);
yearV = cS.yearV;
saveFigures = 1;

% Make dir for new experiment
% mkdir_cpsbc(setNo);

% External variable: unemployment rate
% unempl_rate_cpsbc(saveFigures, setNo);


%% Get cps data

% ****  Import cps variables
if 01
   for year1 = yearV(:)'
      % Filter 
      filter_cpsbc(year1, setNo);

      % Import
      import_cpsbc(year1, setNo);
   end
   return;
end


% ****  Create derived individual variables
   
if 0
   for year1 = yearV(:)'
      school_create_cpsbc(year1, setNo);   
   end
   
   wage_create_cpsbc(yearV, setNo);
   diagnostics_cpsbc.data_report(yearV, setNo);
   return;
end % for year1


%%  Summary variables

% Stats by [age, school, year]
age_school_year_stats_cpsbc(setNo);

% Estimate earnings regressions, using median and mean log
regr_earn_age_year_cpsbc(setNo);
for wageConcept = [cS.iLogMedian, cS.iMeanLog]
   regr_earn_age_year_show_cpsbc(wageConcept, saveFigures, setNo);
end

% Construct cohort earnings profiles
% smoothed and extrapolated
aggregates_cpsbc.cohort_earn_profiles(setNo);


% Time series of aggregate stats
aggr_stats_cpsbc(setNo);

% Write preamble for paper
preamble_cpsbc(setNo);


%%  Diagnostics
if 0
   % Check incwage
   incwage_check_cpsbc(cS.yearV, setNo);
   % Wage stats for fixed age range
   %wage_fixed_age_cpsbc(ageLb, ageUb, sexCode, setNo)
   % Schooling by year
   school_by_year_show_cpsbc(saveFigures, setNo);
   % Wages
   wage_by_year_show_cpsbc(cS.male, 1, setNo);
   % Schooling by cohort
   cohort_school_show_cpsbc(saveFigures, setNo)
   % Show constructed earnings stats, by age, school, year
   earn_show_cpsbc(saveFigures, setNo);
   % Show earnings of a given cohort
   % [medianV, meanV, stdV, nObsV] = cohort_earn_direct_cpsbc(bYear, setNo);
end


% % *******  Results
% if 01
%    % Cohort wage profiles
%    cohort_wage_profiles_cpsbc(saveFigures, setNo);
%    % Wage regressions to show cohort specific age profiles
%    %wage_regr_cpsbc(saveFigures, setNo);
%    wage_regr3_show_cpsbc(saveFigures, setNo)
%    % College wage premium for selected cohorts
%    cohort_college_prem_cpsbc(saveFigures, setNo);
% end


end