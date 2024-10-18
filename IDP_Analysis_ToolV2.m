
%Written by Izzy Lachcik

clc
clear all
close all

folderdir = uigetdir(path, 'Select Folder with Pressure Data');

% create subfolder in selected folder to store generated graphs
newfolderdir = dir(fullfile(folderdir,'\Min and Max Pressure Graphs'));
newFolderName = '\Min and Max Pressure Graphs';
if isempty(newfolderdir)
    mkdir(folderdir, newFolderName); 
end

    
IDP_Data= dir(fullfile(folderdir,'*.xlsx*')); 
IDPData=struct2cell(IDP_Data);


AR= IDPData(1);
FE =IDPData(2);
LB= IDPData(3);

%File path for the three directions
AR= append(IDPData(2),'\',IDPData(1,1));
FE= append(IDPData(2),'\',IDPData(1,2));
LB= append(IDPData(2),'\',IDPData(1,3));

%creates data tables for each direction
ARData = readtable(string(AR),'ReadVariableNames',true);
FEData = readtable(string(FE),'ReadVariableNames',true);
LBData = readtable(string(LB),'ReadVariableNames',true);

% AR_Data=table2array(ARData(:,2:end));


%Allows for the code to run thro FE>LB>AR
t=1
for t=1:3
        if t==1
            Data=table2array(FEData(:,2:end));
            t=2;
            sheetName= 'FE';
        elseif t==2
            Data=table2array(LBData(:,2:end));
            t=3;
            sheetName= 'LB';
        elseif t==3
            Data=table2array(ARData(:,2:end));
            t=0;
            sheetName= 'AR';
        end
         
    S=size(Data);
    S(2)=5; %temp solution
    table=string(zeros(5,S(2)+1)); %creates an empty table to store the data 
    
    labels= ['MIN';'MAX';'MAG';'ABS'];
    table(2:end,1)=labels;
    table(1:1)='Name';
    
    Length= round(length(Data)/4); %Length of one cycle about

    
    %Name= dir(fullfile(folderdir,'*.txt*'));
    %Name= struct2cell(Name);
    %N= append(Name(2),'\',Name(1));

    

    %Pname is the file path for the whole Specimen 
    PName= regexp(folderdir,'\','split');
    P=length(PName);
    Pname= PName(1);
    for i= 2: P-1
        Pname= append(Pname,'\', PName(i));
    end

    PName= append(Pname, '\Sensor Names.txt');

    if isfile(PName) == 0
        %folderdir = uigetdir(path, 'Select Folder with Pressure Data');
        Sensors= inputdlg({'Sensor 1','Sensor 2','Sensor 3','Sensor4 ','Sensor 5'},'Customer',[1 12; 1 12; 1 12; 1 12; 1 12]);
        %xlsfullfile = fullfile(folderdir,'Sensor Names.txt');
        xlsfullfile = char(fullfile(Pname,'Sensor Names.txt'));
        writecell(Sensors,xlsfullfile);
    end

    SensorName = readtable(string(PName),'ReadVariableNames',false);


    for i=1:S(2) %goes thro each of the pressure sensors
    %     AR_LC=AR_Data((length(AR_Data)-AR_Start_LC):end,i);
        Cycle=Data(:,i);
          if i==1
            subplotTitle= SensorName(1,1) 
          elseif i==2
            subplotTitle = SensorName(2,1)
          elseif i==3
            subplotTitle = SensorName(3,1)
          elseif i==4
            subplotTitle =SensorName(4,1)
          elseif i==5
            subplotTitle=SensorName(5,1)
          end


        %plotTitle= ARData.Properties.VariableDescriptions(i+1) %assuming AR, FE, LB all have the same pressure locations
       
        subplotTitle=table2array(subplotTitle);
        plotTitle= append(sheetName, '--',subplotTitle);
         
        
        [peaks,locs]=findpeaks(Cycle,'MinPeakDistance',Length,'NPeaks',3,'SortStr','descend');
        [valleys,locs2]=findpeaks(-Cycle,'MinPeakDistance',Length,'NPeaks',3,'SortStr','descend');
        
    %     MAX=max(peaks);
        MaxLocs=max(locs); %assuming the max peak occurs at the max location from findpeaks peaks
        MAX=Cycle(MaxLocs); 
    
        MinLocs=max(locs2); %assuming the min peak occurs at max location from findpeaks peaks
        MIN=-Cycle(MinLocs);
    %     MIN=max(valleys);
       

       if (MAX < 0) %when MIN and MAX are both negative
                MAG = abs(abs(MIN)-abs(MAX));
            elseif (MIN < 0) % when MIN is negative (sign is flipped)
                MAG= abs(abs(MAX)-abs(MIN));
            else
                MAG= abs(MIN)+abs(MAX);
       end

        if abs(MIN) > abs(MAX)
            AbsMax= abs(MIN);
        else
            AbsMax= abs(MAX);
        end
    
    
      
        
    %     MaxLocs=find(AR_LC==MAX);
    %     MinLocs=find(-AR_LC==MIN);
        
        
    
        curFig=figure('visible','on') 
        plot(1:length(Cycle),Cycle)
        hold on
        plot(MaxLocs,MAX,'o');
        hold on
        plot(MinLocs,-MIN,'o');
        title(plotTitle)
        xlabel 'Time'
        ylabel 'IDP(PSI)'
        hold off
        
        
        answer=questdlg('Are you happy with the results?')
    
        switch answer
            case 'Yes'
            
            a=0;
        case 'No'
            
            a=1;
        end
        
    
           
           while a ==1 %allows user to choose min and max
               
            
                curFig = figure('visible','on');
                plot(1:length(Cycle),Cycle)
                title(['Press Enter. Draw a box around the max peak first than the min peak '])
            
                buttonwait=0
                while ~buttonwait
                    buttonwait = waitforbuttonpress;
                    if ~strcmp(get(gcf,'CurrentKey'),'return')
                        buttonwait = 0;
                    end
                end
            
                rect = getrect(curFig); % [xmin ymin width height]
                % FIND MAX VALUE INSIDE RECTANGLE THAT ISN'T HIGHER THAN RECTANGLE
                rectDomain = 1:length(Cycle);
                rectDomain = rectDomain( rectDomain >= floor(rect(1)) & rectDomain <= ceil((rect(1)+rect(3))) );
                relDistLocsInROI = rectDomain(Cycle(rectDomain) <= ( rect(2)+rect(4) ) & Cycle(rectDomain) >= ( rect(2) ));
                [MAX, I] = max(Cycle(relDistLocsInROI));
                MaxLocs = relDistLocsInROI(I);
                % OVERLAY SELECTED MAX POINT
                hold on
                plot(MaxLocs,MAX,'*r','MarkerSize',8)
                hold off
                % ALLOW USER TO ZOOM
                buttonwait = 0;
                while ~buttonwait
                    buttonwait = waitforbuttonpress;
                    if ~strcmp(get(gcf,'CurrentKey'),'return')
                        buttonwait = 0;
                    end
                end
                rect = getrect(curFig); % [xmin ymin width height]
                % FIND MIN VALUE INSIDE RECTANGLE THAT ISN'T LOWER THAN RECTANGLE 
                rectDomain = 1:length(Cycle);
                rectDomain = rectDomain( rectDomain >= floor(rect(1)) & rectDomain <= ceil((rect(1)+rect(3))) );
                relDistLocsInROI = rectDomain(Cycle(rectDomain) <= ( rect(2)+rect(4) ) & Cycle(rectDomain) >= ( rect(2) ));
                [MIN, I] = min(Cycle(relDistLocsInROI));
                MinLocs = relDistLocsInROI(I);
                % OVERLAY SELECTED MIN POINT
                hold on
                plot(MinLocs,MIN,'*r','MarkerSize',8)
                MIN=-MIN;
                hold off

                if (MAX < 0) %when MIN and MAX are both negative
                    MAG = abs(abs(MIN)-abs(MAX));
                elseif (MIN < 0) % negative sign is flipped
                    MAG= abs(abs(MAX)-abs(MIN)); %when MIN and MAX are both positive
                else
                    MAG= abs(MIN)+abs(MAX);
                end

                if abs(MIN) > abs(MAX)
                    AbsMax= abs(MIN);
                else
                    AbsMax= abs(MAX);
                end
            %     axis(cur_axis) % reset axis before saving image
    
                answer=questdlg('Are you happy with the results?')
    
                switch answer
                    case 'Yes'
                    
                    a=0;
                case 'No'
                    
                    a=1;
                end
        
        
           end
            
%            plotTitle= append(sheetName, ' : ', plotTitle);
           title(plotTitle)
           xlabel 'Time'
           ylabel 'IDP(PSI)'
           name = fullfile(folderdir,newFolderName,[plotTitle '.jpg']);
          
           plotTitle=string(plotTitle);
           
           
    %        plotTitle = strrep(plotTitle, '-', ' ')
           plotT=append('\',plotTitle,'.jpg');
           
%            path= append(folderdir,newFolderName,plotTitle);
           saveas(curFig,fullfile(folderdir,newFolderName,[plotT]),'jpg'); % saves to new plots subfolder
           close(curFig)
           
           %ARData.Properties.VariableNames(i+1) = [subplotTitle];
           %summary= [ARData.Properties.VariableDescriptions(i+1); -MIN;MAX; MAG];%assumes each of the cycles have the same pressure sensor locations
           summary= [subplotTitle; -MIN;MAX; MAG;AbsMax];
           table(:,i+1)=summary(:,1);
    
  
    
    end
    
    % sheetName= 'AR';
    
    xlsfullfile = fullfile(folderdir,'Specimen Summary.xls');
    writematrix(table,xlsfullfile,'Sheet',sheetName);
    
end
close()
