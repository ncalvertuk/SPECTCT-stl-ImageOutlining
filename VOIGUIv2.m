function varargout = VOIGUIv2(varargin)
% VOIGUIv2 MATLAB code for VOIGUIv2.fig
%      VOIGUIv2, by itself, creates a new VOIGUIv2 or raises the existing
%      singleton*.
%
%      H = VOIGUIv2 returns the handle to a new VOIGUIv2 or the handle to
%      the existing singleton*.
%
%      VOIGUIv2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VOIGUIv2.M with the given input arguments.
%
%      VOIGUIv2('Property','Value',...) creates a new VOIGUIv2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VOIGUIv2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VOIGUIv2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VOIGUIv2

% Last Modified by GUIDE v2.5 22-Jun-2018 16:48:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @VOIGUIv2_OpeningFcn, ...
    'gui_OutputFcn',  @VOIGUIv2_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before VOIGUIv2 is made visible.
function VOIGUIv2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VOIGUIv2 (see VARARGIN)

[FileName,PathName] = uigetfile('*.dcm','Select the CT file to open','MultiSelect', 'off');
dirlist = dir(PathName);
filelist = dirlist(~[dirlist.isdir]);
I = strfind(FileName,'_CT');
CTFixedFileName = FileName(1:(I+2));
Names = {filelist.name};
J = strfind(Names,CTFixedFileName);
nCTFiles = 0;for i = 1:length(J);nCTFiles = nCTFiles+~isempty(J{i});end
CT_img = zeros(512,512,nCTFiles);
progressbar('Opening CT Files')
for i = 1:nCTFiles
    cthdr{i} = dicm_hdr([PathName CTFixedFileName sprintf('%03d',i)  '.dcm']);
    CT_img(:,:,i) = double(dicm_img([PathName CTFixedFileName sprintf('%03d',i)  '.dcm']));
    progressbar(i./nCTFiles);
end
CTimgPosition = zeros(size(CT_img,3),3);
for i = 1:size(CT_img,3)
CTimgPosition(i,:) = cthdr{i}.ImagePositionPatient;
end
CTPixSize = cthdr{1}.PixelSpacing;
handles.CThdr = cthdr;
% CTSliceThick = cthdr{1}.SliceThickness;
handles.CTsize = size(CT_img);
handles.PixCent1 = CTimgPosition(1,1) + (0:(handles.CTsize(1)-1))*CTPixSize(1);
handles.PixCent2 =CTimgPosition(1,2) + (0:(handles.CTsize(2)-1))*CTPixSize(2);
handles.PixCent3 = CTimgPosition(:,3);
handles.CT_img = CT_img;

[FileName,PathName] = uigetfile('*.dcm','Select the SPECT file to open','MultiSelect', 'off');
handles.SPECT_img = double(squeeze(dicm_img([PathName FileName])));
handles.SPECTsize = size(handles.SPECT_img);
specthdr = dicm_hdr([PathName FileName]);
handles.SPECThdr = specthdr;
% SPECTscantime = specthdr.AcquisitionTime;
SPECTPixSize = specthdr.PixelSpacing;
SPECTSliceThick = specthdr.SliceThickness;
SPECTImagePosition = specthdr.Unknown_0054_0022.Item_1.ImagePositionPatient;
handles.SPECTPixCent1 = SPECTImagePosition(1) + (0:(handles.SPECTsize(1)-1))*SPECTPixSize(1);
handles.SPECTPixCent2 =  (SPECTImagePosition(2) + (0:(handles.SPECTsize(2)-1))*SPECTPixSize(2));
handles.SPECTPixCent3 = (SPECTImagePosition(3) - (0:(handles.SPECTsize(3)-1))*SPECTSliceThick);

% handles.CT_img = varargin{1};
% handles.PixCent1 = varargin{2};
% handles.PixCent2 = varargin{3};
% handles.PixCent3 = varargin{4};
% handles.SPECT_img = varargin{5};
[FileName,PathName] = uigetfile('*.stl','Select the STL files to open','MultiSelect', 'on');
if(iscell(FileName))
    for i = 1:length(FileName)
        [Surface{i},~] = ShortReadSTLFile([PathName FileName{i}]);
        handles.ROIs{i}{1} = Surface{i}.vertices';
        handles.surfvols(i) = MeshVolCalc(Surface{i})./1000;
    end
    handles.nSurfs = length(FileName);
else
    [Surface,~] = ShortReadSTLFile([PathName FileName]);
    handles.ROIs{1}{1} = Surface.vertices';
    handles.surfvols = MeshVolCalc(Surface)./1000;
    handles.nSurfs = 1;
end
handles.Surface = Surface;
handles.OrganNames = ['All' FileName];

% handles.ROIs = varargin{5};
% handles.OrganNames = ['All' varargin{6}];
% if (length(varargin) >5)
%     handles.SPECTPixCent1 = varargin{6};
%     handles.SPECTPixCent2 = varargin{7};
%     handles.SPECTPixCent3 = varargin{8};
% else
%     handles.SPECTPixCent1 = ((0:127)-127/2).*4.41964;
%     handles.SPECTPixCent2 = ((0:127)-127/2).*4.41964;
%     handles.SPECTPixCent3 = ((0:127)-127/2).*4.41964;
% end

