classdef BFishClass < matlab.mixin.SetGetExactNames
    %BFISHCLASS A lightweight framework for internationalization of GUI and command-line strings.
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        isActive logical        = true          % logical, translates when true, pass-through when false
        libraryFilename string  = string([])    % source of current library, used for future load/save unless otherwise specified
        LibraryTable table      = table         % table used for 'translating' strings
        activeLanguage string   = string([])    % the language (column) from the LibraryTable currently in use

    end

    properties (Dependent)
        isLibraryLoaded % ??? is this necessary?
        localLanguageCode string                % system language code (if detectable)

    end

    properties (Constant)
        defaultLanguageCode string = "EN"       % name used for column 1 when not otherwise specified in LibraryTable
        defaultLanguageDisc string = "Default"  % description for default language used in new LibraryTable

    end

    events
        NewLibrary  % a new library has been loaded, application may wish to refresh lists etc.
        NewLanguage % a new language has been selected

    end
    
    methods
        function obj = BFishClass(libraryFilename)
            %BFISHCLASS Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                libraryFilename string = string([])
            end

            % load library if file provided
            if ~isempty(libraryFilename)
                obj.loadlibrary(libraryFilename);

            end

            % create default library if none available
            if isempty(obj.LibraryTable)
                obj.makenewlibrary;

            end

        end % BFishClass

        %% -----------------------------------------------------------------------------------------
        function value = get.isLibraryLoaded(obj)
            value = ~isempty(obj.libraryFilename);

        end % get.isLibraryLoaded


        %% -----------------------------------------------------------------------------------------
        function languageCode = get.localLanguageCode(obj)
            % get.localLanguageCode query the Java subsystem to determine local 2-letter language code.
            %
            try % to query subsystem
                locale = java.util.Locale.getDefault();
                languageCode = char(locale.getLanguage());

            catch % use class default
                languageCode = obj.defaultLanguageCode;

            end

            languageCode = string(upper(languageCode)); % formatting

        end

        %% -----------------------------------------------------------------------------------------
        function makenewlibrary(obj)
            % MAKENEWLIBRARY creates a new barebones library for building out new translations
            %
            obj.LibraryTable = table("Hello", VariableNames=[obj.defaultLanguageCode]);
            obj.LibraryTable.Properties.VariableDescriptions = obj.defaultLanguageDisc;
            obj.activeLanguage = obj.defaultLanguageCode;

        end % makenewlibrary

        %% -----------------------------------------------------------------------------------------
        function isLoaded = loadlibrary(obj, libraryFilename, Options)
            % LOADLIBRARY loads the library file used for translation in to memory
            %
            arguments
                obj BFishClass
                libraryFilename {mustBeText} = obj.libraryFilename % use existing filename if none passed
                Options.RefreshOnLoad (1,1) logical = true
            end

            % defaults
            isLoaded = false;

            try % to load library in to memory
                % determine which library to use
                isFileAvailable = ~isempty(libraryFilename) && isfile(libraryFilename);
                assert(isFileAvailable, 'BFishClass:loadlibrary:noLibraryFile', 'Function loadlibrary requires a library filename.');

                % pull in file
                NewLibraryTable = readtable(libraryFilename, ...
                    "ReadVariableNames", true, ...
                    "VariableNamingRule", "preserve", ...
                    "TextType", "string");

                % pull out descriptions
                varDiscriptions = NewLibraryTable{1,:};
                NewLibraryTable.Properties.VariableDescriptions = varDiscriptions;
                NewLibraryTable(1,:) = [];

                % any quality checks

                % make the new library active
                obj.LibraryTable = NewLibraryTable;
                obj.libraryFilename = libraryFilename;

                % determine active language
                languages = obj.listlanguages;
                isCurrentLanguageInLibrary = ~isempty(obj.activeLanguage) && ismember(obj.activeLanguage, languages);
                if ~isCurrentLanguageInLibrary
                    obj.activeLanguage = languages(1);
                end

                % load successful
                % --- add logging here ---
                isLoaded = true;

            catch % error when loading
                % notify error occurred
                % --- add logging here ---     

            end

            % (optionally) refresh gui when loading new library
            if isLoaded && Options.RefreshOnLoad
                obj.refreshgui;

            end

            % notify if successful
            if isLoaded
                notify(obj, "NewLibrary")

            end

        end % loadlibrary

        %% -----------------------------------------------------------------------------------------
        function isSaved = savelibrary(obj, libraryFilename)
            % SAVELIBRARY saves the in memory translation table to the specified file
            %
            arguments
                obj BFishClass
                libraryFilename {mustBeText} = obj.libraryFilename % use existing filename if none passed
            end

            % defaults
            isSaved = false;

            try % to save out the file
                % generate name if none available
                isNameNeeded = isempty(libraryFilename);
                if isNameNeeded
                    libraryFilename = strcat("bfishlibrary_", string(datetime("now", Format='yyyyMMdd_hhmm')), ".csv");

                end

                % pull out variable descriptions
                DiscTable = table('Size', [0, width(obj.LibraryTable)], ...
                    'VariableTypes', varfun(@class, obj.LibraryTable, 'OutputFormat', 'cell'), ...
                    'VariableNames', obj.LibraryTable.Properties.VariableNames);
                DiscTable(1,:) = obj.LibraryTable.Properties.VariableDescriptions;

                % write out the table
                OutTable = [DiscTable; obj.LibraryTable];
                writetable(OutTable, libraryFilename)

                % make this the active library filename
                obj.libraryFilename = libraryFilename;

                % save successful
                % --- add logging here ---
                isSaved = true;

            catch % error when saving
                % --- add logging here ---

            end

        end % savelibrary

        %% -----------------------------------------------------------------------------------------
        function languages = listlanguages(obj)
            % LISTLANGUAGES returns, as a string array, the list of languages in the loaded library
            %
            if isempty(obj.LibraryTable)
                languages = string([]);

            else
                languages = string(obj.LibraryTable.Properties.VariableNames);

            end

        end % listlanguages

        %% -----------------------------------------------------------------------------------------
        function isChanged = changelanguage(obj, newLangSelector, Options)
            % CHANGELANGUAGE selects a new active language
            %
            arguments
                obj BFishClass
                newLangSelector
                Options.RefreshOnLoad (1,1) logical = true
            end

            % defaults
            isChanged = false;

            % be flexible with the method of update
            languages = obj.listlanguages;
            nLanguages = numel(languages);
            if isnumeric(newLangSelector)
                isValidNumericChoice = newLangSelector >= 1 && newLangSelector <= nLanguages;
                if isValidNumericChoice
                    obj.activeLanguage = languages(newLangSelector);
                    isChanged = true;

                end

            else
                isValidTextChoice = ismember(newLangSelector, languages);
                if isValidTextChoice
                    obj.activeLanguage = newLangSelector;
                    isChanged = true;

                end

            end

            % (optionally) refresh gui when loading new library
            if isChanged && Options.RefreshOnLoad
                obj.refreshgui;

            end

            % notify if successful
            if isChanged
                notify(obj, "NewLanguage");

            end

        end % changelanguage

        %% -----------------------------------------------------------------------------------------
        function refreshgui(obj)
            % REFRESHGUI reprocess the attached GUI(s) with current library and active language
            %


        end % refreshgui

        %% -----------------------------------------------------------------------------------------
        function isAttached = attach(obj, guiHandle)
            % ATTACH calls HOOK on relevant gui properties and recursively calls ATTACH on component children
            %

            % create list of properties to look for, these can be 'normal'
            % string properties or they can be "Text" objects ('matlab.graphics.primitive.Text')
            textObjNames = ["Title", "Subtitle", "XLabel", "YLabel", "ZLabel", "LatitudeLabel", "LongitudeLabel"];
            simpleNames = ["AltText", "Name", "Placeholder", "String", "Text", "Title", "Tooltip"];
            propNames = unique([textObjNames, simpleNames]);

            % process the possible properties
            for propName = propNames
                isPropPresent = isprop(guiHandle, propName);
                if isPropPresent
                    switch class(guiHandle.(propName))
                        case 'matlab.graphics.primitive.Text'
                            obj.hook(guiHandle.(propName), "String");

                        otherwise
                            obj.hook(guiHandle, propName)

                    end

                end

            end

            % Legend has a title "Text" object and a regular "String"
            isLegendPresent = isprop(guiHandle, "Legend") && ~isempty(guiHandle.Legend);
            if isLegendPresent
                obj.hook(guiHandle.Legend.Title, "String");
                obj.hook(guiHandle.Legend, "String");

            end

            % Children
            isChildPresent = isprop(guiHandle, "Children") && ~isempty(guiHandle.Children);
            if isChildPresent
                for child = guiHandle.Children
                    obj.attach(child);

                end

            end

            % some properties can be objects that can have children of their own
            propsWithChildren = ["Toolbar", "ContextMenu"];
            for propWithChildren = propsWithChildren
                isPropPresent = isprop(guiHandle, propWithChildren);
                if isPropPresent
                    for child = guiHandle.(propWithChildren).Children
                        obj.attach(child);

                    end

                end

            end

        end % attach

        %% -----------------------------------------------------------------------------------------
        function hook(obj, guiHandle, propName)
            % HOOK creates the dynamic property and adds a listener to enable on-the-fly translation
            %

            % add dynamic property
            bfPropName = strcat(propName, "_BF");
            dp = guiHandle.addprop(bfPropName);
            dp.SetObservable = true;

            % add listener for change to dynamic property
            addlistener(guiHandle, bfPropName, 'PostSet', @obj.responder);

            % translate this component (by changing dev string, triggering
            % our recently attached listener
            guiHandle.(bfPropName) = guiHandle.(propName);

        end % hook

        %% -----------------------------------------------------------------------------------------
        function responder(obj, src, eventData)
            % RESPONDER called by listener events when a dynamic property value is changed
            %
            arguments
                obj BFishClass
                src
                eventData
            end

            bfPropName = src.Name;
            propName = regexprep(bfPropName, '_BF$', '');
            guiHandle = eventData.AffectedObject;

            guiHandle.(propName) = obj.translate(guiHandle.(bfPropName));

        end % responder

        %% -----------------------------------------------------------------------------------------
        function outText = translate(obj, inText)
            % TRANSLATE uses input text as lookup key against loaded library to return output text
            %

            % https://www.mathworks.com/help/matlab/ref/matlab.ui.control.uicontrol-properties.html?searchHighlight=uicontrol&s_tid=srchtitle_support_results_2_uicontrol
            % https://www.mathworks.com/help/matlab/characters-and-strings.html

            % there are at least 5 different types possible for text properties
            % 1. Character vector:                  'One'
            % 2. Cell array of character vectors:   {'One','Two','Three'}
            % 3. String array:                      ["One" "Two" "Three"]
            % 4. Categorical array:                 categorical({'one','two','three'})
            % 5. Pipe-delimited row vector:         'One|Two|Three'
            
            try % to process inText
                % prep
                wordList = obj.LibraryTable{:,1};

                switch (class(inText))
                    case 'char' % char vector & pipe-delimited row vector
                        inWords = string(strsplit(inText, '|'));
                        nOut = 0;
                        for word = inWords
                            idx = find(strcmp(word, wordList), 1);
                            isInLibrary = ~isempty(idx);
                            if isInLibrary % translate
                                outWord = obj.LibraryTable{idx, obj.activeLanguage};
                                if isempty(outWord) % active language has no replacement for this word
                                    outWord = word;

                                end

                            else % append new word to library
                                obj.appendlibrary(word);
                                outWord = word;

                            end
                            nOut = nOut + 1;
                            outWords(nOut) = outWord;

                        end
                        outText = char(strjoin(outWords, '|')); % preserve input type

                    case 'cell' % cell array of char vector
                        for thisCell = inText
                            % * do stuff *
                        end

                    case 'string' % string array
                        for thisText = inText
                            % * do stuff *
                        end

                    case 'categorical'

                end

            catch % fail gracefully - copy inString to outString
                outText = inText;

            end

            return

            %% internal functions ------------------------------------------------------------------
            function subStrings = splitstringontags(inputString)
                % Regular expression to match either HTML tags or text
                pattern = '(<[^>]+>)|([^<]+)';

                % Use regexp to extract all parts (tags and text)
                subStrings = regexp(inputString, pattern, 'match');

            end
            
            function [leadingWhitespace, mainString, trailingWhitespace] = preservepadding(inputString)
                % Define the regular expression pattern
                pattern = '^(\s*)(\S.*?\S|\S?)(\s*)$';

                % Apply the regular expression
                tokens = regexp(inputString, pattern, "tokens");

                % Extract the matched groups
                matches = tokens{1}; % Extract the first match
                leadingWhitespace = matches{1};
                mainString = matches{2};
                trailingWhitespace = matches{3};

            end

            function isTag = istag(inputString)
                isTag = startsWith(inputString, '<') && endsWith(inputString, '>');

            end

        end % translate

        function appendlibrary(obj, newWord)
            %% APPENDLIBRARY adds a new word to the LibraryTable
            %


        end % appendlibrary
        
    end

end

