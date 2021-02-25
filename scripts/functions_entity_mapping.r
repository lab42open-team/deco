library(httr)
## function to call the worms API based on a NCBI Taxonomy id

worms_api <- function(tool,id_query){
    
    if (tool=="EXTRACT") {

        ## worms API based on NCBI ids
        url <- paste("http://www.marinespecies.org/rest/AphiaRecordByExternalID/",id_query,"?type=ncbi",sep="")

    } else if (tool=="gnfinder") {
        
        ## worms API based on names
        url <- paste("https://www.marinespecies.org/rest/AphiaRecordsByName/",id_query,"?like=true&marine_only=false&offset=1",sep="")
    } else if (tool=="aphia_id") {
        
        ## get all records from worms API based on aphia id
        url <- paste("https://www.marinespecies.org/rest/AphiaRecordByAphiaID/",id_query,sep="")

    } else {
        print("Please choose between 'EXTRACT', 'gnfinder' and Aphia ids for the worms API")
        break
    }

    get_url <- GET(url)
#    message_for_status(get_url)
    worms_status <- status_code(get_url)
    worms_content <- content(get_url)
    
    if (worms_status==200){

        return(worms_content)
    } else {

        return(worms_status)
    }
}

# function to remove NULL values from the list
list_null <- function(x) {

    if (is.null(x)){
        return(NA)
    } else {
        return(x)
    }
}

# Main function. It requires the tool names, currently EXTRACT and gnfinder to output a dataframe with all the information stored in Worms database.
#
get_AphiaIDs_extract <- function(vector_ids,tool) {

    tool <- tool
    vector_ids <- vector_ids
    worms_content <- list()
    total=length(vector_ids)
    print("EXTRACT")
    pb <- txtProgressBar(min = 0, max = total, style = 3)

    worms_df <- data.frame(matrix(data = NA,nrow= length(vector_ids),ncol=29))

    colnames(worms_df) <- c("AphiaID","url","scientificname","authority","status","unacceptreason","taxonRankID","rank","valid_AphiaID","valid_name","valid_authority","parentNameUsageID","kingdom","phylum","class","order","family","genus","citation","lsid","isMarine","isBrackish","isFreshwater","isTerrestrial","isExtinct","match_type","modified","id","tool")

    for (i in seq(1,length(vector_ids),by=1)){
        
        id_query=as.character(vector_ids[i])
        worms_content <- worms_api(tool,id_query)

        worms_df$id[i] <- id_query
        worms_df$tool[i] <- tool
        
       # if (length(worms_content>1))

        if (!is.numeric(worms_content)) {
                 worms_content <- lapply(worms_content, list_null)
        }

        for (j in seq(1,27,by=1)) {

            if (!is.numeric(worms_content)) {
                
                worms_df[i,j] <- worms_content[[j]]

            } else {

                worms_df[i,j] <- worms_content
            }
        }
        ## not to overload the Worms server
        Sys.sleep(sample(c(0.5,0.6,0.7,0.75), 1))
        setTxtProgressBar(pb, i)
    }
    close(pb)
    return(worms_df)
}

get_AphiaIDs_gnfinder <- function(vector_ids) {

    tool <- "gnfinder"
    vector_ids <- vector_ids
    worms_content <- list()

    total=length(vector_ids)
    print(tool)
    pb <- txtProgressBar(min = 0, max = total, style = 3)

    worms_df <- data.frame(matrix(data = NA,nrow=1,ncol=29))

    for (i in seq(1,length(vector_ids),by=1)){

        id_query=as.character(vector_ids[i])
        worms_content <- worms_api(tool,id_query)
        row_result <- data.frame(matrix(data = NA,nrow=length(worms_content),ncol=29))

        for (l in seq(1,length(worms_content),by=1)){

            row_result[l,28] <- id_query
            row_result[l,29] <- tool


            for (j in seq(1,27,by=1)) {

                if (!is.numeric(worms_content[[l]])) {
                    
                    worms_content[[l]] <- lapply(worms_content[[l]], list_null)
                    
                    row_result[l,j] <- as.character(worms_content[[l]][[j]])

                } else {

                    row_result[l,j] <- as.character(worms_content)
                }
            }
            ## not to overload the Worms server
        }

        worms_df <- bind_rows(row_result, worms_df)
        Sys.sleep(sample(c(0.5,0.6,0.7,0.75), 1))
        setTxtProgressBar(pb, i)
    }

    colnames(worms_df) <- c("AphiaID","url","scientificname","authority","status","unacceptreason","taxonRankID","rank","valid_AphiaID","valid_name","valid_authority","parentNameUsageID","kingdom","phylum","class","order","family","genus","citation","lsid","isMarine","isBrackish","isFreshwater","isTerrestrial","isExtinct","match_type","modified","id","tool")
    
    return(worms_df)
    close(pb)
}
