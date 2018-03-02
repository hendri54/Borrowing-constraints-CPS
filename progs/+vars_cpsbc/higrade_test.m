function tests = higrade_test

tests = functiontests(localfunctions);

end

function oneTest(testCase)
   hS = vars_cpsbc.higrade;
   vS = hS.var_info;
   testCase.verifyTrue(vS.is_valid([10, 90]));
   testCase.verifyFalse(vS.is_valid([20, 290]));
   
   inV = [41, 150, 161, 200];
   outV = hS.recode_to_degrees(inV);
   
   testCase.verifyTrue(outV(1) == 'HSD');
   testCase.verifyTrue(outV(3) == 'CD');
   
   inV = [50, 120, 150, 210];
   tgV = [2,  9,    12, 18];
   outV = hS.recode_to_yrschool(inV);
   testCase.verifyEqual(outV, tgV);
end