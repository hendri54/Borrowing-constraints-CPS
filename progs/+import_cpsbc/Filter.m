% Filter criteria
classdef Filter < handle
   
properties
   sex = 'male';

   % Possible: 'white'
   race = [];

   % Age in PREVIOUS year (where earnings observed)
   ageMin = 16;
   ageMax = 75;

   % Real annual earning to be counted as working
   %  included in mean log wage calc etc
   minRealEarn = 12 * 300;    % +++++

   % Count this fraction of bus income
   fracBusInc = 0;

   % Min hours worked last week
   hoursMin = 30;
   hoursMax = 200;
   weeksMin = 30;


   % ******  Wage regressions

   % Wages outside of this many times the median are deleted
   wageMinFactor = 0.05;
   wageMaxFactor = 100;


   % Age range for aggregate stats (such as years of schooling)
   aggrAgeRangeV = 30 : 50;   
end


methods
   function fltS = Filter
   end
end

end