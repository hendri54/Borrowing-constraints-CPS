function earn_show_cpsbc(saveFigures, setNo)
% Show constructed earnings stats
% ----------------------------------------------

cS = const_cpsbc(setNo);
figS = const_fig_bc1;

% Show these ages
ageShowV = 30 : 10 : 50;

% Stats by [age, school, year]
loadS = var_load_cpsbc(cS.vAgeSchoolYearStats, [], setNo);

% ageIdxV = zeros(size(ageShowV));
legendV = cell(size(ageShowV));
for iAge = 1 : length(ageShowV)
   %ageIdxV(iAge) = find(ageShowV(iAge) == loadS.ageV);
   legendV{iAge} = sprintf('Age %i', ageShowV(iAge));
end

% *********  Fraction working
if 0
   fh = output_bc1.fig_new(saveFigures, []);
   for iSchool = 1 : cS.nSchool
      subplot(2,2,iSchool);
      hold on;
      fracWorkM = squeeze(loadS.fracWorkingM(ageShowV, iSchool, :));
      for iAge = 1 : length(ageShowV)
         idxV = find(fracWorkM(iAge, :) >= 0);
         plot(cS.yearV(idxV),  fracWorkM(iAge, idxV), '-', 'Color', figS.colorM(iAge, :));
      end

      hold off;
      ylabel('Fraction working');
      if iSchool == 1
         legend(legendV, 'Location', 'Best');
      end
      output_bc1.fig_format(fh, 'line');
   end

   save_fig_cpsbc('frac_working', saveFigures, figS.figOpt4S, setNo);
end


% ********  Mean log earn
if 01
   fh = output_bc1.fig_new(saveFigures, []);
   for iSchool = 1 : cS.nSchool
      subplot(2,2,iSchool);
      hold on;
      meanM = squeeze(loadS.meanLogEarnM(ageShowV, iSchool, :));
      for iAge = 1 : length(ageShowV)
         idxV = find(meanM(iAge, :) ~= cS.missVal);
         plot(cS.yearV(idxV),  meanM(iAge, idxV), '-', 'Color', figS.colorM(iAge, :));
      end

      hold off;
      ylabel('Mean log earnings');
      if iSchool == 1
         legend(legendV, 'Location', 'Best');
      end
      output_bc1.fig_format(fh, 'line');
   end


   save_fig_cpsbc('mean_log_earn_age', saveFigures, figS.figOpt4S, setNo);
end



end