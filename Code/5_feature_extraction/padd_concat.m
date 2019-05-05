function [conc] = padd_concat(u,v)
% Add Nan padding at the end of the vector and conactenate them

if length(u) > length(v)
    w=vertcat(v, NaN(length(u)-length(v),1));
    conc= [u,w];
    
elseif length(u) < length(v)
    w=vertcat(u, NaN(-length(u)+length(v), size(u,2)));
    
    conc= [w,v];

else
  
    conc= [v,u];
end

end