handles.PixxSize = abs(handles.PixCent1(2) - handles.PixCent1(1));
handles.PixySize = abs(handles.PixCent2(2) - handles.PixCent2(1));
handles.PixzSize = abs(handles.PixCent3(2) - handles.PixCent3(1));
[handles.ROIs_x, handles.ROIs_y,handles.ROIs_z] = ResampROIs(handles.ROIs);
handles.ROIs_mat = ROICell2Mats(handles.ROIs);
handles.ROIs_temp_mat = handles.ROIs_mat;
handles.ROIs_temp_x = handles.ROIs_x;
handles.ROIs_temp_y = handles.ROIs_y;
handles.ROIs_temp_z = handles.ROIs_z;
handles.ImSize = size(handles.CT_img);
handles.ShiftAmount = str2double(get(handles.shiftam,'String'));
handles.RotateAmount = str2double(get(handles.rotateam,'String'));
set(handles.voitrans,'String',handles.OrganNames)
handles.VOIToTranslate = get(handles.voitrans,'Value')-1;
set(handles.slider1,'Min',1);
set(handles.slider1,'Max',handles.ImSize(1));
set(handles.slider1, 'SliderStep', [1/handles.ImSize(1) , 10/handles.ImSize(1) ]);
set(handles.slider2,'Min',1);
set(handles.slider2,'Max',handles.ImSize(2));
set(handles.slider2, 'SliderStep', [1/handles.ImSize(2) , 10/handles.ImSize(2) ]);
set(handles.slider3,'Min',1);
set(handles.slider3,'Max',handles.ImSize(3));
set(handles.slider3, 'SliderStep', [1/handles.ImSize(3) , 10/handles.ImSize(3) ]);
% handles.xSlice = round((handles.ImSize(1)-1).*get(handles.slider1,'Value'))+1;
handles.xSlice = round(get(handles.slider1,'Value'));
set(handles.Slice1,'String',num2str(handles.xSlice));
% handles.ySlice = round((handles.ImSize(2)-1).*get(handles.slider2,'Value'))+1;
handles.ySlice = round(get(handles.slider2,'Value'));
set(handles.slice2,'String',num2str(handles.ySlice));
% handles.zSlice = round((handles.ImSize(3)-1).*get(handles.slider3,'Value'))+1;
handles.zSlice = round(get(handles.slider3,'Value'));
set(handles.edit3,'String',num2str(handles.zSlice));
handles.Pixx = handles.PixCent1(handles.xSlice);
handles.Pixy = handles.PixCent2(handles.ySlice);
handles.Pixz = handles.PixCent3(handles.zSlice);
% handles.axes1 = ViewSingleSliceOverlay(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_x,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize);
% handles.axes2 = ViewSingleSliceOverlay(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_y,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize);
% handles.axes3 = ViewSingleSliceOverlay(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_z,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize);
handles.minvoxval = min(handles.CT_img(:));
handles.maxvoxval = max(handles.CT_img(:));
set(handles.minvalslider,'Min',min(handles.CT_img(:)));
set(handles.maxvalslider,'Min',min(handles.CT_img(:)));
set(handles.minvalslider,'Max',max(handles.CT_img(:)));
set(handles.maxvalslider,'Max',max(handles.CT_img(:)));
set(handles.minvalslider,'Value',min(handles.CT_img(:)));
set(handles.maxvalslider,'Value',max(handles.CT_img(:)));
set(handles.minvaltxt,'String',num2str(handles.minvoxval));
set(handles.maxvaltxt,'String',num2str(handles.maxvoxval))
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1,1);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1,1);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,0,1);
[~,handles.xSlice_SP] = min(abs(handles.SPECTPixCent1 - handles.PixCent1(handles.xSlice)));
[~,handles.ySlice_SP] = min(abs(handles.SPECTPixCent2 - handles.PixCent2(handles.ySlice)));
[~,handles.zSlice_SP] = min(abs(handles.SPECTPixCent3 - handles.PixCent3(handles.zSlice)));
handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP,0,1);
set(handles.axes1,'XLim',[min(handles.PixCent2) max(handles.PixCent2)]);
set(handles.axes1,'YLim',[min(handles.PixCent3) max(handles.PixCent3)]);
set(handles.axes2,'XLim',[min(handles.PixCent1) max(handles.PixCent1)]);
set(handles.axes2,'YLim',[min(handles.PixCent3) max(handles.PixCent3)]);
set(handles.axes3,'XLim',[min(handles.PixCent1) max(handles.PixCent1)]);
set(handles.axes3,'YLim',[min(handles.PixCent2) max(handles.PixCent2)]);
handles.vertshift1 = zeros(1+length(handles.ROIs_x),1);
handles.vertshift2 = zeros(1+length(handles.ROIs_x),1);
handles.vertshift3 = zeros(1+length(handles.ROIs_x),1);
handles.horizshift1 = zeros(1+length(handles.ROIs_x),1);
handles.horizshift2 = zeros(1+length(handles.ROIs_x),1);
handles.horizshift3 = zeros(1+length(handles.ROIs_x),1);
handles.rotam1 = str2double(get(handles.rotate1,'String')).*ones(1+length(handles.ROIs_x),1);
handles.rotam2 = str2double(get(handles.rotate2,'String')).*ones(1+length(handles.ROIs_x),1);
handles.rotam3 = str2double(get(handles.rotate3,'String')).*ones(1+length(handles.ROIs_x),1);
set(handles.axes1,'YDir','normal');
set(handles.axes2,'YDir','normal');
% set(handles.axes3,'YDir','normal');
% Choose default command line output for VOIGUIv2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes VOIGUIv2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = VOIGUIv2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.xSlice = round(get(handles.slider1,'Value'));
set(handles.Slice1,'String',num2str(handles.xSlice));
handles.Pixx = handles.PixCent1(handles.xSlice);
% handles.axes1 = ViewSingleSliceOverlay(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_x,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize);
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1);
[~,handles.xSlice_SP] = min(abs(handles.SPECTPixCent1 - handles.PixCent1(handles.xSlice)));
handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.ySlice = round(get(handles.slider2,'Value'));
set(handles.slice2,'String',num2str(handles.ySlice));
handles.Pixy = handles.PixCent2(handles.ySlice);
% handles.axes2 = ViewSingleSliceOverlay(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_y,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1);

[~,handles.ySlice_SP] = min(abs(handles.SPECTPixCent2 - handles.PixCent2(handles.ySlice)));
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.zSlice = round(get(handles.slider3,'Value'));
set(handles.edit3,'String',num2str(handles.zSlice));
handles.Pixz = handles.PixCent3(handles.zSlice);
% handles.axes3 = ViewSingleSliceOverlay(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_z,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval);
[~,handles.zSlice_SP] = min(abs(handles.SPECTPixCent3 - handles.PixCent3(handles.zSlice)));
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP,0,1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in up1button.
function up1button_Callback(hObject, eventdata, handles)
% hObject    handle to up1button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.VOIToTranslate < 1)
    handles.vertshift1 = handles.vertshift1+handles.ShiftAmount;
    handles.vertshift2 = handles.vertshift2+handles.ShiftAmount;
else
    handles.vertshift1(handles.VOIToTranslate+1) = handles.vertshift1(handles.VOIToTranslate+1)+handles.ShiftAmount;
    handles.vertshift2(handles.VOIToTranslate+1) = handles.vertshift2(handles.VOIToTranslate+1)+handles.ShiftAmount;
end
set(handles.vert1,'String',num2str(handles.vertshift1(handles.VOIToTranslate+1)));
set(handles.vert2,'String',num2str(handles.vertshift2(handles.VOIToTranslate+1)));
if (handles.VOIToTranslate < 1)
    %     handles.ROIs_temp_x = shiftROI(handles.ROIs_temp_x,-1,3);
    %     handles.ROIs_temp_y = shiftROI(handles.ROIs_temp_y,-1,3);
    %     handles.ROIs_temp_z = shiftROI(handles.ROIs_temp_z,-1,3);
    handles.ROIs_temp_mat = shiftSingleROI(handles.ROIs_temp_mat,handles.ShiftAmount,3);
    %     handles.ROIs_temp_y = shiftSingleROI(handles.ROIs_temp_y,-1,3);
    %     handles.ROIs_temp_z = shiftSingleROI(handles.ROIs_temp_z,-1,3);
else
    %     handles.ROIs_temp_x{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_x{handles.VOIToTranslate},-1,3);
    %     handles.ROIs_temp_y{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_y{handles.VOIToTranslate},-1,3);
    %     handles.ROIs_temp_z{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_z{handles.VOIToTranslate},-1,3);
    handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:) = handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:)+handles.ShiftAmount;
end
% handles.axes1 = ViewSingleSliceOverlay(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_x,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize);
% handles.axes2 = ViewSingleSliceOverlay(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_y,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize);
% handles.axes3 = ViewSingleSliceOverlay(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_z,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize);
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval);
handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);
guidata(hObject, handles);

