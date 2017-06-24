%LDPCRate=[1/2 3/4 4/5 5/6 8/9 9/10]
windowProbability=[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]

cost910=1:0.01:1.25
T=100;
cost=cost910;
for i=1:length(cost)
    for windowInd=1:length(windowProbability)
        totalErrorRate=0;
        for j=1:T
            totalErrorRate=totalErrorRate+RaptorCodeSimulateWithDVBS2LDPC(9/10,cost(i),0.5,windowProbability(windowInd));
        end
        totalErrorRate=totalErrorRate/T;
    end
    error(i,windowInd)=totalErrorRate;
    ['9/10' cost(i) error(i,windowInd);]
end
error910=error;

cost89=1:0.01:1.25
T=100;
cost=cost89;
for i=1:length(cost)
    for windowInd=1:length(windowProbability)
        totalErrorRate=0;
        for j=1:T
            totalErrorRate=totalErrorRate+RaptorCodeSimulateWithDVBS2LDPC(8/9,cost(i),0.5,windowProbability(windowInd));
        end
        totalErrorRate=totalErrorRate/T;
    end
    error(i,windowInd)=totalErrorRate;
    ['8/9' cost(i) error(i,windowInd);]
end
error89=error;

cost56=1.1:0.01:1.35
T=100;
cost=cost56;
for i=1:length(cost)
    for windowInd=1:length(windowProbability)
        totalErrorRate=0;
        for j=1:T
            totalErrorRate=totalErrorRate+RaptorCodeSimulateWithDVBS2LDPC(5/6,cost(i),0.5,windowProbability(windowInd));
        end
        totalErrorRate=totalErrorRate/T;
    end
    error(i,windowInd)=totalErrorRate;
    ['5/6' cost(i) error(i,windowInd);]
end
error56=error;


cost45=1.1:0.01:1.4
T=100;
cost=cost45;
for i=1:length(cost)
    for windowInd=1:length(windowProbability)
        totalErrorRate=0;
        for j=1:T
            totalErrorRate=totalErrorRate+RaptorCodeSimulateWithDVBS2LDPC(4/5,cost(i),0.5,windowProbability(windowInd));
        end
        totalErrorRate=totalErrorRate/T;
    end
    error(i,windowInd)=totalErrorRate;
    ['4/5' cost(i) error(i,windowInd);]
end
error45=error;

cost34=1.2:0.01:1.5
T=100;
cost=cost34;
for i=1:length(cost)
    for windowInd=1:length(windowProbability)
        totalErrorRate=0;
        for j=1:T
            totalErrorRate=totalErrorRate+RaptorCodeSimulateWithDVBS2LDPC(3/4,cost(i),0.5,windowProbability(windowInd));
        end
        totalErrorRate=totalErrorRate/T;
    end
    error(i,windowInd)=totalErrorRate;
    ['3/4' cost(i) error(i,windowInd);]
end
error34=error;

cost12=1.8:0.01:2.2
T=100;
cost=cost12;
for i=1:length(cost)
    for windowInd=1:length(windowProbability)
        totalErrorRate=0;
        for j=1:T
            totalErrorRate=totalErrorRate+RaptorCodeSimulateWithDVBS2LDPC(1/2,cost(i),0.5,windowProbability(windowInd));
        end
        totalErrorRate=totalErrorRate/T;
    end
    error(i,windowInd)=totalErrorRate;
    ['1/2' cost(i) error(i,windowInd);]
end
error12=error;