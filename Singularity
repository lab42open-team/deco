Bootstrap:docker
From:savvasparagkamian/emodnet-data-archaeology:latest

%labels
    Maintainer Savvas Paragkamian
%post
    export WORKDIR="/home/EMODnet-data-archaeology"
    echo "export WORKDIR=$WORKDIR" >> $SINGULARITY_ENVIRONMENT
    chmod -R 777 /home/EMODnet-data-archaeology

%runscript
    echo "Arguments received: $*"
    exec ./home/EMODnet-data-archaeology/scripts/cli-workflow.sh "$@"
