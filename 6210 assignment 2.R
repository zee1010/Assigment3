###In this project we used two different machine learning techniques in a supervised machine learning approach to separate Cytochrome c oxidase 1 (COI) and Cytochrome b (cytb) sequences within the family Muridae.The objective was to investigate whether one classifier outperforms the other when differentiating the two genes. The Muridae family was chosen so sufficient IDs can be obtained for our classification, they are the largest family of rodents and mammals and they also contain one of the most studied genus Mus(Aghov? et al., 2018). COI and cytB are protein coding genes, encoded by the mitochondria, in the past they have been used for phylogenetic analysis at various taxonomic levels as well as successfully estimating divergence(Kartavtsev, 2011). However, because they are both protein coding and encoded by the mitochondria they are likely to have similar sequences. Therefore, It is interesting to explore whether their sequences have sufficient variability within the Muridae family to be considered distinct. The two classifiers used in our project are Random Forest and Naive Bayes classifier. The Random forest classifier uses an ensemble algorithm, which was first introduced Breiman (Latief et al.,2019). It creates multiple decision trees through regression models and each tree predicts an outcome, the one with the most "votes" is used for classification (Yiu, 2021; Latief et al.,2019). Some advantages of the random forest classifier include: efficiency, only few parameters are needed in comparison to other models, and it is not sensitive to over fitting (Latief et al.,2019). The Naive Bayes is based on Bayes theorem and uses a probabilistic prediction approach to create a model (Latief et al.,2019).The term Naive is reflects that the predictors used are independent of each other(Gandhi, 2018). Some advantages of the Naive Bayes model include accuracy and speed. 

###calling all packages required:
#Packages from CRAN:

#install tidyverse package, if needed, then load.
#install.packages("tidyverse")
library(tidyverse) 

#To install randomForest package, if needed and then load
#install.packages("randomForest")
library(randomForest)

#install.packages("rentrez")
library(rentrez)

#install.packages("seqinr")
library(seqinr)

#install.packages("naivebayes")
library(naivebayes)

#install.packages("psych")
library(psych)

#install.packages("ggplot")
library(ggplot2)

#Package from Bioconductor:
#To install Bioconductor packages
#install.packages("BiocManager")
#library(BiocManager)
#BiocManager::install("Biostrings")
library(Biostrings)

#install.packages("remotes")
remotes::install_github("gschofl/rentrez")

# install.packages("caret")
library(caret)

####Data Acquisition

# #Look for searchable fields in nuccore database to determine which ones will be used for analysis
# entrez_db_searchable(db = "nuccore")
# 
# #Create function to fetch fasta files required for analysis from Entrez_fuction script used in class
# FetchFastaFiles <- function(searchTerm, seqsPerFile = 100, fastaFileName) {
#   
# # This function will fetch FASTA files from NCBI nuccore based on a provided search term.
# # searchTerm = character vector containing Entrez search term
# # seqsPerFile = number of sequences to write to each FASTA file
# # fastaFileName = character vector containing name you want to give to the FASTA files you are fetching
#   
# # Initial search for finding maximum number of hits
# search1 <- entrez_search(db = "nuccore", term = searchTerm)
# # Second search for obtaining max number of hits and their IDs
# search2 <- entrez_search(db = "nuccore", term = searchTerm, retmax = search1$count, use_history = T)
#   
# # Fetch the sequences in FASTA format using the web_history object.
# for (start_rec in seq(0, search2$retmax, seqsPerFile)) {
#     fname <- paste(fastaFileName, start_rec, ".fasta", sep = "")
#     recs <- entrez_fetch(db = "nuccore", web_history = search2$web_history, rettype = "fasta", retstart = start_rec, retmax = seqsPerFile)
#     write(recs, fname)
#     print(paste("Wrote records to ", fname, sep = ""))
#   }
#   
# return(search2)
#   
# }
# 
# ##Using the  function to fetch fasta files
# #Searching for Muridae (common and scientific names using ORGN] and gene CytB in nuccore database (nucleotide database). The length of cytB gene sequence length is restricted to 600-1000bp to prevent whole mitochondrial genomes from being incorporated. Each fasta file will contain 1000 sequences
# Muridae_cytB<-FetchFastaFiles("Muridae[ORGN] AND CytB[Gene] AND 600:1000[SLEN]", 1000, "Muridae_cytB")
# 
# #Searching for Muridae (common and scientific names using ORGN] and gene COI in nuccore database (nucleotide database). The length of COI gene sequence length is restricted to 600-700bp to prevent whole mitochondrial genomes from being incorporated. Each fasta file will contain 1000 sequences
# Muridae_COI<-FetchFastaFiles("Muridae[ORGN] AND COI[Gene] AND 400:700[SLEN]", 1000, "Muridae_COI")
# 
# ###Creating a function merge the all the fasta files together using Entrez_fuction script used in class ito one dataframe
# MergeFastaFiles <- function(filePattern) {
#   
# # This function merges multiple FASTA files into one dataframe.
#   
# # filePattern = Character vector containing common pattern in FASTA file names
#   
# # Read the FASTA files in.
# fastaFiles <- list.files(pattern = filePattern)
# l_fastaFiles <- lapply(fastaFiles, readDNAStringSet)
#   
# # Convert them into dataframes.
# l_dfFastaFiles <- lapply(l_fastaFiles, function(x) data.frame(Title = names(x), Sequence = paste(x) ))
#   
# # Combine the list of dataframes into one dataframe.
# Muridae_COIs <- do.call("rbind", l_dfFastaFiles)
#   
# return(Muridae_COIs)
#   
# }
# 
# #Creating dataframes 
# Muridae_COI<-MergeFastaFiles("Muridae_COI*")
# Muridae_cytB<-MergeFastaFiles("Muridae_cytB*")

