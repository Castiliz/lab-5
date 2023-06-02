function varargout = pl(varargin)
% PL MATLAB code for pl.fig
%      PL, by itself, creates a new PL or raises the existing
%      singleton*.
%
%      H = PL returns the handle to a new PL or the handle to
%      the existing singleton*.
%
%      PL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PL.M with the given input arguments.
%
%      PL('Property','Value',...) creates a new PL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pl

% Last Modified by GUIDE v2.5 18-May-2023 22:40:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pl_OpeningFcn, ...
                   'gui_OutputFcn',  @pl_OutputFcn, ...
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


% --- Executes just before pl is made visible.
function pl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pl (see VARARGIN)

% Choose default command line output for pl
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
Ports = seriallist;
set(handles.PuertoCom, 'string', Ports);


% UIWAIT makes pl wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pl_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in connect.
function connect_Callback(hObject, eventdata, handles)
% hObject    handle to connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global obj1
global Activado
ValuePort = get(handles.PuertoCom, 'Value');
Ports = get(handles.PuertoCom,'string');
com = Ports{ValuePort};
obj1 = instrfind('Type' , 'serial', ... 
    'Port',com,'Tag', '');
estado = get(handles.connect,'string');

if contains(estado,'Conectar')
    if isempty(obj1)
        obj1 = serial(com,...
            'BaudRate',115200,...
            'InputBufferSize',4,...
            'BytesAvailableFcn',{@readser},...
            'BytesAvailableFcnMode','byte',...
            'BytesAvailableFcnCount',4,...
            'Timeout',0.1);
    else
        fclose(obj1);
        obj1 = obj1(1);
    end
    fopen(obj1);
    set(handles.connect,'string','Desconectar');
else
    Activado=false;
    pause(2);
    fclose(obj1);
    delete(obj1);
    set(handles.connect,'string','Conectar');
end

function readser(obj,~)
global x pos
global v ca

a = fread(obj,4,'uint8')

if ca == 1
    %derecha
    env=[pos,v,0,1]
    fwrite(obj,env,'uint8');
else
    %izquierda
    env=[pos,v,1,0]
    fwrite(obj,env,'uint8');
end

ecg = a(1)*100+a(2);
x = [x,ecg];

% --- Executes on selection change in PuertoCom.
function PuertoCom_Callback(hObject, eventdata, handles)
% hObject    handle to PuertoCom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PuertoCom contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PuertoCom


% --- Executes during object creation, after setting all properties.
function PuertoCom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PuertoCom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in graph.
function graph_Callback(hObject, eventdata, handles)
% hObject    handle to graph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Activado;
global x;
Activado = true;

while Activado
    amp=x;

    if(length(amp)>900)
        tiempo = linspace(0,3,length(amp));
        plot(tiempo,amp);
        axis([0,3,0,4095]);
        grid;
        drawnow;
        x=[];
        tiempo=[];
    end
end




function np_Callback(hObject, eventdata, handles)
% hObject    handle to np (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of np as text
%        str2double(get(hObject,'String')) returns contents of np as a double


% --- Executes during object creation, after setting all properties.
function np_CreateFcn(hObject, eventdata, handles)
% hObject    handle to np (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function moto_Callback(hObject, eventdata, handles)
% hObject    handle to moto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global pos
pos = floor(get(handles.moto, 'value'))


% --- Executes during object creation, after setting all properties.
function moto_CreateFcn(hObject, eventdata, handles)
% hObject    handle to moto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in Sendport.
function Sendport_Callback(hObject, eventdata, handles)
% hObject    handle to Sendport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Sendport contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Sendport


% --- Executes during object creation, after setting all properties.
function Sendport_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sendport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function velocidad_Callback(hObject, eventdata, handles)
% hObject    handle to velocidad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global v
v = floor(get(handles.velocidad, 'value'));


% --- Executes during object creation, after setting all properties.
function velocidad_CreateFcn(hObject, eventdata, handles)
% hObject    handle to velocidad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in cambs.
function cambs_Callback(hObject, eventdata, handles)
% hObject    handle to cambs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ca
if ca == 0
    ca=1;
else
    ca=0;
end
