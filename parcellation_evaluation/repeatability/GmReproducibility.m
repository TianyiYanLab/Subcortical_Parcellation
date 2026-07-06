clear
GmRandPermParcellationPath = 'D:\research\4pipe comparation\HCP_Lsym-AVR\Ksolution\random group reproducibility\100iterations group parcellation';
nucleus = {'ACCUMBENS','AMYGDALA','CAUDATE','HIPPOCAMPUS','PALLIDUM','PUTAMEN','THALAMUS'};
k_list = [2,2,3,5,3,6,3];

% AllNetsGroup1 = zeros(17799,1,100);
% AllNetsGroup2 = zeros(17799,1,100);

CurrNetGroup1 = zeros(17799,100);
CurrNetGroup2 = zeros(17799,100);
for nuc = 1:length(nucleus)
    tic
    CurrNucGroup1 = [];
    CurrNucGroup2 = [];
    for it = 1:100
        load(fullfile(GmRandPermParcellationPath,nucleus{nuc},['k=',num2str(k_list(nuc))],['it_',num2str(it),'.mat']));
        CurrNucGroup1(:,it) = [group1_L_parcellation_sym;group1_R_parcellation_sym+max(group1_L_parcellation_sym,[],'all')];
        CurrNucGroup2(:,it) = [group2_L_parcellation_sym;group2_R_parcellation_sym+max(group2_L_parcellation_sym,[],'all')];
    end
    
    if nuc~=1
        CurrNetGroup1 = [CurrNetGroup1;CurrNucGroup1+max(CurrNetGroup1,[],'all')];
        CurrNetGroup2 = [CurrNetGroup2;CurrNucGroup2+max(CurrNetGroup2,[],'all')];
    else
        CurrNetGroup1 = CurrNucGroup1;
        CurrNetGroup2 = CurrNucGroup2;
    end
    toc
end

for i = 1:100
    tic
    CurrRepGroup1 = CurrNetGroup1(:,i);
    CurrRepGroup2 = CurrNetGroup2(:,i);
    d = iteration_Dice_munkres(CurrRepGroup1,CurrRepGroup2);
    IntraNetDice(:,i) = diag(d);
    toc
    fprintf('iteration %d finished\n',i)
end