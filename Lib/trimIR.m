function TrimSample = trimIR(convRes,N,filename)

           %% Maximum peak collection
           % Gets index from the highest peak
           [~, maxIndex] =  max(convRes);

           %Set the trim point at the first peak
           TrimSample = maxIndex-0.1*N;

           %% Plot of relevant graphs
           % Plot figure of the signal before time slicing
           figureTitle = strcat('Time slicing ',filename); % Name of the figure

           figure('Name',figureTitle,'NumberTitle','off'); % Adds name to figure, and removes its number
           
           % First figure: All IRs along with the maximum peak
           subplot(2,1,1)                                  % The figure presents two different graphs
           plot(convRes);                                  % The result of the deconvolution (all IRs) are represented
           
           hold on;
           title('Before the time slicing');

           % Draws red circles to determine the trimming point.
           plot([maxIndex maxIndex],[-100 100],'ro');

           % Draws green circles to indicate the length of each IR
           plot([TrimSample TrimSample+N-1],[0 0], 'go');
      
           hold off;

           % Second figure: First IR
           subplot(2,1,2)
           try
                plot(convRes(TrimSample:TrimSample+N));
                title('After the time slicing');

           catch % Store the paths of files which produce an error
                problematicFiles = "";
                disp("Wrong number of sweeps!");
                problematicFiles = strcat(problematicFiles, filename, ", Wrong number of sweeps", "\n");
           end
                     
           beep
        end  