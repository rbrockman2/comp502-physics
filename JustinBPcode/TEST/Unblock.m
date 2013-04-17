function [ocelotCOMP] = Unblock(x,orig)

ocelotCOMP = zeros(size(orig));

oceind2 = 1;
for i=1:(size(orig,1)/8)
    for j=1:(size(orig,2)/8)
        ocetmp2 = reshape(x(:,oceind2),[8 8]);
        ocelotCOMP(((i-1)*8+1):(i*8),((j-1)*8+1):(j*8))=ocetmp2;
        oceind2 = oceind2 + 1;
    end
end

end