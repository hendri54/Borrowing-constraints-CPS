function wage_by_year_show_cpsbc(saveFigures, setNo)
% Show stats for wages by year
% ---------------------------------------

cS = const_cpsbc(setNo);
figS = const_fig_bc1;

% No wage data for last year
ny = length(cS.yearV);
yearV = cS.yearV;

loadS = var_load_cpsbc(cS.vAggrStats, [], setNo);


%% Levels
if 1
   fh = output_bc1.fig_new(saveFigures, []);
   hold on;
   for iSchool = 1 : cS.nSchool
      yV = loadS.meanLogWage_stM(iSchool, :)';
      idxV = find(yV ~= cS.missVal);
      plot(yearV(idxV), yV(idxV), figS.lineStyleDenseV{iSchool}, 'color', figS.colorM(iSchool,:));
   end
   xlabel('Year');
   ylabel('Mean log wage');
   legend(cS.sLabelV, 'Location', 'southwest');
   output_bc1.fig_format(fh, 'line');
   figFn = 'wage_meanlog_by_year';
   save_fig_cpsbc(figFn, saveFigures, [], setNo);
end



%% Relative to college
if 1
   fh = output_bc1.fig_new(saveFigures, []);
   hold on;
   for iSchool =  1 : cS.nSchool
      yV = loadS.meanLogWage_stM(iSchool, :);
      idxV = find(yV ~= cS.missVal);
      plot(yearV(idxV), yV(idxV) - loadS.meanLogWage_stM(cS.iHSG,idxV), ...
         figS.lineStyleDenseV{iSchool}, 'color', figS.colorM(iSchool,:));
   end
   hold off;
   xlabel('Year');
   ylabel('Mean log wage relative to HSG');
   legend(cS.sLabelV, 'Location', 'northwest')
   output_bc1.fig_format(fh, 'line');

   figFn = 'wageprem_by_year';
   save_fig_cpsbc(figFn, saveFigures, [], setNo);
end


end