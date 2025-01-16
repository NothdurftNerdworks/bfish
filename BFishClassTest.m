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
            testCase.BF = BFishClass; % create default class
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

        function newlanguage_event(testCase)
            % Add a listener for the event
            listener = addlistener(testCase.BF, 'NewLanguage', @(src, event) ...
                testCase.verifyTrue(true, 'Event NewLanguage was triggered'));
            testCase.addTeardown(@delete, listener)

            % cause 'NewLanguage'
            testCase.BF.activeLanguage = "ES";

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
            testCase.verifyEqual(testCase.BF.words(end), newWord);

        end

        function addlanguage(testCase)
            newLangName = "Klingon";
            newLangDisc = "Champions";
            testCase.BF.addlanguage(newLangName, newLangDisc);
            testCase.verifyEqual(testCase.BF.languages(end), newLangName);

        end

        function silenterror_event(testCase)
            % Add a listener for the event
            listener = addlistener(testCase.BF, 'SilentError', @(src, event) ...
                testCase.verifyTrue(true, 'Event SilentError was triggered'));
            testCase.addTeardown(@delete, listener)

            % cause 'SilentError'
            testCase.BF.activeLanguage = 100;

        end

        function savelibrary(testCase)
            % designate test file and confirm it does not already exist
            saveName = "savetest.csv";
            assert(~isfile(saveName), "can't test savelibrary method if savefile already exists");

            % save the library
            testCase.BF.savelibrary(saveName);
            testCase.addTeardown(@delete, saveName)

            % validate
            testCase.verifyTrue(isfile(saveName));

        end

        function loadlibrary(testCase)
            % designate test file and confirm it does not already exist
            saveName = "loadtest.csv";
            assert(~isfile(saveName), "can't test loadlibrary method if savefile already exists");

            % save the library
            testCase.BF.savelibrary(saveName);
            testCase.addTeardown(@delete, saveName)

            % validate
            testCase.verifyTrue(testCase.BF.loadlibrary(saveName));

        end

        function newlibrary_event(testCase)
            % designate test file and confirm it does not already exist
            saveName = "loadtest.csv";
            assert(~isfile(saveName), "can't test newlibrary event if loadfile already exists");

            % save the library
            testCase.BF.savelibrary(saveName);
            testCase.addTeardown(@delete, saveName)

            % Add a listener for the event
            listener = addlistener(testCase.BF, 'NewLibrary', @(src, event) ...
                testCase.verifyTrue(true, 'Event NewLibrary was triggered'));
            testCase.addTeardown(@delete, listener)

            % cause event
            testCase.BF.loadlibrary(saveName);

        end

        function simpleattach(testCase)
            testCase.BF.activeLanguage = "ES";

            f = uifigure("Name", "one", "Visible", "off");
            pb = uibutton(f, "Text", "two");
            testCase.addTeardown(@delete, f)

            testCase.BF.attach(f);

            testCase.verifyTrue(strcmp(pb.Text, "dos")); % strcmp allows char/string comparisons

        end

        function singlehook(testCase)
            testCase.BF.activeLanguage = "ES";

            f = uifigure("Name", "one", "Visible", "off");
            pb = uibutton(f, "Text", "two");
            testCase.addTeardown(@delete, f)

            testCase.BF.attach(f);

            % call second time to confirm no errors
            testCase.BF.attach(f);

        end

    end

end