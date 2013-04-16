function [ filteredEvents ] = somFilter(minimumGain, gainMatrix, rawEvents, kohonenSom)


highGainSOMCellMatrix = zeros(kohonenSom.height,kohonenSom.width);
for i=1:kohonenSom.height
    for j=1:kohonenSom.width
        if gainMatrix(i,j) >= minimumGain
            highGainSOMCellMatrix(i,j) = 1;
        end;
    end
end

filteredEvents = zeros(size(rawEvents,1),size(rawEvents,2));

k=0;
for l = 1:size(rawEvents,1)
    winningPE = kohonenSom.findWinner(rawEvents(l,:));
    if highGainSOMCellMatrix(winningPE(1),winningPE(2)) == 1
        k=k+1;
        % disp(winningPE);
        filteredEvents(k,:) = rawEvents(l,:);
    end
end
filteredEvents = filteredEvents(1:k,:);

end

