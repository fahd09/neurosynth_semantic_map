
clear all
% change those to your local gdrive
addpath script/helpers
data_dir = 'data';

load([data_dir '/camat_fj_20comps_1000iter'])
load([data_dir '/camat_fi_20comps_1000iter'])

figure;
plot(diag(mean(camat_fj.^2,3)),   '-ko'); 
hold on
plot(diag(mean(abs(camat_fj),3)), '-ro')
legend({'Squared Correlations';'Absolute Correlations'})
xlabel('Components', 'fontsize', 15)
ylabel('Values', 'fontsize', 15)
title('Fj SHR results', 'fontsize', 20)
saveas(gcf, './plots/squared_corr_vs_absolute_corr_fj', 'png')

figure;
plot(diag(mean(camat_fi.^2,3)),   '-ko'); 
hold on
plot(diag(mean(abs(camat_fi),3)), '-ro')
legend({'Squared Correlations';'Absolute Correlations'})
xlabel('Components', 'fontsize', 15)
ylabel('Values', 'fontsize', 15)
ylim([0, 1])
title('Fi SHR results', 'fontsize', 20)
saveas(gcf, './plots/squared_corr_vs_absolute_corr_fi', 'png')


% using absolute value of correlations

figure;
imagesc(mean(abs(camat_fj),3),  [0, 1])
%axis off
colorbar;
title('SHR results for Words'' Components', 'FontSize', 15)
saveas(gcf, './plots/Fj_splitshalves', 'png')

figure;
imagesc(mean(abs(camat_fi),3), [0, 1])
colorbar;
title('SHR results for studies components', 'FontSize', 15)
saveas(gcf, './plots/Fi_splitshalves', 'png')


figure;
imagesc(mean(camat_fj.^2,3), [0, 1])
%axis off
colorbar;
title('SHR results for Words'' Components', 'FontSize', 15)
saveas(gcf, './plots/Fj_splitshalves_squared_corr', 'png')

figure;
imagesc(mean(camat_fi.^2,3), [0, 1])
colorbar;
title('SHR results for studies components', 'FontSize', 15)
saveas(gcf, './plots/Fi_splitshalves_squared_corr', 'png')



% Additional Visualizations

% % First we concatenate all diagonals
% % then plot results
% 
% alldiags=zeros(20, length(nonzeros(camat_fi(1,1,:))) );
% alltrius=[];
% for i=1:length(nonzeros(camat_fi(1,1,:))),
%     alldiags(:,i) = diag(camat_fi(:,:,i));
%     alltrius = [alltrius; nonzeros(triu(camat_fi(:,:,i),1))];
% end
% 
% figure;
% for p=1:20,
%     subplot(4,5,p)
%     hist(abs(alldiags(p,:)))
%     title(['Component ' num2str(p) ...
%         ' | Mean= ' num2str(mean(abs(alldiags(p,:)),2))])
% end
% 
% %figure; errorbar(mean(abs(alldiags),2),std(abs(alldiags),0,2),'-ro')
% figure; plot(mean(abs(alldiags),2),'-ro')
% title('Mean Correlation per Component')
% xlabel('Components')
% ylabel('Mean Correlation')
% 
% figure; hist(abs(alltrius))
% title('Distribution of Upper Triangles-- exc. diags')

