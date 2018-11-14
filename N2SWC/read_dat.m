function struc=read_dat(fname, strucname)
% READ_DAT(fname) reads a space delimited numeric file with one header line.
%
% If "fname" is omitted the function will prompt for the input file.
%
% Read in a whitespace delimited ASCII numeric file with a one line     
% header of variable names. The file must have a variable name for each 
% column of numbers.  This script will create a structure of numeric    
% column vectors with each column using the corresponding name from the 
% header line.                                                          
%
% Many programs will create these files such as Excel (.txt or .prn)
% and PSI-Plot.
%
% Example input file:
%
%   rt.dat:
% t x v
%   0.00000000000E+00    3.96999999999E-02    0.00000000000E+00
%   5.00258517937E-04    3.99697150269E-02   -7.44753444412E+00
%   1.00272303185E-03    3.98886295490E-02   -5.93834113393E-01
%   2.00322475159E-03    3.99375098253E-02    1.31980134594E-05
%
% Example usage and output:
%
%   s=read_dat('rt.dat');
%   plot(s.t,s.x, s.t,s.v)
%
% or
%
%   s=read_dat

% David Edwards <david@btdt.org>    Sat Apr  9 15:28:43 PDT 2005
% Mon May  2 23:01:25 PDT 2005 (line 50: Print the selected file name)

