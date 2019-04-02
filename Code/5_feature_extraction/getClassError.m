function[classerror] =  getClassError ( yhat, labels)

error0=0; error1=0;

for i = 1: length(yhat)
    if labels(i) == 1 & yhat(i) == 0
        error1 = error1 + 1;
    end
    if labels(i) == 0 & yhat(i) == 1
        error0 = error0 + 1;
    end
end

nclass0 = length(find(labels == 0));
nclass1 = length(find(labels == 1));

classerror = 0.5 * error0 ./ nclass0 + 0.5*error1./nclass1;

return