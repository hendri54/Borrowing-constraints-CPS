function cS = const_cpsbc(setNo)
% Returns values of constants
%{
Requires model1 constants + shared dir
Only specific constants are copied from bc1
%}
% -----------------------------------------

cS.dbg = 111;
cS.setNo = setNo;

cS.setDefault = 1;


%% Variable codes

cS.missVal = -9191;

cS.male = 1;
cS.female = 2;
cS.both = 3;
cS.sexStrV = {'men', 'women', 'both'};

cS.iHSD = 1;
cS.iHSG = 2;
cS.iCD = 3;
cS.iCG = 4;
cS.nSchool = 4;
cS.sLabelV = {'HSD', 'HSG', 'CD', 'CG'};



%% Default parameters: Demographics, Preferences

% College lasts this many periods
cS.collLength = 4;

% Cohorts modeled
cS.bYearV = [1915, 1942, 1961, 1979]';
% Year to be displayed for each cohort (high school graduation)
cS.cohYearV = cS.bYearV + 18;

% Age at model age 1
cS.age1 = 18;

% % Work start ages (for present values)
% % Use first possible year of work start for each school group
% cS.ageWorkStart_sV = [0; 2; cS.collLength] + cS.age1;

% Start early, just in case
cS.ageWorkStart_sV = [17, 18, 20, 22];

% Last year of work to include
%  Higher yields missing values in age year stats
cS.ageWorkLast = 65;



%% Constants

% % Directories
% dirS = helper_cpsbc.directories(setNo);
% cS = struct_lh.merge(cS, dirS, cS.dbg);
% clear dirS;

% Base year for prices
cS.cpiBaseYear = 2010;


% Data years
%  but earnings are for previous year
cS.yearV = 1964 : 2010;
% Years with wage data
cS.wageYearV = max(cS.yearV - 1, 1964);




%%  Filter

cS.fltSex = cS.male;

cS.fltRace = [];

% Age in PREVIOUS year (where earnings observed)
cS.fltAgeMin = 16;
cS.fltAgeMax = 75;

% Real annual earning to be counted as working
%  included in mean log wage calc etc
cS.minRealEarn = 12 * 300;    % +++++

% Count this fraction of bus income
cS.fracBusInc = 0;

% Min hours worked last week
cS.fltHoursMin = 30;
cS.fltWeeksMin = 30;


% ******  Wage regressions

% Wages outside of this many times the median are deleted
cS.wageMinFactor = 0.05;
cS.wageMaxFactor = 100;


% Which earnings concept to use in wage regressions?
cS.iLogMedian = 23;
cS.iMeanLog = 90;
% cS.wageRegrEarnConcept = cS.iMedian;

% Age range for aggregate stats (such as years of schooling)
cS.aggrAgeRangeV = 30 : 50;




%%  Variables

% ***********  Imported cps variables
% varNo 1 to 99, by ind

% CPS variable names
cS.cpsVarNameV = cell([20, 1]);

cS.vWeight = 13;
cS.cpsVarNameV{cS.vWeight} = 'wtsupp';

% Age - in interview year
cS.vAge = 1;
cS.cpsVarNameV{cS.vAge} = 'age';

cS.vSex = 2;
cS.cpsVarNameV{cS.vSex} = 'sex';

cS.vRace = 3;
cS.cpsVarNameV{cS.vRace} = 'race';

%cS.vGQ = 4;
%cS.cpsVarNameV{cS.vGQ} = 'gq';

% Type of employment, not recoded
cS.vClassWkr = 4;
cS.cpsVarNameV{cS.vClassWkr} = 'classwkr';

% Is person in labor force? 1 = yes, 0 = no
cS.vLabForce = -99;
%cS.cpsVarNameV{cS.vLabForce} = 'labforce';

% Is person working? 1 = yes, 0 = no
cS.vEmpStat = -99;
%cS.cpsVarNameV{cS.vEmpStat} = 'empstat';

% Hours per week. No need to recode.
cS.vHoursWeek = 7;
cS.cpsVarNameV{cS.vHoursWeek} = 'hrswork';

% Weeks per year. Recoded.
cS.vWeeksYear = 8;
cS.cpsVarNameV{cS.vWeeksYear} = 'wkswork2';


% Income: wage and salary
%  saved for year it was reported, not when it was earned
cS.vIncWage = 12;
cS.cpsVarNameV{cS.vIncWage} = 'incwage';
% Business income
cS.vIncBus = 14;
cS.cpsVarNameV{cS.vIncBus} = 'incbus';


% Schooling
cS.vHigrade = 9;
cS.cpsVarNameV{cS.vHigrade} = 'higrade';

cS.vEduc99 = 10;
cS.cpsVarNameV{cS.vEduc99} = 'educ99';

cS.vEduc = 11;
cS.cpsVarNameV{cS.vEduc} = 'educ';


%%  Generated cps variables
% by ind, varNo 101 - 199

cS.vFilter = 101;

% Schooling
% Years of school
cS.vSchoolYears = 102;
% School group: HSD, HSG, CD, CG
cS.vSchoolGroup = 103;


% Income
% Real wage per week. Outliers dropped.
cS.vRealWeeklyWage = 120;

% Is person working (earning more than fixed real annual earnings?)
%  either bus or wage income
% cS.vIsWorking = 121;

% Real annual earnings, incl share of bus income
cS.vRealAnnualEarn = 122;

% Test variable
cS.vTest = 199;



%%  Summary variables
% No year dim. varNo = 201 : 300

% Wage stats by [age, school, year]
%  Records wages in years they were earned
cS.vAgeSchoolYearStats = 201;

% Regress log earnings on age and year dummies
cS.vEarnRegrAgeYearMedian = 202;
cS.vEarnRegrAgeYearMeanLog = 203;

% Cohort earnings profiles (constant dollars)
cS.vCohortEarnProfilesMedian = 204;
% Mean log profile is conditional on working
cS.vCohortEarnProfilesMeanLog = 205;

% Aggregate stats by year
cS.vAggrStats = 206;

% Preamble data
cS.vPreambleData = 207;

% Year effects from regressing mean log wage on year
% cS.vYearEffects = 202;

% Unemployment rate, wide range of years
% cS.vUnemplRate = 203;


end
