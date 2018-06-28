function varargout = StockFillGUI(varargin)
% STOCKFILLGUI MATLAB code for StockFillGUI.fig
%      STOCKFILLGUI, by itself, creates a new STOCKFILLGUI or raises the existing
%      singleton*.
%
%      H = STOCKFILLGUI returns the handle to a new STOCKFILLGUI or the handle to
%      the existing singleton*.
%
%      STOCKFILLGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STOCKFILLGUI.M with the given input arguments.
%
%      STOCKFILLGUI('Property','Value',...) creates a new STOCKFILLGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StockFillGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StockFillGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StockFillGUI

% Last Modified by GUIDE v2.5 25-Jun-2018 15:55:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @StockFillGUI_OpeningFcn, ...
    'gui_OutputFcn',  @StockFillGUI_OutputFcn, ...
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


% --- Executes just before StockFillGUI is made visible.
function StockFillGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StockFillGUI (see VARARGIN)
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
handles.FileNames = varargin{6};
handles.CTPixSize(3) = abs(handles.PixCent3(2) - handles.PixCent3(1));
handles.ROI = zeros([length(handles.SPECTPixCent1) length(handles.SPECTPixCent2) length(handles.SPECTPixCent3)]);
if (iscell(handles.SPECTImage))
    handles.n_imgs = length(handles.SPECTImage);
else
    handles.n_imgs = 1;
end
if(iscell(handles.Surface))
    handles.nSurfs = length(handles.Surface);
    handles.meancounts = zeros(handles.nSurfs,handles.n_imgs);
    handles.stdcounts = zeros(handles.nSurfs,handles.n_imgs);
    handles.vols = handles.meancounts;
    handles.roivols = handles.meancounts;
    for i = 1:handles.nSurfs
        [meancounts,stdcounts,roivol,R] = STLCountsUncert(handles.CTPixSize,handles.SPECTPixCent1,handles.SPECTPixCent2,handles.SPECTPixCent3,handles.SPECTImage,handles.Surface{i},20);
        handles.meancounts(i,:) = meancounts;
        handles.stdcounts(i,:) = stdcounts;
        handles.vols(i) = MeshVolCalc(handles.Surface{i},0)./1000;
        handles.roivols(i,:) = roivol;
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

handles.stockact = str2double(get(handles.stockact_text,'String'));
handles.stockactuncert = str2double(get(handles.stockact_uncert,'String'));
handles.stockhour = str2double(get(handles.stockhour_text,'String')).*handles.hour;
handles.stockmin = str2double(get(handles.stockmin_text,'String')).*handles.minute;
handles.stocksec = str2double(get(handles.stocksec_text,'String'));
handles.stocktime = handles.stockhour+handles.stockmin+handles.stocksec;

handles.stockhouruncert = str2double(get(handles.stockhouruncert_text,'String')).*handles.hour;
handles.stockminuncert = str2double(get(handles.stockminuncert_text,'String')).*handles.minute;
handles.stocksecuncert = str2double(get(handles.stocksecuncert_text,'String'));
handles.stocktimeuncert = handles.stockhouruncert+handles.stockminuncert+handles.stocksecuncert;

handles.resact = str2double(get(handles.resact_text,'String'));
handles.resactuncert = str2double(get(handles.resactuncert_text,'String'));
handles.reshour = str2double(get(handles.reshour_text,'String')).*handles.hour;
handles.resmin = str2double(get(handles.resmin_text,'String')).*handles.minute;
handles.ressec = str2double(get(handles.ressec_text,'String'));
handles.restime = handles.reshour+handles.resmin+handles.ressec;

handles.reshouruncert = str2double(get(handles.reshouruncert_text,'String')).*handles.hour;
handles.resminuncert = str2double(get(handles.resminuncert_text,'String')).*handles.minute;
handles.ressecuncert = str2double(get(handles.ressecuncert_text,'String'));
handles.restimeuncert = handles.reshouruncert+handles.resminuncert+handles.ressecuncert;

handles.stockemptyweight = str2double(get(handles.stockempty_text,'String'));
handles.stockemptyweightuncert = str2double(get(handles.stockemptyuncert_text,'String'));

handles.stockfullweight = str2double(get(handles.stockfull_text,'String'));
handles.stockfullweightuncert = str2double(get(handles.stockfulluncert_text,'String'));

