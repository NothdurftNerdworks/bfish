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

        function changelanguage_bycode(testCase)
            testCase.BF.activeLanguage = "ES";
            testCase.verifyEqual(testCase.BF.activeLanguage, "ES");

        end

        function changelanguage_byvalue(testCase)
            testCase.BF.activeLanguage = 2;
            testCase.verifyEqual(testCase.BF.activeLanguage, "ZH");

        end

        function changelanguage_bydisc(testCase)
            testCase.BF.activeLanguage = "French";
            testCase.verifyEqual(testCase.BF.activeLanguage, "FR");

        end

        function translate_char(testCase)
            testCase.BF.activeLanguage = "ES";
            enText = 'one';
            esText = 'uno';
            testCase.verifyEqual(testCase.BF.translate(enText), esText);

        end

        function translate_pipedelimchar(testCase)
            testCase.BF.activeLanguage = "ES";
            enText = 'one|two|three';
            esText = 'uno|dos|tres';
            testCase.verifyEqual(testCase.BF.translate(enText), esText);

        end

        function translate_cell(testCase)
            testCase.BF.activeLanguage = "ES";
            enText = {'one', 'two', 'three'};
            esText = {'uno', 'dos', 'tres'};
            testCase.verifyEqual(testCase.BF.translate(enText), esText);

        end

        function translate_strings(testCase)
            testCase.BF.activeLanguage = "ES";
            enText = ["one" "two" "three"];
            esText = ["uno" "dos" "tres"];
            testCase.verifyEqual(testCase.BF.translate(enText), esText);

        end

        function translate_categorical(testCase)
            testCase.BF.activeLanguage = "ES";
            enText = categorical({'one','two','three'});
            esText = categorical({'uno','dos','tres'});
            testCase.verifyEqual(testCase.BF.translate(enText), esText);

        end

        function preservepadding(testCase)
            testCase.BF.activeLanguage = "ES";
            enText = "  one   ";
            esText = "  uno   ";
            testCase.verifyEqual(testCase.BF.translate(enText), esText);

        end

        function matchcase(testCase)
            testCase.BF.activeLanguage = "ES";
            enText = ["one", "ONE", "One"];
            esText = ["uno", "UNO", "Uno"];
            testCase.verifyEqual(testCase.BF.translate(enText), esText);

        end

        function addword(testCase)
            newWord = "PizzaParty";
            testCase.BF.translate(newWord);
            testCase.verifyEqual(testCase.BF.LibraryTable{end,1}, newWord);

        end

        function addlanguage(testCase)
            newLangName = "Klingon";
            newLangDisc = "Champions";
            testCase.BF.addlanguage(newLangName, newLangDisc);
            testCase.verifyEqual(testCase.BF.languages(end), newLangName);

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