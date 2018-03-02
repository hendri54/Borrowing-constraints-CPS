% Top codes vary by year
% There is no bottom coding (incwage >= 0)
classdef incwage < handle
   
properties (Constant)
   missValCodeV = [9999998, 9999999];
end
   
methods 
   function vS = var_info(varS)
      vS = dataLH.Variable('incwage',  'minVal', 0,  'maxVal', 9999997,  'missValCodeV',  varS.missValCodeV);
   end

   
   %% Recode
   %{
   Multiply top codes by 1.5 (Autor et al 2008)
   But: in later years (1996+) it simply is not clear what values are top
      codes.
   %}
   function outV = recode(varS, inV, yearV)
      outV = inV;
      
      % Missing value codes
      outV(inV < 0) = NaN;
      for i1 = 1 : length(varS.missValCodeV)
         outV(inV == varS.missValCodeV(i1)) = NaN;
      end
      
      % Top codes
      yearValueV = unique(yearV(yearV > 1900));
      varName = 'incwage';
      for iy = 1 : length(yearValueV)
         yIdxV = find(yearV == yearValueV(iy)  &  ~isnan(outV));
         if ~isempty(yIdxV)
            xMax = max(outV(yIdxV));
            idxV = find(outV(yIdxV) == xMax);
            if length(idxV) > 4
               fprintf('%s.  Top code %i:  %8.0f.  Occurs %i times (%5.1f pct). \n', ...
                  varName, yearValueV(iy), xMax, length(idxV),  100 .* length(idxV) ./ length(outV));
               outV(yIdxV(idxV)) = xMax .* 1.5;
            else
               fprintf('%s.  Max value %i: %8.0f.  Occurs %i times (%5.1f pct). \n', ...
                  varName, yearValueV(iy), xMax, length(idxV),  100 .* length(idxV) ./ length(outV));
            end
         end
      end
   end   
end

end