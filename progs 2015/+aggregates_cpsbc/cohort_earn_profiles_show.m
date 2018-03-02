function cohort_earn_profiles_show(loadS, wageConcept, saveFigures, setNo)
% Show cohort earnings profiles
%{
%}

cS = const_cpsbc(setNo);
figS = const_fig_bc1;
figOptS = figS.figOpt4S;


if wageConcept == cS.iLogMedian
   % loadS = var_load_cpsbc(cS.vCohortEarnProfilesMedian, [], setNo);
   prefixStr = 'Median';    
elseif wageConcept == cS.iMeanLog
   % loadS = var_load_cpsbc(cS.vCohortEarnProfilesMeanLog, [], setNo);
   prefixStr = 'MeanLog';
else
   error('Invalid');
end

bYearV = loadS.bYearV;

for iCohort = 1 : length(bYearV)
   fh = output_bc1.fig_new(saveFigures, figOptS);
   
   for iSchool = 1 : cS.nSchool
      subplot(2,2,iSchool);
      hold on;
      
      % Complete profile
      iLine = 1;
      logEarnV = loadS.logEarn_ascM(:, iSchool, iCohort);
      idxV = find(logEarnV ~= cS.missVal);
      plot(idxV, logEarnV(idxV), figS.lineStyleDenseV{iLine}, 'color', figS.colorM(iLine,:));
      
      % Raw data
      iLine = iLine + 1;
      logEarnV = loadS.logRawEarn_ascM(:, iSchool, iCohort);
      idxV = find(logEarnV ~= cS.missVal);
      plot(idxV, logEarnV(idxV), 'o', 'color', figS.colorM(iLine,:));
      
      hold off;
      xlabel('Age');
      ylabel([prefixStr, ' earnings']);
      output_bc1.fig_format(fh, 'line');
   end
   
   save_fig_cpsbc(sprintf('earn_profile_%s_coh%i', prefixStr, bYearV(iCohort)), saveFigures, figOptS, setNo);
end


end