% --- Executes on button press in down1button.
function down1button_Callback(hObject, eventdata, handles)
% hObject    handle to down1button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.VOIToTranslate < 1)
    handles.vertshift1 = handles.vertshift1-handles.ShiftAmount;
    handles.vertshift2 = handles.vertshift2-handles.ShiftAmount;
else
    handles.vertshift1(handles.VOIToTranslate+1) = handles.vertshift1(handles.VOIToTranslate+1)-handles.ShiftAmount;
    handles.vertshift2(handles.VOIToTranslate+1) = handles.vertshift2(handles.VOIToTranslate+1)-handles.ShiftAmount;
end
set(handles.vert1,'String',num2str(handles.vertshift1(handles.VOIToTranslate+1)));
set(handles.vert2,'String',num2str(handles.vertshift2(handles.VOIToTranslate+1)));
if (handles.VOIToTranslate < 1)
    %     handles.ROIs_temp_x = shiftROI(handles.ROIs_temp_x,1,3);
    %     handles.ROIs_temp_y = shiftROI(handles.ROIs_temp_y,1,3);
    %     handles.ROIs_temp_z = shiftROI(handles.ROIs_temp_z,1,3);
    handles.ROIs_temp_mat = shiftSingleROI(handles.ROIs_temp_mat,-handles.ShiftAmount,3);
else
    %     handles.ROIs_temp_x{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_x{handles.VOIToTranslate},1,3);
    %     handles.ROIs_temp_y{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_y{handles.VOIToTranslate},1,3);
    %     handles.ROIs_temp_z{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_z{handles.VOIToTranslate},1,3);
    handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:) = handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:)-handles.ShiftAmount;
end
% handles.axes1 = ViewSingleSliceOverlay(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_x,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize);
% handles.axes2 = ViewSingleSliceOverlay(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_y,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize);
% handles.axes3 = ViewSingleSliceOverlay(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_z,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize);
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval);
handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);
guidata(hObject, handles);

% --- Executes on button press in left1button.
function left1button_Callback(hObject, eventdata, handles)
% hObject    handle to left1button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.VOIToTranslate<1)
    handles.horizshift1 = handles.horizshift1-handles.ShiftAmount;
    handles.vertshift3 = handles.vertshift3-handles.ShiftAmount;
else
    handles.horizshift1(handles.VOIToTranslate+1) = handles.horizshift1(handles.VOIToTranslate+1)-handles.ShiftAmount;
    handles.vertshift3(handles.VOIToTranslate+1) = handles.vertshift3(handles.VOIToTranslate+1)-handles.ShiftAmount;
end
set(handles.horiz1,'String',num2str(handles.horizshift1(handles.VOIToTranslate+1)));
set(handles.vert3,'String',num2str(handles.vertshift3(handles.VOIToTranslate+1)));
if (handles.VOIToTranslate<1)
    %     handles.ROIs_temp_x = shiftROI(handles.ROIs_temp_x,-1,2);
    %     handles.ROIs_temp_y = shiftROI(handles.ROIs_temp_y,-1,2);
    %     handles.ROIs_temp_z = shiftROI(handles.ROIs_temp_z,-1,2);
    handles.ROIs_temp_mat = shiftSingleROI(handles.ROIs_temp_mat,-handles.ShiftAmount,2);
else
    %     handles.ROIs_temp_x{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_x{handles.VOIToTranslate},-1,2);
    %     handles.ROIs_temp_y{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_y{handles.VOIToTranslate},-1,2);
    %     handles.ROIs_temp_z{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_z{handles.VOIToTranslate},-1,2);
    handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:) = handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:)-handles.ShiftAmount;
end
% handles.axes1 = ViewSingleSliceOverlay(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_x,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize);
% handles.axes2 = ViewSingleSliceOverlay(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_y,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize);
% handles.axes3 = ViewSingleSliceOverlay(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_z,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize);
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval);

handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);
guidata(hObject, handles);

% --- Executes on button press in right1button.
function right1button_Callback(hObject, eventdata, handles)
% hObject    handle to right1button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.VOIToTranslate<1)
    handles.horizshift1 = handles.horizshift1+handles.ShiftAmount;
    handles.vertshift3 = handles.vertshift3+handles.ShiftAmount;
else
    handles.horizshift1(handles.VOIToTranslate+1) = handles.horizshift1(handles.VOIToTranslate+1)+handles.ShiftAmount;
    handles.vertshift3(handles.VOIToTranslate+1) = handles.vertshift3(handles.VOIToTranslate+1)+handles.ShiftAmount;
end
set(handles.horiz1,'String',num2str(handles.horizshift1(handles.VOIToTranslate+1)));
set(handles.vert3,'String',num2str(handles.vertshift3(handles.VOIToTranslate+1)));
if (handles.VOIToTranslate<1)
    %     handles.ROIs_temp_x = shiftROI(handles.ROIs_temp_x,1,2);
    %     handles.ROIs_temp_y = shiftROI(handles.ROIs_temp_y,1,2);
    %     handles.ROIs_temp_z = shiftROI(handles.ROIs_temp_z,1,2);
    handles.ROIs_temp_mat = shiftSingleROI(handles.ROIs_temp_mat,handles.ShiftAmount,2);
else
    %     handles.ROIs_temp_x{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_x{handles.VOIToTranslate},1,2);
    %     handles.ROIs_temp_y{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_y{handles.VOIToTranslate},1,2);
    %     handles.ROIs_temp_z{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_z{handles.VOIToTranslate},1,2);
    handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:) = handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:)+handles.ShiftAmount;
end
% handles.axes1 = ViewSingleSliceOverlay(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_x,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize);
% handles.axes2 = ViewSingleSliceOverlay(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_y,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize);
% handles.axes3 = ViewSingleSliceOverlay(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_z,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize);
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval);

handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);
guidata(hObject, handles);

% --- Executes on button press in up2button.
function up2button_Callback(hObject, eventdata, handles)
% hObject    handle to up2button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.VOIToTranslate<1)
    handles.vertshift1 = handles.vertshift1+handles.ShiftAmount;
    handles.vertshift2= handles.vertshift2+handles.ShiftAmount;
else
    handles.vertshift1(handles.VOIToTranslate+1) = handles.vertshift1(handles.VOIToTranslate+1)+handles.ShiftAmount;
    handles.vertshift2(handles.VOIToTranslate+1) = handles.vertshift2(handles.VOIToTranslate+1)+handles.ShiftAmount;
end
set(handles.vert1,'String',num2str(handles.vertshift1(handles.VOIToTranslate+1)));
set(handles.vert2,'String',num2str(handles.vertshift2(handles.VOIToTranslate+1)));
if (handles.VOIToTranslate<1)
    %     handles.ROIs_temp_x = shiftROI(handles.ROIs_temp_x,-1,3);
    %     handles.ROIs_temp_y = shiftROI(handles.ROIs_temp_y,-1,3);
    %     handles.ROIs_temp_z = shiftROI(handles.ROIs_temp_z,-1,3);
    handles.ROIs_temp_mat = shiftSingleROI(handles.ROIs_temp_mat,handles.ShiftAmount,3);
