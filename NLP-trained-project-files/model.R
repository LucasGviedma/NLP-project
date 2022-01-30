# THE FOLLOWING COMMENTED LINES SHOULD ONLY BE RUN IF KERAS AND TENSORFLOW HAVEN'T BEEN INSTALLED ALREADY IN YOUR R STUDIO ENVIRONMENT (or alternative editor)
# IF SO, PLEASE EXECUTE THEM IN THE ORDER THAT IS SHOWN (for the other normal packages just uncomment their respective install line and run it as usual)

# KERAS AND TENSORFLOW

# install.packages(c("keras", "tensorflow"))
# library("devtools")
# devtools::install_github("rstudio/keras", dependencies=TRUE)
# devtools::install_github("rstudio/tensorflow", dependencies=TRUE)
library(keras)
# install_keras()
library(tensorflow)
# install_tensorflow(version= "default")

# OTHER PACKAGES

# install.packages("tm")
# install.packages("textstem")
library(tm)
library(textstem)

source("aux_functions.R")

df        <- read.csv("dataset_intent_classification.csv")
model     <- load_model_hdf5("trained_model.hdf5")
tokenizer <- load_text_tokenizer("tokenizer.hdf5")
sorted_labels <- c("AddToPlaylist", "BookRestaurant", "GetWeather", "PlayMusic", "RateBook", "SearchCreativeWork", "SearchScreeningEvent")

run_chatbot(df, model, tokenizer)

