function varargout = InsertFillGUI(varargin)
% INSERTFILLGUI MATLAB code for InsertFillGUI.fig
%      INSERTFILLGUI, by itself, creates a new INSERTFILLGUI or raises the existing
%      singleton*.
%
%      H = INSERTFILLGUI returns the handle to a new INSERTFILLGUI or the handle to
%      the existing singleton*.
%
%      INSERTFILLGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INSERTFILLGUI.M with the given input arguments.
%
%      INSERTFILLGUI('Property','Value',...) creates a new INSERTFILLGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before InsertFillGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to InsertFillGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help InsertFillGUI

% Last Modified by GUIDE v2.5 25-Jun-2018 15:42:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @InsertFillGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @InsertFillGUI_OutputFcn, ...
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


% --- Executes just before InsertFillGUI is made visible.
function InsertFillGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to InsertFillGUI (see VARARGIN)
handles.iROI = get(handles.roi_popupmenu,'Value');
handles.SPECTImage = varargin{1};
handles.SPECTsize = size(handles.SPECTImage);
handles.SPECThdr = varargin{2};
handles.SPECTPixSize = handles.SPECThdr.PixelSpacing;
handles.SPECTSliceThick = handles.SPECThdr.SliceThickness;
handles.SPECTImagePosition = handles.SPECThdr.Unknown_0054_0022.Item_1.ImagePositionPatient;
handles.SPECTPixCent1 = handles.SPECTImagePosition(1) + (0:(handles.SPECTsize(1)-1))*handles.SPECTPixSize(1);
handles.SPECTPixCent2 = handles.SPECTImagePosition(2) + (0:(handles.SPECTsize(2)-1))*handles.SPECTPixSize(2);
handles.SPECTPixCent3 = handles.SPECTImagePosition(3) - (0:(handles.SPECTsize(3)-1))*handles.SPECTSliceThick;
handles.CThdr = varargin{3};
% CTimgPosition = zeros(size(CT_img,3),3);
for i = 1:length(handles.CThdr)
    CTimgPosition(i,:) = handles.CThdr{i}.ImagePositionPatient;
end
handles.CTPixSize = handles.CThdr{1}.PixelSpacing;
handles.CTsize = [512 512 length(handles.CThdr)];
handles.PixCent1 = CTimgPosition(1,1) + (0:(handles.CTsize(1)-1))*handles.CTPixSize(1);
handles.PixCent2 = CTimgPosition(1,2) + (0:(handles.CTsize(2)-1))*handles.CTPixSize(2);
handles.PixCent3 = CTimgPosition(:,3);
handles.Surface = varargin{4};
handles.ROINames = varargin{5};
handles.CTPixSize(3) = abs(handles.PixCent3(2) - handles.PixCent3(1));
handles.ROI = zeros(size(handles.SPECTImage));
if(iscell(handles.Surface))
    handles.nSurfs = length(handles.Surface);
    handles.meancounts = zeros(handles.nSurfs,1);
    handles.stdcounts = zeros(handles.nSurfs,1);
    handles.vols = handles.meancounts;
    handles.roivols = handles.meancounts;
    for i = 1:handles.nSurfs
        [meancounts,stdcounts,roivol,R] = STLCountsUncert(handles.CTPixSize,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.SPECTImage,handles.Surface{i},20);
        handles.meancounts(i,1) = meancounts;
        handles.stdcounts(i,1) = stdcounts;
        handles.vols(i) = MeshVolCalc(handles.Surface{i},0)./1000;
        handles.roivols(i) = roivol;
        handles.ROI = handles.ROI+i.*R;
    end
else
    handles.nSurfs = 1;
    [meancounts,stdcounts,roivol,R] = STLCountsUncert(handles.CTPixSize,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.SPECTImage,handles.Surface,20);
    handles.meancounts = meancounts;
    handles.stdcounts = stdcounts;
    handles.vols = MeshVolCalc(handles.Surface,0)./1000;
    handles.roivols = roivol;
    handles.ROI = R;
end
handles.acqtimestring = handles.SPECThdr.AcquisitionTime;
handles.hour = 60*60;
handles.minute = 60;

