# Method Information Index
# Track20, Avenir Health
# January 2021

#####################################################################
# Load packages
#####################################################################
library(dplyr)
library(tidyr)
library(stringr)
library(haven)
library(sjlabelled)
library(questionr)
library(survey)

options(scipen = 999)

#####################################################################
# Read in data
#####################################################################

# Set Working Directory


women <- read_dta("UGIR7HFL.DTA")
##################################################################

#####################################################################
# Create dataset to modern method users
#####################################################################
df <- women %>% filter(v313==3)
##################################################################

#####################################################################
# Mutate data
#####################################################################
df <- df %>% mutate(told_om=case_when(v3a05==1  ~ 1 , v3a05>=0 & v3a05<9 ~ 0 ),
                    told_side_eff = case_when(v3a02==1 ~ 1, v3a02==0 ~ 0),
                    told_to_do = case_when(v3a04==1 & v3a02==1 ~ 1, v3a02>=0 & v3a02<9 ~ 0 ) ,
                    total = told_om + told_side_eff + told_to_do,
                    mii= case_when(total==3 ~ 1, total<3 ~ 0),
                    sampleweights=v005/100000)
##################################################################

#####################################################################
# Set survey design
#####################################################################
des <- svydesign(ids=~v021, strata=~v025, weights=~sampleweights, data=df)
##################################################################


#####################################################################
# Weighted Results
#####################################################################

# % of Modern Method Users Told of Other Methods
svymean(~told_om, des, na.rm=TRUE)

# % of Modern Method Users Told of Side Effects
svymean(~told_side_eff, des, na.rm=TRUE)

# % of Modern Method Users Told what to do about Side Effects
svymean(~told_to_do, des, na.rm=TRUE)

# % of Modern Method Users with All Three of the Above
svymean(~mii, des, na.rm=TRUE)

# For individual methods, there may be sample size issues- we will only display results if there are more than 25 unweighted observations
mii_method <- svyby(~mii, ~v312, des, svymean, na.rm=TRUE)
method_n <- as.data.frame(table(df$v312)) %>% mutate(v312=as.numeric(Var1)) %>% select(-Var1)
mii_method <- full_join(mii_method, method_n, by="v312")  %>%
  mutate(Method=case_when(v312==1 ~ "Pill", v312==2 ~ "IUD",  v312==3 ~ "Injections",  v312==6 ~ "Female Sterilization",  v312==11 ~ "Implants")) %>%
  filter(Freq>25 & !is.na(Freq)  & !is.na(Method))

##################################################################



