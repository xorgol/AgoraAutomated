function x = beam(R,V,N,Enc)

% Beamforming matrix [R x V x N]

for m=1:R
    for c=1:V
        for s=1:N
            x(m,c,s)=Enc(s+(m-1)*N,c);
        end
    end
end

end