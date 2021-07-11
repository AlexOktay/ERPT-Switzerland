library(tidyverse)
library(haven)
library(ggplot2)
library(ggthemes)
library(sjlabelled)
library(foreign)
library(dplyr)
library(stargazer)
library(ggpubr)

#Setup
rm(list = ls())
graphics.off()
input_path<-"insert path of input folder"
output_path<-"insert path of output folder"

# Import
setwd(input_path)
df <- read_dta(file = "dataset_final_normalized2014.dta") #can be used on both 2014 or 2015 normalized data
codebook_goods <- read.csv("Codebook.csv")
setwd(output_path)

# Section 1: Data cleaning------------------------------------------------------

#Useful variables for future graph labeling
months_labels<-c("jan14", "feb14", "mar14", "apr14", "may14", "jun14", "jul14", 
                 "aug14", "sep14", "oct14", "nov14", "dec14", "jan15", "feb15", 
                 "mar15", "apr15", "may15", "jun15", "jul15", "aug15", "sep15", 
                 "oct15", "nov15", "dec15")
months_quarters_labels<-c("jan14", "", "", "apr14", "", "", "jul14", 
                          "", "", "oct14", "", "", "jan15", "", 
                          "", "apr15", "", "", "jul15", "", "", 
                          "oct15", "", "")
months_quarters_labels2<-c("jan14", "apr14", "jul14", "oct14", "jan15", "apr15", "jul15",
                           "oct15")
months_quarters_labels3<-c("jan14", "jul14", "jan15", "jul15")
quarter_labels<-c("2014Q1", "2014Q2", "2014Q3", "2014Q4", "2015Q1", "2015Q2", "2015Q3", "2015Q4")
n24=seq(1,24,3)
n24_2=seq(1,24,6)
n8=1:8

#Relabel Country
df<-remove_all_labels(df)
for (i in 1:48) {
  if (df[i,1]==2) {
    df[i,1]<-"Switzerland"
  }
  else {
    df[i,1]<-"Euro-Zone"   
  }
}

# Remove constant variables
df<-df[ , colSums(is.na(df)) == 0] # Drop the N/A
for (i in 3:164) {
  if(df[32,i]-df[33,i]==0) {
    df<-df[-c(i)]
  }
}
df<-df[ , colSums(is.na(df)) == 0] # Drop the N/A
for (i in 3:164) {
  if(df[40,i]-df[41,i]==0) {
    df<-df[-c(i)]
  }
}

# Section 2: Diff-in-Diff-------------------------------------------------------
df$time <- ifelse(df$month >= 14, 1, 0)
df$treated <- ifelse(df$country == "Switzerland", 1, 0)
df$did <- df$time * df$treated

n=ncol(df)-5
var<-colnames(df)
var<-var[-c(1,2,n-2,n-1,n)]
results <- data.frame(matrix(ncol = 5, nrow = 0))
x <- c("Goodnumber", "Goodtype", "DiD_estimate", "Std._Error","P_value")
colnames(results) <- x
for (i in 1:n) {
  didreg = lm(as.formula(paste(var[i], "~",
                               paste(var[c(n-2, n-1, n)], collapse = "+"),
                               sep = "")), data = df)
  goo<-as_numeric(substring(var[i],3))
  goo2<-toString(codebook_goods[goo,2])
  est<-summary(didreg)$coefficients[4,1]
  st<-summary(didreg)$coefficients[4,2]
  pval<-summary(didreg)$coefficients[4,4]
  results[nrow(results) + 1,] = c(goo,goo2,est,st,pval)
}

results$DiD_estimate <- as.numeric(as.character(results$DiD_estimate))
results$Std._Error <- as.numeric(as.character(results$Std._Error))
results$P_value <- as.numeric(as.character(results$P_alue))

#implied elasticity
results$elasticity<-(results$DiD_estimate/100)/((1.08-1.201)/1.201)

#Results
toppositive<-results[order(results$DiD_estimate,decreasing=TRUE),]
toppositive <- toppositive %>%
  filter(DiD_estimate > 0)
bottom20<-results[order(as.numeric(as.character(results$DiD_estimate))),][1:20,]
unaffected20<-results[order(abs(results$DiD_estimate)),][1:20,]


# Figure 1: All-items HICP plot with fitted value------------------------------
didreg = lm(x_17 ~ treated + time + did, data = df)
euro_before<-didreg$fitted.values[1]
euro_after<-didreg$fitted.values[18]
CH_before<-didreg$fitted.values[28]
CH_after<-didreg$fitted.values[45]

