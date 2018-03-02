% Matrix with all cps data
%{
Stored as a table; all years
Processed sequentially, creating new copies of the file as we go along ??
%}
classdef DataMatrix < handle
   
properties (SetAccess = private)
   setName  char
   
   dbg  uint16  = 111
end

methods
   function dmS = DataMatrix(setName)
      dmS.setName = setName;
   end
   
   %% Run import in sequence, starting from raw data
   %{
   Must run this in sequence because it sequentially modifies the data file
   %}
   function run_all(dmS)
      dirS = helper_cpsbc.directories(dmS.setName);
      diaryS = filesLH.DiaryFile(fullfile(dirS.outDir, 'import_log.txt'), 'new');
      dmS.import_raw_data;
      dmS.recode;
      dmS.filter;
      diaryS.close;
      diaryS.strip_formatting;
   end
   
   
   %% Make copy of raw data as table
   function import_raw_data(dmS)
      fprintf('\nImporting raw data \n');
      cS = const_cpsbc(dmS.setName);
      
      % Load the raw data file (which is never touched)
      dirS = helper_cpsbc.directories(dmS.setName);
      m = load(fullfile(dirS.rawDir, 'raw_data.mat'));
      m = dataset2table(m.st_dataset);
      fprintf('  %.0f k observations, %i variables \n',  size(m, 1) ./ 1e3, size(m, 2));
      dmS.save(m);
      
      % Variables not in table
      missVarV = setdiff(cellstr(cS.importVarV), m.Properties.VariableNames);
      if ~isempty(missVarV)
         fprintf('\nVariables not in dataset:  \n');
         for i1 = 1 : length(missVarV)
            fprintf('    %s', missVarV{i1});
         end
         fprintf('\n');
      end
      
      % Check that all expected variables are present in all years
      fprintf('\nNumber of observations in each year: \n');
      varNameV = intersect(cellstr(cS.importVarV), m.Properties.VariableNames);
      dmS.nobs_year_var(m, varNameV);
   end
   
   
   %% Load the data matrix
   function m = load(dmS)
      dirS = helper_cpsbc.directories(dmS.setName);
      m = load(fullfile(dirS.matDir, 'raw_data.mat'));
      m = m.m;
   end
   
   
   %% Save the data matrix
   function save(dmS, m)
      dirS = helper_cpsbc.directories(dmS.setName);
      save(fullfile(dirS.matDir, 'raw_data.mat'), 'm');
   end
   
   
   %% Recode variables and make derived variables needed for filtering
   function recode(dmS)
      fprintf('\nRecoding and making derived variables\n');
      m = dmS.load;
      cS = const_cpsbc(dmS.setName);
      
      % Sex
      m.sexMale = (m.sex == 1);
      m.sex = [];
      
      % Race
      m.raceWhite = (m.race == 100);
      m.race = [];
      
      % IncWage recode
      vS = vars_cpsbc.incwage;
      m.earnings = vS.recode(m.incwage, m.year);
      m.incwage = [];
      
      % Business income
      vS = vars_cpsbc.incbus;
      m.incbus = vS.recode(m.incbus, m.year);
      
      % Wkswork2
      m.weeksWorked = recode_cpsbc.wkswork2(m.wkswork2);      
      m.wkswork2 = [];
      
      % Education
      [m.schoolCl, m.yrSchool] = import_cpsbc.school_create(m.educ99, m.higrade, m.year, cS);
      
      % Weight
      m.weight = m.(cS.weightVar);
      
      % Real weekly wage
      fprintf('    Making weekly wage\n');
      m.wage = import_cpsbc.wage_create(m, cS);
      
      dmS.save(m);
      
      fprintf('    Years with data: %i - %i \n',  min(m.year), max(m.year));
      
      fprintf('    Recoding done\n');
   end
   
   
   %% Filter
   %{
   Requires derived variables
   %}
   function filter(dmS)
      fprintf('\nFiltering\n');
      cS = const_cpsbc(dmS.setName);
      nfS = formatLH.NumberFormat;
      m = dmS.load;
      
      validV = true(size(m, 1), 1);
      disp(['N before filter:     ',  nfS.format(sum(validV))]);
      
      % Year filter
      validV(m.year < cS.yearV(1)  |  m.year > cS.yearV(end)) = false;
      dmS.filter_results('year', validV, m.year);
      
      % Sex filter
      if ~isempty(cS.fltS.sex)
         switch cS.fltS.sex
            case 'male'
               validV(~m.sexMale) = false;
            otherwise
               error('Invalid');
         end
      
         dmS.filter_results('sex', validV, m.year);
      end


      % Race
      if ~isempty(cS.fltS.race)
         switch cS.fltS.race
            case 'white'
               validV(~mS.raceWhite) = false;
            otherwise
               error('Invalid');
         end
         dmS.filter_results('race', validV, m.year);
      end


      % Age  -  keep in mind that we want age last year when earnings were
      % observed
      validV(m.age < (cS.fltS.ageMin + 1) | m.age > (cS.fltS.ageMax + 1)) = false;
      dmS.filter_results('age', validV, m.year);

      % No in gq (not available before 1968)
      validV(m.gq ~= 1  &  m.year >= 1968) = false;
      dmS.filter_results('gq', validV, m.year);
      
      % Employment status: at work
      validV(m.empstat ~= 10) = false;
      dmS.filter_results('empstat', validV, m.year);
      
      % In the labor force
      validV(m.labforce ~= 2) = false;
      dmS.filter_results('labforce', validV, m.year);
      
      % Wage and salary workers only (not armed forces [26])
      validV(m.classwkr < 20  |  m.classwkr > 28) = false;
      validV(m.classwkr == 26) = false;
      dmS.filter_results('classwkr', validV, m.year);
      
      % Positive earnings
      % lb = 1: keep only positive
      validV(~(m.earnings > 0)) = false;
      dmS.filter_results('earnings', validV, m.year);
      
      % Can compute wage per week
      validV(~(m.wage > 0)) = false;
      dmS.filter_results('wage', validV, m.year);
      
      % Hours worked
      validV(m.ahrsworkt < cS.fltS.hoursMin  |  m.ahrsworkt > cS.fltS.hoursMax) = false;
      dmS.filter_results('hours', validV, m.year);

      % Weeks worked
      validV(m.weeksWorked < cS.fltS.weeksMin) = false;
      dmS.filter_results('weeks', validV, m.year);

      % Schooling
      validV(~(m.yrSchool >= 0)  |  ~(m.schoolCl > 0)) = false;
      dmS.filter_results('school', validV, m.year);
      
      % In school filter (many not in universe)
      % Not used b/c not available before 1990