handles.IsotopeID = get(handles.isotope_menu,'Value');
handles.IsotopeTau = [1./(log(2)./(6.6475*24*handles.hour));1./(log(2)./(6.0067*handles.hour));1./(log(2)./(8.0197*24*handles.hour));1./(log(2)./(64.1*handles.hour))]; % Lu-177;Tc-99m;I-131;Y-90;
set(handles.tau_text,'String',sprintf('%0.2f',(handles.IsotopeTau(handles.IsotopeID))));

handles.stock_scanned_act = CalcStockAct(handles.stockact,handles.resact,handles.restime,handles.stocktime,handles.acqtime,handles.IsotopeTau(handles.IsotopeID));
set(handles.totalscanact_text,'String',sprintf('%0.2f',(handles.stock_scanned_act)));

handles.StockVol = handles.stockfullweight - handles.stockemptyweight;
set(handles.edit21,'String',sprintf('%0.2f',(handles.stock_scanned_act/handles.StockVol)));

handles.stock_scanned_actconc = handles.stock_scanned_act/handles.StockVol;

set(handles.roiselect_menu,'String',handles.ROINames);
handles.InsertEmptyWeight = 1.*ones(handles.nSurfs,1);
handles.InsertEmptyWeightUncert = 0.005.*ones(handles.nSurfs,1);
handles.InsertFullWeight = 100.*ones(handles.nSurfs,1);
handles.InsertFullWeightUncert = 0.005.*ones(handles.nSurfs,1);
handles.iROI = get(handles.roiselect_menu,'Value');
set(handles.insertempty_text,'String',num2str(handles.InsertEmptyWeight(handles.iROI)));
set(handles.insertemptyuncert_text,'String',num2str(handles.InsertEmptyWeightUncert(handles.iROI)));
set(handles.insertfull_text,'String',num2str(handles.InsertFullWeight(handles.iROI)));
set(handles.insertfulluncert_text,'String',num2str(handles.InsertFullWeightUncert(handles.iROI)));

handles.InsertWeight = handles.InsertFullWeight-handles.InsertEmptyWeight;
set(handles.edit27,'String',sprintf('%0.2f',handles.InsertWeight(handles.iROI)));

handles.InsertActivity = handles.stock_scanned_actconc.*handles.InsertWeight;
set(handles.edit26,'String',sprintf('%0.2f',handles.InsertActivity(handles.iROI)));

set(handles.stlvol_text,'String',sprintf('%0.2f',handles.vols(handles.iROI)));

set(handles.edit30,'String',sprintf('%0.2f',handles.roivols(handles.iROI,1)));

set(handles.counts_text,'String',sprintf('%0.2f',handles.meancounts(handles.iROI,1)));
set(handles.countsuncert_text,'String',sprintf('%0.2f',handles.stdcounts(handles.iROI,1)));
handles.ScanDur = 60*20;
handles.mean_cf = zeros(handles.nSurfs,handles.n_imgs);
handles.sigma_cf = zeros(handles.nSurfs,handles.n_imgs);
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i,k),handles.sigma_cf(i,k)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
% Choose default command line output for StockFillGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes StockFillGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = StockFillGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



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