# Search for CytB gene from nuccore database 
cytb_search <- reutils::esearch(db="nuccore",term = "Muridae[ORGN] AND CytB[Gene] AND 600:1000[SLEN]", usehistory = T) 

# Fetch data into fasta file.
cytb_fetch <- reutils::efetch(cytb_search, db="nuccore", rettype="fasta", retmode = "text", outfile = "cytb.txt")  

# Read DNA String Set from fasta file 
stringSet1 <- readDNAStringSet(cytb_fetch, format="fasta")

# Creating dataframe 
Muridae_cytB <- data.frame(Title=names(stringSet1), Sequence=paste(stringSet1))

# Search for COI gene from nuccore database 
COI_search <- reutils::esearch(db="nuccore",term = "Muridae[ORGN] AND COI[Gene] AND 400:700[SLEN]", usehistory = T) 

# Fetch data into fasta file.
COI_fetch <- reutils::efetch(COI_search, db="nuccore", rettype="fasta", retmode = "text", outfile = "COI.txt")  

# Read DNA String Set from fasta file 
stringSet2 <- readDNAStringSet(COI_fetch, format="fasta")

# Creating dataframe 
Muridae_COI <- data.frame(Title=names(stringSet2), Sequence=paste(stringSet2))


#cleaning up species names so they are more easily readable using stringr package and the function word(). This constricts the title to only species name, which are specified by 2L and 3L and a new column called species name is created
Muridae_COI$Species_name <- word(Muridae_COI$Title, 2L, 3L)

#Rearranging columns so species name comes after title, followed by sequence
Muridae_COI <- Muridae_COI[, c("Title", "Species_name", "Sequence")]

#Same for cytB sequences
Muridae_cytB$Species_name <- word(Muridae_cytB$Title, 2L, 3L)
Muridae_cytB <- Muridae_cytB[, c("Title", "Species_name", "Sequence")]

####Data Exploration
#Viewing data frames
View(Muridae_COI)
View(Muridae_cytB)

#summary
summary(Muridae_COI)
summary(Muridae_cytB)

#check column names
names(Muridae_COI)
names(Muridae_cytB)

#To see wide range of sequence lengths for COI we will create a histogram with sequence length on the x-axis and frequency on y =-axis
hist(nchar(Muridae_COI$Sequence), xlab="Sequence length", ylab= "Frequency", main="Frequency histogram for COI sequence lengths")

#same for cytB
hist(nchar(Muridae_cytB$Sequence), xlab="Sequence length", ylab= "Frequency", main="Frequency histogram for cytB sequence lengths")
#cytB sequence length is more spread out compared to COI indicating variability

####Data Filtering

