function [x] = MakeBlocks(ocelot)

x = zeros([64 prod(size(ocelot)./8)]);

oceind1 = 1;
for i=1:(size(ocelot,1)/8)
    for j=1:(size(ocelot,2)/8)
        ocetmp1 = ocelot(((i-1)*8+1):(i*8),((j-1)*8+1):(j*8));
        x(:,oceind1) = reshape(ocetmp1,[64 1]);
        oceind1 = oceind1 + 1;
    end
end

end