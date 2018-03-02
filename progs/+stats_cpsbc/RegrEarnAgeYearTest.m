classdef RegrEarnAgeYearTest < matlab.unittest.TestCase
    
   properties (TestParameter)
      wageConcept = {'logMedian', 'meanLog'};
   end
    
   methods (Test)
      function oneTest(tS, wageConcept)
         setName = 'test';
         iSchool = 2;
         regrS = stats_cpsbc.RegrEarnAgeYear(wageConcept, iSchool, setName);
         regrS.regress;
      end
   end
   
end