if (nargin == 0)
    [fname,ppath] = uigetfile( ...
{'*.csv;*.txt;*.prn;*.dat', 'ASCII Files (*.csv, *.txt, *.prn, *.dat)'; ...
        '*.csv','Comma Separated Vectors (*.csv)'; ...
        '*.txt','Excel Text (tab delimited) (*.txt)'; ...
        '*.prn','Excel Formatted Text (space delimited) (*.prn)'; ...
        '*.dat','PSI Plot Text (*.dat)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Select an ASCII whitespace delimited numeric file');

    if (fname == 0)
        error('No file selected.');
    else
        fname=[ppath,fname];
        ['Selected file: ' fname]
    end
end

fid=fopen(fname, 'r');

% Read in the header line of variable names
tline(1)='/';
while tline(1)=='/'
    tline=fgetl(fid);
end

ii=0
while 1
    if ~ischar(tline), break, end
    ii = ii +1
% skip to end if ii is not a multiple of 5?
    numline(1:2) = str2num(tline)
    freq(ii) = numline (1)
    power(ii) = numline(2)
    tline = fgetl(fid);
end
var_Names = fgetl(fid);

fclose(fid);

% Retrieving Observation Depth Representations (Port1/2/3...)
var_Names = deblank(var_Names);             % Remove trailing whitespace
var_Names = regexprep(var_Names,'^\s+',''); % Remove leading whitespace

% Load the string of variable names into a cell array
var_Names=regexprep(var_Names, '[,\s]+', ''','''); % t x-> t','x
var_Names=['var_Names={''', var_Names, '''};'];
eval(var_Names);

% Reorganize the var_names as Maqu formating: PORT1, PORT2...
ind_var=0;
for i=1:(floor(length(var_Names)/2)+1)
    if i>1
        ind_var=ind_var+1;
        inter_var_names{ind_var}=strcat(var_Names{2+2*(i-2)}, var_Names{3+2*(i-2)});
    end
end

% Check if the var_name duplicated & if it is change them into Port1SM/ST.
for i=1:ind_var
    var_names{i}=[];
end

for i=1:(ind_var-1)    
    if inter_var_names{i}==inter_var_names{i+1}
        var_names{i}=strcat(inter_var_names{i},'SM');
        var_names{i+1}=strcat(inter_var_names{i+1},'ST');     
    else
        if isempty(var_names{i})
            var_names{i}=inter_var_names{i};
        end
    end
end
% 
for i=1:length(var_names)
    if isempty(var_names{i})
        var_names{i}=inter_var_names{i};
    end
end

% This part can be used to find the index of certain line, 
% in which certain "string" you don't want to have in the text file.
% Find '#N/A' index in the text
%  textscan(fid,'',-1,'headerlines',-1,'headercolumns',0,...
% 						   'returnonerror',0,'emptyvalue',0, 'CollectOutput', true);
fid=fopen(fname, 'r');
Data =textscan(fid, '%s', 'delimiter', '\n', 'whitespace', '\t');
CStr = Data{1};
fclose(fid);
%% Replace 'N/A' with '-8888' as no available data.
IndexC = strfind(CStr, '#N/A');
Index = find(~cellfun('isempty', IndexC), 1);
Index1=[];

if isempty(Index)
    IndexC1=strfind(CStr, '* * *');
    Index1 = find(~cellfun('isempty', IndexC1), 1);
end

if ~isempty(Index)
    CStr=strrep(CStr, '#N/A', '-8888');

    FID = fopen(fname, 'w');
    if FID == -1, error('Cannot open file'), end
    fprintf(FID, '%s\n', CStr{:});
    fclose(FID);
elseif ~isempty(Index1)
    CStr=strrep(CStr, '* * *', '-8888'); 
    FID = fopen(fname, 'w');
    if FID == -1, error('Cannot open file'), end
    fprintf(FID, '%s\n', CStr{:});
    fclose(FID);
end

%%
% Read the date and data into a matrix and convert to a cell array and
% then into a structure using var_names.

fid=fopen(fname, 'r');
mat = textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f',-1,...
               'headerlines', 3,'headercolumns',0,...
               'returnonerror',0,'emptyvalue',0,'CollectOutput', true);

fclose(fid);

try_delimeter1=strfind(mat{1}(:,1), '/');
Index_try = find(~cellfun('isempty', try_delimeter1), 1);

if Index_try
    delimeter_mat='/';
    replace_dilimtr='/0';
    datetimeformat='yyyy/mm/ddHH:MM';
else
    delimeter_mat='-';
    replace_dilimtr='-0';
    datetimeformat='yyyy-mm-ddHH:MM';
end

i_end=length(mat{1}(:, 1));
for i=1:i_end %i=1:length(indx_single)
    mat_Date_Lnth(i,1)=length(mat{1}{i, 1});  % Unique values: 8 9 10
end

indx_m_d=find(mat_Date_Lnth==8);
mat{1}(indx_m_d,1)=strrep(mat{1}(indx_m_d,1), delimeter_mat, replace_dilimtr);

indx_slash=cell2mat(strfind(mat{1}(:,1), delimeter_mat)); % Unique values: 5 7 8
indx_xxx=find(mat_Date_Lnth==9);

mat_buffer=zeros(i_end,1);

mat_buffer(indx_xxx)=indx_slash(indx_xxx,2);

indx_mm_d=find(mat_buffer==8);
nFinal=mat_Date_Lnth(indx_mm_d,1)+1;

for i=1:length(nFinal)
    newstr=sprintf(repmat('0', 1, 10));
    newstr(setdiff(1:nFinal(i), 9))=mat{1}{indx_mm_d(i),1};
    mat{1}{indx_mm_d(i),1}=newstr;
end

indx_m_dd=find(mat_buffer==7);
nFinal1=mat_Date_Lnth(indx_m_dd,1)+1;

for i=1:length(nFinal1)
    newstr=sprintf(repmat('0', 1, 10));
    newstr(setdiff(1:nFinal1(i), 6))=mat{1}{indx_m_dd(i),1};
    mat{1}{indx_m_dd(i),1}=newstr;
end

mat_Date_Str=strcat(mat{1}(:, 1), mat{1}(:,2));
mat_Date=datenum(mat_Date_Str, datetimeformat);

%%

[n,m]=size(mat{2});


% dlmread adds a column of zeros if there is extra white space after the
% last column of numbers. Therefore, only get Nvar columns.
Nvar = size(var_names,2);

if (m >= Nvar)
    mat_Data = mat{2}(:,[1:Nvar]);
    var_names_mat=var_names;
else
    mat_Data=mat{2}(:,[1:m]);
    
    for i=1:m
        var_names_mat{i}=var_names{i};
    end
    
    Nvar=m;
end

mat_full=horzcat(mat_Date, mat_Data);
var_names_mat1=cat(2,{'Date_Time'}, var_names_mat);

c=mat2cell(mat_full,n,ones(1,(Nvar+1)));
struc=cell2struct(c,var_names_mat1,2);

% save(strucname, '-struct', 'struc');

%%
% % This part can be used to find the index of certain line, 
% % in which certain "string" you don't want to have in the text file.
% % Find '#N/A' index in the text
% Data = textscan(fid, '%s', 'delimiter', '\n', 'whitespace', '');
% CStr = Data{1,1};
% fclose(fid);
% 
% IndexC = strfind(CStr, '#N/A');
% Index = find(~cellfun('isempty', IndexC), 1);
% 
% % Remove the found '#N/A' involved line
% if ~isempty(Index)
%   CStr(1:Index - 1) = [];
% end
% % Save the file again:
% % FID = fopen(FileName, 'w');
% % if FID == -1, error('Cannot open file'), end
% % fprintf(FID, '%s\n', CStr{:});
