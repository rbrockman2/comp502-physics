function cnv = ConvergenceEval(errVecAll,CE)

if errVecAll(2,1)>CE.maxIter
    cnv = 1;
    disp('Did Not Converge, Reached Max. Learning Step')
elseif errVecAll(2,4)<CE.eps
    cnv = 3;
    disp('Converged By RMS Point RMSD Difference')
elseif errVecAll(2,3)<CE.eps
    cnv = 2;
    disp('Converged By Mean Point RMSD Difference')
elseif errVecAll(2,2)<CE.eps
    cnv = 2;
    disp('Converged By Mean Abs. Err. Difference')
elseif errVecAll(2,5)>CE.epsdecpct
    cnv = 5;
    disp('Converged By Decision Pct')
else
    cnv = 0;
end

end