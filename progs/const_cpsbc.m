% Returns values of constants
classdef const_cpsbc < handle
   
properties
   setName  char
   dbg  uint16 = 111
end


properties (Constant)
   % Variable codes

   missVal = -9191;

   male = 1;
   female = 2;
   both = 3;
   sexStrV = {'men', 'women', 'both'};

   iHSD = 1;
   iHSG = 2;
   iCD = 3;
   iCG = 4;
   nSchool = 4;
   sLabelV = {'HSD', 'HSG', 'CD', 'CG'};
   

   % Default parameters: Demographics, Preferences

   % College lasts this many periods
   collLength = 4;

   % Cohorts modeled
   bYearV = [1915, 1942, 1961, 1979]';

   % Age at model age 1
   age1 = 18;

   % % Work start ages (for present values)
   % % Use first possible year of work start for each school group
   % cS.ageWorkStart_sV = [0; 2; cS.collLength] + cS.age1;

   % Start early, just in case
   ageWorkStart_sV = [17, 18, 20, 22]';

   % Last year of work to include
   %  Higher yields missing values in age year stats
   ageWorkLast = 65;

   
   
   % Base year for prices
   cpiBaseYear = 2010;
   % Data years
   %  but earnings are for previous year
   yearV = (1965 : 2015)';

   % Variables to be imported
   importVarV = ["year", "age", "race", "sex", "gq",   "empstat", "labforce", "classwkr", ...
      "incbus", "incwage",  "ahrsworkt",  "wkswork1",  "wkswork2",  ...
      "educ", "higrade", "educ99", "schlcoll",  "asecwt"];
   
   % Weight variable to use
   weightVar = 'asecwt';
end


properties (SetAccess = private)
   cohYearV  uint16
   wageYearV  uint16
   
   % Filter settings
   fltS  import_cpsbc.Filter
end


methods
   

function cS = const_cpsbc(setName)

   cS.setName = setName;

   % Year to be displayed for each cohort (high school graduation)
   cS.cohYearV = cS.bYearV + 18;

   % Years with wage data
   cS.wageYearV = max(cS.yearV - 1, 1964);
   
   cS.fltS = import_cpsbc.Filter;
end

end

end




% %%  Variables
% 
% % ***********  Imported cps variables
% % varNo 1 to 99, by ind
% 
% % CPS variable names
% cS.cpsVarNameV = cell([20, 1]);
% 
% cS.vWeight = 13;
% cS.cpsVarNameV{cS.vWeight} = 'wtsupp';
% 
% % Age - in interview year
% cS.vAge = 1;
% cS.cpsVarNameV{cS.vAge} = 'age';
% 
% cS.vSex = 2;
% cS.cpsVarNameV{cS.vSex} = 'sex';
% 
% cS.vRace = 3;
% cS.cpsVarNameV{cS.vRace} = 'race';
% 
% %cS.vGQ = 4;
% %cS.cpsVarNameV{cS.vGQ} = 'gq';
% 
% % Type of employment, not recoded
% cS.vClassWkr = 4;
% cS.cpsVarNameV{cS.vClassWkr} = 'classwkr';
% 
% % Is person in labor force? 1 = yes, 0 = no
% cS.vLabForce = -99;
% %cS.cpsVarNameV{cS.vLabForce} = 'labforce';
% 
% % Is person working? 1 = yes, 0 = no
% cS.vEmpStat = -99;
% %cS.cpsVarNameV{cS.vEmpStat} = 'empstat';
% 
% % Hours per week. No need to recode.
% cS.vHoursWeek = 7;
% cS.cpsVarNameV{cS.vHoursWeek} = 'hrswork';
% 
% % Weeks per year. Recoded.
% cS.vWeeksYear = 8;
% cS.cpsVarNameV{cS.vWeeksYear} = 'wkswork2';
% 
% 
% % Income: wage and salary
% %  saved for year it was reported, not when it was earned
% cS.vIncWage = 12;
% cS.cpsVarNameV{cS.vIncWage} = 'incwage';
% % Business income
% cS.vIncBus = 14;
% cS.cpsVarNameV{cS.vIncBus} = 'incbus';
% 
% 
% % Schooling
% cS.vHigrade = 9;
% cS.cpsVarNameV{cS.vHigrade} = 'higrade';
% 
% cS.vEduc99 = 10;
% cS.cpsVarNameV{cS.vEduc99} = 'educ99';
% 
% cS.vEduc = 11;
% cS.cpsVarNameV{cS.vEduc} = 'educ';
% 
% 
% %%  Generated cps variables
% % by ind, varNo 101 - 199
% 
% cS.vFilter = 101;
% 
% % Schooling
% % Years of school
% cS.vSchoolYears = 102;
% % School group: HSD, HSG, CD, CG
% cS.vSchoolGroup = 103;
% 
% 
% % Income
% % Real wage per week. Outliers dropped.
% cS.vRealWeeklyWage = 120;
% 
% % Is person working (earning more than fixed real annual earnings?)
% %  either bus or wage income
% % cS.vIsWorking = 121;
% 
% % Real annual earnings, incl share of bus income
% cS.vRealAnnualEarn = 122;
% 
% % Test variable
% cS.vTest = 199;
% 
% 
% 
% %%  Summary variables
% % No year dim. varNo = 201 : 300
% 
% % Wage stats by [age, school, year]
% %  Records wages in years they were earned
% cS.vAgeSchoolYearStats = 201;
% 
% % Regress log earnings on age and year dummies
% cS.vEarnRegrAgeYearMedian = 202;
% cS.vEarnRegrAgeYearMeanLog = 203;
% 
% % Cohort earnings profiles (constant dollars)
% cS.vCohortEarnProfilesMedian = 204;
% % Mean log profile is conditional on working
% cS.vCohortEarnProfilesMeanLog = 205;
% 
% % Aggregate stats by year
% cS.vAggrStats = 206;
% 
% % Preamble data
% cS.vPreambleData = 207;
% 
% % Year effects from regressing mean log wage on year
% % cS.vYearEffects = 202;
% 
% % Unemployment rate, wide range of years
% % cS.vUnemplRate = 203;
% 