#Creating a new nucleotides column to clean up the sequences to have biological sequences rather than alignments. 
#trimming ends, removing gaps and N's (may still have up to 5% Ns)
Muridae_COI <- Muridae_COI %>%
  mutate(Sequence2 = str_remove(Sequence, "^[-N]+")) %>%
  mutate(Sequence2 = str_remove(Sequence2, "[-N]+$")) %>%
  mutate(Sequence2 = str_remove_all(Sequence2, "-+")) %>%
  filter(str_count(Sequence2, "N") <= (0.05 * str_count(Sequence)))
#Same for cytB
Muridae_cytB <- Muridae_cytB %>%
  mutate(Sequence2 = str_remove(Sequence, "^[-N]+")) %>%
  mutate(Sequence2 = str_remove(Sequence2, "[-N]+$")) %>%
  mutate(Sequence2 = str_remove_all(Sequence2, "-+")) %>%
  filter(str_count(Sequence2, "N") <= (0.05 * str_count(Sequence)))

#Because the sequence range was so wide as can be seen in the histogram we will constrain seqeunces to above first quartile but below 3rd
#Determining first and third quartile sequence lengths for COI and cytB. This will tell us at what value of sequence length 25% of the observations fall below that sequence length and for 75% of sequence lengths fall above that length. This ensures that we aren't keeping lengths that are either too short or too long as they could have different properties
q1_COI <- quantile(nchar(Muridae_COI$Sequence2), probs = 0.25, na.rm = TRUE)
q1_COI

q3_COI <- quantile(nchar(Muridae_COI$Sequence2), probs = 0.75, na.rm = TRUE)
q3_COI

q1_cytB <- quantile(nchar(Muridae_cytB$Sequence2), probs = 0.25, na.rm = TRUE)
q1_cytB

q3_cytB <- quantile(nchar(Muridae_cytB$Sequence2), probs = 0.75, na.rm = TRUE)
q3_cytB

#We are now constraining sequence lengths to those that are greater than the first quartile but lesser than the third quartile. 
Muridae_COI <- Muridae_COI %>%
  filter((str_count(Sequence2) >= q1_COI & str_count(Sequence2) <= q3_COI))
#same for Muridae
Muridae_cytB <- Muridae_cytB %>%
  filter((str_count(Sequence2) >= q1_cytB & str_count(Sequence2) <= q3_cytB))

#View to ensure our queries worked
View(Muridae_COI)
View(Muridae_cytB)

class(Muridae_COI)
class(Muridae_cytB)

##Caluculating Sequence features:
#converting sequence column to a DNAStringSet
Muridae_COI$Sequence2 <- DNAStringSet(Muridae_COI$Sequence2)
#same for cytB
Muridae_cytB$Sequence2 <- DNAStringSet(Muridae_cytB$Sequence2)

#to ensure it has been converted to a DNA String Set
class(Muridae_COI$Sequence2)
class(Muridae_cytB$Sequence2)

##Calculating Nucleotide frequency and binding the column to our dataframe. Alphabet frequency cannot be used here as it may lead to the incorporation of Ns (more than required, 5% may still be included because of how our data is filtered)
Muridae_COI <- cbind(Muridae_COI, as.data.frame(letterFrequency(Muridae_COI$Sequence2, letters = c("A", "C","G", "T"))))
#same by cytB
Muridae_cytB <- cbind(Muridae_cytB, as.data.frame(letterFrequency(Muridae_cytB$Sequence2, letters = c("A", "C","G", "T"))))
#view to ensure they have been incorporated as a column
View(Muridae_COI)
View(Muridae_cytB)

##Calculating proprtions of A, T C and G for COI.Cs not included as rest of the proportion is C
Muridae_COI$Aprop <- (Muridae_COI$A) / (Muridae_COI$A + Muridae_COI$T + Muridae_COI$C + Muridae_COI$G)

Muridae_COI$Tprop <- (Muridae_COI$T) / (Muridae_COI$A + Muridae_COI$T + Muridae_COI$C + Muridae_COI$G)

Muridae_COI$Gprop <- (Muridae_COI$G) / (Muridae_COI$A + Muridae_COI$T + Muridae_COI$C + Muridae_COI$G)

#same for CytB
Muridae_cytB$Aprop <- (Muridae_cytB$A) / (Muridae_cytB$A + Muridae_cytB$T + Muridae_cytB$C + Muridae_cytB$G)

Muridae_cytB$Tprop <- (Muridae_cytB$T) / (Muridae_cytB$A + Muridae_cytB$T + Muridae_cytB$C + Muridae_cytB$G)

