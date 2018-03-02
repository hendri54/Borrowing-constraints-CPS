function school_by_year_show_cpsbc(saveFigures, setNo)
% Show stats for schooling by year
% ---------------------------------------

cS = const_cpsbc(setNo);
ny = length(cS.yearV);

% Stats: school by year for a particular age range
[avgSchoolV, fracM] = school_by_year_cpsbc(setNo);

output_bc1.fig_new(saveFigures, []);
fh = plot(cS.yearV, avgSchoolV, 'ro');
xlabel('Year');
ylabel('Avg years of school');
output_bc1.fig_format(fh, 'line');

save_fig_cpsbc('school_avg_by_year', saveFigures, [], setNo);


% *******  Fractions

output_bc1.fig_new(saveFigures, []);
fh = plot(cS.yearV, fracM, '-');
xlabel('Year');
ylabel('Fraction by school class');
legend(cS.sLabelV, 'Location', 'southeast');
output_bc1.fig_format(fh, 'line');

save_fig_cpsbc('school_class_by_year', saveFigures, [], setNo);


end