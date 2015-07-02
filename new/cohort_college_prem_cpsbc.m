function cohort_college_prem_cpsbc(saveFigures, setNo)
% Show college wage premiums for selected cohorts
% -----------------------------------------------

cS = const_cpsbc(setNo);
minObs = 50;

% Take out year effects?
removeYearEffects = 01;



% *********  Pool 10 birth years
if 01
   % Birth cohorts
   byLbV = [1925 : 10 : 1965];
   byUbV = byLbV + 9;
   ageV = 25 : 45;

   % Construct age profiles , by [birth year, school, age]
   outS = byear_school_age_stats_cpsbc(byLbV, byUbV, ageV, setNo);

   legendV = cell(size(byUbV));

   % Plot
      hold on;
      for iBy = 1 : length(byUbV)
         bYear = round(0.5 * (byLbV(iBy) + byUbV(iBy)));
         legendV{iBy} = sprintf('%i', bYear);
                  
         nObsM = squeeze(outS.nObsM(iBy, [cS.iHSG, cS.iCG], :));
         if removeYearEffects
            wageM = outS.wageExYearEffectsM;
         else
            wageM = outS.meanLogWageM;
         end
            
         logWageM = squeeze(wageM(iBy, [cS.iHSG, cS.iCG], :));
         
         idxV = find(nObsM(2,:) >= minObs  &  nObsM(1,:) >= minObs);
         if length(idxV) > 9            
            % College wage premium
            premV = logWageM(2,idxV) - logWageM(1,idxV);
            % HP filter
            premV = hpfilter(premV, 10);
            plot(ageV(idxV),  premV, '-', 'Color', cS.colorM(iBy,:));
         end
      end

      hold off;
      grid on;
      xlabel('Age');
      title('College premium');
      
      legend(legendV, 'Location', 'EastOutside');   % , 'Orientation', 'horizontal');

   figFn = [cS.figDir, 'cohort_collprem'];
   if removeYearEffects
      figFn = [figFn, '_ex_yeareffects'];
   end
   save_fig_cpsbc(figFn, saveFigures, cS.figOptS, setNo);
end




end