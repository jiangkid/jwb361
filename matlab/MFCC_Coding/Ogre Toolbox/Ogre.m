function varargout = Ogre(varargin)
% OGRE M-file for Ogre.fig
%      OGRE, by itself, creates a new OGRE or raises the existing
%      singleton*.
%
%      H = OGRE returns the handle to a new OGRE or the handle to
%      the existing singleton*.
%
%      OGRE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OGRE.M with the given input arguments.
%
%      OGRE('Property','Value',...) creates a new OGRE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Ogre_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Ogre_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help Ogre

% Last Modified by GUIDE v2.5 23-May-2006 06:04:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Ogre_OpeningFcn, ...
                   'gui_OutputFcn',  @Ogre_OutputFcn, ...
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


% --- Executes just before Ogre is made visible.
function Ogre_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Ogre (see VARARGIN)


[A,Amap] = imread('asicon.gif');
image(A);
colormap(Amap)

% Choose default command line output for Ogre
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Ogre wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Ogre_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in OMethodPopup.
function OMethodPopup_Callback(hObject, eventdata, handles)
% hObject    handle to OMethodPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns OMethodPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OMethodPopup

val = get(hObject,'Value');
str = get(hObject, 'String');
x = handles.audiovec;
colormap('default'); 
switch  str{val},
    case 'STFT NB'
        X = Stft(x);
        imagesc(log(abs(X))); axis xy
        title(str{val})
        win = 512;
        overlap = 2;
        hop = win/overlap;
        nfft = 512;
        
    case 'STFT WB'
        X = Stft(x,64,2,512);
        imagesc(log(abs(X))); axis xy
        title(str{val})
        win = 64;
        overlap = 2;
        hop = win/overlap;
        nfft = 512;
        
    case 'LPC Env.'
        %different methods of spectral envelope analysis
        [S,Res] = LPCAna(x);
        imagesc(log(abs(S))); axis xy
        title(str{val})
        win = 512;
        overlap = 2;
        hop = win/overlap;
        nfft = 512;
        X = S;

    case 'LPC Res.'
        %different methods of spectral envelope analysis
        [S,Res] = LPCAna(x);
        X = fft(Res);
        imagesc(log(abs(X))); axis xy
        title(str{val})
        win = 512;
        overlap = 2;
        hop = win/overlap;
        nfft = 512;
    
    case 'Welch'
        S = WelchAna(x);
        imagesc(log(abs(S))); axis xy
        title(str{val})
        win = 512;
        overlap = 2;
        hop = win/overlap;
        nfft = 512;
        X = S;
    
    case 'CEPS Env.'
        [S,Res] = CepsAna(x,10);
        imagesc(log(abs(S))); axis xy
        title(str{val})
        win = 512;
        overlap = 2;
        hop = win/overlap;
        nfft = 512;
        X = S;
    
    case 'CEPS Res.'
        [S,Res] = CepsAna(x,10);
        imagesc(log(abs(Res))); axis xy
        title(str{val})
        win = 512;
        overlap = 2;
        hop = win/overlap;
        nfft = 512;
        X = Res;
end
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function OMethodPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OMethodPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in Loadbutton.
function Loadbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Loadbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fname, path] = uigetfile('*.wav','Select WAVE file');
fname1 = [path fname]
[x,fs] = wavread(fname1);
plot(x)
handles.audiovec = x;
handles.samplingrate = fs;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function Loadbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Loadbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over OMethodPopup.
function OMethodPopup_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to OMethodPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press over OMethodPopup with no controls selected.
function OMethodPopup_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to OMethodPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x = handles.audiovec;
fs = handles.samplingrate;
soundsc(x,fs)

