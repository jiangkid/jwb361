clear all;
clc;
melp_init;              % инициализаци?переменных ?констант

for i=1:(Nframe-1)    % покадровый анализ речевого сигнал?
    % Обновление буфера фильтр?Чебышева 4-го по?дк?
    sig_in(1:FRL)=sig_in(FRL+1:FRL*2); 
    %Обновление буфера ФН??частотой срез?1000 Гц(ОТ)
    sig_1000(1:FRL)=sig_1000(FRL+1:FRL*2); 
    % Обновление буфера полосовы?фильтров
    melp_bands(:,1:FRL)=melp_bands(:,FRL+1:FRL*2);
    % обновление огибающи?речи ?полоса?
    melp_envelopes(:,1:FRL)=melp_envelopes(:,FRL+1:FRL*2); 
    
    % Вз?ие нового кадр?речи
    sig_origin=s((i-1)*FRL+1:i*FRL); 
    
    % Ослабление пост?нной состав?ющей
    [sig_in(FRL+1:FRL*2),cheb_s]=filter(dcr_num,dcr_den,sig_origin,cheb_s); 
    
    % Вычисление целочисленного значен? ОТ
    [sig_1000(FRL+1:FRL*2),butter_s]=filter(butt_1000num,butt_1000den,...
        sig_in(FRL+1:FRL*2),butter_s);  % ФН??частотой срез?1000 Гц 
    cur_intp=intpitch(sig_1000,160,40); % целочисленно?значение ОТ
    
    % АНАЛИЗ СИГНАЛ?ПО ПОЛОСА?
    % Получени?поло??огибающи?сигнал?
    [melp_bands(:,FRL+1:FRL*2),state_b,melp_envelopes(:,FRL+1:FRL*2),...
        state_e]=melp_5b(sig_in(FRL+1:FRL*2),state_b,state_e); 
    
    % Вычисление дробного значен? ОТ 
    [p2,vp(1)]=pitch2(melp_bands(1,:),cur_intp); 
    
    % Анализ вокализованности поло?
    vp(2:5)=melp_bpva(melp_bands,melp_envelopes,p2); 
    r2=vp(1); %вокализованность первой полосы
    
    % Определени?джиттера 
    if vp(1)<0.5 
        jitter=1; 
    else
        jitter=0;
    end

    % LPC анализ
    koef_lpc=melp_lpc(sig_in(81:280)); 
    koef_lpc=koef_lpc.*0.994.^(2:11);   % умножени?на коэффициен?
                                        % расширен? полосы частот 
    % Определени?остатк?предсказан?
    e_resid=lpc_residual(koef_lpc,sig_in); 
    
    % Окончательно?определени?вокализованности поло?
    peak=sqrt(e_resid(106:265)*e_resid(106:265)'/160)/...
        (sum(abs(e_resid(106:265)))/160); % Определени?пикового значен?
    if peak>1.34 
        vp(1)=1; 
    end
    if peak>1.6
        vp(2:3)=1; 
    end 
    
    % Окончательно?определени?ОТ
    temp_s(1:6)=0; 
    [fltd_resid,temp_s]=filter(butt_1000num,butt_1000den,e_resid,temp_s); 
    temp(1:5)=0; 
    fltd_resid=[temp,fltd_resid,temp]; 
    [p3,r3]=pitch3(sig_in,fltd_resid,p2,pavg); 
    
    % Вычисление усилен? 
    G=melp_gain(sig_in,vp(1),p2); 
    Gs(i,:)=G;
    % Обновление среднего значен? ОТ
    [pavg,buffer]=melp_APU(p3,r3,G(2),buffer); 
    
    % Преобразование коэффициенто?ЛП ?ЛС?
    LSF=melp_lpc2lsf(koef_lpc); 
    
    % Расширение минимального рассто??
    LSF=lsf_clmp(LSF); 
    
    % Многоуровневое векторно?квантовани?
    MSVQ=melp_msvq(koef_lpc,LSF); 
    
    % Квантовани?усилен?
    QG=melp_Qgain(G2p,G); 
    G2p=G(2); % обновление значен? усилен? дл?предыдущег?кадр?
    
    % Квантовани?ОТ
    if vp(1)>0.6 
        Qpitch=melp_Qpitch(p3);
    end
    
    % Определени?амплитуд фурь?спектр?
    lsfs=d_lsf(MSVQ);           % определени?вектор?квантованных ЛС?
    lpc2=melp_lsf2lpc(lsfs);    % преобразование ЛС??коэффициенты ЛП
    tresid2=lpc_residual(lpc2,sig_in(76:285)); % Определени?остатк?
                                % предсказан? по квантованным КЛ?
    resid2=tresid2.*hamming(200)';  % применение окна Хэмминга
    resid2(201:512)=0;              % дополнение ну?ми
    magf=abs(fft(resid2));          % амплитуд?фурь?спектр?
    [fm,Wf]=find_harm(magf,p3);     % определени?гармоник основной частот?
    
    % Квантовани?амплитуд фурь?спектр?
    QFM=melp_FMCQ(fm,Wf); 
    
    % Формирование кадр?передачи
    c(i).ls=MSVQ; 
    c(i).QFM=QFM; 
    c(i).G=QG; 
    if vp(1)>0.6 
        c(i).pitch=Qpitch; 
        c(i).vp=vp(2:5); 
        c(i).jt=jitter; 
    else
        c(i).pitch=0;
        c(i).vp=0; 
        c(i).jt=0; 
    end 
end