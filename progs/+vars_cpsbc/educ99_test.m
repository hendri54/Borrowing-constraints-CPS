function tests = educ99_test

tests = functiontests(localfunctions);

end

function oneTest(testCase)
   eS = vars_cps.educ99;
   vS = eS.var_info;
   testCase.verifyTrue(vS.is_valid([0, 1, 9, 13, 18]));
   
   inV = [6, 10];
   tgV = [9, 12];
   outV = eS.recode_to_yrschool(inV);
   testCase.verifyEqual(outV, tgV);
   
   outV = eS.recode_to_degrees(inV);
   testCase.verifyTrue(outV(1) == 'HSD');
   testCase.verifyTrue(outV(2) == 'HSG');
end