function regr_earn_age_year_show_cpsbc(wageConcept, saveFigures, setNo)
% Show results of wage regressions
%{
Log earnings (not wages) on age and time dummies
%}

cS = const_cpsbc(setNo);
figS = const_fig_bc1;

if wageConcept == cS.iLogMedian
   loadVarNo = cS.vEarnRegrAgeYearMedian;
   figPrefix = 'regr_earn_median_';
elseif wageConcept == cS.iMeanLog
   loadVarNo = cS.vEarnRegrAgeYearMeanLog;
   figPrefix = 'regr_earn_meanlog_';
else
   error('Invalid');
end

loadV = var_load_cpsbc(loadVarNo, [], setNo);


%% Age dummies
if 1
   % Normalize dummies to 0 for this age
   refAge = 25;
   fh = output_bc1.fig_new(saveFigures, []);
   hold on;
   for iSchool = 1 : cS.nSchool
      regrS = loadV{iSchool};
      refAgeIdx = find(regrS.ageValueV == refAge);
      plot(regrS.ageValueV, regrS.ageDummyV - regrS.ageDummyV(refAgeIdx), ...
         figS.lineStyleDenseV{iSchool}, 'color', figS.colorM(iSchool,:));
   end
   hold off;
   xlabel('Age');
   ylabel('Age dummy');
   legend(cS.sLabelV, 'Location', 'south');
   output_bc1.fig_format(fh, 'line');
   save_fig_cpsbc([figPrefix, 'age_dummies'], saveFigures, [], setNo);
end


%% Year dummies
if 1
   % Normalize dummies to 0 for this year
   refYear = 1970;
   fh = output_bc1.fig_new(saveFigures, []);
   hold on;
   for iSchool = 1 : cS.nSchool
      regrS = loadV{iSchool};
      refYearIndex = find(regrS.yearValueV == refYear);
      plot(regrS.yearValueV, regrS.yearDummyV - regrS.yearDummyV(refYearIndex), ...
         figS.lineStyleDenseV{iSchool}, 'color', figS.colorM(iSchool,:));
   end
   hold off;
   xlabel('Age');
   ylabel('Year dummy');
   legend(cS.sLabelV, 'Location', 'south');
   output_bc1.fig_format(fh, 'line');
   save_fig_cpsbc([figPrefix, 'year_dummies'], saveFigures, [], setNo);
end


end