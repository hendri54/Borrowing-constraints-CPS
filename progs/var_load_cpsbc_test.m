function tests = var_load_cpsbc_test

tests = functiontests(localfunctions);

end

function oneTest(tS)
   setName = 'test';
   year1 = 1970;
   cS = const_cpsbc(setName);
   varName = 'test';
   outV = 1 : 10;
   var_save_cpsbc(outV, varName, year1, setName);
   [out2V, success] = var_load_cpsbc(varName, year1, setName);
   
   tS.verifyTrue(success);
   tS.verifyEqual(outV, out2V);
end