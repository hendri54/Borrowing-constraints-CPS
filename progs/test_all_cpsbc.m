function test_all_cpsbc

dirS = helper_cpsbc.directories(1);
cd(dirS.progDir);

import matlab.unittest.TestSuite

run([TestSuite.fromFolder(dirS.progDir), TestSuite.fromPackage('import_cpsbc'), ...
   TestSuite.fromPackage('stats_cpsbc'),  TestSuite.fromPackage('vars_cpsbc')]);

end