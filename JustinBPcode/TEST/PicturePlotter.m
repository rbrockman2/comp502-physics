function COMP = PicturePlotter(DataSetAtIter,orig,imfact,setname,hLayerVec,iter,gam,alpha)

figure
colormap(gcf,gray);
COMP = Unblock(DataSetAtIter, orig);
image(COMP*imfact)

title([ setname ': ' num2str(hLayerVec(1)) ' PEs, Step=' num2str(iter) ', $\gamma$ =' num2str(gam) ', $\alpha$=' num2str(alpha)])
set(gcf,'color','w')

%plot(yt,Res.Train.dataMat(:,:,end)','bo',ytT',Res.Test.dataMat(:,:,end)','r.','markersize',2)
%title(['Output: NPE(1) = ' num2str(hLayerVec(1)) ' , $\gamma =$ , ' num2str(gam) ', $K =$ ' num2str(batchSize)],'interpreter','latex','fontsize',16)
%set(gcf,'color','w')
%xlabel('Desired Output','interpreter','latex','fontsize',16);
%ylabel('Actual Output','interpreter','latex','fontsize',16);
%hl = legend('Training Ouput', 'Test Output','N.N. Training Output', 'N.N. Test Output');
%set(hl, 'interpreter','latex','fontsize',11,'location','best')

export_fig(['T1P1-' setname '-Res_' num2str([gam hLayerVec(1) iter],'gam-%d_NPE-%d_I-%d') '.eps']); % '_' num2str(C(2:5),'%i-%i-%i-%i') '.eps'])

close


figure
colormap(gcf,gray);
COMP = Unblock(DataSetAtIter, orig);
image(abs(COMP*imfact-orig))

title([setname ' Difference: ' num2str(hLayerVec(1)) ' PEs, Step=' num2str(iter) ', $\gamma$ =' num2str(gam) ', $\alpha$=' num2str(alpha)])
set(gcf,'color','w')

%plot(yt,Res.Train.dataMat(:,:,end)','bo',ytT',Res.Test.dataMat(:,:,end)','r.','markersize',2)
%title(['Output: NPE(1) = ' num2str(hLayerVec(1)) ' , $\gamma =$ , ' num2str(gam) ', $K =$ ' num2str(batchSize)],'interpreter','latex','fontsize',16)
%set(gcf,'color','w')
%xlabel('Desired Output','interpreter','latex','fontsize',16);
%ylabel('Actual Output','interpreter','latex','fontsize',16);
%hl = legend('Training Ouput', 'Test Output','N.N. Training Output', 'N.N. Test Output');
%set(hl, 'interpreter','latex','fontsize',11,'location','best')

export_fig(['T1P1-DIFF-' setname '-Res_' num2str([gam hLayerVec(1) iter],'gam-%d_NPE-%d_I-%d') '.eps']); % '_' num2str(C(2:5),'%i-%i-%i-%i') '.eps'])

close

end