handles.acqhour = str2double(handles.acqtimestring(1:2))*handles.hour;
handles.acqmin = str2double(handles.acqtimestring(3:4))*handles.minute;
handles.acqsec = str2double(handles.acqtimestring(5:6));
handles.acqtime = handles.acqhour+handles.acqmin+handles.acqsec;
set(handles.acqhour_text,'String',handles.acqtimestring(1:2));
set(handles.acqmin_text,'String',handles.acqtimestring(3:4));
set(handles.acqsec_text,'String',handles.acqtimestring(5:6));

handles.insertact = zeros(handles.nSurfs,1);
handles.insertactuncert = zeros(handles.nSurfs,1);
handles.insertact(handles.iROI) = str2double(get(handles.insertact_text,'String'));
handles.insertactuncert(handles.iROI) = str2double(get(handles.insertactuncert_text,'String'));
handles.inserthour = zeros(handles.nSurfs,1);
handles.insertmin = zeros(handles.nSurfs,1);
handles.insertsec = zeros(handles.nSurfs,1);
handles.inserthouruncert = zeros(handles.nSurfs,1);
handles.insertminuncert = zeros(handles.nSurfs,1);
handles.insertsecuncert = zeros(handles.nSurfs,1);
handles.inserthour(handles.iROI) = str2double(get(handles.insertacthour_text,'String')).*handles.hour;
handles.insertmin(handles.iROI) = str2double(get(handles.insertactmin_text,'String')).*handles.minute;
handles.insertsec(handles.iROI) = str2double(get(handles.insertactsec_text,'String'));
handles.inserttime = handles.inserthour+handles.insertmin+handles.insertsec;

handles.inserthouruncert(handles.iROI) = str2double(get(handles.insertacthouruncert_text,'String')).*handles.hour;
handles.insertminuncert(handles.iROI) = str2double(get(handles.insertactminuncert_text,'String')).*handles.minute;
handles.insertsecuncert(handles.iROI) = str2double(get(handles.insertactsecuncert_text,'String'));
handles.inserttimeuncert = handles.inserthouruncert+handles.insertminuncert+handles.insertsecuncert;

handles.resact = zeros(handles.nSurfs,1);
handles.resactuncert = zeros(handles.nSurfs,1);
handles.reshour = zeros(handles.nSurfs,1);
handles.resmin = zeros(handles.nSurfs,1);
handles.ressec = zeros(handles.nSurfs,1);
handles.reshouruncert = zeros(handles.nSurfs,1);
handles.resminuncert = zeros(handles.nSurfs,1);
handles.ressecuncert = zeros(handles.nSurfs,1);
handles.resact(handles.iROI) = str2double(get(handles.resact_text,'String'));
handles.resactuncert(handles.iROI) = str2double(get(handles.resactuncert_text,'String'));
handles.reshour(handles.iROI) = str2double(get(handles.restacthour_text,'String')).*handles.hour;
handles.resmin(handles.iROI) = str2double(get(handles.restactmin_text,'String')).*handles.minute;
handles.ressec(handles.iROI) = str2double(get(handles.restactsec_text,'String'));
handles.restime = handles.reshour+handles.resmin+handles.ressec;

handles.reshouruncert(handles.iROI) = str2double(get(handles.restacthouruncert_text,'String')).*handles.hour;
handles.resminuncert(handles.iROI) = str2double(get(handles.restactminuncert_text,'String')).*handles.minute;
handles.ressecuncert(handles.iROI) = str2double(get(handles.restactsecuncert_text,'String'));
handles.restimeuncert = handles.reshouruncert+handles.resminuncert+handles.ressecuncert;

handles.IsotopeID = get(handles.isotope_pop,'Value');
handles.IsotopeTau = [1./(log(2)./(6.6475*24*handles.hour));1./(log(2)./(6.0067*handles.hour));1./(log(2)./(8.0197*24*handles.hour));1./(log(2)./(64.1*handles.hour))]; % Lu-177;Tc-99m;I-131;Y-90;
set(handles.tau_text,'String',sprintf('%0.2f',(handles.IsotopeTau(handles.IsotopeID))));