else
    %     handles.ROIs_temp_x{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_x{handles.VOIToTranslate},-1,3);
    %     handles.ROIs_temp_y{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_y{handles.VOIToTranslate},-1,3);
    %     handles.ROIs_temp_z{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_z{handles.VOIToTranslate},-1,3);
    handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:) = handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:)+handles.ShiftAmount;
end
% handles.axes1 = ViewSingleSliceOverlay(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_x,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize);
% handles.axes2 = ViewSingleSliceOverlay(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_y,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize);
% handles.axes3 = ViewSingleSliceOverlay(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_z,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize);
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval);

handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);
guidata(hObject, handles);

% --- Executes on button press in down2button.
function down2button_Callback(hObject, eventdata, handles)
% hObject    handle to down2button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.VOIToTranslate<1)
    handles.vertshift1 = handles.vertshift1-handles.ShiftAmount;
    handles.vertshift2 = handles.vertshift2-handles.ShiftAmount;
else
    handles.vertshift1(handles.VOIToTranslate+1) = handles.vertshift1(handles.VOIToTranslate+1)-handles.ShiftAmount;
    handles.vertshift2(handles.VOIToTranslate+1) = handles.vertshift2(handles.VOIToTranslate+1)-handles.ShiftAmount;
end
set(handles.vert1,'String',num2str(handles.vertshift1(handles.VOIToTranslate+1)));
set(handles.vert2,'String',num2str(handles.vertshift2(handles.VOIToTranslate+1)));
if (handles.VOIToTranslate<1)
    %     handles.ROIs_temp_x = shiftROI(handles.ROIs_temp_x,1,3);
    %     handles.ROIs_temp_y = shiftROI(handles.ROIs_temp_y,1,3);
    %     handles.ROIs_temp_z = shiftROI(handles.ROIs_temp_z,1,3);
    handles.ROIs_temp_mat = shiftSingleROI(handles.ROIs_temp_mat,-handles.ShiftAmount,3);
else
    %     handles.ROIs_temp_x{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_x{handles.VOIToTranslate},1,3);
    %     handles.ROIs_temp_y{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_y{handles.VOIToTranslate},1,3);
    %     handles.ROIs_temp_z{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_z{handles.VOIToTranslate},1,3);
    handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:) = handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:)-handles.ShiftAmount;
end
% handles.axes1 = ViewSingleSliceOverlay(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_x,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize);
% handles.axes2 = ViewSingleSliceOverlay(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_y,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize);
% handles.axes3 = ViewSingleSliceOverlay(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_z,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize);
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval);

handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);
guidata(hObject, handles);

% --- Executes on button press in right2button.
function right2button_Callback(hObject, eventdata, handles)
% hObject    handle to right2button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.VOIToTranslate<1)
    handles.horizshift2 = handles.horizshift2+handles.ShiftAmount;
    handles.horizshift3 = handles.horizshift3+handles.ShiftAmount;
else
    handles.horizshift2(handles.VOIToTranslate+1) = handles.horizshift2(handles.VOIToTranslate+1)+handles.ShiftAmount;
    handles.horizshift3(handles.VOIToTranslate+1) = handles.horizshift3(handles.VOIToTranslate+1)+handles.ShiftAmount;
end
set(handles.horiz2,'String',num2str(handles.horizshift2(handles.VOIToTranslate+1)));
set(handles.horiz3,'String',num2str(handles.horizshift3(handles.VOIToTranslate+1)));
if (handles.VOIToTranslate<1)
    %     handles.ROIs_temp_x = shiftROI(handles.ROIs_temp_x,1,1);
    %     handles.ROIs_temp_y = shiftROI(handles.ROIs_temp_y,1,1);
    %     handles.ROIs_temp_z = shiftROI(handles.ROIs_temp_z,1,1);
    handles.ROIs_temp_mat = shiftSingleROI(handles.ROIs_temp_mat,handles.ShiftAmount,1);
else
    %     handles.ROIs_temp_x{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_x{handles.VOIToTranslate},1,1);
    %     handles.ROIs_temp_y{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_y{handles.VOIToTranslate},1,1);
    %     handles.ROIs_temp_z{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_z{handles.VOIToTranslate},1,1);
    handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:) = handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:)+handles.ShiftAmount;
end
% handles.axes1 = ViewSingleSliceOverlay(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_x,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize);
% handles.axes2 = ViewSingleSliceOverlay(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_y,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize);
% handles.axes3 = ViewSingleSliceOverlay(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_z,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize);
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval);

handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);
guidata(hObject, handles);

% --- Executes on button press in left2button.
function left2button_Callback(hObject, eventdata, handles)
% hObject    handle to left2button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.VOIToTranslate<1)
    handles.horizshift2 = handles.horizshift2-handles.ShiftAmount;
    handles.horizshift3 = handles.horizshift3-handles.ShiftAmount;
else
    handles.horizshift2(handles.VOIToTranslate+1) = handles.horizshift2(handles.VOIToTranslate+1)-handles.ShiftAmount;
    handles.horizshift3(handles.VOIToTranslate+1) = handles.horizshift3(handles.VOIToTranslate+1)-handles.ShiftAmount;
end
set(handles.horiz2,'String',num2str(handles.horizshift2(handles.VOIToTranslate+1)));
set(handles.horiz3,'String',num2str(handles.horizshift3(handles.VOIToTranslate+1)));
if (handles.VOIToTranslate<1)
    %     handles.ROIs_temp_x = shiftROI(handles.ROIs_temp_x,-1,1);
    %     handles.ROIs_temp_y = shiftROI(handles.ROIs_temp_y,-1,1);
    %     handles.ROIs_temp_z = shiftROI(handles.ROIs_temp_z,-1,1);
    handles.ROIs_temp_mat = shiftSingleROI(handles.ROIs_temp_mat,-handles.ShiftAmount,1);
else
    %     handles.ROIs_temp_x{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_x{handles.VOIToTranslate},-1,1);
    %     handles.ROIs_temp_y{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_y{handles.VOIToTranslate},-1,1);
    %     handles.ROIs_temp_z{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_z{handles.VOIToTranslate},-1,1);
    handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:) = handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:)-handles.ShiftAmount;
end
% handles.axes1 = ViewSingleSliceOverlay(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_x,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize);
% handles.axes2 = ViewSingleSliceOverlay(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_y,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize);
% handles.axes3 = ViewSingleSliceOverlay(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_z,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize);
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval);

handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);
guidata(hObject, handles);

% --- Executes on button press in up3button.
function up3button_Callback(hObject, eventdata, handles)
% hObject    handle to up3button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.VOIToTranslate<1)
    handles.horizshift1 = handles.horizshift1-handles.ShiftAmount;
    handles.vertshift3 = handles.vertshift3-handles.ShiftAmount;
