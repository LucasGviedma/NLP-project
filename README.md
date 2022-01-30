# NLP-project

### There are two available options to run the chatbot:
In both cases, to launch the chatbot you'll need to download the respective folder (keep all its files together in it), "double click"/run the model.R file (so that it considers the source directory of the project) and run all the lines in the file. The last line: run_model(...) is the function that will initiate the conversation with the chatbot. **When the model is fitted or loaded (depending on the chosen option) some warnings related to cuda libraries might appear, but they can be ignored**

### IMPORTANT: 
I guess you already have installed tensorflow and keras in your R enivroment or editor, but if that's not the case, please uncomment **all** the commented lines in the libraries section of the model.R file and run them in the shown order to install them. After that first installation you can comment them again (I'd also recommend to just relaunch the editor but this is optional) and just load keras and tensorflow as normal libraries with library(keras) / library(tensorflow). For the other packages that might not be installed just uncomment their respective packages.install lines as usual.

#### Option 1: train the model as i did during the process and launch the chatbot -> Folder: "NLP-normal-project-files" 
In this version the model.R file will contain all the data normalization, cleaning, semmatization, separation, tokenization processes together with the building and training in the model, after which you'll be able to run the main function to run the chatbot: run_model(...). Remember that all lines must be executed.

#### Option 2: use a pretrained by me model -> Folder: "NLP-trained-project-files" 
In this version the model.R file will just load a pretrained version of the model and tokenizer to allow the execution of the main function without all the time spent in the process shown in option1. Remember that all lines must be executed.