function stockact_text_Callback(hObject, eventdata, handles)
% hObject    handle to stockact_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stockact_text as text
%        str2double(get(hObject,'String')) returns contents of stockact_text as a double
handles.stockact = str2double(get(hObject,'String'));
handles.stock_scanned_act = CalcStockAct(handles.stockact,handles.resact,handles.restime,handles.stocktime,handles.acqtime,handles.IsotopeTau(handles.IsotopeID));
set(handles.totalscanact_text,'String',sprintf('%0.2f',(handles.stock_scanned_act)));
handles.StockVol = handles.stockfullweight - handles.stockemptyweight;
set(handles.edit21,'String',sprintf('%0.2f',(handles.stock_scanned_act/handles.StockVol)));
handles.stock_scanned_actconc = handles.stock_scanned_act/handles.StockVol;
handles.InsertActivity = handles.stock_scanned_actconc.*handles.InsertWeight;
set(handles.edit26,'String',sprintf('%0.2f',handles.InsertActivity(handles.iROI)));
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function stockact_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stockact_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stockact_uncert_Callback(hObject, eventdata, handles)
% hObject    handle to stockact_uncert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stockact_uncert as text
%        str2double(get(hObject,'String')) returns contents of stockact_uncert as a double
handles.stockactuncert = str2double(get(hObject,'String'));
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function stockact_uncert_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stockact_uncert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stockhour_text_Callback(hObject, eventdata, handles)
% hObject    handle to stockhour_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stockhour_text as text
%        str2double(get(hObject,'String')) returns contents of stockhour_text as a double
handles.stockhour = str2double(get(hObject,'String')).*handles.hour;
handles.stocktime = handles.stockhour+handles.stockmin+handles.stocksec;
handles.stock_scanned_act = CalcStockAct(handles.stockact,handles.resact,handles.restime,handles.stocktime,handles.acqtime,handles.IsotopeTau(handles.IsotopeID));
set(handles.totalscanact_text,'String',sprintf('%0.2f',(handles.stock_scanned_act)));
handles.StockVol = handles.stockfullweight - handles.stockemptyweight;
set(handles.edit21,'String',sprintf('%0.2f',(handles.stock_scanned_act/handles.StockVol)));
handles.stock_scanned_actconc = handles.stock_scanned_act/handles.StockVol;
handles.InsertActivity = handles.stock_scanned_actconc.*handles.InsertWeight;
set(handles.edit26,'String',sprintf('%0.2f',handles.InsertActivity(handles.iROI)));
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function stockhour_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stockhour_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stockmin_text_Callback(hObject, eventdata, handles)
% hObject    handle to stockmin_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stockmin_text as text
%        str2double(get(hObject,'String')) returns contents of stockmin_text as a double
handles.stockmin = str2double(get(hObject,'String')).*handles.minute;
handles.stocktime = handles.stockhour+handles.stockmin+handles.stocksec;
handles.stock_scanned_act = CalcStockAct(handles.stockact,handles.resact,handles.restime,handles.stocktime,handles.acqtime,handles.IsotopeTau(handles.IsotopeID));
set(handles.totalscanact_text,'String',sprintf('%0.2f',(handles.stock_scanned_act)));
handles.StockVol = handles.stockfullweight - handles.stockemptyweight;
set(handles.edit21,'String',sprintf('%0.2f',(handles.stock_scanned_act/handles.StockVol)));
handles.stock_scanned_actconc = handles.stock_scanned_act/handles.StockVol;
handles.InsertActivity = handles.stock_scanned_actconc.*handles.InsertWeight;
set(handles.edit26,'String',sprintf('%0.2f',handles.InsertActivity(handles.iROI)));
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function stockmin_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stockmin_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stocksec_text_Callback(hObject, eventdata, handles)
% hObject    handle to stocksec_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stocksec_text as text
%        str2double(get(hObject,'String')) returns contents of stocksec_text as a double
handles.stocksec = str2double(get(hObject,'String'));
handles.stocktime = handles.stockhour+handles.stockmin+handles.stocksec;
handles.stock_scanned_act = CalcStockAct(handles.stockact,handles.resact,handles.restime,handles.stocktime,handles.acqtime,handles.IsotopeTau(handles.IsotopeID));
set(handles.totalscanact_text,'String',sprintf('%0.2f',(handles.stock_scanned_act)));
handles.StockVol = handles.stockfullweight - handles.stockemptyweight;
set(handles.edit21,'String',sprintf('%0.2f',(handles.stock_scanned_act/handles.StockVol)));
handles.stock_scanned_actconc = handles.stock_scanned_act/handles.StockVol;
handles.InsertActivity = handles.stock_scanned_actconc.*handles.InsertWeight;
set(handles.edit26,'String',sprintf('%0.2f',handles.InsertActivity(handles.iROI)));
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function stocksec_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stocksec_text (see GCBO)
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
handles.resact = str2double(get(hObject,'String'));
handles.stock_scanned_act = CalcStockAct(handles.stockact,handles.resact,handles.restime,handles.stocktime,handles.acqtime,handles.IsotopeTau(handles.IsotopeID));
set(handles.totalscanact_text,'String',sprintf('%0.2f',(handles.stock_scanned_act)));
handles.StockVol = handles.stockfullweight - handles.stockemptyweight;
set(handles.edit21,'String',sprintf('%0.2f',(handles.stock_scanned_act/handles.StockVol)));
handles.stock_scanned_actconc = handles.stock_scanned_act/handles.StockVol;
handles.InsertActivity = handles.stock_scanned_actconc.*handles.InsertWeight;
set(handles.edit26,'String',sprintf('%0.2f',handles.InsertActivity(handles.iROI)));
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
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
handles.resactuncert = str2double(get(hObject,'String'));
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
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