else
    handles.horizshift1(handles.VOIToTranslate+1) = handles.horizshift1(handles.VOIToTranslate+1)-handles.ShiftAmount;
    handles.vertshift3(handles.VOIToTranslate+1) = handles.vertshift3(handles.VOIToTranslate+1)-handles.ShiftAmount;
end
set(handles.horiz1,'String',num2str(handles.horizshift1(handles.VOIToTranslate+1)));
set(handles.vert3,'String',num2str(handles.vertshift3(handles.VOIToTranslate+1)));
if (handles.VOIToTranslate<1)
    %     handles.ROIs_temp_x = shiftROI(handles.ROIs_temp_x,-1,2);
    %     handles.ROIs_temp_y = shiftROI(handles.ROIs_temp_y,-1,2);
    %     handles.ROIs_temp_z = shiftROI(handles.ROIs_temp_z,-1,2);
    handles.ROIs_temp_mat = shiftSingleROI(handles.ROIs_temp_mat,-handles.ShiftAmount,2);
else
    %     handles.ROIs_temp_x{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_x{handles.VOIToTranslate},-1,2);
    %     handles.ROIs_temp_y{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_y{handles.VOIToTranslate},-1,2);
    %     handles.ROIs_temp_z{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_z{handles.VOIToTranslate},-1,2);
    handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:) = handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:)-handles.ShiftAmount;
end
% handles.axes1 = ViewSingleSliceOverlay(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_x,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize);
% handles.axes2 = ViewSingleSliceOverlay(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_y,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize);
% handles.axes3 = ViewSingleSliceOverlay(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_z,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize);
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval);

handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);
guidata(hObject, handles);

% --- Executes on button press in down3button.
function down3button_Callback(hObject, eventdata, handles)
% hObject    handle to down3button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.VOIToTranslate<1)
    handles.horizshift1 = handles.horizshift1+handles.ShiftAmount;
    handles.vertshift3 = handles.vertshift3+handles.ShiftAmount;
else
    handles.horizshift1(handles.VOIToTranslate+1) = handles.horizshift1(handles.VOIToTranslate+1)+handles.ShiftAmount;
    handles.vertshift3(handles.VOIToTranslate+1) = handles.vertshift3(handles.VOIToTranslate+1)+handles.ShiftAmount;
end
set(handles.horiz1,'String',num2str(handles.horizshift1(handles.VOIToTranslate+1)));
set(handles.vert3,'String',num2str(handles.vertshift3(handles.VOIToTranslate+1)));
if (handles.VOIToTranslate<1)
    %     handles.ROIs_temp_x = shiftROI(handles.ROIs_temp_x,1,2);
    %     handles.ROIs_temp_y = shiftROI(handles.ROIs_temp_y,1,2);
    %     handles.ROIs_temp_z = shiftROI(handles.ROIs_temp_z,1,2);
    handles.ROIs_temp_mat = shiftSingleROI(handles.ROIs_temp_mat,handles.ShiftAmount,2);
else
    %     handles.ROIs_temp_x{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_x{handles.VOIToTranslate},1,2);
    %     handles.ROIs_temp_y{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_y{handles.VOIToTranslate},1,2);
    %     handles.ROIs_temp_z{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_z{handles.VOIToTranslate},1,2);
    handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:) = handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:)+handles.ShiftAmount;
end
% handles.axes1 = ViewSingleSliceOverlay(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_x,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize);
% handles.axes2 = ViewSingleSliceOverlay(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_y,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize);
% handles.axes3 = ViewSingleSliceOverlay(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_z,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize);
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval);

handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);
guidata(hObject, handles);

% --- Executes on button press in left4button.
function left4button_Callback(hObject, eventdata, handles)
% hObject    handle to left4button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.VOIToTranslate<1)
    handles.horizshift2 = handles.horizshift2-handles.ShiftAmount;
    handles.horizshift3 = handles.horizshift3-handles.ShiftAmount;
else
    handles.horizshift2(handles.VOIToTranslate+1) = handles.horizshift2(handles.VOIToTranslate+1)-handles.ShiftAmount;
    handles.horizshift3(handles.VOIToTranslate+1) = handles.horizshift3(handles.VOIToTranslate+1)-handles.ShiftAmount;
end
set(handles.horiz2,'String',num2str(handles.horizshift2(handles.VOIToTranslate+1)));
set(handles.horiz3,'String',num2str(handles.horizshift3(handles.VOIToTranslate+1)));
if (handles.VOIToTranslate<1)
    %     handles.ROIs_temp_x = shiftROI(handles.ROIs_temp_x,-1,1);
    %     handles.ROIs_temp_y = shiftROI(handles.ROIs_temp_y,-1,1);
    %     handles.ROIs_temp_z = shiftROI(handles.ROIs_temp_z,-1,1);
    handles.ROIs_temp_mat = shiftSingleROI(handles.ROIs_temp_mat,-handles.ShiftAmount,1);
else
    %     handles.ROIs_temp_x{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_x{handles.VOIToTranslate},-1,1);
    %     handles.ROIs_temp_y{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_y{handles.VOIToTranslate},-1,1);
    %     handles.ROIs_temp_z{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_z{handles.VOIToTranslate},-1,1);
    handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:) = handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:)-handles.ShiftAmount;
end
% handles.axes1 = ViewSingleSliceOverlay(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_x,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize);
% handles.axes2 = ViewSingleSliceOverlay(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_y,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize);
% handles.axes3 = ViewSingleSliceOverlay(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_z,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize);
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval);

handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);
guidata(hObject, handles);

% --- Executes on button press in right3button.
function right3button_Callback(hObject, eventdata, handles)
% hObject    handle to right3button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.VOIToTranslate<1)
    handles.horizshift2 = handles.horizshift2+handles.ShiftAmount;
    handles.horizshift3 = handles.horizshift3+handles.ShiftAmount;
else
    handles.horizshift2(handles.VOIToTranslate+1) = handles.horizshift2(handles.VOIToTranslate+1)+handles.ShiftAmount;
    handles.horizshift3(handles.VOIToTranslate+1) = handles.horizshift3(handles.VOIToTranslate+1)+handles.ShiftAmount;
end
set(handles.horiz2,'String',num2str(handles.horizshift2(handles.VOIToTranslate+1)));
set(handles.horiz3,'String',num2str(handles.horizshift3(handles.VOIToTranslate+1)));
if (handles.VOIToTranslate<1)
    %     handles.ROIs_temp_x = shiftROI(handles.ROIs_temp_x,1,1);
    %     handles.ROIs_temp_y = shiftROI(handles.ROIs_temp_y,1,1);
    %     handles.ROIs_temp_z = shiftROI(handles.ROIs_temp_z,1,1);
    handles.ROIs_temp_mat = shiftSingleROI(handles.ROIs_temp_mat,handles.ShiftAmount,1);
