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
            error("not implemented")

        end

        function translatewords(testCase)
            error("not implemented")

        end

        function preservepadding(testCase)
            error("not implemented")

        end

        function matchcase(testCase)
            error("not implemented")

        end

        function addword(testCase)
            error("not implemented")

        end

        function addlanguage(testCase)
            error("not implemented")

        end

        function silenterrorevent(testCase)
            error("not implemented")

        end

        function savelibrary(testCase)
            error("not implemented")

        end

        function loadlibrary(testCase)
            error("not implemented")

        end

        function unimplementedTest(testCase)
            testCase.verifyFail("Unimplemented test");
        end
    end

end