function reshour_text_Callback(hObject, eventdata, handles)
% hObject    handle to reshour_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of reshour_text as text
%        str2double(get(hObject,'String')) returns contents of reshour_text as a double
handles.reshour = str2double(get(hObject,'String')).*handles.hour;
handles.restime = handles.reshour+handles.resmin+handles.ressec;
handles.stock_scanned_act = CalcStockAct(handles.stockact,handles.resact,handles.restime,handles.stocktime,handles.acqtime,handles.IsotopeTau(handles.IsotopeID));
set(handles.totalscanact_text,'String',sprintf('%0.2f',(handles.stock_scanned_act)));
handles.StockVol = handles.stockfullweight - handles.stockemptyweight;
set(handles.edit21,'String',sprintf('%0.2f',(handles.stock_scanned_act/handles.StockVol)));
handles.stock_scanned_actconc = handles.stock_scanned_act/handles.StockVol;
handles.InsertActivity = handles.stock_scanned_actconc.*handles.InsertWeight;
set(handles.edit26,'String',sprintf('%0.2f',handles.InsertActivity(handles.iROI)));
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function reshour_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reshour_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function resmin_text_Callback(hObject, eventdata, handles)
% hObject    handle to resmin_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resmin_text as text
%        str2double(get(hObject,'String')) returns contents of resmin_text as a double
handles.resmin = str2double(get(hObject,'String')).*handles.minute;
handles.restime = handles.reshour+handles.resmin+handles.ressec;
handles.stock_scanned_act = CalcStockAct(handles.stockact,handles.resact,handles.restime,handles.stocktime,handles.acqtime,handles.IsotopeTau(handles.IsotopeID));
set(handles.totalscanact_text,'String',sprintf('%0.2f',(handles.stock_scanned_act)));
handles.StockVol = handles.stockfullweight - handles.stockemptyweight;
set(handles.edit21,'String',sprintf('%0.2f',(handles.stock_scanned_act/handles.StockVol)));
handles.stock_scanned_actconc = handles.stock_scanned_act/handles.StockVol;
handles.InsertActivity = handles.stock_scanned_actconc.*handles.InsertWeight;
set(handles.edit26,'String',sprintf('%0.2f',handles.InsertActivity(handles.iROI)));
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function resmin_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resmin_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ressec_text_Callback(hObject, eventdata, handles)
% hObject    handle to ressec_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ressec_text as text
%        str2double(get(hObject,'String')) returns contents of ressec_text as a double
handles.ressec = str2double(get(hObject,'String'));
handles.restime = handles.reshour+handles.resmin+handles.ressec;
handles.stock_scanned_act = CalcStockAct(handles.stockact,handles.resact,handles.restime,handles.stocktime,handles.acqtime,handles.IsotopeTau(handles.IsotopeID));
set(handles.totalscanact_text,'String',sprintf('%0.2f',(handles.stock_scanned_act)));
handles.StockVol = handles.stockfullweight - handles.stockemptyweight;
set(handles.edit21,'String',sprintf('%0.2f',(handles.stock_scanned_act/handles.StockVol)));
handles.stock_scanned_actconc = handles.stock_scanned_act/handles.StockVol;
handles.InsertActivity = handles.stock_scanned_actconc.*handles.InsertWeight;
set(handles.edit26,'String',sprintf('%0.2f',handles.InsertActivity(handles.iROI)));
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ressec_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ressec_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stockempty_text_Callback(hObject, eventdata, handles)
% hObject    handle to stockempty_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stockempty_text as text
%        str2double(get(hObject,'String')) returns contents of stockempty_text as a double
handles.stockemptyweight = str2double(get(hObject,'String'));
handles.StockVol = handles.stockfullweight - handles.stockemptyweight;
set(handles.edit21,'String',sprintf('%0.2f',(handles.stock_scanned_act/handles.StockVol)));
handles.stock_scanned_actconc = handles.stock_scanned_act/handles.StockVol;
handles.InsertActivity = handles.stock_scanned_actconc.*handles.InsertWeight;
set(handles.edit26,'String',sprintf('%0.2f',handles.InsertActivity(handles.iROI)));
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function stockempty_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stockempty_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stockemptyuncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to stockemptyuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stockemptyuncert_text as text
%        str2double(get(hObject,'String')) returns contents of stockemptyuncert_text as a double
handles.stockemptyweightuncert = str2double(get(hObject,'String'));
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function stockemptyuncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stockemptyuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stockfull_text_Callback(hObject, eventdata, handles)
% hObject    handle to stockfull_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stockfull_text as text
%        str2double(get(hObject,'String')) returns contents of stockfull_text as a double
handles.stockfullweight = str2double(get(hObject,'String'));
handles.StockVol = handles.stockfullweight - handles.stockemptyweight;
set(handles.edit21,'String',sprintf('%0.2f',(handles.stock_scanned_act/handles.StockVol)));
handles.stock_scanned_actconc = handles.stock_scanned_act/handles.StockVol;
handles.InsertActivity = handles.stock_scanned_actconc.*handles.InsertWeight;
set(handles.edit26,'String',sprintf('%0.2f',handles.InsertActivity(handles.iROI)));
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function stockfull_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stockfull_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stockfulluncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to stockfulluncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stockfulluncert_text as text
%        str2double(get(hObject,'String')) returns contents of stockfulluncert_text as a double
handles.stockfullweightuncert = str2double(get(hObject,'String'));
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function stockfulluncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stockfulluncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in isotope_menu.
function isotope_menu_Callback(hObject, eventdata, handles)
% hObject    handle to isotope_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns isotope_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from isotope_menu
handles.IsotopeID = get(handles.isotope_menu,'Value');
set(handles.tau_text,'String',sprintf('%0.2f',(handles.IsotopeTau(handles.IsotopeID))));
handles.stock_scanned_act = CalcStockAct(handles.stockact,handles.resact,handles.restime,handles.stocktime,handles.acqtime,handles.IsotopeTau(handles.IsotopeID));
set(handles.totalscanact_text,'String',sprintf('%0.2f',(handles.stock_scanned_act)));
handles.StockVol = handles.stockfullweight - handles.stockemptyweight;
set(handles.edit21,'String',sprintf('%0.2f',(handles.stock_scanned_act/handles.StockVol)));
handles.InsertActivity = handles.stock_scanned_actconc.*handles.InsertWeight;
set(handles.edit26,'String',sprintf('%0.2f',handles.InsertActivity(handles.iROI)));
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function isotope_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to isotope_menu (see GCBO)
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



