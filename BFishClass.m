classdef BFishClass < matlab.mixin.SetGetExactNames
    %BFISHCLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        listeners
        library

    end
    
    methods
        function obj = BFishClass
            %BFISHCLASS Construct an instance of this class
            %   Detailed explanation goes here
            

        end % BFishClass

        function isAttached = attach(obj, guiHandle)
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

        function hook(obj, guiHandle, propName)
            % add dynamic property
            bfPropName = strcat(propName, "_BF");
            dp = guiHandle.addprop(bfPropName);
            dp.SetObservable = true;

            % add listener for change to dynamic property
            addlistener(guiHandle, bfPropName, 'PostSet', @obj.responsder);

            % translate this component (by changing dev string, triggering
            % our recently attached listener
            guiHandle.(bfPropName) = guiHandle.(propName);

        end % hook

        function responsder(obj, src, eventData)
            bfPropName = src.Name;
            propName = regexprep(bfPropName, '_BF$', '');
            guiHandle = eventData.AffectedObject;

            guiHandle.(propName) = obj.translate(guiHandle.(bfPropName));

        end % responder

        function outString = translate(obj, inString)
            % https://www.mathworks.com/help/matlab/ref/matlab.ui.control.uicontrol-properties.html?searchHighlight=uicontrol&s_tid=srchtitle_support_results_2_uicontrol
            % https://www.mathworks.com/help/matlab/characters-and-strings.html

            % there are at least 5 different types possible for text properties
            % 1. Character vector:                  'One'
            % 2. Cell array of character vectors:   {'One','Two','Three'}
            % 3. String array:                      ["One" "Two" "Three"]
            % 4. Categorical array:                 categorical({'one','two','three'})
            % 5. Pipe-delimited row vector:         'One|Two|Three'
            
            try % to process inString
                switch(class(inString))
                    case 'char'
                        cells = strsplit(inString, '|');

                    case 'cell'

                    case 'string'

                    case 'categorical'

                end

            catch % fail gracefully - copy inString to outString
                outString = inString;

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

        function languages = listlanguages(obj)


        end % listlanguages
        
    end

end

