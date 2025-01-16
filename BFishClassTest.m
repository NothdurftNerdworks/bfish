classdef BFishClassTest < matlab.unittest.TestCase

    methods (TestClassSetup)
        % Shared setup for the entire test class
    end

    methods (TestMethodSetup)
        % Setup for each test
        function setup(testCase)
            % Setup code
            testCase.BF = BFishClass; % create generic class 
        end
    end

    methods (Test)
        % Test methods
        function changelanguage(testCase)

        end

        function translatewords(testCase)
            % Test code
        end

        function preservepadding(testCase)

        end

        function matchcase(testCase)

        end

        function addword(testCase)

        end

        function addlanguage(testCase)

        end

        function silenterrorevent(testCase)

        end

        function savelibrary(testCase)

        end

        function loadlibrary(testCase)

        end


        function unimplementedTest(testCase)
            testCase.verifyFail("Unimplemented test");
        end
    end

end