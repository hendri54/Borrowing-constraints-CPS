function cohort_pvearn_show(loadS, wageConcept, saveFigures, setNo)

cS = const_cpsbc(setNo);
figS = const_fig_bc1;

if wageConcept == cS.iMeanLog
   wcStr = 'meanlog';
else
   wcStr = 'logmedian';
end


%% Levels  and  premium relative to HSG
if 1
   yLabelStrV = {'Log present value',  'Lifetime earnings premium'};
   figNameV = {'cohort_pv_lty_',  'cohort_lty_premium_'};
   for iPlot = 1 : 2
      xV = loadS.bYearV;

      fh = output_bc1.fig_new(saveFigures, []);
      hold on;

      for iSchool = 1 : cS.nSchool
         yV = log(loadS.pvEarn_scM(iSchool, :));
         if iPlot == 2
            yV = yV - log(loadS.pvEarn_scM(cS.iHSG, :));
         end
         plot(xV, yV,  figS.lineStyleDenseV{iSchool}, 'color', figS.colorM(iSchool, :));
      end

      hold off;
      xlabel('Cohort');
      ylabel(yLabelStrV{iPlot});
      legend(cS.sLabelV, 'location', 'northwest');
      output_bc1.fig_format(fh, 'line');
      output_bc1.fig_save([figNameV{iPlot}, wcStr], saveFigures, cS);
   end
end




end