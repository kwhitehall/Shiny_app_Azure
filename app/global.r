#Import data from blob storage
# https://cran.r-project.org/web/packages/AzureStor/AzureStor.pdf

library(AzureStor)
blob_cont <- blob_container("https://myblob.blob.core.windows.net/container", key="myKey")

#in-mem operation
rawvec <- download_blob(blob_cont, "data.csv", NULL)
data <- read.csv(text=rawToChar(rawvec), sep=";", dec=",")

# Compute more values from x variable in a helper dataframe
data_helper <- NULL
data_helper$sqrt_x <- sqrt(data$x)
data_helper$x2 <- (data$x)^2
data_helper$x3 <- (data$x)^3