Muridae_cytB$Gprop <- (Muridae_cytB$G) / (Muridae_cytB$A + Muridae_cytB$T + Muridae_cytB$C + Muridae_cytB$G)

##View to ensure proportions have been added
View(Muridae_COI)
View(Muridae_cytB)

##Adding dinucleotide k-mers of length 2 to account for sequence variability
Muridae_COI <- cbind(Muridae_COI, as.data.frame(dinucleotideFrequency(Muridae_COI$Sequence2, as.prob = TRUE)))
#same for cytB
Muridae_cytB <- cbind(Muridae_cytB, as.data.frame(dinucleotideFrequency(Muridae_cytB$Sequence2, as.prob = TRUE)))

##Adding dinucleotide k-mers of length 3 to account for sequence variability
Muridae_COI <- cbind(Muridae_COI, as.data.frame(trinucleotideFrequency(Muridae_COI$Sequence2, as.prob = TRUE)))

Muridae_cytB <- cbind(Muridae_cytB, as.data.frame(trinucleotideFrequency(Muridae_cytB$Sequence2, as.prob = TRUE)))

#add new column called 'Code' to COI sequences so they can easily be differentiated when dataframe is merged
Muridae_COI$Code <- 'COI'
#same for cytB
Muridae_cytB$Code <- 'cytB'
#Merging cytB and COI dataframes into one data frame
Muridae_all<- rbind(Muridae_COI, Muridae_cytB)
#to enssure they have been merged correctly and have 5433 observations, 3632 from cyt_B and 1801 from COI
table(Muridae_all$Code)
View(Muridae_all)
str(Muridae_all)
head(Muridae_all)
#to see most occuring species name in the data frame
sort(table(Muridae_all$Species_name))

#Since the data collected is either part of COI genes or cytB there are no missing cases, but if there were, only complete cases of genes and species name would have been taken and the rest would have been filtered out using complete.cases. The Muridae family is large enough that filtering out incomplete data would not impact our results.

###Main Analysis

###Creating Validating data set
#We want to see if COI and cytB have enough variation in their sequences to be classified separately 
#Change sequence data back to character so it is easier to apply tidyverse functions
Muridae_all$Sequence2<- as.character(Muridae_all$Sequence2)

# #The maximum sample size is 1801 as there are only 1801 sequences for COI. We will take 25% of the sample to be the validation dataset. This will separate from our training dataset.
# .25*1801
# #We will take 450 samples from each data set which will be used as our validation dataset later on. To make our script reproducible we will be setting seed.
# set.seed(221)
# Muridae_Validation <- Muridae_all %>%group_by(Code) %>% sample_n(450)
# #Checking sample size for each marker is same
# table(Muridae_Validation$Code)
# 
# ###Creating Training data set
# #Picking data that is not part of the validating dataset
# set.seed(192)
# Muridae_Training<- Muridae_all %>% filter (!Title %in% Muridae_Validation) %>% group_by(Code) %>% sample_n(1351)
# #ensuring we have 1351 samples of each for our training dataset
# table(Muridae_Training$Code)
# 
# #checking column numbers and names to determine which columns will be used in the next part of the code
# names(Muridae_Training)

# To make our script reproducible we will be setting seed.
set.seed(221)
#The maximum sample size is 1801 as there are only 1801 sequences for COI. We will take 25% of the sample to be the validation dataset. This will separate from our training dataset.
strees_Validatiion <- sum(Muridae_all$Code =="COI", TRUE)*.25 
#We will take 450 samples from each data set which will be used as our validation dataset later on. 

#The rest of the samples go into training set.
strees_Training <- sum(Muridae_all$Code =="COI", TRUE)*.75

Muridae_Validation <- Muridae_all %>%group_by(Code) %>% sample_n(strees_Validatiion)
#Checking sample size for each marker is same
table(Muridae_Validation$Code)

###Creating Training data set
#Picking data that is not part of the validating dataset
set.seed(192)
Muridae_Training<- Muridae_all %>% filter (!Title %in% Muridae_Validation) %>% group_by(Code) %>% sample_n(strees_Training)
#ensuring we have 1351 samples of each for our training dataset
table(Muridae_Training$Code)

