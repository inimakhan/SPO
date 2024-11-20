%__________________________________________________________________ %
%                                                                   %
%                                                                   %
%                    Stochastic paint optimizer (SPO)               %
%                                                                   %
%                                                                   %
%               Developed in MATLAB R2020b (MacOs-Monterey)         %
%                                                                   %
%                      Author and programmer                        %
%                ---------------------------------                  %
%    Prof Ali Kaveh    Nima Khodadadi(ʘ‿ʘ)  Simak Talatahri         %
%                                                                   %
%                                                                   %
%                                                                   %
%                                                                   %
%                            e-Mail(2)                              %
%                ---------------------------------                  %
%                         inimakhan@me.com                          %
%                         nkhod002@fiu.edu                          %                                                                  %
%                                                                   %
%                                                                   % 
%                    https://nimakhodadadi.com                      %
%                                                                   %
%                                                                   %
%                                                                   %
%                                                                   %
%                        Cite this article                          %
%           Kaveh, A., Talatahari, S., & Khodadadi, N. (2020).      %
%          Stochastic paint optimizer: theory and application       %
%          in civil engineering. Engineering with Computers, 1-32   %
%                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%% Outputs:
% BestColors       (Best solution)
% BestFitness      (final Best fitness)
% Conv_History     (Convergence History Curve)
format long
disp('SPO is Running');
Var_Number=3;                        % Number of Variable
LB = (0)*ones(1,Var_Number);        % Upper Bound
UB = (1).*ones(1,Var_Number);    % Lower Bound
ObjFuncName= @objective;                  %Name of the Function
Colors_Number=50;                     %Number of Colors (Npop)
MaxIter=100;                          %Maximum number of iterations


%% Updating the Size of ProblemParams (If Necessary)
if length(LB)==1
    LB=repmat(LB,1,Var_Number);
end
if length(UB)==1
    UB=repmat(UB,1,Var_Number);
end

%% initialization
% Number of each group
N1stColors=fix(Colors_Number/3);
N2ndColors=fix(Colors_Number/3);
N3rdColors=Colors_Number-N1stColors-N2ndColors;
Colors=zeros(Colors_Number,Var_Number);
Fun_eval=zeros(Colors_Number,1);


% Initializing the first Colors
for ind=1:Colors_Number
    Colors(ind,:)=unifrnd(LB,UB);
    Fun_eval(ind,:)=feval(ObjFuncName,Colors(ind,:)); % Evaluating the initial Colors
end


%% Main Loop

for Iter=1:MaxIter
    for ind=1:Colors_Number
        [Fun_eval,id]=sort(Fun_eval);
        Colors=Colors(id,:);
        % Sort and Divide Colors to 3 Groups
        Group1st=Colors(1:N1stColors,:);
        Group2nd=Colors(1+N1stColors:N1stColors+N2ndColors,:);
        Group3rd=Colors((N1stColors+N2ndColors+1):Colors_Number,:);
        
        % Complement Combination
        Id1=randi(N1stColors); % Select one color blongs to the 1st group
        Id2=randi(N3rdColors); % Select one color blongs to 3st group
        NewColors(1,:)=Colors(ind,:)+rand(1,Var_Number).*(Group1st(Id1,:)-Group3rd(Id2,:));
        
        % Analog Combination
        if ind<=N1stColors
            Id=randi(N1stColors,2);
            AnalogGroup=Group1st;
        elseif ind<=N1stColors+N2ndColors
            Id=randi(N2ndColors,2);
            AnalogGroup=Group2nd;
        else
            Id=randi(N3rdColors,2);
            AnalogGroup=Group3rd;
        end
        NewColors(2,:)=Colors(ind,:)+rand(1,Var_Number).*(AnalogGroup(Id(2),:)-AnalogGroup(Id(1),:));
        
        % Triangle Combination
        Id1=randi(N1stColors); % Select a color blengs to the 1st group
        Id2=randi(N2ndColors); % Select a color blengs to the 2nd group
        Id3=randi(N3rdColors); % Select a color blengs to the 3rd group
        
        NewColors(3,:)=Colors(ind,:)+rand(1,Var_Number).*(Group1st(Id1,:)+Group2nd(Id2,:)+Group3rd(Id3,:))/3;
        
        % Rectangle Combination
        Id1=randi(N1stColors); % Select a color blengs to the  1st group
        Id2=randi(N2ndColors); % Select a color blengs to the  2nd group
        Id3=randi(N3rdColors); % Select a color blengs to the  3rd group
        Id4=randi(Colors_Number);% Select a color blengs to the  all groups
        
        NewColors(4,:)=Colors(ind,:)+(rand(1,Var_Number).*Group1st(Id1,:)+rand(1,Var_Number).*Group2nd(Id2,:)+...
            rand(1,Var_Number).*Group3rd(Id3,:)+rand(1,Var_Number).*Colors(Id4,:))/4;
        %i2=randi(size(NewColors,1))
        for i2=1:size(NewColors,1)
            %for i2=randi(size(NewColors,1))
            
            NewColors(i2,:)=bound(NewColors(i2,:),UB,LB); % Checking/Updating the boundary limits for Colorss
            Fun_evalNew(i2,:)=feval(ObjFuncName, NewColors(i2,:));% Evaluating New Solutions
            
        end
        Fun_eval=[Fun_eval;Fun_evalNew ];
        Colors=[Colors;NewColors ];
        
    end
    
    
    % Update the BestColors
    [Fun_eval, SortOrder]=sort(Fun_eval);
    Colors=Colors(SortOrder,:);
    [SortedFit,idbest]=min(Fun_eval);
    BestColors=Colors(idbest,:);
    Colors=Colors(1:Colors_Number,:);
    Fun_eval=Fun_eval(1:Colors_Number,:);
    
    
    
    
    Conv_History(Iter)=SortedFit; % Store Best Cost Ever Found
    
    disp([' Iter= ',num2str(Iter),   '  BestCost= ', num2str(Conv_History(Iter))])
    
    plot(Conv_History,'Color','r','LineWidth',2)
    title('Convergence curve')
    xlabel('Iteration');
    ylabel('Best fitness function');
    axis tight
    legend('SPO')
    
    
end


%%Boundary Handling
function x=bound(x,UB,LB)
x(x>UB)=UB(x>UB); x(x<LB)=LB(x<LB);
end

