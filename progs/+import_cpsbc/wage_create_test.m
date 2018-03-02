function tests = wage_create_test

tests = functiontests(localfunctions);

end

function oneTest(tS)
   setName = 'test';
   cS = const_cpsbc(setName);
   
   m = table;
   n = 17;
   m.earnings = linspace(10, 20, n)';
   m.incbus = linspace(10, 5, n)';
   m.weeksWorked = linspace(20, 30, n)';
   m.year = round(linspace(1970, 2010, n))';
   
   wageV = import_cpsbc.wage_create(m, cS);
   tS.verifyTrue(all(wageV > 0));
end