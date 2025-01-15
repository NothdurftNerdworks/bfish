classdef BFishClass < matlab.mixin.SetGetExactNames
    %BFISHCLASS A lightweight framework for internationalization of GUI and command-line strings.
    %   Detailed explanation goes here
    
    properties
        isActive logical            = true          % logical, translates when true, pass-through when false
        ME MException               = MException.empty  % store last error that occurred for troubleshooting

    end

    properties (SetAccess = private)
        libraryFilename string      = string([])    % source of current library, used for future load/save unless otherwise specified
        LibraryTable table          = table         % table used for 'translating' strings             

    end

    properties (Dependent)
        isLibraryLoaded % ??? is this necessary?
        localLanguage string                        % system language code (if detectable)
        languages string                            % string array of languages in current library
        activeLanguage string                       % the language (column) from the LibraryTable currently in use (untyped for flexibility)

    end

    properties (Access = private, Hidden = true)
        thisActiveLanguage string   = string([])    % store the language in use internally

    end

    events
        NewLibrary  % a new library has been loaded, application may wish to refresh lists etc.
        NewLanguage % a new language has been selected
        SilentError % occurrs when a new error is caught and our 'ME' property is updated

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
        function language = get.localLanguage(obj)
            % get.localLanguageCode query the Java subsystem to determine local 2-letter language code.
            %

            try % to query subsystem
                locale = java.util.Locale.getDefault();
                language = locale.getLanguage();

            catch err
                % log error
                obj.ME = err;

                % recover
                isTablePresent = ~isempty(obj.LibraryTable);
                if isTablePresent % default to development language
                    language = obj.languages(1);

                else % no local language to use
                    language = missing;

                end

            end

            language = upper(string(language)); % formatting

        end % get.localLanguage

        %% -----------------------------------------------------------------------------------------
        function languages = get.languages(obj)
            % LISTLANGUAGES returns, as a string array, the list of languages in the loaded library
            %

            if isempty(obj.LibraryTable)
                languages = string([]);

            else
                languages = string(obj.LibraryTable.Properties.VariableNames);

            end

        end % get.languages

        %% -----------------------------------------------------------------------------------------
        function activeLang = get.activeLanguage(obj)
            % GET.ACTIVELANGUAGE property get method to designate the language (column) of the LibraryTable to use
            %   dependent property that returns value from private property 'thisActiveLanguage'

            activeLang = obj.thisActiveLanguage;

        end % get.activeLanguage(obj)

        %% -----------------------------------------------------------------------------------------
        function set.activeLanguage(obj, newLangSelector)
            % SET.ACTIVELANGUAGE property set method to designate the language (column) of the LibraryTable to use
            %   needs access to other class properties so we designate as 'dependent' and implement a private
            %   property 'thisActiveLanguage' for storing the value.

            try % to decipher input and update language accordingly
                % defaults
                isChanged = false;

                isNumber = isnumeric(newLangSelector) || all(isstrprop(newLangSelector, "digit"));
                if isNumber
                    newLangSelector = str2double(newLangSelector);
                    nLanguages = numel(obj.languages);
                    isValidNumericChoice = newLangSelector >= 1 && newLangSelector <= nLanguages;
                    assert(isValidNumericChoice, ...
                        'BFishClass:set_activeLanguage:numberBeyondLimit', ...
                        sprintf("Requested value: %d is outside LibraryTable range: [1 %d]", newLangSelector, nLanguages));

                    obj.thisActiveLanguage = obj.languages(newLangSelector);
                    isChanged = true;

                else % check against library variable names
                    isValidNameChoice = ismember(upper(newLangSelector), obj.languages);
                    if isValidNameChoice
                        obj.thisActiveLanguage = upper(newLangSelector);
                        isChanged = true;

                    else % check library variable descriptions
                        discIdx = find(strcmpi(newLangSelector, obj.LibraryTable.Properties.VariableDescriptions), 1);
                        isValidDiscChoice = ~isempty(discIdx);
                        if isValidDiscChoice
                            obj.thisActiveLanguage = obj.languages(discIdx);
                            isChanged = true;

                        else % we are unable to change
                            assert(isNumber || isValidNameChoice || isValidDiscChoice, ...
                                'BFishClass:set_activeLanguage:langNotInLibrary', ...
                                sprintf("Requested language: %s is not present in current LibraryTable", newLangSelector));

                        end

                    end

                end

                % notify if successful
                if isChanged
                    notify(obj, "NewLanguage");
                end

            catch err % failure to update language
                obj.ME = err;

            end

        end % set.activelanguage

        %% -----------------------------------------------------------------------------------------
        function set.ME(obj, val)
            % SET.ME property set method to enable notifications
            %

            obj.ME = val;
            notify(obj, "SilentError");

        end % set.ME

        %% -----------------------------------------------------------------------------------------
        function isMade = makenewlibrary(obj)
            % MAKENEWLIBRARY creates a new example library for building out new translations
            %

            % make the LibraryTable
            langCodeStrings = ["EN", "ZH", "HI", "ES", "FR"];
            langDiscStrings = ["English", "Chinese", "Hindi", "Spanish", "French"];
            enStrings = ["Hello"; "one"; "two"; "three"];
            zhStrings = ["你好"; "一"; "二"; "三"];
            hiStrings = ["नमस्ते"; "एक"; "दो"; "तीन"];
            esStrings = ["Hola"; "uno"; "dos"; "tres"];
            frStrings = ["Bonjour"; "un"; "deux"; "trois"];

            T = table(enStrings, zhStrings, hiStrings, esStrings, frStrings, ...
                VariableNames=langCodeStrings);
            T.Properties.VariableDescriptions = langDiscStrings;
            obj.LibraryTable = T;

            % set active language
            isLocalInLibrary = ismember(obj.localLanguage, obj.languages);
            if isLocalInLibrary
                obj.activeLanguage = obj.localLanguage;

            else
                obj.activeLanguage = obj.languages(1);

            end

            % outcome
            isMade = true;

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
                assert(isFileAvailable, ...
                    'BFishClass:loadlibrary:noLibraryFile', ...
                    'Function loadlibrary requires the filename of an existing file.');

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
                isCurrentLanguageInLibrary = ~isempty(obj.activeLanguage) && ismember(obj.activeLanguage, obj.languages);
                if ~isCurrentLanguageInLibrary
                    obj.activeLanguage = obj.languages(1);
                end

                % load successful
                % --- add logging here ---
                isLoaded = true;

            catch err % error when loading
                % notify error occurred
                % --- add logging here ---
                obj.ME = err;

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
            nLanguages = numel(obj.languages);
            if isnumeric(newLangSelector)
                isValidNumericChoice = newLangSelector >= 1 && newLangSelector <= nLanguages;
                if isValidNumericChoice
                    obj.activeLanguage = obj.languages(newLangSelector);
                    isChanged = true;

                end

            else
                isValidTextChoice = ismember(newLangSelector, obj.languages);
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
                switch (class(inText))
                    case 'char' % char vector & pipe-delimited row vector
                        inString = string(inText);                                      % char to string
                        inStrArray = strsplit(inString, '|');                           % handle pipe-delimited
                        outStrArray = obj.translatestrings(inStrArray);                              % *process string array*
                        outString = strjoin(outStrArray, '|');                          % redo pipe-delimeter
                        outText = char(outString);                                      % string to char

                    case 'cell' % cell array of char vector
                        inStrArray = string(inText);                                    % cell array to string array
                        outStrArray = obj.translatestrings(inStrArray);                              % *process string array*
                        outText = arrayfun(@char, outStrArray, 'UniformOutput', false); % string array to cell array

                    case 'string' % string array
                        outText = obj.translatestrings(inText);                                      % *process string array*

                    case 'categorical' 
                        inStrArray = string(categories(inText));                        % get string array of category names
                        outStrArray = obj.translatestrings(inStrArray);                              % *process string array*
                        outText = renamecats(inText, inStrArray, outStrArray);          % rename categories

                    otherwise % pass-through
                        outText = inText; 

                end

            catch % fail gracefully - copy inString to outString
                outText = inText;

            end

            return

        end % translate

        %% -----------------------------------------------------------------------------------------
        function addword(obj, newWord)
            % ADDWORD adds a new word to the LibraryTable default language
            %

            % make row for new word that matches existing table
            WordTable = table('Size', [1, width(obj.LibraryTable)], ...
                'VariableTypes', varfun(@class, obj.LibraryTable, 'OutputFormat', 'cell'), ...
                'VariableNames', obj.LibraryTable.Properties.VariableNames);
            WordTable(1,1) = {newWord};

            % append to library
            obj.LibraryTable = [obj.LibraryTable; WordTable];

        end % addword

        %% -----------------------------------------------------------------------------------------
        function addlanguage(obj, langCode, langDisc)
            % ADDLANGUAGE
            %
            arguments
                obj BFishClass
                langCode string {mustBeText}
                langDisc string {mustBeText}
            end
            % confirm language not present in library
            isLangPresent = any(strcmp(langCode, obj.languages));
            assert(~isLangPresent, ...
                'BFishClass:addlanguage:langAlreadyExists', ...
                sprintf('Cannot add a new language (%s) with the same name as existing language.', langCode))

            % create single column table to match up with existing LibraryTable
            LangTable = table('Size', [height(obj.LibraryTable), 1], ...
                'VariableTypes', string("string"), ... % bug with table declaration expecting string array
                'VariableNames', langCode);
            LangTable.Properties.VariableDescriptions(langCode) = langDisc;

            % merge new language table with active library
            obj.LibraryTable = [obj.LibraryTable LangTable];

        end % addlanguage

        function askgoogle(obj)
            % ASKGOOGLE query translate.google.com for a specified language
            %   Auxilliary function to simplify adding new translations to the active library. 
            % 
            % NOTE: in principle this could be easily automated, but it would be using the free service in bad faith.
            %   It *might* be worth adding in a call with Google API user/pass but that seems like overkill for occasional use.

            % ask user which language they want to translate to
            requestedLang = input("Translate the library to what language? :","s");

            % open webpage
            url = strcat("https://translate.google.com/?", ...
                "sl=", obj.LibraryTable.Properties.VariableNames{1}, ...
                "&tl=", requestedLang, ...
                "&text=", strjoin(obj.LibraryTable{:,1}, "%7C"), ...
                "&op=translate");

            % prompt user to input results from webpage
            web(url);

            % parse results
            googleResults = input("Copy & paste results from Google here. :", "s");
            splitResults = strsplit(googleResults, "|");

            % add to library
            isLangPresent = any(strcmp(requestedLang, obj.languages));
            if ~isLangPresent
                obj.addlanguage(requestedLang, requestedLang);
            end
            obj.LibraryTable{:, requestedLang} = splitResults';

        end % askgoogle
        
    end

    methods (Access = private, Hidden = true, Sealed = true)
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
        function strings = translatestrings(obj, strings)
            % PROCESS
            %
            % work on each string in the array
            for wString = 1:numel(strings)
                % break strings in to logical parts
                parts = splitstringontags(strings(wString));

                % work on each part
                for wPart = 1:numel(parts)
                    part = parts(wPart);

                    % translate valid word candidates
                    isTranslatable = ~istag(part);
                    if isTranslatable
                        [pre, word, post] = preservepadding(part);

                        % locate word in library
                        wordList = obj.LibraryTable{:,1};
                        idx = find(strcmp(word, wordList), 1); % search for exact word first
                        if isempty(idx) % do case-insensitive search if no exact match
                            idx = find(strcmpi(word, wordList), 1);
                        end
                        isWordInLibrary = ~isempty(idx);

                        % act on word
                        if isWordInLibrary % replace
                            proposedReplacement = obj.LibraryTable{idx, obj.activeLanguage};
                            isReplacementValid = ~isempty(proposedReplacement) && ~ismissing(proposedReplacement);
                            if isReplacementValid
                                replacementWord = proposedReplacement;
                                replacementWord = matchcase(replacementWord, word);
                                replacementPart = pre + replacementWord + post;
                                parts(wPart) = replacementPart;

                            end

                        else % append word to library
                            obj.addword(word);

                        end

                    end

                end
                strings(wString) = strjoin(parts, "");

            end

            %% translatestrings: nested functions --------------------------------------------------
            function words = splitstringontags(inputString)
                % Regular expression to match either HTML tags or text
                pattern = '(<[^>]+>)|([^<]+)';

                % Use regexp to extract all parts (tags and text)
                words = regexp(inputString, pattern, 'match');

            end % splitstringontags

            function [leadingWhitespace, mainString, trailingWhitespace] = preservepadding(inputString)
                % Define the regular expression pattern
                pattern = '^(\s*)(\S.*?\S|\S?)(\s*)$';

                % Apply the regular expression
                tokens = regexp(inputString, pattern, "tokens");

                % Extract the matched groups
                matches = tokens{1}; % Extract the first match
                leadingWhitespace = matches(1);
                mainString = matches(2);
                trailingWhitespace = matches(3);

            end % preservepadding

            function word = matchcase(word, pattern)
                isUpper = strcmp(pattern, upper(pattern));
                if isUpper
                    word = upper(word);
                else
                    isLower = strcmp(pattern, lower(pattern));
                    if isLower
                        word = lower(word);
                    else
                        isFirstCap = ~isempty(regexp(pattern, '^[A-Z][a-z]*$', 'once'));
                        if isFirstCap
                            word = upper(extractBefore(word,2)) + extractAfter(word,1);
                        end

                    end

                end

            end % matchcase

            function isTag = istag(inputString)
                isTag = startsWith(inputString, '<') && endsWith(inputString, '>');

            end % istag

        end % translatestrings

    end

end

