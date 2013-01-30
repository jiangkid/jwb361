%Bandpass Voicing Analog
%Precondition:   s(1:360) ������������ź�;intP��ǰһ֡�͵�ǰ֡����������;intR�Ƕ�Ӧ�����ϵ��
%		           smooth��ƽ���˲�����״̬,full_wave��ȫ�������˲�����״̬,melp_bands(1:180)�������ͨ�ź�
%                ����һ֡�Ľ��,melp_envelopes�����Ӧ�İ����ź�
%Input:
%        melp_bands(5�����Ĵ�ͨ�źţ�

function vbp=melp_bpva(melp_bands,melp_envelopes,p2)
p2=round(p2);
vbp(1:4) = 0;%2~5�Ӵ�
for j=1:4
    [p(1),r(1)]=FPR(melp_bands(j+1,:),p2);%2~5�Ӵ�
    [p(2),r(2)]=FPR(melp_envelopes(j,:),p2);
    r(2)=r(2)-0.1;
    if r(2)>r(1)
        vbp(j)=r(2);
    else
        vbp(j)=r(1);
    end
end
end
