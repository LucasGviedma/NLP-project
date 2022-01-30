# THE FOLLOWING COMMENTED LINES SHOULD ONLY BE RUN IF KERAS AND TENSORFLOW HAVEN'T BEEN INSTALLED ALREADY IN YOUR R STUDIO ENVIRONMENT (or alternative editor)
# THE SAMME APPLIES FOR THE REST OF THE PACKAGES, EXECUTE THEM IN THE ORDER THAT IS SHOWN

# install.packages(c("keras", "tensorflow"))
# install.packages("devtools")
# install.packages("hash")
# install.packages("tm")
# install.packages("textstem")
# install.packages("tidyverse")
# 
# library("devtools")
# devtools::install_github("rstudio/keras", dependencies=TRUE)
# devtools::install_github("rstudio/tensorflow", dependencies=TRUE)

library(keras)
# install_keras()

library(tensorflow)
# install_tensorflow(version= "default")

library(tidyverse)
library(hash)
library(tm)
library(textstem)

source("aux_functions.R")
  
# Dataset read and reorder
df <- read.csv("dataset_intent_classification.csv")
df <- df[order(df$intent),]
row.names(df) <- NULL

df <- data_normalization(df)
df <- subset(df, select = c(text, intent))

# Dataset division and label selection
train_test_division_index <- sample.int(nrow(df), 0.7*nrow(df))

train <- df[train_test_division_index,]

train_x <- subset(train, select = c(text))
train_y <- subset(train, select = c(intent))
  
test  <- df[-train_test_division_index,]

test_x  <- subset(test, select = c(text))
test_y  <- subset(test, select = c(intent))
  
# Create and train tokenizer (only with train dataset for a more "real" evaluation)
tokenizer <- text_tokenizer(num_words = 100, filters = "", lower = FALSE,   #eee lower
                            split = " ", char_level = FALSE, oov_token = 'oov')
  
tokenizer %>% fit_text_tokenizer(train_x$text)
  
embeded_train_x <- texts_to_sequences(tokenizer, train_x$text)
embeded_train_x <- pad_sequences(sequences = embeded_train_x, maxlen = 50, padding = "post")

embeded_test_x  <- texts_to_sequences(tokenizer, test_x$text)
embeded_test_x  <- pad_sequences(sequences = embeded_test_x,  maxlen = 50, padding = "post")
  
# One hot encode labels
sorted_labels = sort(unique(train_y)$intent)
i=1
dict <- hash()
while(i<length(sorted_labels)+1){
  dict[[sorted_labels[i]]] <- i-1
  i <- i + 1 
}
  
encoded_train_y <- sapply(train_y$intent, function (x) dict[[x]])
encoded_test_y  <- sapply(test_y$intent, function (x) dict[[x]])
  
encoded_train_y <- to_categorical(y = encoded_train_y)
encoded_test_y  <- to_categorical(y = encoded_test_y)

# Model definition
model <- keras_model_sequential() %>% 
         layer_embedding(input_dim = length(tokenizer$word_index) + 1 , output_dim = 384, input_length = 50) %>%  # Transform tokenized vectors in weight vectors
         bidirectional(layer_lstm(units = 192, dropout = 0.2)) %>%                                                # Make the model consider what's before and after every token for context
         layer_dense(units = 192, activation = "relu") %>%                                                        # Normal deep neural layer 
         layer_dropout(rate = 0.5) %>%                                                                            # % of neurons that are will be "dropped"
         layer_dense(units = length(sorted_labels), activation = "softmax") %>%                                   # Normal deep neural layer 
         compile(
            optimizer = 'Adam',                                                                                   # Stochastic gradient descent based algorithm
            loss      = 'categorical_crossentropy',                                                               # Loss for one hot encoded variables
            metrics   =  c('accuracy')                                                                            # Metric for classification problem
         )
      
print(model)
    
# Training and evaluation
model %>% fit(embeded_train_x, encoded_train_y, callbacks = list(
    callback_early_stopping(monitor = "loss")
))
      
model %>% evaluate(embeded_test_x, encoded_test_y)

#MAIN FUNCTION
run_chatbot(df, model, tokenizer)
