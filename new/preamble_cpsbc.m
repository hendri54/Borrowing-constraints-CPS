function preamble_cpsbc(setNo)
% Write latex commands that define constants for preamble of paper
%{
%}
% ------------------------------------------------

cS = const_cpsbc(setNo);

tbFn = [cS.tbDir, 'preamble_cpsbc.tex'];
fp = fopen(tbFn, 'w');


%% Filter

fprintf(fp, '\\newcommand{\\cpsYears}{%i-%i}\n', cS.yearV(1), cS.yearV(end));
fprintf(fp, '\\newcommand{\\cpsAgeMin}{%i}\n',  cS.fltAgeMin);
fprintf(fp, '\\newcommand{\\cpsAgeMax}{%i}\n',  cS.fltAgeMax);


%% Earnings profiles

% Min real earnings to be counted as > 0
xStr = separatethousands(cS.minRealEarn, ',', 0);
fprintf(fp, '\\newcommand{\\cpsMinRealEarn}{%s}\n',  xStr);

% Cohorts kept in wage regressions
fprintf(fp, '\\newcommand{\\cpsWageRegrCohorts}{%i-%i}\n', cS.wageRegrCohortV(1), cS.wageRegrCohortV(end));


fclose(fp);
disp(['Saved table  ',  tbFn]);


end