function totalscanact_text_Callback(hObject, eventdata, handles)
% hObject    handle to totalscanact_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totalscanact_text as text
%        str2double(get(hObject,'String')) returns contents of totalscanact_text as a double


% --- Executes during object creation, after setting all properties.
function totalscanact_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalscanact_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stockhouruncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to stockhouruncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stockhouruncert_text as text
%        str2double(get(hObject,'String')) returns contents of stockhouruncert_text as a double
handles.stockhouruncert = str2double(get(hObject,'String')).*handles.hour;
handles.stocktimeuncert = handles.stockhouruncert+handles.stockminuncert+handles.stocksecuncert;
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function stockhouruncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stockhouruncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stockminuncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to stockminuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stockminuncert_text as text
%        str2double(get(hObject,'String')) returns contents of stockminuncert_text as a double
handles.stockminuncert = str2double(get(hObject,'String')).*handles.minute;
handles.stocktimeuncert = handles.stockhouruncert+handles.stockminuncert+handles.stocksecuncert;
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function stockminuncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stockminuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stocksecuncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to stocksecuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stocksecuncert_text as text
%        str2double(get(hObject,'String')) returns contents of stocksecuncert_text as a double
handles.stocksecuncert = str2double(get(hObject,'String'));
handles.stocktimeuncert = handles.stockhouruncert+handles.stockminuncert+handles.stocksecuncert;
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function stocksecuncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stocksecuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function reshouruncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to reshouruncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of reshouruncert_text as text
%        str2double(get(hObject,'String')) returns contents of reshouruncert_text as a double
handles.reshouruncert = str2double(get(hObject,'String')).*handles.hour;
handles.restimeuncert = handles.reshouruncert+handles.resminuncert+handles.ressecuncert;
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function reshouruncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reshouruncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function resminuncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to resminuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resminuncert_text as text
%        str2double(get(hObject,'String')) returns contents of resminuncert_text as a double
handles.resminuncert = str2double(get(hObject,'String')).*handles.minute;
handles.restimeuncert = handles.reshouruncert+handles.resminuncert+handles.ressecuncert;
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function resminuncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resminuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ressecuncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to ressecuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ressecuncert_text as text
%        str2double(get(hObject,'String')) returns contents of ressecuncert_text as a double
handles.ressecuncert = str2double(get(hObject,'String'));
handles.restimeuncert = handles.reshouruncert+handles.resminuncert+handles.ressecuncert;
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ressecuncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ressecuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in roiselect_menu.
function roiselect_menu_Callback(hObject, eventdata, handles)
% hObject    handle to roiselect_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns roiselect_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from roiselect_menu
handles.iROI = get(handles.roiselect_menu,'Value');
set(handles.insertempty_text,'String',num2str(handles.InsertEmptyWeight(handles.iROI)));
set(handles.insertemptyuncert_text,'String',num2str(handles.InsertEmptyWeightUncert(handles.iROI)));
set(handles.insertfull_text,'String',num2str(handles.InsertFullWeight(handles.iROI)));
set(handles.insertfulluncert_text,'String',num2str(handles.InsertFullWeightUncert(handles.iROI)));
set(handles.edit27,'String',sprintf('%0.2f',handles.InsertWeight(handles.iROI)));
set(handles.edit26,'String',sprintf('%0.2f',handles.InsertActivity(handles.iROI)));
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.stlvol_text,'String',sprintf('%0.2f',handles.vols(handles.iROI)));