#Building a gene classifier to separate COI and cytB genes using A, T, G proportions, followed by more complex k-mers if needed
random_classifier <- randomForest::randomForest(x = Muridae_Training[, 9:11], y = as.factor(Muridae_Training$Code), ntree = 50, importance = TRUE)
#looking to see if gene classifier worked
random_classifier
#increasing the number of trees to 500 to see if it more accurate
random_classifier_ <- randomForest::randomForest(x = Muridae_Training[, 9:11], y = as.factor(Muridae_Training$Code), ntree = 500, importance = TRUE)
random_classifier_
#It wasn't able to classify all of them accurately using ATCG proportions, error rate of 0.07% so k-mers of length 2 will be used to see if it classifies it better
random_classifier_1 <- randomForest::randomForest(x = Muridae_Training[, 12:27], y = as.factor(Muridae_Training$Code), ntree = 50, importance = TRUE)
random_classifier_1
#The error rate remains at 0.07% so increasing the number of trees to 500
random_classifier_1_1 <- randomForest::randomForest(x = Muridae_Training[, 12:27], y = as.factor(Muridae_Training$Code), ntree = 500, importance = TRUE)
random_classifier_1_1
#Error rate increases to 0.11% at 500 so k-mers of length 3 will be used to see if it classifies it better
random_classifier_2 <- randomForest::randomForest(x = Muridae_Training[, 28:91], y = as.factor(Muridae_Training$Code), ntree = 50, importance = TRUE)
random_classifier_2
#this classified them perfectly
#testing on unseen data
predictValidation <- predict(random_classifier_2, Muridae_Validation[, c(70, 28:91)])

#These are the predictions that were made
predictValidation
class(predictValidation)
length(predictValidation)
table(predictValidation)

#Viewing confusion matrix to determine true positives, negatives as well as false positives and negatives in the dataset
random_classifier_2$confusion

#relative importance of each feature
random_classifier_2$importance

#This shows the fraction of votes each gene got
random_classifier_2$votes


#Trying to see if classifier works on unseen data
table(observed = Muridae_Validation$Code, predicted = predictValidation)
#Our classifer works well with unseen data as well

# ##Adding error values to be used later 
# random_error<-0.0007
# random_error_1<-0.0007
# random_error_2<-0
# 

##Next we will try a different classifier known as Naive Bayes classifer to see if COI and cytB can be distinguished. Creating classifier with ATG proportions as training
Bayes_Classifier<-naive_bayes(x = Muridae_Training[, 9:11], y = as.factor(Muridae_Training$Code))
Bayes_Classifier

#Predicting
Bayes_predict<- predict(Bayes_Classifier, Muridae_Training, type='prob')
(head(cbind(Bayes_predict, Muridae_Training)))
### the first few rows are COI sequences and and it is able to predict it with a 80-90% probability

#Confusion matrix-train data
Bayes_train<-predict(Bayes_Classifier, Muridae_Training)
(tab1<-table(Bayes_train, Muridae_Training$Code))
#there were 1333 correct predictions for COI and 1351 for cytB

#Statistical tests and CM of single nucleotide training set 
cm1 <- confusionMatrix(Bayes_train, as.factor(Muridae_Training$Code))
cm1

#Confusion matrix-test data
Bayes_test<-predict(Bayes_Classifier, Muridae_Validation)
(tab2<-table(Bayes_test, Muridae_Validation$Code))
#there were 455 correct COI and 450 correct cytB genes classified
#the error rate is 
Bayes_error<-1-sum(diag(tab1))/sum(tab1)

#Trying to see if the classifier can be made more accurate by incorporating k-mers of length 2

Bayes_Classifier_1<-naive_bayes(x = Muridae_Training[, 12:27], y = as.factor(Muridae_Training$Code))
Bayes_Classifier_1

#Predicting
Bayes_predict_1<- predict(Bayes_Classifier_1, Muridae_Training, type='prob')
head(cbind(Bayes_predict_1, Muridae_Training))
### the first few rows are COI sequences and and it is able to predict it with almost 100% probability
#Confusion matrix-train data
Bayes_train_1<-predict(Bayes_Classifier_1, Muridae_Training)
(tab_1_1<-table(Bayes_train_1, Muridae_Training$Code))
#there were 1348 correct predictions for COI and 1351 for cytB
#Confusion matrix-test data
Bayes_test_1<-predict(Bayes_Classifier_1, Muridae_Validation)
(tab2_1<-table(Bayes_test_1, Muridae_Validation$Code))
#there were 449 correct COI and 450 correct cytB genes classified
#the error rate for training dataset is
Bayes_error_1<-1-sum(diag(tab_1_1))/sum(tab_1_1)


