function cohort_school_show_cpsbc(saveFigures, setNo)
% Show schooling by cohort
% -----------------------------------------

cS = const_cpsbc(setNo);
figS = const_fig_bc1;

% Cohorts and ages to use
bYearV = (1930 : 1980)';
ageV = (30 : 40)';

% Fraction by [birth year, school]
fracM = cohort_school_cpsbc(bYearV, ageV, setNo);
% Fraction trying college - out of total pop
fracTryCollV = fracM(:, cS.iCD) + fracM(:,cS.iCG);
% Fraction trying college - out of HS grads
fracTryCollHSV = fracTryCollV ./ (1 - fracM(:, cS.iHSD));
% Fraction dropping out
fracDropV = fracM(:, cS.iCD) ./ (fracM(:, cS.iCD) + fracM(:, cS.iCG));
% Fraction BA of HS grads
fracBA_HSV = fracM(:, cS.iCG) ./ (1 - fracM(:, cS.iHSD));



% *************  Fraction by level
if 01
   fh = output_bc1.fig_new(saveFigures, []);
   hold on;
   for iSchool = 1 : cS.nSchool
      idxV = find(fracM(:, iSchool) > 0);
      plot(bYearV(idxV), fracM(idxV, iSchool), '-',  'Color', figS.colorM(iSchool,:));
   end

   hold off;
   xlabel('Birth year');
   ylabel('Fraction by school');
   output_bc1.fig_format(fh, 'line');

   save_fig_cpsbc('cohort_school', saveFigures, [], setNo);
end


% ********  Fraction trying college
if 01
   fh = output_bc1.fig_new(saveFigures, []);
   hold on;
   idxV = find(fracTryCollV > 0);
   plot(bYearV(idxV), fracTryCollV(idxV), '-',  'Color', figS.colorM(cS.iCG,:));
   
   % Fraction of HS grads trying college
   idxV = find(fracTryCollHSV > 0);
   plot(bYearV(idxV), fracTryCollHSV(idxV), '-',  'Color', figS.colorM(cS.iCD,:));
   %plot(gradeM(:,1) - 20,  gradeM(:,2) - gradeM(1,2), '-',  'Color',  figS.colorM(1,:));

   hold off;
   xlabel('Birth year');
   ylabel('Fraction trying college');
   legend({'Coll/all', 'Coll/HS'}, 'Location', 'Best');
   output_bc1.fig_format(fh, 'line');

   save_fig_cpsbc('cohort_college', saveFigures, [], setNo);   
end


% ********  Fraction dropping out
if 01
   fh = output_bc1.fig_new(saveFigures, []);
   hold on;
   idxV = find(fracDropV > 0);
   plot(bYearV(idxV), fracDropV(idxV), '-',  'Color', figS.colorM(cS.iCG,:));
   %plot(gradeM(:,1) - 20,  gradeM(:,2) - gradeM(1,2), '-',  'Color',  figS.colorM(1,:));

   hold off;
   xlabel('Birth year');
   ylabel('Fraction dropping out');
   output_bc1.fig_format(fh, 'line');

   save_fig_cpsbc('cohort_dropout', saveFigures, [], setNo);   
end


% ***********  Fraction trying (out of HS) and fraction succeeding
if 01
   fh = output_bc1.fig_new(saveFigures, []);
   hold on;
   idxV = find(fracDropV > 0);
   plot(bYearV(idxV), 1 - fracDropV(idxV),   '-', 'Color', figS.colorM(1,:));
   plot(bYearV(idxV), fracTryCollHSV(idxV),  '-', 'Color', figS.colorM(2,:));
   plot(bYearV(idxV), fracBA_HSV(idxV),   '-', 'Color', figS.colorM(3,:));
   %plot(gradeM(:,1) - 20,  gradeM(:,2) - gradeM(1,2), '-',  'Color',  figS.colorM(3,:));

   hold off;
   xlabel('Birth year');
   legend({'BA/try', 'Try/HS', 'BA/HS'}, 'Location', 'Best');
   ylabel('Fraction completing BA');
   output_bc1.fig_format(fh, 'line');

   save_fig_cpsbc('cohort_completion', saveFigures, [], setNo);   
end

end