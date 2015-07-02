function unempl_rate_cpsbc(saveFigures, setNo)
% Save unemployment rate by year
% -----------------------------------

cS = const_cpsbc(setNo);
ny = length(cS.yearV);

%  columns are year, unempl rate (pct)
fn = [cS.dataDir, 'unemployment_rate.csv']; 
unemplM = load(fn);

saveS.yearV = unemplM(:,1);
saveS.unemplV = unemplM(:, 2);

var_save_cpsbc(saveS, cS.vUnemplRate, [], setNo);

if saveFigures >= 0
   % Plot unemployment rates
   plot(saveS.yearV, saveS.unemplV, 'bo');
   xlabel('Year');
   title('Unemployment rates');
   grid on;
   
   save_fig_rnls('unempl_rate', saveFigures, [], setNo);
end


end