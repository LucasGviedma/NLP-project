
library(keras)

source("aux_functions.R")

df  <- data.frame (text  = c(), intent = c(topic_input))
model2 <- load_model_hdf5("trained_model.hdf5")

run_chatbot(df, model2, tokenizer)