%       validV(m.schlcoll > 0  &  m.schlcoll < 5) = false;
%       disp(['N after in school filter:  ',  nfS.format(sum(validV))]);
      
      % Positive weight
      validV(~(m.weight > 0)) = false;
      dmS.filter_results('weight', validV, m.year);
      
      % Filter out wage outliers
      validWageV = import_cpsbc.wage_outliers(m.wage, m.weight, m.year, cS);
      validV(~validWageV) = false;
      dmS.filter_results('wage outlier', validV, m.year);

      m(~validV,:) = [];
      
      dmS.save(m);
      
      % Check that all years are present. The last imported year has no data b/c wages are for the
      % previous year
      assert(isequal(unique(m.year),  cS.yearV(1 : (end-1))),  'Not all years have data');
   end
end


methods (Static)
   %% No of observations by [year, variable]
   function nobs_year_var(m, varNameV)
      grpstats(m, 'year', @(x) sum(~isnan(x)),  'DataVars', varNameV)
%       %yearValueV = unique(m.year(m.year > 0));
%       ny = length(yearValueV);
%       nVar = length(varNameV);
%       for iy = 1 : ny
%          yIdxV = find(m.year == yearValueV(iy));
%          for iVar = 1 : nVar
%             nObs_yvM(iy,iVar) = sum(~isnan(m.(varName)(yIdxV)));
%          end
%       end
      
   end
   
   
   % Show results after each filter
   function filter_results(varName, validV, yearV)
      nfS = formatLH.NumberFormat;
      disp(['N after ', varName, ' filter:  ',  nfS.format(sum(validV))]);
      fprintf('  year range %i - %i \n',  min(yearV(validV)),  max(yearV(validV)));
   end
end
   
end