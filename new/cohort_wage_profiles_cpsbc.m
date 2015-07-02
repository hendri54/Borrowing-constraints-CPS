function cohort_wage_profiles_cpsbc(saveFigures, setNo)
% Construct cohort age EARNINGS profiles

% Checked: 2011-05-23
% ------------------------------------------

cS = const_cpsbc(setNo);

% Min no of obs per cell
minObs = 50;


% **********  single birth years
if 01
   % Birth years to use
   byLbV = 1920 : 1989;
   byUbV = byLbV;
   nBy = length(byUbV);
   % Ages to use in fitting quartic
   ageV = 23 : 53;
   % Report wage growth between these ages
   agePointV = [25 40];
   
   % Construct age profiles 
   %  only at ages in ageV
   outS = byear_school_age_stats_cpsbc(byLbV, byUbV, ageV, setNo);
   
   % Wage growth over cohort's life, by [byear, school]
   cohGrowthM = zeros([nBy, cS.nSchool]);

   for iSchool = 1 : cS.nSchool
      subplot(2,2,iSchool);
      % By [birth year, age]
      meanLogWageM = squeeze(outS.meanLogEarnM(:, iSchool, :));
      nObsM = squeeze(outS.nObsM(:, iSchool, :));
      
      % Fit a profile for each cohort, at ages agePointV
      fitM = zeros([length(byUbV), 2]);
      for iBy = 1 : length(byUbV)
         nObsV = nObsM(iBy,:);
         logWageV = meanLogWageM(iBy, :);
         
         % Find valid obs
         idxV = find(nObsV >= minObs  &  logWageV ~= cS.missVal);
         % Find ages to report
         idx1 = find(ageV(idxV) == agePointV(1));
         idx2 = find(ageV(idxV) == agePointV(2));
         if length(idxV) > 9  &&  ~isempty(idx1)  &&  ~isempty(idx2)
            predV = fit_wages_cpsbc(ageV(idxV), logWageV(idxV), sqrt(nObsV(idxV)));
            fitM(iBy, :) = predV([idx1, idx2]);
         end
      end % for iBy
      
      
      % Plot
      %  Which cohorts have data?
      idxV = find(fitM(:, 1) ~= 0  & fitM(:,2) ~= 0);
      cohGrowthM(idxV, iSchool) = fitM(idxV,2) - fitM(idxV,1);
      
      plot(byLbV(idxV),  fitM(idxV, 2) - fitM(idxV, 1), 'bo');
      %plot(bYear1 + idxV - 1,  fitM(idxV, 2), 'bo',  bYear1 + idxV - 1, fitM(idxV, 1), 'ro');

      grid on;
      xlabel('Birth year');
      
   end
   
   figFn = [cS.figDir, 'cohort_wage_growth'];
   save_fig_cpsbc(figFn, saveFigures, cS.figOpt4S, setNo);
   
   
   % *******  For comparison: avg wage growth over same period
   if 01
      % Mean log wage by [school, year]
      meanLogWageM = wage_by_year_cpsbc(cS.male, cS.wageYearV, setNo);
      
      meanGrowthM = zeros([length(byUbV), cS.nSchool]);
      
      for iSchool = 1 : cS.nSchool
         subplot(2,2,iSchool);
         hold on;
         
         % Loop over cohorts
         for iBy = 1 : length(byUbV)
            bYear = byLbV(1) + iBy - 1;
            % Years at which this cohort is of the right ages
            cYearV = bYear + agePointV;
            idx1 = find(cS.wageYearV == cYearV(1));
            idx2 = find(cS.wageYearV == cYearV(2));
            if ~isempty(idx1)  &&  ~isempty(idx2)
               if meanLogWageM(iSchool, idx1) ~= cS.missVal  &&  meanLogWageM(iSchool, idx2) ~= cS.missVal
                  meanGrowthM(iBy, iSchool) = meanLogWageM(iSchool,idx2) - meanLogWageM(iSchool,idx1);
                  plot(bYear, meanGrowthM(iBy, iSchool), 'bo');
               end
            end
         end
         
         hold off;
         grid on;
         xlabel('Birth year');
         title('Mean wage change over cohorts life');
      end % for school
      
      figFn = [cS.figDir, 'cohort_aggr_wage_growth'];
      save_fig_cpsbc(figFn, saveFigures, cS.figOpt4S, setNo);
      
      
      % Difference between cohort specific and average wage growth
      for iSchool = 1 : cS.nSchool
         subplot(2,2,iSchool);
         
         idxV = find(cohGrowthM(:, iSchool) ~= 0  &  meanGrowthM(:, iSchool) ~= 0);
         plot(byLbV(1) - 1 + idxV,  cohGrowthM(idxV,iSchool) - meanGrowthM(idxV, iSchool),  'bo');
         
         grid on;
         xlabel('Birth year');
         title('Cohort vs mean growth');
      end % iSchool
      
      figFn = [cS.figDir, 'cohort_mean_wage_growth'];
      save_fig_cpsbc(figFn, saveFigures, cS.figOpt4S, setNo);
   end % if
end



% *********  Pool 10 birth years
if 01
   % Birth cohorts
   byLbV = 1920 : 10 : 1980;
   byUbV = byLbV + 9;
   nBy = length(byUbV);
   ageV = 25 : 60;

   % Construct age profiles 
   outS = byear_school_age_stats_cpsbc(byLbV, byUbV, ageV, setNo);

   % Plot
   for iSchool = 1 : cS.nSchool
      legendV = cell([nBy, 1]);
      iPlot = 0;
      
      subplot(2,2,iSchool);
      hold on;
      for iBy = 1 : nBy
         nObsV = squeeze(outS.nObsM(iBy, iSchool, :));
         logWageV = squeeze(outS.meanLogWageM(iBy, iSchool, :));
         idxV = find(nObsV >= minObs);
         if length(idxV) > 9
            iPlot = iPlot + 1;
            legendV{iPlot} = sprintf('%i', round(0.5 .* (byLbV(iBy)+byUbV(iBy))));
            % Fit a quartic
            predV = fit_wages_cpsbc(ageV(idxV), logWageV(idxV), sqrt(nObsV(idxV)));
            %predV = logWageV(idxV);
            plot(ageV(idxV),  predV, '-', 'Color', cS.colorM(iBy,:));
            %plot(ageV(idxV),  logWageV(idxV), 'o', 'Color', cS.colorM(iBy,:));
         end
      end

      hold off;
      grid on;
      xlabel('Age');
      title(['Mean log wage. ',  cS.schoolLabelV{iSchool}]);
      legend(legendV(1 : iPlot), 'Location', 'SouthOutside', 'Orientation', 'horizontal');
   end 

   figFn = [cS.figDir, 'cohort_wage_profiles'];
   save_fig_cpsbc(figFn, saveFigures, cS.figOpt4S, setNo);
end

end