else
    %     handles.ROIs_temp_x{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_x{handles.VOIToTranslate},1,1);
    %     handles.ROIs_temp_y{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_y{handles.VOIToTranslate},1,1);
    %     handles.ROIs_temp_z{handles.VOIToTranslate} = shiftSingleROI(handles.ROIs_temp_z{handles.VOIToTranslate},1,1);
    handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:) = handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:)+handles.ShiftAmount;
end
% handles.axes1 = ViewSingleSliceOverlay(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_x,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize);
% handles.axes2 = ViewSingleSliceOverlay(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_y,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize);
% handles.axes3 = ViewSingleSliceOverlay(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_z,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize);
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval);

handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);
guidata(hObject, handles);


function Slice1_Callback(hObject, eventdata, handles)
% hObject    handle to Slice1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Slice1 as text
%        str2double(get(hObject,'String')) returns contents of Slice1 as a double


% --- Executes during object creation, after setting all properties.
function Slice1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Slice1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function slice2_Callback(hObject, eventdata, handles)
% hObject    handle to slice2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slice2 as text
%        str2double(get(hObject,'String')) returns contents of slice2 as a double


% --- Executes during object creation, after setting all properties.
function slice2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slice2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vert1_Callback(hObject, eventdata, handles)
% hObject    handle to vert1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vert1 as text
%        str2double(get(hObject,'String')) returns contents of vert1 as a double


% --- Executes during object creation, after setting all properties.
function vert1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vert1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function horiz1_Callback(hObject, eventdata, handles)
% hObject    handle to horiz1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of horiz1 as text
%        str2double(get(hObject,'String')) returns contents of horiz1 as a double


% --- Executes during object creation, after setting all properties.
function horiz1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to horiz1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vert2_Callback(hObject, eventdata, handles)
% hObject    handle to vert2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vert2 as text
%        str2double(get(hObject,'String')) returns contents of vert2 as a double


% --- Executes during object creation, after setting all properties.
function vert2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vert2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function horiz2_Callback(hObject, eventdata, handles)
% hObject    handle to horiz2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of horiz2 as text
%        str2double(get(hObject,'String')) returns contents of horiz2 as a double


% --- Executes during object creation, after setting all properties.
function horiz2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to horiz2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vert3_Callback(hObject, eventdata, handles)
% hObject    handle to vert3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vert3 as text
%        str2double(get(hObject,'String')) returns contents of vert3 as a double


% --- Executes during object creation, after setting all properties.
function vert3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vert3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function horiz3_Callback(hObject, eventdata, handles)
% hObject    handle to horiz3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of horiz3 as text
%        str2double(get(hObject,'String')) returns contents of horiz3 as a double


% --- Executes during object creation, after setting all properties.
function horiz3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to horiz3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in voitrans.
function voitrans_Callback(hObject, eventdata, handles)
% hObject    handle to voitrans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns voitrans contents as cell array
%        contents{get(hObject,'Value')} returns selected item from voitrans
handles.VOIToTranslate = get(hObject,'Value')-1;
set(handles.horiz1,'String',num2str(handles.horizshift1(handles.VOIToTranslate+1)));
set(handles.horiz2,'String',num2str(handles.horizshift2(handles.VOIToTranslate+1)));
set(handles.horiz3,'String',num2str(handles.horizshift3(handles.VOIToTranslate+1)));
set(handles.vert1,'String',num2str(handles.vertshift1(handles.VOIToTranslate+1)));
set(handles.vert2,'String',num2str(handles.vertshift2(handles.VOIToTranslate+1)));
set(handles.vert3,'String',num2str(handles.vertshift3(handles.VOIToTranslate+1)));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function voitrans_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voitrans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in clockwise1.
function clockwise1_Callback(hObject, eventdata, handles)
% hObject    handle to clockwise1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.VOIToTranslate<1)
    handles.rotam1 = handles.rotam1-handles.RotateAmount;    
else
    handles.rotam1(handles.VOIToTranslate+1) = handles.rotam1(handles.VOIToTranslate+1)-handles.RotateAmount;    
end
set(handles.rotate1,'String',num2str(handles.rotam1(handles.VOIToTranslate+1)));
cent = zeros(3,1);
if (handles.VOIToTranslate<1)
    cent(1) = (max(handles.PixCent1) - min(handles.PixCent1))./2 + min(handles.PixCent1);
    cent(2) = (max(handles.PixCent2) - min(handles.PixCent2))./2 + min(handles.PixCent2);
    cent(3) = (max(handles.PixCent3) - min(handles.PixCent3))./2 + min(handles.PixCent3);
else
    cent(1) = (max(handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:)) - min(handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:)))./2 + min(handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:));
    cent(2) = (max(handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:)) - min(handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:)))./2 + min(handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:));
    cent(3) = (max(handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:)) - min(handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:)))./2 + min(handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:));
end
handles.ROIs_temp_mat = rotateROI(handles.ROIs_temp_mat,cent,-handles.RotateAmount,2,3,handles.VOIToTranslate);
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval);

handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);
guidata(hObject, handles);


% --- Executes on button press in anticlock1.
function anticlock1_Callback(hObject, eventdata, handles)
% hObject    handle to anticlock1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.VOIToTranslate<1)
    handles.rotam1 = handles.rotam1+handles.RotateAmount;    
else
    handles.rotam1(handles.VOIToTranslate+1) = handles.rotam1(handles.VOIToTranslate+1)+handles.RotateAmount;    
end
set(handles.rotate1,'String',num2str(handles.rotam1(handles.VOIToTranslate+1)));
cent = zeros(3,1);
if (handles.VOIToTranslate<1)
    cent(1) = (max(handles.PixCent1) - min(handles.PixCent1))./2 + min(handles.PixCent1);
    cent(2) = (max(handles.PixCent2) - min(handles.PixCent2))./2 + min(handles.PixCent2);
    cent(3) = (max(handles.PixCent3) - min(handles.PixCent3))./2 + min(handles.PixCent3);
else
    cent(1) = (max(handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:)) - min(handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:)))./2 + min(handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:));
    cent(2) = (max(handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:)) - min(handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:)))./2 + min(handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:));
    cent(3) = (max(handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:)) - min(handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:)))./2 + min(handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:));
end
handles.ROIs_temp_mat = rotateROI(handles.ROIs_temp_mat,cent,handles.RotateAmount,2,3,handles.VOIToTranslate);
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval);
handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);
guidata(hObject, handles);

% --- Executes on button press in clockwise2.
function clockwise2_Callback(hObject, eventdata, handles)
% hObject    handle to clockwise2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.VOIToTranslate<1)
    handles.rotam2 = handles.rotam2-handles.RotateAmount;    
else
    handles.rotam2(handles.VOIToTranslate+1) = handles.rotam2(handles.VOIToTranslate+1)-handles.RotateAmount;    
end
set(handles.rotate2,'String',num2str(handles.rotam2(handles.VOIToTranslate+1)));
cent = zeros(3,1);
if (handles.VOIToTranslate<1)
    cent(1) = (max(handles.PixCent1) - min(handles.PixCent1))./2 + min(handles.PixCent1);
    cent(2) = (max(handles.PixCent2) - min(handles.PixCent2))./2 + min(handles.PixCent2);
    cent(3) = (max(handles.PixCent3) - min(handles.PixCent3))./2 + min(handles.PixCent3);
