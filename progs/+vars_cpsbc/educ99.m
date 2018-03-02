classdef educ99 < handle
      
properties
end

methods
   %% Constructor
   function eS = educ99
      
   end
end


methods (Static)
   %% Var info
   function vS = var_info
      vS = dataLH.Variable('educ99',  'minVal', 1,  'maxVal', 18,  'missValCodeV', 0);
   end
   
   
   %% Recode to degree attained
   function outV = recode_to_degrees(inV)
      outV = categorical(zeros(size(inV)),  1:4, {'HSD', 'HSG', 'CD', 'CG'});
      
      outV(inV >= 1   &  inV <= 9) = 'HSD';
      outV(inV == 10) = 'HSG';
      outV(inV >= 11  &  inV <= 14) = 'CD';
      outV(inV >= 15  &   inV <= 18) = 'CG';
      
   end
   
   
   %% Recode into years of schooling
   function outV = recode_to_yrschool(inV)
      % Recode
      outV = -1 .* ones(size(inV));
      outV(isnan(inV)) = NaN;

      oldV = [0        1   4 : 18];
      newV = [NaN  0   2.5   6.5   9  10 11 12 12  13  14 14 14  16 18 18 18];

      for i1 = 1 : length(oldV)
         outV(inV == oldV(i1)) = newV(i1);
      end

      if any(outV == -1)
         error('Not all values assigned');
      end      
   end
end
   
end
