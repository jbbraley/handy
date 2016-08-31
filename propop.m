function class = propop(class,fhandle,delim)
%% propop
% Populates the class properties from a text file
%
% class - handle of class with properties to be populated
% fhandle - file handle for data file that contains property values
% delim - file content delimiter
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
% Determine longest dimension
if length(strsplit(contents{1},delim))>=size(contents,1) || length(strsplit(contents{1},delim))==1
	headerdim = 'R'; % 2 is the longest dimension or only one entry
else
    headerdim = 'C'; % 1 is the longest dimension
end
% Read header strings
header = fhandle.pullheader(contents,delim,headerdim,1);
% Read corresponding values
vals = fhandle.pullheader(contents,delim,headerdim,2);

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
    propval = str2num(vals{ii});
    % Error handle non-numeric value
    if isempty(propval)
        % Store value as string
        propval = vals{ii};
    end
    % Assign value to property
    class.(prop{propind}) = propval;
end
    
    
end
