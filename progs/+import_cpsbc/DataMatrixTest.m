function tests = DataMatrixTest

tests = functiontests(localfunctions);

end

function oneTest(tS)
   setName = 'test';
   dmS = import_cpsbc.DataMatrix(setName);
   dmS.run_all;
end