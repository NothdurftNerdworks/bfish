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
            isAxis = any(class(guiHandle) == [ ...
                "matlab.ui.control.UIAxes", ...
                'matlab.graphics.axis.Axes', ...
                'matlab.graphics.axis.GeographicAxes', ...
                'matlab.graphics.axis.PolarAxes']);

            if isAxis
                % axis-related objects have "Text" objects
                for objName = ["Title", "Subtitle", "XLabel", "YLabel", "ZLabel", "LatitudeLabel", "LongitudeLabel"]
                    if isprop(guiHandle, objName)
                        % add dynamic property
                        bfPropName = "String_BF";
                        dp = guiHandle.(objName).addprop(bfPropName);
                        dp.SetObservable = true;

                        % add listener for change to dynamic property
                        addlistener(guiHandle.(objName), bfPropName, 'PostSet', @obj.translate);

                        % translate this component (by changing dev string, triggering
                        % our recently attached listener
                        guiHandle.(objName).String_BF = guiHandle.(objName).String;

                    end

                end

            else
                % other uicontrol and uicomponent have normal properties
                for propName = ["AltText", "Name", "Placeholder", "String", "Text", "Title", "Tooltip"]
                    if isprop(guiHandle, propName)
                        % add dynamic property
                        bfPropName = strcat(propName, "_BF");
                        dp = guiHandle.addprop(bfPropName);
                        dp.SetObservable = true;

                        % add listener for change to dynamic property
                        addlistener(guiHandle, bfPropName, 'PostSet', @obj.translate);

                        % translate this component (by changing dev string, triggering
                        % our recently attached listener
                        guiHandle.(bfPropName) = guiHandle.(propName);

                    end

                end

            end

            % recursively process all children & ContextMenu & Legend & Toolbar of guiHandle

            % Legend has
            % Title.String
            % String
            % pizza pizza pizza

            % Children
            isChildPresent = isprop(guiHandle, "Children") && ~isempty(guiHandle.Children);
            if isChildPresent
                for child = guiHandle.Children
                    obj.attach(child);

                end

            end

            % Toolbar
            isToolbarPresent = isprop(guiHandle, "Toolbar") && ~isempty(guiHandle.Toolbar);
            if isToolbarPresent
                for child = guiHandle.Toolbar.Children
                    obj.attach(child);

                end

            end

            % ContextMenu
            isContextMenuPresent = isprop(guiHandle, "ContextMenu") && ~isempty(guiHandle.ContextMenu);
            if isContextMenuPresent
                for child = guiHandle.ContextMenu.Children
                    obj.attach(child);

                end

            end

        end % attach

        function translate(obj, src, eventData)
            % https://www.mathworks.com/help/matlab/ref/matlab.ui.control.uicontrol-properties.html?searchHighlight=uicontrol&s_tid=srchtitle_support_results_2_uicontrol
            % https://www.mathworks.com/help/matlab/characters-and-strings.html

            % there are at least 5 different types possible for text properties
            % 1. Character vector:                  'One'
            % 2. Cell array of character vectors:   {'One','Two','Three'}
            % 3. String array:                      ["One" "Two" "Three"]
            % 4. Categorical array:                 categorical({'one','two','three'})
            % 5. Pipe-delimited row vector:         'One|Two|Three'












            

        end % translate

        function languages = listlanguages(obj)


        end % listlanguages
        
    end

end

