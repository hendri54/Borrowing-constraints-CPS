% Variable higrade
%{
Can load code/value pairs with vars_cps.load_value_list
%}
classdef higrade < handle
      
properties
end


methods
   %% Constructor
   function hS = higrade
   end
end


methods (Static)
   function vS = var_info
      vS = dataLH.Variable('higrade',  'minVal', 10, 'maxVal', 210, 'missValCodeV', [0, 999]);
   end
   
   
   %% Recode to school groups
   function outV = recode_to_degrees(inV)
      outV = categorical(zeros(size(inV)),  1 : 4,  {'HSD', 'HSG', 'CD', 'CG'});
      
      outV(inV >= 10   &  inV <= 141) = 'HSD';
      outV(inV == 150) = 'HSG';
      outV(inV >= 151  &  inV <= 181) = 'CD';
      outV(inV >= 190  &  inV <= 210) = 'CG';
   end
   
   
   %% Recode higrade to highest year of schooling completed
   %{
   %}
   function outV = recode_to_yrschool(inV)
      outV = -1 .* ones(size(inV));
      outV(isnan(inV)) = NaN;

      oldV = [0        10    31    40    41    50    51    60    61    70    71    80    81    90    91 ...
         100   101   110   111   120   121   130   131   140   141   150   151   160   161   ...
         170   171   180   181   190   191   200   201   210   999];
      newV = [NaN   0     0     1     1     2     2     3     3     4     4     5     5     6     6  ...
         7     7     8     8     9     9     10    10    11    11    12    12    13    13    ...
         14    14    15    15    16    16    17    17    18    NaN];

      for i1 = 1 : length(oldV)
         outV(inV == oldV(i1)) = newV(i1);
      end

      if any(outV == -1)
         error('Not all values assigned');
      end
   end   
end
   
end
