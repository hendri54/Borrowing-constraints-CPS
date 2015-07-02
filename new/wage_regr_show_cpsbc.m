function wage_regr_show_cpsbc(saveFigures, setNo)
% Show results of regressing mean log wage on year / cohort dummies
% then on experience
% --------------------------------------------------------

cS = const_cpsbc(setNo);

loadS = wage_regr2_cpsbc(setNo);

% Plot cohort dummies
if 01
   hold on;
   for iSchool = 1 : cS.nSchool
      % birth years covered
      byV = loadS.byM(:, iSchool);
      idxV = find(byV > 0);
      plot(byV(idxV), loadS.cohDummyM(idxV, iSchool), '-', 'Color', cS.colorM(iSchool,:));
      
   end
   hold off;
   grid on;
   xlabel('Year');
   title('Cohort dummies');

   figFn = [cS.figDir,  'cohort_dummies'];
   save_fig_cpsbc(figFn, saveFigures, cS.figOpt4S, setNo)
end


% Plot year dummies
if 01
   % Also plot mean log wage in that year
   meanLogWageYearM = wage_by_year_cpsbc(cS.male, cS.yearV, setNo);

   for iSchool = 1 : cS.nSchool
      subplot(2,2,iSchool);
   
      idxV = find(loadS.yearDummyM(:, iSchool) ~= cS.missVal);
      yrDummyV = loadS.yearDummyM(idxV, iSchool);
      % Make means the same
      yrDummyV = yrDummyV - mean(yrDummyV) + mean(meanLogWageYearM(iSchool,:));
      
      plot(cS.yearV(idxV), yrDummyV, 'bo',   cS.yearV, meanLogWageYearM(iSchool,:), 'r-');
      xlabel('Year');
      title(['Year dummies  ', cS.schoolLabelV{iSchool}]);
      legend({'Dummy', 'Mean log wage'}, 'Location', 'Best');
      grid on;
   end
   
   figFn = [cS.figDir,  'year_dummies'];
   save_fig_cpsbc(figFn, saveFigures, cS.figOpt4S, setNo)
end


% Show cohort dummies college - HS
if 01
   hold on;
   % Birth range range present in both cases
   by1 = max(loadS.byM(1, cS.iHSG), loadS.byM(1, cS.iCG));
   by2 = min(max(loadS.byRangeM(:, cS.iHSG)), max(loadS.byRangeM(:, cS.iCG)));
   
   for bYear = by1 : by2
      idxHS = find(bYear == loadS.byM(:, cS.iHSG));
      idxCG = find(bYear == loadS.byM(:, cS.iCG));
      plot(bYear,  loadS.cohDummyM(idxCG, cS.iCG) - loadS.cohDummyM(idxHS, cS.iHSG), 'o');
   end
   
   % Also show GRE scores
   if 0
      [yearV, ~, ~, greV] = sat_cpsbc(setNo);
      idxV = find(greV > 0);
      greV = greV(idxV) ./ 500;
      greV = greV - greV(1);
      plot(yearV(idxV) - 24,  greV, '-');
   end
   
   hold off;
   grid on;
   title('Cohort effect CG - HS');
   xlabel('Birth year');

   figFn = [cS.figDir,  'coh_effect_cg_hs'];
   save_fig_cpsbc(figFn, saveFigures, [], setNo)
end




% ************  Show wage growth over lifecycle against birth year
if 01
   for iSchool = 1 : cS.nSchool
      subplot(2,2,iSchool);
      
      % Birth years available
      byV = loadS.byRangeM(1, iSchool) : loadS.byRangeM(2, iSchool);

      % Store the wage growth numbers here
      wGrowthV = zeros(size(byV));

      % Show growth between these experience levels
      exp1 = 5;
      exp2 = 25;
      
      hold on;
      for i1 = 1 : length(byV)
         expProfileV = loadS.expProfileM(:, i1, iSchool); 
         cIdxV = find(expProfileV > cS.missVal);
         if cIdxV(1) <= exp1  &&  cIdxV(end) >= exp2
            profileV = zeros([100, 1]);
            profileV(cIdxV) = hpfilter(loadS.expProfileM(cIdxV, i1, iSchool), 10);
            wGrowthV(i1) = profileV(exp2) - profileV(exp1);

            plot(byV(i1),  wGrowthV(i1), 'bo');
            
            % Show from raw profiles
            %if expProfileV(exp2) ~= cS.missVal  &&  expProfileV(exp1) ~= cS.missVal
            %   plot(byV(i1), expProfileV(exp2) - expProfileV(exp1), 'rx');
            %end
         end
         
      end
      hold off;
      grid on;
      xlabel('Birth year');
      title(sprintf('Wage growth between ages %i and %i',  loadS.ageRangeM(1, iSchool) + exp1, loadS.ageRangeM(1, iSchool) + exp2));

   end % iSchool

   figFn = [cS.figDir,  'exper_wage_growth'];
   save_fig_cpsbc(figFn, saveFigures, cS.figOpt4S, setNo)
end




% **********  Show selected cohort profiles
if 01
   byShowV = 1935 : 5 : 1970;
   
   for iSchool = 1 : cS.nSchool
      subplot(2,2,iSchool);
         
      hold on;
      for i1 = 1 : length(byShowV)
         % Index into birth year dummies
         byIdx = byShowV(i1) - loadS.byRangeM(1, iSchool);
         
         % Find obs for this cohort
         cIdxV = find(loadS.expProfileM(:, byIdx, iSchool) > cS.missVal);
         if length(cIdxV) > 5
            profileV = hpfilter(loadS.expProfileM(cIdxV, byIdx, iSchool), 10);
            plot(cIdxV,  profileV, 'Color', cS.colorM(i1,:));
         end
      end

      % Fitted profile
      experValueV = 1 : 40;
      plot(experValueV,  loadS.predExperProfileM(experValueV, iSchool), 'ro-');
      hold off;
      xlabel('Experience');
      title('Profiles for selected cohorts');
   end

   figFn = [cS.figDir,  'cohort_profiles'];
   save_fig_cpsbc(figFn, saveFigures, cS.figOpt4S, setNo)
end



% Predicted experience profile
if 01
   hold on;
   for iSchool = 1 : cS.nSchool
      experValueV = 1 : 40;
      plot(experValueV,  loadS.predExperProfileM(experValueV, iSchool), '-', 'Color', cS.colorM(iSchool,:));
   end
   
   hold off;
   grid on;
   xlabel('Experience');
   title('Predicted experience profile');
   legend(cS.schoolLabelV, 'Location', 'Northwest');
   figFn = [cS.figDir,  'exp_profile'];
   save_fig_cpsbc(figFn, saveFigures, cS.figOpt4S, setNo);
end




end