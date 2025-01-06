classdef BFishClass < matlab.mixin.SetGetExactNames
    %BFISHCLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        isActive logical = true
        LibraryTable table = table
        activeLanguage string = string([])

    end

    properties (Dependent)
        isLibraryLoaded

    end
    
    methods
        function obj = BFishClass(libraryFilename)
            %BFISHCLASS Construct an instance of this class
            %   Detailed explanation goes here

            arguments
                libraryFilename string = string([])
            end

            if ~isempty(libraryFilename)
                obj.loadlibrary(libraryFilename)

            end
            

        end % BFishClass

        %% -----------------------------------------------------------------------------------------
        function value = get.isLibraryLoaded(obj)
            value = ~isempty(obj.LibraryTable);

        end % get.isLibraryLoaded

        %% -----------------------------------------------------------------------------------------
        function loadlibrary(obj, libraryFilename)
            % LOADLIBRARY  loads the library file used for translation in to memory
            %   


        end % loadlibrary

        %% -----------------------------------------------------------------------------------------
        function savelibrary(obj, libraryFilename)
            % SAVELIBRARY  saves the in memory translation table to the specified file
            %


        end % savelibrary

        %% -----------------------------------------------------------------------------------------
        function languages = listlanguages(obj)
            % LISTLANGUAGES  returns, as a string array, the list of languages in the loaded library
            %

            if ~obj.isLibraryLoaded
                languages = string([]);
                return

            else

            end

        end % listlanguages

        %% -----------------------------------------------------------------------------------------
        function isAttached = attach(obj, guiHandle)
            % ATTACH  calls HOOK on relevant gui properties and recursively calls ATTACH on component children
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
            % HOOK  creates the dynamic property and adds a listener to enable on-the-fly translation
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
            % RESPONDER  called by listener events when a dynamic property value is changed
            %

            bfPropName = src.Name;
            propName = regexprep(bfPropName, '_BF$', '');
            guiHandle = eventData.AffectedObject;

            guiHandle.(propName) = obj.translate(guiHandle.(bfPropName));

        end % responder

        %% -----------------------------------------------------------------------------------------
        function outText = translate(obj, inText)
            % TRANSLATE  uses input text as lookup key against loaded library to return output text
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
                        cells = strsplit(inText, '|');
                        for thisCell = cells
                            % * do stuff *
                        end
                        outText = strjoin(cells, '|');

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

            function [leadingWhitespace, mainString, trailingWhitespace] = preservepadding(inputString)
                % Define the regular expression pattern
                pattern = '^(\s*)(\S.*?\S|\S?)(\s*)$';

                % Apply the regular expression
                tokens = regexp(inputString, pattern, "tokens");

                % Extract the matched groups
                leadingWhitespace = tokens{1}{1};
                mainString = tokens{1}{2};
                trailingWhitespace = tokens{1}{3};

            end

        end % translate
        
    end

end