p1_fitted <- ggplot(df) +
  theme_classic() + 
  geom_line(aes(x = as.integer(as.factor(month)), y = x_17, color=country))+
  geom_segment(aes(x=1,xend=13,y=euro_before,yend=euro_before),linetype="dashed",color="black")+
  geom_segment(aes(x=13,xend=24,y=euro_after,yend=euro_after),linetype="dashed",color="black")+
  geom_segment(aes(x=1,xend=13,y=CH_before,yend=CH_before),linetype="dashed",color="#d40000")+
  geom_segment(aes(x=13,xend=24,y=CH_after,yend=CH_after),linetype="dashed",color="#d40000")+
  labs(y = "",
       x = "") +
  geom_vline(xintercept = 13)+
  annotate("text", x=1.5, y=102.2, label= "Prices",color="grey31",size=5.5) + 
  theme(axis.title = element_text(),
        legend.title = element_blank(),
        axis.text = element_text(size=14),
        legend.text = element_text(size=14),
        legend.position = "bottom",
        legend.margin=margin(0,0,0,0),
        legend.box.margin=margin(-15,0,0,0),
        plot.margin = unit(c(0.1,0.1,0,-0.4), "cm"))+
  scale_color_manual(values = c( "#000000", "#d40000"))+
  scale_x_continuous(labels = months_quarters_labels3, breaks = n24_2)+
  ylim(99,102.2)

pdf("fig1.pdf", width=6, height=3.5)
p1_fitted
dev.off()


# Figure 2: Fuel+Holidays+Books plot with fitted value--------------------------

#Fuel
didreg1<-lm(x_198 ~ treated + time + did, data = df)
euro_before1<-didreg1$fitted.values[1]
euro_after1<-didreg1$fitted.values[18]
CH_before1<-didreg1$fitted.values[28]
CH_after1<-didreg1$fitted.values[45]

p2_fitted <- ggplot(df) +
  theme_classic() + 
  ggtitle("a) Liquid fuels")+
  geom_line(aes(x = as.integer(as.factor(month)), y = x_198, color=country))+
  geom_segment(aes(x=1,xend=13,y=euro_before1,yend=euro_before1),linetype="dashed",color="black")+
  geom_segment(aes(x=13,xend=24,y=euro_after1,yend=euro_after1),linetype="dashed",color="black")+
  geom_segment(aes(x=1,xend=13,y=CH_before1,yend=CH_before1),linetype="dashed",color="red")+
  geom_segment(aes(x=13,xend=24,y=CH_after1,yend=CH_after1),linetype="dashed",color="red")+
  labs(y = "",
       x = "") +
  geom_vline(xintercept = 13)+
  theme(axis.title = element_text(),
        legend.title = element_blank(),
        axis.text = element_text(size = 14),
        legend.text = element_text(size = 14),
        legend.position = "none",
        legend.margin=margin(0,0,0,0),
        legend.box.margin=margin(-15,0,0,0),
        plot.margin = unit(c(0.3,0.1,0.3,-0.4), "cm"),
        plot.title = element_text(size=16))+
  scale_color_manual(values = c( "#000000", "#d40000"))+
  scale_x_continuous(labels = months_quarters_labels3, breaks = n24_2)+
  ylim(60,100)

# Holidays
didreg2 <- lm(x_323 ~ treated + time + did, data = df)
euro_before2<-didreg2$fitted.values[1]
euro_after2<-didreg2$fitted.values[18]
CH_before2<-didreg2$fitted.values[28]
CH_after2<-didreg2$fitted.values[45]

p3_fitted <- ggplot(df) +
  theme_classic() + 
  ggtitle("b) Package holidays")+
  geom_line(aes(x = as.integer(as.factor(month)), y = x_323, color=country))+
  geom_segment(aes(x=1,xend=13,y=euro_before2,yend=euro_before2),linetype="dashed",color="black")+
  geom_segment(aes(x=13,xend=24,y=euro_after2,yend=euro_after2),linetype="dashed",color="black")+
  geom_segment(aes(x=1,xend=13,y=CH_before2,yend=CH_before2),linetype="dashed",color="red")+
  geom_segment(aes(x=13,xend=24,y=CH_after2,yend=CH_after2),linetype="dashed",color="red")+
  labs(y = "",
       x = "") +
  geom_vline(xintercept = 13)+
  theme(axis.title = element_text(),
        legend.title = element_blank(),
        axis.text = element_text(size = 14),
        legend.text = element_text(size = 14),
        legend.position = "none",
        legend.margin=margin(0,0,0,0),
        legend.box.margin=margin(-15,0,0,0),
        plot.margin = unit(c(0.3,0.1,0.3,-0.4), "cm"),
        plot.title = element_text(size=16))+
  scale_color_manual(values = c( "#000000", "#d40000"))+
  scale_x_continuous(labels = months_quarters_labels3, breaks = n24_2)+
  ylim(80,120)