set(handles.roi_popupmenu,'String',handles.ROINames);
handles.InsertEmptyWeight = 1.*ones(handles.nSurfs,1);
handles.InsertEmptyWeightUncert = 0.005.*ones(handles.nSurfs,1);
handles.InsertFullWeight = 100.*ones(handles.nSurfs,1);
handles.InsertFullWeightUncert = 0.005.*ones(handles.nSurfs,1);

set(handles.emptyweight_text,'String',num2str(handles.InsertEmptyWeight(handles.iROI)));
set(handles.emptyweightuncert_text,'String',num2str(handles.InsertEmptyWeightUncert(handles.iROI)));
set(handles.fullweight_text,'String',num2str(handles.InsertFullWeight(handles.iROI)));
set(handles.fullweightuncert_text,'String',num2str(handles.InsertFullWeightUncert(handles.iROI)));

handles.InsertWeight = handles.InsertFullWeight-handles.InsertEmptyWeight;
set(handles.insertweight_text,'String',sprintf('%0.2f',handles.InsertWeight(handles.iROI)));

for i = 1:handles.nSurfs
    handles.insert_scanned_act(i) = CalcStockAct(handles.insertact(i),handles.resact(i),handles.restime(i),handles.inserttime(i),handles.acqtime,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.insertactivity_text,'String',sprintf('%0.2f',(handles.insert_scanned_act(handles.iROI))));
handles.insertactconc = handles.insert_scanned_act./handles.InsertWeight;
set(handles.insertactconc_text,'String',sprintf('%0.2f',(handles.insertactconc(handles.iROI))));

set(handles.stlvol_text,'String',sprintf('%0.2f',handles.vols(handles.iROI)));

set(handles.voivol_text,'String',sprintf('%0.2f',handles.roivols(handles.iROI)));
set(handles.counts_text,'String',sprintf('%0.2f',handles.meancounts(handles.iROI)));
set(handles.countsuncert_text,'String',sprintf('%0.2f',handles.stdcounts(handles.iROI)));
handles.ScanDur = 60*20;
handles.mean_cf = zeros(handles.nSurfs,1);
handles.sigma_cf = zeros(handles.nSurfs,1);
handles.insert_scanned_act_sigma = zeros(handles.nSurfs,1);
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));

