function wage_regr3_show_cpsbc(saveFigures, setNo)
% Show results of regressing mean log wage on cohort dummies / age dummies
% --------------------------------------------------------

cS = const_cpsbc(setNo);

loadS = wage_regr3_cpsbc(setNo);

% Which index is the 1960 birth cohort
% idxCoh60 = find(loadS.byV == 1960);

% Plot cohort dummies
if 0
   hold on;
   for iSchool = 1 : cS.nSchool
      idxV = find(loadS.cohDummyM(:, iSchool) ~= cS.missVal);
      plot(loadS.byV(idxV), loadS.cohDummyM(idxV, iSchool), '-', 'Color', cS.colorM(iSchool,:));
      
   end
   hold off;
   grid on;
   xlabel('Year');
   title('Cohort dummies');

   figFn = [cS.figDir,  'cohort_dummies'];
   save_fig_cpsbc(figFn, saveFigures, cS.figOpt4S, setNo)
end



% Show cohort dummies college - HS
if 0
   hold on;
   
   % Find birth years with data for both school groups
   idxV = find(loadS.cohDummyM(:, cS.iHSG) ~= cS.missVal  &  loadS.cohDummyM(:, cS.iCG) ~= cS.missVal);
   plot(loadS.byV(idxV), loadS.cohDummyM(idxV, cS.iCG) - loadS.cohDummyM(idxV, cS.iHSG), '-', 'Color', cS.colorM(1,:));
   
   hold off;
   grid on;
   title('Cohort effect CG - HS');
   xlabel('Birth year');

   figFn = [cS.figDir,  'coh_effect_cg_hs'];
   save_fig_cpsbc(figFn, saveFigures, [], setNo)
end


% Predicted age profile
%  levels do not include year effects
if 0
   hold on;
   for iSchool = 1 : cS.nSchool
      % Cohort profile, from age dummies
      outS = cohort_age_profile(1960, iSchool, loadS, setNo);
      idxV = find(outS.profileV ~= cS.missVal);
      plot(idxV,  outS.profileV(idxV), '-', 'Color', cS.colorM(iSchool,:));
   end
   
   hold off;
   grid on;
   xlabel('Age');
   title('Predicted age profile');
   legend(cS.schoolLabelV, 'Location', 'Northwest');
   figFn = [cS.figDir,  'age_profile'];
   save_fig_cpsbc(figFn, saveFigures, [], setNo);
end


% ********  Year effects
if 0
   hold on;
   for iSchool = 1 : cS.nSchool
      plot(cS.yearV,  loadS.yearEffectM(:, iSchool), '-', 'Color', cS.colorM(iSchool,:));
   end
   
   hold off;
   grid on;
   xlabel('Year');
   title('Year Effects');
   legend(cS.schoolLabelV, 'Location', 'Northwest');
   figFn = [cS.figDir,  'year_effects'];
   save_fig_cpsbc(figFn, saveFigures, [], setNo);
   
end


% *********  Compare actual / predicted for some cohorts
if 01
   bYearV = [1940, 1960];
   nBy = length(bYearV);
   
   legendV = cell([2 * nBy, 1]);
   ir = 0;
   for iBy = 1 : nBy
      ir = ir + 1;
      legendV{ir} = sprintf('%i', bYearV(iBy));
      ir = ir + 1;
      legendV{ir} = ' ';
   end
   
   % Actual profiles
   byS = byear_school_age_stats_cpsbc(bYearV, bYearV, 1 : cS.fltAgeMax, setNo);
   
   for iSchool = 1 : cS.nSchool
      subplot(2,2,iSchool);
      hold on;
      
      for iBy = 1 : nBy
         % Constructed profile
         outS = cohort_age_profile_cpsbc(bYearV(iBy), iSchool, loadS, setNo);
         idxV = find(outS.profileV ~= cS.missVal);
         profileV  = outS.profileV(idxV);
         yrEffectV = outS.yearEffectV(idxV);
         % Fill in first / last years
         yrIdxV = find(yrEffectV ~= cS.missVal);
         meanYrEffect = mean(yrEffectV(yrIdxV));
         if yrEffectV(1) == cS.missVal
            yrEffectV(1 : yrIdxV(1)) = meanYrEffect;
         end
         if yrEffectV(end) == cS.missVal
            yrEffectV(yrIdxV(end) : end) = meanYrEffect;
         end
         
         plot(idxV, profileV + yrEffectV, '-', 'Color', cS.colorM(iBy, :));
         
         % Show the actual profile
         profile2V = squeeze(byS.meanLogEarnM(iBy, iSchool, :));
         idxV = find(profile2V ~= cS.missVal);
         plot(idxV, profile2V(idxV), 'd', 'Color', cS.colorM(iBy, :));
         
      end
      
      hold off;
      grid on;
      xlabel('Age');
   end % iSchool
   
   legend(legendV, 'Location', 'South');
  
   figFn = [cS.figDir, 'cohort_profiles'];
   save_fig_cpsbc(figFn, saveFigures, cS.figOpt4S, setNo);
end


end