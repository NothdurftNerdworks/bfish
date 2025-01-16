classdef BFishClassTest < matlab.unittest.TestCase
    properties
        BF BFishClass = BFishClass.empty

    end

    methods (TestClassSetup)
        % Shared setup for the entire test class
    end

    methods (TestMethodSetup)
        % Setup for each test
        function setup(testCase)
            % Setup code
            testCase.BF = BFishClass; % create generic class
            testCase.BF.activeLanguage = "EN";

        end
    end

    methods (TestMethodTeardown)
        function closeFigure(testCase)
            delete(testCase.BF)

        end
    end

    methods (Test)
        % Test methods
        function listlanguages(testCase)
            expectedLanguages = ["EN", "ZH", "HI", "ES", "FR"];
            languages = testCase.BF.languages;
            testCase.verifyEqual(languages, expectedLanguages);

        end

        function changelanguagebycode(testCase)
            testCase.BF.activeLanguage = "ES";
            testCase.verifyEqual(testCase.BF.activeLanguage, "ES");

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