% Choose default command line output for InsertFillGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes InsertFillGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = InsertFillGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in roi_popupmenu.
function roi_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to roi_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns roi_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from roi_popupmenu
handles.iROI = get(hObject,'Value');
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
set(handles.insertact_text,'String',num2str(handles.insertact(handles.iROI)));
set(handles.insertactuncert_text,'String',num2str(handles.insertactuncert(handles.iROI)));
set(handles.insertacthour_text,'String',num2str(handles.inserthour(handles.iROI)./handles.hour));
set(handles.insertactmin_text,'String',num2str(handles.insertmin(handles.iROI)./handles.minute));
set(handles.insertactsec_text,'String',num2str(handles.insertsec(handles.iROI)));
set(handles.insertacthouruncert_text,'String',num2str(handles.inserthouruncert(handles.iROI)./handles.hour));
set(handles.insertactminuncert_text,'String',num2str(handles.insertminuncert(handles.iROI)./handles.minute));
set(handles.insertactsecuncert_text,'String',num2str(handles.insertsecuncert(handles.iROI)));
set(handles.resact_text,'String',num2str(handles.resact(handles.iROI)));
set(handles.resactuncert_text,'String',num2str(handles.resactuncert(handles.iROI)));
set(handles.restacthour_text,'String',num2str(handles.reshour(handles.iROI)./handles.hour));
set(handles.restactmin_text,'String',num2str(handles.resmin(handles.iROI)./handles.minute));
set(handles.restactsec_text,'String',num2str(handles.ressec(handles.iROI)));
set(handles.restacthouruncert_text,'String',num2str(handles.reshouruncert(handles.iROI)./handles.hour));
set(handles.restactminuncert_text,'String',num2str(handles.resminuncert(handles.iROI)./handles.minute));
set(handles.restactsecuncert_text,'String',num2str(handles.ressecuncert(handles.iROI)));
set(handles.emptyweight_text,'String',num2str(handles.InsertEmptyWeight(handles.iROI)));
set(handles.emptyweightuncert_text,'String',num2str(handles.InsertEmptyWeightUncert(handles.iROI)));
set(handles.fullweight_text,'String',num2str(handles.InsertFullWeight(handles.iROI)));
set(handles.fullweightuncert_text,'String',num2str(handles.InsertFullWeightUncert(handles.iROI)));
set(handles.insertweight_text,'String',sprintf('%0.2f',handles.InsertWeight(handles.iROI)));
set(handles.insertactivity_text,'String',sprintf('%0.2f',handles.insert_scanned_act(handles.iROI)));
set(handles.totalactivityuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
set(handles.insertactconc_text,'String',sprintf('%0.2f',(handles.insertactconc(handles.iROI))));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
set(handles.stlvol_text,'String',sprintf('%0.2f',handles.vols(handles.iROI)));
set(handles.voivol_text,'String',sprintf('%0.2f',handles.roivols(handles.iROI)));
set(handles.counts_text,'String',sprintf('%0.2f',handles.meancounts(handles.iROI)));
set(handles.countsuncert_text,'String',sprintf('%0.2f',handles.stdcounts(handles.iROI)));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function roi_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function acqhour_text_Callback(hObject, eventdata, handles)
% hObject    handle to acqhour_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of acqhour_text as text
%        str2double(get(hObject,'String')) returns contents of acqhour_text as a double


% --- Executes during object creation, after setting all properties.
function acqhour_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to acqhour_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function acqmin_text_Callback(hObject, eventdata, handles)
% hObject    handle to acqmin_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of acqmin_text as text
%        str2double(get(hObject,'String')) returns contents of acqmin_text as a double


% --- Executes during object creation, after setting all properties.
function acqmin_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to acqmin_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function acqsec_text_Callback(hObject, eventdata, handles)
% hObject    handle to acqsec_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of acqsec_text as text
%        str2double(get(hObject,'String')) returns contents of acqsec_text as a double


% --- Executes during object creation, after setting all properties.
function acqsec_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to acqsec_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function insertact_text_Callback(hObject, eventdata, handles)
% hObject    handle to insertact_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of insertact_text as text
%        str2double(get(hObject,'String')) returns contents of insertact_text as a double
handles.insertact(handles.iROI) = str2double(get(hObject,'String'));
for i = 1:handles.nSurfs
    handles.insert_scanned_act(i) = CalcStockAct(handles.insertact(i),handles.resact(i),handles.restime(i),handles.inserttime(i),handles.acqtime,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.insertactivity_text,'String',sprintf('%0.2f',(handles.insert_scanned_act(handles.iROI))));
handles.insertactconc = handles.insert_scanned_act./handles.InsertWeight;
set(handles.insertactconc_text,'String',sprintf('%0.2f',(handles.insertactconc(handles.iROI))));
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function insertact_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to insertact_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function insertactuncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to insertactuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of insertactuncert_text as text
%        str2double(get(hObject,'String')) returns contents of insertactuncert_text as a double
handles.insertactuncert(handles.iROI) = str2double(get(hObject,'String'));
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function insertactuncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to insertactuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function insertacthour_text_Callback(hObject, eventdata, handles)
% hObject    handle to insertacthour_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of insertacthour_text as text
%        str2double(get(hObject,'String')) returns contents of insertacthour_text as a double
handles.inserthour(handles.iROI) = str2double(get(hObject,'String')).*handles.hour;
handles.inserttime = handles.inserthour+handles.insertmin+handles.insertsec;
for i = 1:handles.nSurfs
    handles.insert_scanned_act(i) = CalcStockAct(handles.insertact(i),handles.resact(i),handles.restime(i),handles.inserttime(i),handles.acqtime,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.insertactivity_text,'String',sprintf('%0.2f',(handles.insert_scanned_act(handles.iROI))));
handles.insertactconc = handles.insert_scanned_act./handles.InsertWeight;
set(handles.insertactconc_text,'String',sprintf('%0.2f',(handles.insertactconc(handles.iROI))));
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function insertacthour_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to insertacthour_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function insertactmin_text_Callback(hObject, eventdata, handles)
% hObject    handle to insertactmin_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of insertactmin_text as text
%        str2double(get(hObject,'String')) returns contents of insertactmin_text as a double
handles.insertmin(handles.iROI) = str2double(get(hObject,'String')).*handles.minute;
handles.inserttime = handles.inserthour+handles.insertmin+handles.insertsec;
for i = 1:handles.nSurfs
    handles.insert_scanned_act(i) = CalcStockAct(handles.insertact(i),handles.resact(i),handles.restime(i),handles.inserttime(i),handles.acqtime,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.insertactivity_text,'String',sprintf('%0.2f',(handles.insert_scanned_act(handles.iROI))));
handles.insertactconc = handles.insert_scanned_act./handles.InsertWeight;
set(handles.insertactconc_text,'String',sprintf('%0.2f',(handles.insertactconc(handles.iROI))));
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function insertactmin_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to insertactmin_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function insertactsec_text_Callback(hObject, eventdata, handles)
% hObject    handle to insertactsec_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of insertactsec_text as text
%        str2double(get(hObject,'String')) returns contents of insertactsec_text as a double
handles.insertsec(handles.iROI) = str2double(get(hObject,'String'));
handles.inserttime = handles.inserthour+handles.insertmin+handles.insertsec;
for i = 1:handles.nSurfs
    handles.insert_scanned_act(i) = CalcStockAct(handles.insertact(i),handles.resact(i),handles.restime(i),handles.inserttime(i),handles.acqtime,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.insertactivity_text,'String',sprintf('%0.2f',(handles.insert_scanned_act(handles.iROI))));
handles.insertactconc = handles.insert_scanned_act./handles.InsertWeight;
set(handles.insertactconc_text,'String',sprintf('%0.2f',(handles.insertactconc(handles.iROI))));
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function insertactsec_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to insertactsec_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function insertacthouruncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to insertacthouruncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of insertacthouruncert_text as text
%        str2double(get(hObject,'String')) returns contents of insertacthouruncert_text as a double
handles.inserthouruncert(handles.iROI) = str2double(get(hObject,'String')).*handles.hour;
handles.inserttimeuncert = handles.inserthouruncert+handles.insertminuncert+handles.insertsecuncert;
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function insertacthouruncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to insertacthouruncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function insertactminuncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to insertactminuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of insertactminuncert_text as text
%        str2double(get(hObject,'String')) returns contents of insertactminuncert_text as a double
handles.insertminuncert(handles.iROI) = str2double(get(hObject,'String')).*handles.minute;
handles.inserttimeuncert = handles.inserthouruncert+handles.insertminuncert+handles.insertsecuncert;
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function insertactminuncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to insertactminuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function insertactsecuncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to insertactsecuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of insertactsecuncert_text as text
%        str2double(get(hObject,'String')) returns contents of insertactsecuncert_text as a double
handles.insertsecuncert(handles.iROI) = str2double(get(hObject,'String'));
handles.inserttimeuncert = handles.inserthouruncert+handles.insertminuncert+handles.insertsecuncert;
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function insertactsecuncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to insertactsecuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function resact_text_Callback(hObject, eventdata, handles)
% hObject    handle to resact_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resact_text as text
%        str2double(get(hObject,'String')) returns contents of resact_text as a double
handles.resact(handles.iROI) = str2double(get(hObject,'String'));
for i = 1:handles.nSurfs
    handles.insert_scanned_act(i) = CalcStockAct(handles.insertact(i),handles.resact(i),handles.restime(i),handles.inserttime(i),handles.acqtime,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.insertactivity_text,'String',sprintf('%0.2f',(handles.insert_scanned_act(handles.iROI))));
handles.insertactconc = handles.insert_scanned_act./handles.InsertWeight;
set(handles.insertactconc_text,'String',sprintf('%0.2f',(handles.insertactconc(handles.iROI))));
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function resact_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resact_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function resactuncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to resactuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resactuncert_text as text
%        str2double(get(hObject,'String')) returns contents of resactuncert_text as a double
handles.resactuncert(handles.iROI) = str2double(get(hObject,'String'));
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function resactuncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resactuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function restacthour_text_Callback(hObject, eventdata, handles)
% hObject    handle to restacthour_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of restacthour_text as text
%        str2double(get(hObject,'String')) returns contents of restacthour_text as a double
handles.reshour(handles.iROI) = str2double(get(hObject,'String')).*handles.hour;
handles.restime = handles.reshour+handles.resmin+handles.ressec;
for i = 1:handles.nSurfs
    handles.insert_scanned_act(i) = CalcStockAct(handles.insertact(i),handles.resact(i),handles.restime(i),handles.inserttime(i),handles.acqtime,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.insertactivity_text,'String',sprintf('%0.2f',(handles.insert_scanned_act(handles.iROI))));
handles.insertactconc = handles.insert_scanned_act./handles.InsertWeight;
set(handles.insertactconc_text,'String',sprintf('%0.2f',(handles.insertactconc(handles.iROI))));
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function restacthour_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to restacthour_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function restactmin_text_Callback(hObject, eventdata, handles)
% hObject    handle to restactmin_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of restactmin_text as text
%        str2double(get(hObject,'String')) returns contents of restactmin_text as a double
handles.resmin(handles.iROI) = str2double(get(hObject,'String')).*handles.minute;
handles.restime = handles.reshour+handles.resmin+handles.ressec;
for i = 1:handles.nSurfs
    handles.insert_scanned_act(i) = CalcStockAct(handles.insertact(i),handles.resact(i),handles.restime(i),handles.inserttime(i),handles.acqtime,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.insertactivity_text,'String',sprintf('%0.2f',(handles.insert_scanned_act(handles.iROI))));
handles.insertactconc = handles.insert_scanned_act./handles.InsertWeight;
set(handles.insertactconc_text,'String',sprintf('%0.2f',(handles.insertactconc(handles.iROI))));
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function restactmin_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to restactmin_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function restactsec_text_Callback(hObject, eventdata, handles)
% hObject    handle to restactsec_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of restactsec_text as text
%        str2double(get(hObject,'String')) returns contents of restactsec_text as a double
handles.ressec(handles.iROI) = str2double(get(hObject,'String'));
handles.restime = handles.reshour+handles.resmin+handles.ressec;
for i = 1:handles.nSurfs
    handles.insert_scanned_act(i) = CalcStockAct(handles.insertact(i),handles.resact(i),handles.restime(i),handles.inserttime(i),handles.acqtime,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.insertactivity_text,'String',sprintf('%0.2f',(handles.insert_scanned_act(handles.iROI))));
handles.insertactconc = handles.insert_scanned_act./handles.InsertWeight;
set(handles.insertactconc_text,'String',sprintf('%0.2f',(handles.insertactconc(handles.iROI))));
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function restactsec_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to restactsec_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function restacthouruncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to restacthouruncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of restacthouruncert_text as text
%        str2double(get(hObject,'String')) returns contents of restacthouruncert_text as a double
handles.reshouruncert(handles.iROI) = str2double(get(hObject,'String')).*handles.hour;
handles.restimeuncert = handles.reshouruncert+handles.resminuncert+handles.ressecuncert;
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function restacthouruncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to restacthouruncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function restactminuncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to restactminuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of restactminuncert_text as text
%        str2double(get(hObject,'String')) returns contents of restactminuncert_text as a double
handles.resminuncert(handles.iROI) = str2double(get(hObject,'String')).*handles.minute;
handles.restimeuncert = handles.reshouruncert+handles.resminuncert+handles.ressecuncert;
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function restactminuncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to restactminuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function restactsecuncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to restactsecuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of restactsecuncert_text as text
%        str2double(get(hObject,'String')) returns contents of restactsecuncert_text as a double
handles.ressecuncert(handles.iROI) = str2double(get(hObject,'String'));
handles.restimeuncert = handles.reshouruncert+handles.resminuncert+handles.ressecuncert;
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function restactsecuncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to restactsecuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function emptyweight_text_Callback(hObject, eventdata, handles)
% hObject    handle to emptyweight_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of emptyweight_text as text
%        str2double(get(hObject,'String')) returns contents of emptyweight_text as a double
handles.InsertEmptyWeight(handles.iROI) = str2double(get(hObject,'String'));
handles.InsertWeight = handles.InsertFullWeight-handles.InsertEmptyWeight;
handles.insertactconc = handles.insert_scanned_act./handles.InsertWeight;
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.insertweight_text,'String',sprintf('%0.2f',handles.InsertWeight(handles.iROI)));
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
set(handles.insertactconc_text,'String',sprintf('%0.2f',(handles.insertactconc(handles.iROI))));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function emptyweight_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to emptyweight_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function emptyweightuncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to emptyweightuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of emptyweightuncert_text as text
%        str2double(get(hObject,'String')) returns contents of emptyweightuncert_text as a double
handles.InsertEmptyWeightUncert(handles.iROI) = str2double(get(hObject,'String'));
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function emptyweightuncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to emptyweightuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fullweight_text_Callback(hObject, eventdata, handles)
% hObject    handle to fullweight_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fullweight_text as text
%        str2double(get(hObject,'String')) returns contents of fullweight_text as a double
handles.InsertFullWeight(handles.iROI) = str2double(get(hObject,'String'));
handles.InsertWeight = handles.InsertFullWeight-handles.InsertEmptyWeight;
handles.insertactconc = handles.insert_scanned_act./handles.InsertWeight;
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.insertweight_text,'String',sprintf('%0.2f',handles.InsertWeight(handles.iROI)));
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
set(handles.insertactconc_text,'String',sprintf('%0.2f',(handles.insertactconc(handles.iROI))));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function fullweight_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fullweight_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fullweightuncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to fullweightuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fullweightuncert_text as text
%        str2double(get(hObject,'String')) returns contents of fullweightuncert_text as a double
handles.InsertFullWeightUncert(handles.iROI) = str2double(get(hObject,'String'));
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
set(handles.insertactconc_text,'String',sprintf('%0.2f',(handles.insertactconc(handles.iROI))));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function fullweightuncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fullweightuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in savecfs_push.
function savecfs_push_Callback(hObject, eventdata, handles)
% hObject    handle to savecfs_push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uiputfile('.mat','Save CFs and Associated Variables');
savename = [path file];
SPECTImage = handles.SPECTImage; %#ok<*NASGU>
ROI = handles.ROI;
Surface = handles.Surface;ROINames = handles.ROINames;meancounts = handles.meancounts;stdcounts = handles.stdcounts;vols = handles.vols;roivols =handles.roivols;acqtime = handles.acqtime;
inserttime = handles.inserttime;inserttimeuncert = handles.inserttimeuncert;resact=handles.resact;resactuncert=handles.resactuncert;restime=handles.restime;restimeuncert=handles.restimeuncert;
InsertEmptyWeight=handles.InsertEmptyWeight;InsertEmptyWeightUncert=handles.InsertEmptyWeightUncert;InsertFullWeight=handles.InsertFullWeight;InsertFullWeightUncert=handles.InsertFullWeightUncert;
IsotopeTau = handles.IsotopeTau(handles.IsotopeID);insert_scanned_act=handles.insert_scanned_act;InsertWeight=handles.InsertWeight;insert_scanned_act_conc=handles.insertactconc;
ScanDur=handles.ScanDur;mean_cf=handles.mean_cf;sigma_cf=handles.sigma_cf;insertact=handles.insertact;insertactuncert=handles.insertactuncert;resact=handles.resact;resactuncert=handles.resactuncert;
save(savename,'SPECTImage','ROI','Surface','ROINames','ROI','meancounts','stdcounts','vols','roivols','acqtime','insertact','insertactuncert','inserttime','inserttimeuncert','resact','resactuncert',...
    'restime','restimeuncert','IsotopeTau','InsertEmptyWeight','InsertEmptyWeightUncert','InsertFullWeight','InsertFullWeightUncert','InsertWeight','ScanDur','mean_cf','sigma_cf','insert_scanned_act_conc');