set(handles.edit30,'String',sprintf('%0.2f',handles.roivols(handles.iROI)));

set(handles.counts_text,'String',sprintf('%0.2f',handles.meancounts(handles.iROI,1)));
set(handles.counts_text,'String',sprintf('%0.2f',handles.meancounts(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function roiselect_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roiselect_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function insertempty_text_Callback(hObject, eventdata, handles)
% hObject    handle to insertempty_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of insertempty_text as text
%        str2double(get(hObject,'String')) returns contents of insertempty_text as a double
handles.InsertEmptyWeight(handles.iROI) = str2double(get(hObject,'String'));
handles.InsertWeight = handles.InsertFullWeight-handles.InsertEmptyWeight;
set(handles.edit27,'String',sprintf('%0.2f',handles.InsertWeight(handles.iROI)));
handles.InsertActivity = handles.stock_scanned_actconc.*handles.InsertWeight;
set(handles.edit26,'String',sprintf('%0.2f',handles.InsertActivity(handles.iROI)));
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function insertempty_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to insertempty_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function insertemptyuncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to insertemptyuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of insertemptyuncert_text as text
%        str2double(get(hObject,'String')) returns contents of insertemptyuncert_text as a double
handles.InsertEmptyWeightUncert(handles.iROI) = str2double(get(hObject,'String'));
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function insertemptyuncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to insertemptyuncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function insertfull_text_Callback(hObject, eventdata, handles)
% hObject    handle to insertfull_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of insertfull_text as text
%        str2double(get(hObject,'String')) returns contents of insertfull_text as a double
handles.InsertFullWeight(handles.iROI) = str2double(get(hObject,'String'));
handles.InsertWeight = handles.InsertFullWeight-handles.InsertEmptyWeight;
set(handles.edit27,'String',sprintf('%0.2f',handles.InsertWeight(handles.iROI)));
handles.InsertActivity = handles.stock_scanned_actconc.*handles.InsertWeight;
set(handles.edit26,'String',sprintf('%0.2f',handles.InsertActivity(handles.iROI)));
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function insertfull_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to insertfull_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function insertfulluncert_text_Callback(hObject, eventdata, handles)
% hObject    handle to insertfulluncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of insertfulluncert_text as text
%        str2double(get(hObject,'String')) returns contents of insertfulluncert_text as a double
handles.InsertFullWeightUncert(handles.iROI) = str2double(get(hObject,'String'));
for k = 1:handles.n_imgs
    for i = 1:handles.nSurfs
        [handles.mean_cf(i),handles.sigma_cf(i)] = Calc_cfuncert_stock(handles.stockact,handles.resact,handles.stockactuncert,handles.resactuncert,handles.stockfullweight,handles.stockfullweightuncert,...
            handles.stockemptyweight,handles.stockemptyweightuncert,handles.InsertFullWeight(i),...
            handles.InsertFullWeightUncert(i),handles.InsertEmptyWeight(i),handles.InsertEmptyWeightUncert(i),...
            handles.stocktime,handles.restime,handles.acqtime,handles.stocktimeuncert,handles.restimeuncert,...
            handles.meancounts(i,k),handles.stdcounts(i,k),handles.ScanDur,handles.IsotopeTau(handles.IsotopeID));
    end
end
set(handles.cf_text,'String',sprintf('%0.2f',handles.mean_cf(handles.iROI,1)));
set(handles.cfuncert_text,'String',sprintf('%0.2f',handles.sigma_cf(handles.iROI,1)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function insertfulluncert_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to insertfulluncert_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit27_Callback(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit27 as text
%        str2double(get(hObject,'String')) returns contents of edit27 as a double


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
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



function edit29_Callback(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit29 as text
%        str2double(get(hObject,'String')) returns contents of edit29 as a double


% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit30_Callback(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit30 as text
%        str2double(get(hObject,'String')) returns contents of edit30 as a double


% --- Executes during object creation, after setting all properties.
function edit30_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
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


% --- Executes during object creation, after setting all properties.
function uipanel2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in savecfs_button.
function savecfs_button_Callback(hObject, eventdata, handles)
% hObject    handle to savecfs_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uiputfile('.mat','Save CFs and Associated Variables');
savename = [path file];
SPECTImage = handles.SPECTImage; %#ok<*NASGU>
ROI = handles.ROI;
Surface = handles.Surface;ROINames = handles.ROINames;meancounts = handles.meancounts;stdcounts = handles.stdcounts;vols = handles.vols;roivols =handles.roivols;acqtime = handles.acqtime;stockact = handles.stockact;stockactuncert=handles.stockactuncert;
stocktime = handles.stocktime;stocktimeuncert = handles.stocktimeuncert;resact=handles.resact;resactuncert=handles.resactuncert;restime=handles.restime;restimeuncert=handles.restimeuncert;
stockemptyweight=handles.stockemptyweight;stockemptyweightuncert=handles.stockemptyweightuncert;stockfullweight=handles.stockfullweight;stockfullweightuncert=handles.stockfullweightuncert;
IsotopeTau = handles.IsotopeTau(handles.IsotopeID);stock_scanned_act=handles.stock_scanned_act;StockVol=handles.StockVol;stock_scanned_actconc=handles.stock_scanned_actconc;InsertEmptyWeight=handles.InsertEmptyWeight;InsertEmptyWeightUncert=handles.InsertEmptyWeightUncert;
InsertFullWeight=handles.InsertFullWeight;InsertFullWeightUncert=handles.InsertFullWeightUncert;InsertWeight=handles.InsertWeight;InsertActivity=handles.InsertActivity;ScanDur=handles.ScanDur;mean_cf=handles.mean_cf;sigma_cf=handles.sigma_cf;
FileNames = handles.FileNames;
save(savename,'SPECTImage','ROI','Surface','ROINames','ROI','meancounts','stdcounts',...
    'vols','roivols','acqtime','stockact','stockactuncert','stocktime','stocktimeuncert',...
    'resact','resactuncert','restime','restimeuncert','stockemptyweight','stockemptyweightuncert',...
    'stockfullweight','stockfullweightuncert','IsotopeTau','stock_scanned_act','StockVol',...
    'stock_scanned_actconc','InsertEmptyWeight','InsertEmptyWeightUncert','InsertFullWeight',...
    'InsertFullWeightUncert','InsertWeight','InsertActivity','ScanDur','mean_cf','sigma_cf','FileName');
