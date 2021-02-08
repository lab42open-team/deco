Bootstrap:docker
From:savvasparagkamian/emodnet-data-archaeology:latest

%post
export WORKDIR="/home/EMODnet-data-archaeology"
echo "export WORKDIR=$WORKDIR" >> $SINGULARITY_ENVIRONMENT

%runscript
echo "This gets run when you run the image!" 
exec ./scripts/cli-workflow.sh "$@"
