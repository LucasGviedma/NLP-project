data_normalization <- function(df){
  
  # First normalization process
  normalization_base <- function(x){

    # Remove special characters and misspells
    x <- gsub("[^a-zA-z?0-9\']", " ", x)
    x <- gsub("[?]",  " ? ",   x)
    x <- gsub(" s ",  "\'s ",  x)
    x <- gsub("n t ", "n\'t ", x)
    x <- gsub(" d ",  "\'d ",  x)
    x <- gsub(" m ",  "\'m ",  x)
    x <- gsub(" ve ", "\'ve ", x)
    x <- gsub(" ll ", "\'ll ", x)
    x <- gsub(" re ", "'re ",  x)

    # Remove stop words and newly generated multiple spaces
    x <- removeWords(x, stopwords("en"))
    x <- gsub("[ ]+", " ",     x)

    # Set all letters to lowercase
    return(tolower(x))
  }

  df$text <- sapply(df$text, normalization_base)

  # Apply lemmatization (there is no need for doing it before removing the
  # stopwords because "stopwords" includes multiple versions of the verbs it removes)
  df$doc_id <- row.names(df)
  corpus    <- Corpus(DataframeSource(df))
  corpus    <- tm_map(corpus, lemmatize_strings)
  corpus    <- data.frame(text = sapply(corpus, as.character), stringsAsFactors = FALSE)
  df$text   <- corpus$text
  
  return(df)
  
}

user_input_processing_and_prediction <- function(input, model, tokenizer){
  
  # User input preprocessing
  input <- data.frame(text = c(input))
  input <- data_normalization(input)
  
  embeded_input <- texts_to_sequences(tokenizer, input$text)[1]
  embeded_input <- pad_sequences(sequences = embeded_input, maxlen = 50, padding = "post")
  
  unknown_val <- 1 %in% embeded_input
  
  prediction <- model %>% predict(embeded_input)
  return(c(sorted_labels[which.max(prediction)], unknown_val))
}

run_chatbot <- function(df, model, tokenizer){

  print("Welcome to the test chatbot \\(0_0)//")
  keep_running = TRUE
  while(keep_running){
    
    user_input <- readline(prompt="Input (insert 'exit' to exit): ")
    print(user_input)
    if (tolower(user_input) == "exit"){
      
      keep_running = FALSE
      print("Bye! Have a nice day!")
      write.csv(df, "dataset_intent_classification.csv", row.names = FALSE)
      
    }
    else{
      
      return <- user_input_processing_and_prediction(user_input, model, tokenizer)
      
      pred <- return[1]
      unk  <- return[2]
      
      if (unk == "TRUE"){
        
        print(paste0("Your request has words I had never seen, think you are interested in ", pred, ". Am i right?"))
        correctness_input <- "NULL"
        
        while (tolower(correctness_input) != "yes" && tolower(correctness_input) != "no"){
          correctness_input <- readline(prompt="Input (yes/no): ")
        }
        
        if (tolower(correctness_input) == "yes"){
          
          print("Great! I will include these words in my memory!")
          new_line <- data.frame (text  = c(user_input), intent = c(pred))
          df <- rbind(df, new_line)
          
        }
        else{
          
          print("I'm sorry. Would you mind saying which of the following topics you were trying to address?")
          topic_input <- "NULL"
          
          while (topic_input != "AddToPlaylist" && topic_input != "BookRestaurant"     && topic_input != "GetWeather"           && topic_input != "PlayMusic" &&     
                 topic_input != "RateBook"      && topic_input != "SearchCreativeWork" && topic_input != "SearchScreeningEvent" && topic_input != "Ignore"){
            
            topic_input <- readline(prompt="Input (AddToPlaylist, BookRestaurant, GetWeather, PlayMusic, RateBook, SearchCreativeWork, SearchScreeningEvent, Ignore <- to avoid including question in the previous intents): ")
          }
          
          print("Thank you! I'll try to be more precise next time.")
          
          if (tolower(topic_input) != "none"){
            
            new_line <- data.frame (text  = c(user_input), intent = c(topic_input))
            df <- rbind(df, new_line)
            
          }
        }
      }
      else{
        print(paste0("Yessir! Lets ",pred))
      }
    }
  }
}
