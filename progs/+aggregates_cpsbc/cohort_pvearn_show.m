function cohort_pvearn_show(loadS, wageConcept, saveFigures, setNo)

cS = const_cpsbc(setNo);
% figS = const_fig_bc1;

if wageConcept == cS.iMeanLog
   wcStr = 'meanlog';
else
   wcStr = 'logmedian';
end


%% Levels  and  premium relative to HSG
% Also indicate cohorts used in model
if 1
   yLabelStrV = {'Log present value',  'Lifetime earnings premium'};
   figNameV = {'cohort_pv_lty_',  'cohort_lty_premium_'};
   iSchoolV = cS.iCD : cS.nSchool;
   
   for iPlot = 1 : 2
      data_cvM = loadS.pvEarn_scM(iSchoolV, :)';
      if iPlot == 2
         % Relative to HSG
         data_cvM = data_cvM - loadS.pvEarn_scM(cS.iHSG, :)' * ones([1, size(data_cvM, 2)]);
      end
%       xV = loadS.bYearV;

      
%       fh = output_bc1.fig_new(saveFigures, []);
%       hold on;

      for iCase = 1 : 2
%          for iSchool = cS.iCD : cS.nSchool
%             yV = log(loadS.pvEarn_scM(iSchool, :));
%             if iPlot == 2
%                yV = yV - log(loadS.pvEarn_scM(cS.iHSG, :));
%             end
            
            fh = output_bc1.plot_by_cohort(loadS.bYearV,  data_cvM,  saveFigures, cS);
            
%             if iCase == 1
%                % Show all cohorts as a line
%                plot(xV, yV,  figS.lineStyleDenseV{iSchool}, 'color', figS.colorM(iSchool, :));
%             else
%                % Show model cohorts
%                for ic = 1 : length(cS.bYearV)
%                   byIdx = find(xV == cS.bYearV(ic));
%                   plot(xV(byIdx), yV(byIdx), 'o', 'color', figS.colorM(iSchool,:));
%                end
%             end
%          end
      end
      
%       hold off;
%       xlabel('Cohort');
      ylabel(yLabelStrV{iPlot});
      legend(cS.sLabelV(iSchoolV), 'location', 'northwest');
      output_bc1.fig_format(fh, 'line');
      output_bc1.fig_save([figNameV{iPlot}, wcStr], saveFigures, cS);
   end
end




end