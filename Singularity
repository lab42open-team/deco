Bootstrap:docker
From:savvasparagkamian/deco:latest

%labels
    Maintainer Savvas Paragkamian
%post
    export WORKDIR="/home/deco"
    echo "export WORKDIR=$WORKDIR" >> $SINGULARITY_ENVIRONMENT
    chmod -R 777 /home/deco

%runscript
    echo "Arguments received: $*"
    exec ./home/deco/scripts/cli-workflow.sh "$@"