else
    cent(1) = (max(handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:)) - min(handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:)))./2 + min(handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:));
    cent(2) = (max(handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:)) - min(handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:)))./2 + min(handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:));
    cent(3) = (max(handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:)) - min(handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:)))./2 + min(handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:));
end
handles.ROIs_temp_mat = rotateROI(handles.ROIs_temp_mat,cent,-handles.RotateAmount,1,3,handles.VOIToTranslate);
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval);
handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);
guidata(hObject, handles);

% --- Executes on button press in anticlock2.
function anticlock2_Callback(hObject, eventdata, handles)
% hObject    handle to anticlock2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.VOIToTranslate<1)
    handles.rotam2 = handles.rotam2+handles.RotateAmount;    
else
    handles.rotam2(handles.VOIToTranslate+1) = handles.rotam2(handles.VOIToTranslate+1)+handles.RotateAmount;    
end
set(handles.rotate2,'String',num2str(handles.rotam2(handles.VOIToTranslate+1)));
cent = zeros(3,1);
if (handles.VOIToTranslate<1)
    cent(1) = (max(handles.PixCent1) - min(handles.PixCent1))./2 + min(handles.PixCent1);
    cent(2) = (max(handles.PixCent2) - min(handles.PixCent2))./2 + min(handles.PixCent2);
    cent(3) = (max(handles.PixCent3) - min(handles.PixCent3))./2 + min(handles.PixCent3);
else
    cent(1) = (max(handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:)) - min(handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:)))./2 + min(handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:));
    cent(2) = (max(handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:)) - min(handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:)))./2 + min(handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:));
    cent(3) = (max(handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:)) - min(handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:)))./2 + min(handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:));
end
handles.ROIs_temp_mat = rotateROI(handles.ROIs_temp_mat,cent,handles.RotateAmount,1,3,handles.VOIToTranslate);
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval);
handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);
guidata(hObject, handles);

% --- Executes on button press in clockwise3.
function clockwise3_Callback(hObject, eventdata, handles)
% hObject    handle to clockwise3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.VOIToTranslate<1)
    handles.rotam3 = handles.rotam3+handles.RotateAmount;    
else
    handles.rotam3(handles.VOIToTranslate+1) = handles.rotam3(handles.VOIToTranslate+1)+handles.RotateAmount;    
end
set(handles.rotate3,'String',num2str(handles.rotam3(handles.VOIToTranslate+1)));
cent = zeros(3,1);
if (handles.VOIToTranslate<1)
    cent(1) = (max(handles.PixCent1) - min(handles.PixCent1))./2 + min(handles.PixCent1);
    cent(2) = (max(handles.PixCent2) - min(handles.PixCent2))./2 + min(handles.PixCent2);
    cent(3) = (max(handles.PixCent3) - min(handles.PixCent3))./2 + min(handles.PixCent3);
else
    cent(1) = (max(handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:)) - min(handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:)))./2 + min(handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:));
    cent(2) = (max(handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:)) - min(handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:)))./2 + min(handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:));
    cent(3) = (max(handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:)) - min(handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:)))./2 + min(handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:));
end
handles.ROIs_temp_mat = rotateROI(handles.ROIs_temp_mat,cent,handles.RotateAmount,1,2,handles.VOIToTranslate);
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval);
handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);
guidata(hObject, handles);

% --- Executes on button press in anticlock3.
function anticlock3_Callback(hObject, eventdata, handles)
% hObject    handle to anticlock3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.VOIToTranslate<1)
    handles.rotam3 = handles.rotam3-handles.RotateAmount;    
else
    handles.rotam3(handles.VOIToTranslate+1) = handles.rotam3(handles.VOIToTranslate+1)-handles.RotateAmount;    
end
set(handles.rotate3,'String',num2str(handles.rotam3(handles.VOIToTranslate+1)));
cent = zeros(3,1);
if (handles.VOIToTranslate<1)
    cent(1) = (max(handles.PixCent1) - min(handles.PixCent1))./2 + min(handles.PixCent1);
    cent(2) = (max(handles.PixCent2) - min(handles.PixCent2))./2 + min(handles.PixCent2);
    cent(3) = (max(handles.PixCent3) - min(handles.PixCent3))./2 + min(handles.PixCent3);
else
    cent(1) = (max(handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:)) - min(handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:)))./2 + min(handles.ROIs_temp_mat{handles.VOIToTranslate}(1,:));
    cent(2) = (max(handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:)) - min(handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:)))./2 + min(handles.ROIs_temp_mat{handles.VOIToTranslate}(2,:));
    cent(3) = (max(handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:)) - min(handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:)))./2 + min(handles.ROIs_temp_mat{handles.VOIToTranslate}(3,:));
end
handles.ROIs_temp_mat = rotateROI(handles.ROIs_temp_mat,cent,-handles.RotateAmount,1,2,handles.VOIToTranslate);
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval);
handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);
guidata(hObject, handles);


function rotate1_Callback(hObject, eventdata, handles)
% hObject    handle to rotate1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotate1 as text
%        str2double(get(hObject,'String')) returns contents of rotate1 as a double


% --- Executes during object creation, after setting all properties.
function rotate1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotate1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rotate2_Callback(hObject, eventdata, handles)
% hObject    handle to rotate2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotate2 as text
%        str2double(get(hObject,'String')) returns contents of rotate2 as a double


% --- Executes during object creation, after setting all properties.
function rotate2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotate2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rotate3_Callback(hObject, eventdata, handles)
% hObject    handle to rotate3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotate3 as text
%        str2double(get(hObject,'String')) returns contents of rotate3 as a double


% --- Executes during object creation, after setting all properties.
function rotate3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotate3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function shiftam_Callback(hObject, eventdata, handles)
% hObject    handle to shiftam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ShiftAmount = str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of shiftam as text
%        str2double(get(hObject,'String')) returns contents of shiftam as a double


% --- Executes during object creation, after setting all properties.
function shiftam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shiftam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rotateam_Callback(hObject, eventdata, handles)
% hObject    handle to rotateam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.RotateAmount = str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of rotateam as text
%        str2double(get(hObject,'String')) returns contents of rotateam as a double


