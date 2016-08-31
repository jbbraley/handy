function class = propop(class,fhandle,delim, RC)
%% propop
% Populates the class properties from a text file
%
% class - handle of class with properties to be populated
% fhandle - file handle for data file that contains property values
% delim - file content delimiter
% RC - string. 'R' or 'C'. row or column for header (each property label in a seperate column
%       or row)
%
% uses file class
% 
% author: John Braley
% create date: 31-Aug-2016 11:04:39
	
	
%% Error screen entry
if nargin<1
    error('Specifiy class handle and file handle');
end
if nargin<2
    error('Specify file handle')
end
if nargin<3; delim = ','; end


%% Get headers from data file
% Read in entire file
contents = fhandle.read();
if nargin<4
    % Determine longest dimension
    if length(strsplit(contents{1},delim))>=size(contents,1) || length(strsplit(contents{1},delim))==1
        RC = 'R'; % 2 is the longest dimension or only one entry
    else
        RC = 'C'; % 1 is the longest dimension
    end
end

switch RC
    case {'R'; 'r'; 'row'}
        headerdim = 0;
    case {'C'; 'c'; 'col'; 'column'}
        headerdim = 1;
end

%% Get headers from data file
% Read header strings
header = fhandle.pullheader(contents,delim,RC,1);
% Read corresponding values
if max(size(contents))==2 % If only 2 rows or columns in file
    % Read second column or row
    vals = fhandle.pullheader(contents,delim,RC,2);
else
    % Break up file contents by delimiter
    for ii = 1:size(contents,1)
        % Split single row at a time
        cont{ii} = strsplit(contents{ii},delim);
        % Record array length
        contL(ii) = length(cont{ii});
    end
    cellsize = [length(contL) max(contL)];
    
    % Initialize 'vals' as cell array
    vals = cell(cellsize(headerdim+1)-1,cellsize(~headerdim+1));
    % Fill cells with empty string to normalize behavior of empty fields
    vals(:,:) = {''};
    n=1;
    for ii = 1:length(cont)    
        % Record each set of property values in seperate columns
        if headerdim
            % Record row from column 2 to end so as to skip header column
            vals(1:length(cont{ii})-1,n) = cont{ii}(2:end);
            n=n+1;
        else 
            % Record row starting at row 2
            if ii==1; continue; end
            vals(n,1:length(cont{ii})) = cont{ii};
            n=n+1;
        end
    end
end

%% Get and match class properties
% Query class properties
prop = properties(class);
% Add wildcard to property names
for ii = 1:length(prop)
    expr(ii) = {[prop{ii} '*']};
end
% Find property that matches header and populate, for each header entry
for ii = 1:length(header)
    % wildcard match property name with entries
    match = regexp(header{ii},expr);
    % Find and index header with a match
    propind = find(~cellfun(@isempty,match));
    % Error screen 0 matches
    if isempty(propind)
        continue
    end
    
    % Try assigning corresponding value to property as a number
    % Initialize variable
    propval = [];
    % If there is only one value for each property label in file
    if size(vals,1)==1
        Value = vals{ii}; % Set each property value to single value
    else
        % Convert to character array
        Value = char(vals(:,ii));
    end
    
    % Try to convert to numeric array
    propval = str2num(Value);
    % Error handle non-numeric value
    if isempty(propval)
        % Store value as cell array of strings
        propval = vals(:,ii);
        % Remove empty Strings
        propval(strcmp('',propval)) = [];
    end
    % Assign value to property
    class.(prop{propind}) = propval;
end
    
    
end