% --- Executes on selection change in isotope_pop.
function isotope_pop_Callback(hObject, eventdata, handles)
% hObject    handle to isotope_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns isotope_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from isotope_pop
handles.IsotopeID = get(handles.isotope_pop,'Value');
set(handles.tau_text,'String',sprintf('%0.2f',(handles.IsotopeTau(handles.IsotopeID))));
for i = 1:handles.nSurfs
    [handles.mean_cf(i),handles.sigma_cf(i),handles.insert_scanned_act(i),handles.insert_scanned_act_sigma(i)] = Calc_cfuncert_insert(handles.insertact(i),handles.resact(i),handles.insertactuncert(i),handles.resactuncert(i),...                
        handles.inserttime(i),handles.restime(i),handles.acqtime,handles.inserttimeuncert(i),handles.restimeuncert(i),...
        handles.meancounts(i),handles.stdcounts(i),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
end
handles.insertactconc = handles.insert_scanned_act./handles.InsertWeight;
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI)));
set(handles.actconcuncert_text,'String',sprintf('%0.2f',handles.insert_scanned_act_sigma(handles.iROI)));
set(handles.insertactconc_text,'String',sprintf('%0.2f',(handles.insertactconc(handles.iROI))));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function isotope_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to isotope_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tau_text_Callback(hObject, eventdata, handles)
% hObject    handle to tau_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tau_text as text
%        str2double(get(hObject,'String')) returns contents of tau_text as a double