% --- Executes during object creation, after setting all properties.
function rotateam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotateam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saverois.
function saverois_Callback(hObject, eventdata, handles)
% hObject    handle to saverois (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ROIs = handles.ROIs_temp_mat;
[FileName,PathName] = uiputfile('*.mat','Save as');
save([PathName FileName],'ROIs');
if(handles.nSurfs > 1)
    progressbar('Saving Individual Voxellised ROIs (CT Voxel Grid)');
    for i = 1:handles.nSurfs
        handles.Surface{i}.vertices = ROIs{i}';
        ROIVox{i} = CreateROIVox(handles.Surface{i},handles.PixCent1,handles.PixCent2,handles.PixCent3);
        writeMIDASROIFile([PathName FileName(1:end-4) handles.OrganNames{i+1}(1:end-4) '_CTVox' ],ROIVox{i});
        stlwrite([PathName FileName(1:end-4) handles.OrganNames{i+1}(1:end-4) '_Shift.stl' ],handles.Surface{i});
        progressbar(i./handles.nSurfs)
    end
    [~,I] = sort(handles.surfvols,'Descend');
    CombROIVox = zeros(length(handles.PixCent1),length(handles.PixCent2),length(handles.PixCent3));
    for i = 1:length(I)
        R = ROIVox{I(i)};
        CombROIVox(R>0) = i.*R(R>0);
    end
    writeROIuint8File([PathName FileName(1:end-4)  '_Comb_CTVox' ],CombROIVox);   
    progressbar('Saving Individual Voxellised ROIs (SPECT Voxel Grid)');
    for i = 1:handles.nSurfs        
        SPECTROIVox{i} = CreateROIVox(handles.Surface{i},handles.SPECTPixCent1,handles.SPECTPixCent2,handles.SPECTPixCent3);
        writeMIDASROIFile([PathName FileName(1:end-4) handles.OrganNames{i+1}(1:end-4) '_SPECTVox' ],SPECTROIVox{i});
        progressbar(i./handles.nSurfs)
    end
    [~,I] = sort(handles.surfvols,'Descend');
    CombSPECTROIVox = zeros(length(handles.SPECTPixCent1),length(handles.SPECTPixCent2),length(handles.SPECTPixCent3));
    for i = 1:length(I)
        R = SPECTROIVox{I(i)};
        CombSPECTROIVox(R>0) = i.*R(R>0);
    end
    writeROIuint8File([PathName FileName(1:end-4)  '_Comb_SPECTVox' ],CombSPECTROIVox);
else   
    handles.Surface.vertices = ROIs{1}';
    ROIVox = CreateROIVox(handles.Surface,handles.PixCent1,handles.PixCent2,handles.PixCent3);
    writeMIDASROIFile([PathName FileName(1:end-4) handles.OrganNames(1:end-4) '_CTVox' ],ROIVox);            
    SPECTROIVox = CreateROIVox(handles.Surface,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.SPECTPixCent3);
    writeMIDASROIFile([PathName FileName(1:end-4) handles.OrganNames(1:end-4) '_SPECTVox' ],SPECTROIVox);  
    stlwrite([PathName FileName(1:end-4) handles.OrganNames(1:end-4) '_Shift.stl' ],handles.Surface);
end
guidata(hObject, handles);


% --- Executes on slider movement.
function minvalslider_Callback(hObject, eventdata, handles)
% hObject    handle to minvalslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.minvoxval = get(hObject,'Value');
set(handles.minvaltxt,'String',num2str(handles.minvoxval))
% caxis(handles.axes1,[handles.minvoxval 0.7.*handles.maxvoxval])
% caxis(handles.axes2,[handles.minvoxval 0.7.*handles.maxvoxval])
% caxis(handles.axes3,[handles.minvoxval 0.7.*handles.maxvoxval])
handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function minvalslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minvalslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function minvaltxt_Callback(hObject, eventdata, handles)
% hObject    handle to minvaltxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minvaltxt as text
%        str2double(get(hObject,'String')) returns contents of minvaltxt as a double


% --- Executes during object creation, after setting all properties.
function minvaltxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minvaltxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function maxvalslider_Callback(hObject, eventdata, handles)
% hObject    handle to maxvalslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.maxvoxval = get(hObject,'Value');
set(handles.maxvaltxt,'String',num2str(handles.maxvoxval))
% caxis(handles.axes1,[handles.minvoxval 0.7.*handles.maxvoxval])
% caxis(handles.axes2,[handles.minvoxval 0.7.*handles.maxvoxval])
% caxis(handles.axes3,[handles.minvoxval 0.7.*handles.maxvoxval])
handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function maxvalslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxvalslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function maxvaltxt_Callback(hObject, eventdata, handles)
% hObject    handle to maxvaltxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxvaltxt as text
%        str2double(get(hObject,'String')) returns contents of maxvaltxt as a double


% --- Executes during object creation, after setting all properties.
function maxvaltxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxvaltxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in optim_pushbutton.
function optim_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to optim_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[ShiftSurface,ROI,shiftam,rotam,shift_counts,shift_counts_ct,nvox,nvox_ct,tv_am] = MaxCTandSPECTROICounts(handles.Surface,[handles.PixxSize handles.PixySize handles.PixzSize],...
    handles.SPECTPixCent1,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.SPECT_img,handles.PixCent1,handles.PixCent2,handles.PixCent3,handles.CT_img,50,false);
for i = 1:handles.nSurfs
    handles.ROIs_temp_mat{i} = ShiftSurface{i}.vertices';
end
% handles.axes1 = ViewSingleSliceOverlay_Mat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes2 = ViewSingleSliceOverlay_Mat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,1);
% handles.axes3 = ViewSingleSliceOverlay_Mat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval);

handles.axes1 = ViewSingleSliceOverlay_SPECTMat(handles.axes1,handles.CT_img,handles.xSlice,1,handles.ROIs_temp_mat,handles.PixCent2,handles.PixCent3,handles.Pixx,handles.PixxSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.xSlice_SP,1);
handles.axes2 = ViewSingleSliceOverlay_SPECTMat(handles.axes2,handles.CT_img,handles.ySlice,2,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent3,handles.Pixy,handles.PixySize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent3,handles.ySlice_SP,1);
handles.axes3 = ViewSingleSliceOverlay_SPECTMat(handles.axes3,handles.CT_img,handles.zSlice,3,handles.ROIs_temp_mat,handles.PixCent1,handles.PixCent2,handles.Pixz,handles.PixzSize,handles.minvoxval,handles.maxvoxval,handles.SPECT_img,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.zSlice_SP);


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in stock_button.
function stock_button_Callback(hObject, eventdata, handles)
% hObject    handle to stock_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.nSurfs > 1)
    for i = 1:handles.nSurfs
        handles.Surface{i}.vertices = handles.ROIs_temp_mat{i}';
    end
else
    handles.Surface.vertices =handles.ROIs_temp_mat{1}';
end
StockFillGUI(handles.SPECT_img,handles.SPECThdr,handles.CThdr,handles.Surface,handles.OrganNames(2:end))


% --- Executes on button press in indiv_button.
function indiv_button_Callback(hObject, eventdata, handles)
% hObject    handle to indiv_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.nSurfs > 1)
    for i = 1:handles.nSurfs
        handles.Surface{i}.vertices = handles.ROIs_temp_mat{i}';
    end
else
    handles.Surface.vertices =handles.ROIs_temp_mat{1}';
end
InsertFillGUI(handles.SPECT_img,handles.SPECThdr,handles.CThdr,handles.Surface,handles.OrganNames(2:end))


% --- Executes on button press in save_cf_button.
function save_cf_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_cf_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