# Books with fitted values
didreg3 <- lm(x_31 ~ treated + time + did, data = df)
euro_before3<-didreg3$fitted.values[1]
euro_after3<-didreg3$fitted.values[18]
CH_before3<-didreg3$fitted.values[28]
CH_after3<-didreg3$fitted.values[45]

p4_fitted <- ggplot(df) +
  theme_classic() + 
  ggtitle("c) Books")+
  geom_line(aes(x = as.integer(as.factor(month)), y = x_31, color=country))+
  geom_segment(aes(x=1,xend=13,y=euro_before3,yend=euro_before3),linetype="dashed",color="black")+
  geom_segment(aes(x=13,xend=24,y=euro_after3,yend=euro_after3),linetype="dashed",color="black")+
  geom_segment(aes(x=1,xend=13,y=CH_before3,yend=CH_before3),linetype="dashed",color="red")+
  geom_segment(aes(x=13,xend=24,y=CH_after3,yend=CH_after3),linetype="dashed",color="red")+
  labs(y = "",
       x = "") +
  geom_vline(xintercept = 13)+
  theme(axis.title = element_text(),
        legend.title = element_blank(),
        axis.text = element_text(size = 14),
        legend.text = element_text(size = 14),
        legend.position = "none",
        legend.margin=margin(0,0,0,0),
        legend.box.margin=margin(-15,0,0,0),
        plot.margin = unit(c(0.3,0.1,0.3,-0.4), "cm"),
        plot.title = element_text(size=16))+
  scale_color_manual(values = c( "#000000", "#d40000"))+
  scale_x_continuous(labels = months_quarters_labels3, breaks = n24_2)+
  ylim(90,105)

# grid display of the 3
p2<-ggarrange(p2_fitted, p3_fitted, p4_fitted, nrow=1,common.legend = TRUE, legend="bottom")
pdf("fig2.pdf", width=12.5, height=4)
p2
dev.off()

# Section 3: Export results as tables-------------------------------------------

# Full DiD estimation: HRCIP
didreg = lm(x_17 ~ treated + time + did, data = df)
stargazer( didreg, 
           dep.var.labels = ("Outcome"),
           column.labels = c(""),
           covariate.labels = c("Intercept (B0)", "Treatment (B1)", "Post-treatment (B2)", "Diff in Diff (B3)"),
           omit.stat = "all", 
           digits = 2, intercept.bottom = FALSE )

# Full DiD estimation: fuel, holidays and books
didreg1 = lm(x_198 ~ treated + time + did, data = df)
didreg2 = lm(x_323 ~ treated + time + did, data = df)
didreg3 = lm(x_31 ~ treated + time + did, data = df)
stargazer( didreg1, didreg2, didreg3,
           dep.var.labels = c("Liquid Fuel","Package Holidays", "Books","3"),
           column.labels = c(""),
           covariate.labels = c("Intercept (B0)", "Treatment (B1)", "Post-treatment (B2)", "Diff in Diff (B3)"),
           omit.stat = "all", 
           digits = 2, intercept.bottom = FALSE )

# Full results
results_bis<-results[c(2,6,5)]
results_bis<-results_bis[-c(73:82),]
results_bis$elasticity <- round(results_bis$elasticity ,digit=3)
results_bis$P_value <- as.data.frame(sapply(results_bis$P_value, as.numeric)) 
for (i in 1:108) {
  if (results_bis[i,3]<0.01) {
    results_bis[i,2]<-paste(toString(results_bis[i,2]),"***",sep="")
  }
  else if (results_bis[i,3]<0.05) {
    results_bis[i,2]<-paste(toString(results_bis[i,2]),"**",sep="")
  }
  else if (results_bis[i,3]<0.1) {
    results_bis[i,2]<-paste(toString(results_bis[i,2]),"*",sep="")
  }
}
results_bis<-results_bis[c(1,2)]
row.names(results_bis) <- NULL
stargazer(results_bis,summary=FALSE,column.sep.width = "-13pt", digits=5)
