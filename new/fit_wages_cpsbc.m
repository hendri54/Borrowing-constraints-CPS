function predV = fit_wages_cpsbc(ageV, logWageV, wtV)
% Fit age wage profile
% Quartic in experience (age - 20)

% IN:
%     may NOT contain missing values
% -----------------------------------------------

cS = const_cpsbc(1);

n = length(ageV);

if n > 9
   % Experience
   experV = (ageV(:) - 20) ./ 10;
   xM = [ones([n,1]), experV, experV .^ 2, experV .^ 3, experV .^ 4];
      
   rsS = lsq_weighted_lh(logWageV(:), xM, wtV(:), 0.05, 1);
   
   predV = xM * rsS.betaV;
else
   error('Too few values');
end



end