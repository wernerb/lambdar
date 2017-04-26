# create function to install and load R packages
installPackages <- function(packages, repo='https://cloud.r-project.org/'){
    new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
    if(length(new.packages)) {install.packages(new.packages, repos=repo)}
    for (p in 1:length(packages)){
        eval(parse(text=paste("library(",packages[p],")")))
    }
}
# install the required packages
requiredPackages <- c('catR','jsonlite', 'curl', 'data.table', 'plumber', 'mirt')
installPackages(packages=requiredPackages)
# remove objects that are not required
rm(list=c('requiredPackages'))