#Trying to see if the classifier can be made more accurate by incorporating k-mers of length 3
Bayes_Classifier_2<-naive_bayes(x = Muridae_Training[, 28:91], y = as.factor(Muridae_Training$Code))
Bayes_Classifier_2

#Predicting
Bayes_predict_2<- predict(Bayes_Classifier_2, Muridae_Training, type='prob')
head(cbind(Bayes_predict_2, Muridae_Training))
### the first few rows are COI sequences and and it is able to predict it with almost 100% probability
#Confusion matrix-train data
Bayes_train_2<-predict(Bayes_Classifier_2, Muridae_Training)
(tab_1_2<-table(Bayes_train_2, Muridae_Training$Code))
#there were 1351 correct predictions for COI and 1351 for cytB

#Statistical tests and CM of trinucleotide training set 
cm2 <- confusionMatrix(Bayes_train_2, as.factor(Muridae_Training$Code))
cm2

#Confusion matrix-test data
Bayes_test_2<-predict(Bayes_Classifier_2, Muridae_Validation)
(tab2_2<-table(Bayes_test_2, Muridae_Validation$Code))
#there were 450 correct COI and 450 correct cytB genes classified
#the error rate for training dataset is
(Bayes_error_2<-1-sum(diag(tab_1_2))/sum(tab_1_2))
#This led to perfect classification as that seen in random forest classifier

# ##plotting accuracy rates of each classifier from random forest as well as Naive Bayes. Random forest classifiers with increased number of trees(500) were omitted as they had similar error rates or higher to those with 50 trees
# error_rates<-rbind(Bayes_error, Bayes_error_1, Bayes_error_2, random_error, random_error_1, random_error_2)
# #convert to dataframe
# error_rates<-as.data.frame(error_rates)
# #convert classfier name so it is considered a column and not individual rows
# error_rates <-  error_rates %>% 
#   rownames_to_column('classifier_name')
# #Viewing to see if it worked
# error_rates
# #replacing column name to error in data frame
# colnames(error_rates)<-c("classifier_names", "error")
# #Viewing to see if it worked
# error_rates
# #Creating a barplot for accuracy of each classifier created
# bar_plot<-ggplot(error_rates, aes(x=classifier_names, y=error, title="Error frequency in classfiers")) +
#   geom_bar(stat="identity")+theme_minimal()

# #Creating a barplot for accuracy of each classifier created
# theme_update(plot.title = element_text(hjust = 0.5))
# bar_plot<-ggplot(error_rates, aes(x=classifier_names, y=error)) + ggtitle("Error frequency in classfiers") + theme(plot.title = element_text(hjust = 0.5))  + geom_bar(stat="identity") +theme_minimal()
# bar_plot


##plotting accuracy rates of each classifier from random forest as well as Naive Bayes. Random forest classifiers with increased number of trees(500) were omitted as they had similar error rates or higher to those with 50 trees
error_rates<-rbind(Bayes_error, Bayes_error_1, Bayes_error_2)
rownames(error_rates) <- c("singlenucleotide", "dinucleotide", "trinucleotide")
error_rates<-as.data.frame(error_rates) 
error_rates <- error_rates %>% 
  rownames_to_column('classifier_name')
colnames(error_rates) <- c('dataset', 'error_rates')

#Viewing to see if it worked
error_rates

#Creating a barplot for accuracy of each classifier created
theme_update(plot.title = element_text(hjust = 0.5))
bar_plot<-ggplot(error_rates, aes(x= reorder(dataset, -error_rates), y=error_rates)) + ggtitle("Error frequency in three data sets")+ xlab("Data Set")+ ylab("Error Rate") + theme(plot.title = element_text(hjust = 0.5))  + geom_bar(stat="identity", color='blue', fill='red') +theme_minimal()
bar_plot