% --- Executes during object creation, after setting all properties.
function tau_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tau_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function insertactivity_text_Callback(hObject, eventdata, handles)
% hObject    handle to insertactivity_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of insertactivity_text as text
%        str2double(get(hObject,'String')) returns contents of insertactivity_text as a double


% --- Executes during object creation, after setting all properties.
function insertactivity_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to insertactivity_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function insertweight_text_Callback(hObject, eventdata, handles)
% hObject    handle to insertweight_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of insertweight_text as text
%        str2double(get(hObject,'String')) returns contents of insertweight_text as a double


% --- Executes during object creation, after setting all properties.
function insertweight_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to insertweight_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stlvol_text_Callback(hObject, eventdata, handles)
% hObject    handle to stlvol_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stlvol_text as text
%        str2double(get(hObject,'String')) returns contents of stlvol_text as a double


% --- Executes during object creation, after setting all properties.
function stlvol_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stlvol_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function voivol_text_Callback(hObject, eventdata, handles)
% hObject    handle to voivol_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of voivol_text as text
%        str2double(get(hObject,'String')) returns contents of voivol_text as a double


% --- Executes during object creation, after setting all properties.
function voivol_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voivol_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function counts_text_Callback(hObject, eventdata, handles)
% hObject    handle to counts_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of counts_text as text
%        str2double(get(hObject,'String')) returns contents of counts_text as a double


