clear all;
clc;
melp_init;              % ������������?���������� ?��������

for i=1:(Nframe-1)    % ���������� ������ �������� ������?
    % ���������� ������ ������?�������� 4-�� ��?��?
    sig_in(1:FRL)=sig_in(FRL+1:FRL*2); 
    %���������� ������ ��??�������� ����?1000 ��(��)
    sig_1000(1:FRL)=sig_1000(FRL+1:FRL*2); 
    % ���������� ������ ��������?��������
    melp_bands(:,1:FRL)=melp_bands(:,FRL+1:FRL*2);
    % ���������� ��������?���� ?������?
    melp_envelopes(:,1:FRL)=melp_envelopes(:,FRL+1:FRL*2); 
    
    % ��?�� ������ ����?����
    sig_origin=s((i-1)*FRL+1:i*FRL); 
    
    % ���������� ����?���� ������?����
    [sig_in(FRL+1:FRL*2),cheb_s]=filter(dcr_num,dcr_den,sig_origin,cheb_s); 
    
    % ���������� �������������� ������? ��
    [sig_1000(FRL+1:FRL*2),butter_s]=filter(butt_1000num,butt_1000den,...
        sig_in(FRL+1:FRL*2),butter_s);  % ��??�������� ����?1000 �� 
    cur_intp=intpitch(sig_1000,160,40); % ������������?�������� ��
    
    % ������ ������?�� ������?
    % ��������?����??��������?������?
    [melp_bands(:,FRL+1:FRL*2),state_b,melp_envelopes(:,FRL+1:FRL*2),...
        state_e]=melp_5b(sig_in(FRL+1:FRL*2),state_b,state_e); 
    
    % ���������� �������� ������? �� 
    [p2,vp(1)]=pitch2(melp_bands(1,:),cur_intp); 
    
    % ������ ���������������� ����?
    vp(2:5)=melp_bpva(melp_bands,melp_envelopes,p2); 
    r2=vp(1); %���������������� ������ ������
    
    % ����������?�������� 
    if vp(1)<0.5 
        jitter=1; 
    else
        jitter=0;
    end

    % LPC ������
    koef_lpc=melp_lpc(sig_in(81:280)); 
    koef_lpc=koef_lpc.*0.994.^(2:11);   % ��������?�� ����������?
                                        % ��������? ������ ������ 
    % ����������?������?����������?
    e_resid=lpc_residual(koef_lpc,sig_in); 
    
    % ������������?����������?���������������� ����?
    peak=sqrt(e_resid(106:265)*e_resid(106:265)'/160)/...
        (sum(abs(e_resid(106:265)))/160); % ����������?�������� ������?
    if peak>1.34 
        vp(1)=1; 
    end
    if peak>1.6
        vp(2:3)=1; 
    end 
    
    % ������������?����������?��
    temp_s(1:6)=0; 
    [fltd_resid,temp_s]=filter(butt_1000num,butt_1000den,e_resid,temp_s); 
    temp(1:5)=0; 
    fltd_resid=[temp,fltd_resid,temp]; 
    [p3,r3]=pitch3(sig_in,fltd_resid,p2,pavg); 
    
    % ���������� ������? 
    G=melp_gain(sig_in,vp(1),p2); 
    Gs(i,:)=G;
    % ���������� �������� ������? ��
    [pavg,buffer]=melp_APU(p3,r3,G(2),buffer); 
    
    % �������������� ������������?�� ?��?
    LSF=melp_lpc2lsf(koef_lpc); 
    
    % ���������� ������������ ������??
    LSF=lsf_clmp(LSF); 
    
    % �������������� ��������?����������?
    MSVQ=melp_msvq(koef_lpc,LSF); 
    
    % ����������?������?
    QG=melp_Qgain(G2p,G); 
    G2p=G(2); % ���������� ������? ������? ��?����������?����?
    
    % ����������?��
    if vp(1)>0.6 
        Qpitch=melp_Qpitch(p3);
    end
    
    % ����������?�������� ����?������?
    lsfs=d_lsf(MSVQ);           % ����������?������?������������ ��?
    lpc2=melp_lsf2lpc(lsfs);    % �������������� ��??������������ ��
    tresid2=lpc_residual(lpc2,sig_in(76:285)); % ����������?������?
                                % ����������? �� ������������ ��?
    resid2=tresid2.*hamming(200)';  % ���������� ���� ��������
    resid2(201:512)=0;              % ���������� ��?��
    magf=abs(fft(resid2));          % ��������?����?������?
    [fm,Wf]=find_harm(magf,p3);     % ����������?�������� �������� ������?
    
    % ����������?�������� ����?������?
    QFM=melp_FMCQ(fm,Wf); 
    
    % ������������ ����?��������
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