###Results and Discussion:
#Our study was intended to investigate whether Random Forest or Naive Bayes classifier would be better at predicting COI and cytB within the Muridae family. We predicted that Random forest would be able to classify COI and cytB genes far more efficiently and accurately based on our literature search. In one example from Lemons et al., 2020, the random forest classifier was outperformed Naive Bayes and had an accuracy of 97.82% when diagnosing breast cancer. From our results we can see that using both classifiers, Random Forest and Naive Bayes were not able to accurately classify all COI and cytB sequences from AGT proportions alone within the Muridae family. In Random Forest the first classifier generated had an error rate of 0.07, and although negligible we wanted to see if it could be classified more accurately. We decided to increase the number of trees to 500, however, the error rate remained at 0.07%. Next k-mers of length 2 were used for our training dataset however the error rate remained at 0.07%, increasing the number of trees to 500 did not help with accuracy, so we used k-mers of length 3. Using k-mer length of 3 we were able to classify both our training dataset as well as validation dataset accurately with 0 error rate. The error rate of each of the three classifiers can be seen in figure 3 labelled as "random_error, random_error_1 and random_error_2. This is analysis was followed up by Na?ve Bayes prediction algorithm. Naive Bayes followed a similar pattern, where AGT proportions and k-mer of length 2 were not sufficient to accurately differentiate all COI and cytB, however using k-mer of length 3 was able to differentiate both our training and validation dataset accurately. The error rate of each of these classifiers can also be seen in figure three labelled as Bayes_error, Bayes_error_1 and Bayes_error_2. Despite what is found in the literature, our results show that Random Forest and Naive Bayes performed somewhat equally as both required additional information i.e k-mer length of 3 to accurately classify all genes. However, it is noteworthy that random forest classifiers had a lower error rate for AGT and k-mer length of 2 for training sets when compared with Bayes. 

#In terms of biases, our dataset had a large amount of data from the species from Mus spertus, 2nd largest from Apodemus draco and 3rd largest from Apodemus sylvaticus. This may impact our classifier and it may be more accurate for those species however, the degree to which it is impacted was not tested here. In the future it will be beneficial to explore statistical tests to see if the observed differences are significant between the two models. In addition, testing various other classifiers could be beneficial in determining which one works best for gene classification of COI and cytB this can include the regression model. We could also test this classifier on other taxonomic species to see if there is common sequence variation between cytB and COI that is present in other species. In conclusion our results show that Random forest and Naive Bayes perform quite equally when classifying COI and cytB genes within the Muridae family.

#References:
#Yiu, T. (2021, September 29). Understanding random forest. Medium. Retrieved October 27, 2022, from https://towardsdatascience.com/understanding-random-forest-58381e0602d2

#Latief, M. A., Siswantining, T., Bustamam, A., &amp; Sarwinda, D. (2019). A comparative performance evaluation of Random Forest feature selection on classification of hepatocellular carcinoma gene expression data. 2019 3rd International Conference on Informatics and Computational Sciences (ICICoS). https://doi.org/10.1109/icicos48119.2019.8982435 

#Gandhi, R. (2018, May 17). Naive Bayes classifier. Medium. Retrieved October 27, 2022, from https://towardsdatascience.com/naive-bayes-classifier-81d512f50a7c 

#Introduction to the rodentia. Rodentia. (n.d.). Retrieved October 27, 2022, from https://ucmp.berkeley.edu/mammal/rodentia/rodentia.html 

#Aghov?, T., Kimura, Y., Bryja, J., Dobigny, G., Granjon, L., &amp; Kergoat, G. J. (2018). Fossils know it best: Using a new set of fossil calibrations to improve the temporal phylogenetic framework of Murid rodents (rodentia: Muridae). Molecular Phylogenetics and Evolution, 128, 98-111. https://doi.org/10.1016/j.ympev.2018.07.017 

#Kartavtsev, Y. P. (2011). Divergence at cyt-b and co-1 mtdna genes on different taxonomic levels and genetics of speciation in Animals. Mitochondrial DNA, 22(3), 55-65. https://doi.org/10.3109/19401736.2011.588215 

#Lemons, K. (2020). A comparison between na?ve Bayes and Random Forest to predict breast cancer. International Journal of Undergraduate Research and Creative Activities, 12(1), 1. https://doi.org/10.7710/2168-0620.0287 

#westlandindia. (2018, February 14). Naive Bayes classification with R | example with steps. YouTube. Retrieved October 27, 2022, from https://www.youtube.com/watch?v=RLjSQdcg8AM

#Column not being recognised as variable in R. Stack Overflow. (1967, December 1). Retrieved October 28, 2022, from https://stackoverflow.com/questions/63714762/column-not-being-recognised-as-variable-in-r