% --- Executes during object creation, after setting all properties.
function counts_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to counts_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function countsuncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to countsuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of countsuncert_text as text
%        str2double(get(hObject,'String')) returns contents of countsuncert_text as a double


% --- Executes during object creation, after setting all properties.
function countsuncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to countsuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cf_text_Callback(hObject, eventdata, handles)
% hObject    handle to cf_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cf_text as text
%        str2double(get(hObject,'String')) returns contents of cf_text as a double


% --- Executes during object creation, after setting all properties.
function cf_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cf_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cfuncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to cfuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cfuncert_text as text
%        str2double(get(hObject,'String')) returns contents of cfuncert_text as a double


% --- Executes during object creation, after setting all properties.
function cfuncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cfuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function insertactconc_text_Callback(hObject, eventdata, handles)
% hObject    handle to insertactconc_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of insertactconc_text as text
%        str2double(get(hObject,'String')) returns contents of insertactconc_text as a double


% --- Executes during object creation, after setting all properties.
function insertactconc_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to insertactconc_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function totalactivityuncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to totalactivityuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totalactivityuncert_text as text
%        str2double(get(hObject,'String')) returns contents of totalactivityuncert_text as a double


% --- Executes during object creation, after setting all properties.
function totalactivityuncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalactivityuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function actconcuncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to actconcuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of actconcuncert_text as text
%        str2double(get(hObject,'String')) returns contents of actconcuncert_text as a double


% --- Executes during object creation, after setting all properties.
function actconcuncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to actconcuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
