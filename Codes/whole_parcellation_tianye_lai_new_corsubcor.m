%% Wang et al. 2015 individualized parcellation
clear;clc;
clear;clc;

str_hem='rh';%!!!!!!!!记得改下面
[subcor16,Header]=y_Read(['D:\d001_research\Insom_Wang\code\Reslice_Tian_Subcortex_S1_3T_2009cAsym.nii']);
subcor16(find(subcor16>8))=0;%%%右脑
%subcor16(find(subcor16<9))=0;%%%左脑

% str_hem='rh';%!!!!!!!!记得改下面
% cor14=importdata(['D:\d001_research\Insom_Wang\code\label7_55_65_47.mat']);
% %cor14(find(cor14>7))=0;%%%%%左脑
% cor14(find(cor14<8))=0;%%%右脑
% 
% subcor16=cor14;
subcor_region=size(unique(subcor16),1)-1;
subcor_label=unique(subcor16);
subcor_label=subcor_label(2:end);
diff_label=subcor_label(1,1)-1;

se = strel('sphere',2);% 邻域的定义
str0=['D:\d001_research\Insom_Wang\Insomnia56\filter_regress\'];
list0=dir(str0);

iter=100;

confidence=[1.05,1.06,1.07,1.08,1.09,1.10,1.11,1.12,1.13,1.14,1.15];
%out_path = 'D:\d001_research\Insom_Wang\Insomnia56\whole_brain_parcellation_tianye_lai_new\cortical\';
out_path = 'D:\d001_research\Insom_Wang\Insomnia56\whole_brain_parcellation_tianye_lai_new\subcortical\';

for i=3:length(list0)
    tic
    [sub_ima,Header]=y_Read([str0,list0(i).name]);
    for confi_i=6
        ref_temp_subcor=subcor16; 
        temp_iti=zeros(1,iter);
        for iti=1:iter
            
            last_ref_temp_subcor = ref_temp_subcor;
            high_confi_temp_subcor=zeros(size(subcor16,1),size(subcor16,2),size(subcor16,3));
            ref_signal_subcor = cal_roi_signal_ts(ref_temp_subcor,sub_ima,subcor_region,subcor_label);
            boundary_info = getBoundary(ref_temp_subcor,se);%将迭代限制在相邻的脑区
            for x=1:size(subcor16,1)
                for y=1:size(subcor16,2)
                    for z=1:size(subcor16,3)
                        if subcor16(x,y,z)~=0
                            curr_voxel = subcor16(x,y,z);
                            curr_voxel_ind = sub2ind(size(ref_temp_subcor),x,y,z);
                            voxel_xyz=sub_ima(x,y,z,:);
                            voxel_xyz=squeeze(voxel_xyz);
                            %voxel_xyz = zscore(voxel_xyz);
                            [r p ]=corr(voxel_xyz,ref_signal_subcor);
                            [new_a new_b]=sort(r,'descend');
                            confi_xyz=new_a(1)/new_a(2);
                            if confi_xyz>=confidence(1,confi_i)
                                high_confi_temp_subcor(x,y,z)=subcor_label(new_b(1));
                            end
                        end
                    end
                end
            end
%             if length(unique(high_confi_temp_subcor))-1<subcor_region % make sure every parcel at least have one voxel
%                 break
%             end
            high_confi_signal_subcor=cal_roi_signal_ts(high_confi_temp_subcor,sub_ima,subcor_region,subcor_label);
            ref_signal_subcor=(high_confi_signal_subcor+ref_signal_subcor)/2;
            for x=1:size(subcor16,1)
                for y=1:size(subcor16,2)
                    for z=1:size(subcor16,3)
                        if subcor16(x,y,z)~=0
                            curr_voxel = subcor16(x,y,z);
                            [tta ttb]=find(subcor_label==curr_voxel);
                            curr_voxel =tta;
                            curr_voxel_ind = sub2ind(size(ref_temp_subcor),x,y,z);
                            if ismember(curr_voxel_ind,boundary_info{curr_voxel,1})
                                curr_voxel_in_boundary_ind = find(boundary_info{curr_voxel,1}==curr_voxel_ind);
                                voxel_xyz=sub_ima(x,y,z,:);
                                voxel_xyz=squeeze(voxel_xyz);
                                %voxel_xyz = zscore(voxel_xyz);

                                [r p ]=corr(voxel_xyz,ref_signal_subcor(:,-diff_label+boundary_info{curr_voxel,2}{curr_voxel_in_boundary_ind}));
                                [new_a new_b]=sort(r,'descend');
                                ref_temp_subcor(x,y,z)=boundary_info{curr_voxel,2}{curr_voxel_in_boundary_ind}(new_b(1));
                            end
                        end
                    end
                end
            end
            ref_temp_subcor_vec = ref_temp_subcor(ref_temp_subcor~=0);
            last_ref_temp_subcor_vec = last_ref_temp_subcor(last_ref_temp_subcor~=0);
            d = pdist([ref_temp_subcor_vec';last_ref_temp_subcor_vec'],'hamming');
%             if d<=0.02
%                 fprintf('sub %d it %d finished ratio=%d\n',i,iti,d)
%                 toc
%                 break
%             else
%                 fprintf('sub %d it %d finished ratio=%d\n',i,iti,d)
%                 toc
%             end
            temp_iti(1,iti)=dice_coefficient( last_ref_temp_subcor, ref_temp_subcor);

        end

        name_temp_dice_iti=[out_path,'cor_dice_',str_hem,list0(i).name(1:end-18),'_confi',strrep(num2str(confidence(1,confi_i),'%.2f'), '.', '_'),'.mat'];
        save(name_temp_dice_iti,'temp_iti')
        final_signal_subcor=cal_roi_signal_ts(ref_temp_subcor,sub_ima,subcor_region,subcor_label);
    
        name_temp_subcor=[out_path,'cor_temp_',str_hem,list0(i).name(1:end-18),'_confi',strrep(num2str(confidence(1,confi_i),'%.2f'), '.', '_'),'.mat'];
        save(name_temp_subcor,'ref_temp_subcor')
        
        name_signal_subcor=[out_path,'cor_signal_',str_hem,list0(i).name(1:end-18),'_confi',strrep(num2str(confidence(1,confi_i),'%.2f'), '.', '_'),'.mat'];
        save(name_signal_subcor,'final_signal_subcor')



%         name_temp_dice_iti=[out_path,'subcor_dice_',str_hem,list0(i).name(1:end-18),'_confi',strrep(num2str(confidence(1,confi_i),'%.2f'), '.', '_'),'.mat'];
%         save(name_temp_dice_iti,'temp_iti')
%         final_signal_subcor=cal_roi_signal_ts(ref_temp_subcor,sub_ima,subcor_region,subcor_label);
%     
%         name_temp_subcor=[out_path,'subcor_temp_',str_hem,list0(i).name(1:end-18),'_confi',strrep(num2str(confidence(1,confi_i),'%.2f'), '.', '_'),'.mat'];
%         save(name_temp_subcor,'ref_temp_subcor')
%         
%         name_signal_subcor=[out_path,'subcor_signal_',str_hem,list0(i).name(1:end-18),'_confi',strrep(num2str(confidence(1,confi_i),'%.2f'), '.', '_'),'.mat'];
%         save(name_signal_subcor,'final_signal_subcor')
%         
        toc
    end
end
% mat2nii(ref_temp_subcor,fullfile(out_path,[list0(i).name(1:end-4),'.nii']),size(ref_temp_subcor),32,ref_temp_file);
